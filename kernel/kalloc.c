// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

// 引用计数数组
// 这里的数组大小需要覆盖物理内存范围。
// PHYSTOP / PGSIZE = 128MB / 4KB = 32768
int refcount[PHYSTOP / PGSIZE];

// 计算物理地址对应的索引
int page_index(void *pa) {
  return ((uint64)pa) / PGSIZE;
}

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  // 初始化引用计数为0
  memset(refcount, 0, sizeof(refcount));
  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    // 初始化时，将 refcount 设为 1，以便 kfree 将其减为 0 并放入空闲链表
    refcount[page_index(p)] = 1;
    kfree(p);
  }
}

// 释放物理页
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // 加锁保护引用计数
  acquire(&kmem.lock);
  int idx = page_index(pa);
  
  // 安全检查
  if (refcount[idx] < 1) {
    panic("kfree refcount < 1");
  }

  refcount[idx]--;

  // 如果引用计数还大于0，说明还有其他进程在使用，不能释放
  if (refcount[idx] > 0) {
    release(&kmem.lock);
    return;
  }

  // 引用计数为0，执行真正的释放操作
  // 此时仍持有锁，确保没有其他进程能并发获取到此页（虽然在释放阶段不太可能）
  // 填充垃圾数据可以发现悬空引用，但为了效率，也可以放在锁外，这里放在锁内比较安全
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;
  r->next = kmem.freelist;
  kmem.freelist = r;
  
  release(&kmem.lock);
}

// 分配物理页
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r) {
    kmem.freelist = r->next;
    
    // 分配出去时，将引用计数初始化为 1
    int idx = page_index(r);
    refcount[idx] = 1; 
  }
  release(&kmem.lock);

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    
  return (void*)r;
}

// 增加引用计数（供 vm.c 使用）
int
inc_ref(void *pa) {
  int res;
  acquire(&kmem.lock);
  int idx = page_index(pa);
  if(refcount[idx] < 1) panic("inc_ref: count < 1");
  refcount[idx]++;
  res = refcount[idx];
  release(&kmem.lock);
  return res;
}

// 减少引用计数（供 vm.c 使用）
int
dec_ref(void *pa) {
  int res;
  acquire(&kmem.lock);
  int idx = page_index(pa);
  if(refcount[idx] < 1) panic("dec_ref: count < 1");
  refcount[idx]--;
  res = refcount[idx];
  release(&kmem.lock);
  return res;
}