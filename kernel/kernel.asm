
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	39813103          	ld	sp,920(sp) # 8000a398 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	398050ef          	jal	800053ae <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	e7a9                	bnez	a5,80000076 <kfree+0x5a>
    8000002e:	84aa                	mv	s1,a0
    80000030:	0002f797          	auipc	a5,0x2f
    80000034:	6b878793          	addi	a5,a5,1720 # 8002f6e8 <end>
    80000038:	02f56f63          	bltu	a0,a5,80000076 <kfree+0x5a>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57b63          	bgeu	a0,a5,80000076 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	106000ef          	jal	8000014e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    8000004c:	0000a917          	auipc	s2,0xa
    80000050:	39490913          	addi	s2,s2,916 # 8000a3e0 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	595050ef          	jal	80005dea <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	61d050ef          	jal	80005e82 <release>
}
    8000006a:	60e2                	ld	ra,24(sp)
    8000006c:	6442                	ld	s0,16(sp)
    8000006e:	64a2                	ld	s1,8(sp)
    80000070:	6902                	ld	s2,0(sp)
    80000072:	6105                	addi	sp,sp,32
    80000074:	8082                	ret
    panic("kfree");
    80000076:	00007517          	auipc	a0,0x7
    8000007a:	f8a50513          	addi	a0,a0,-118 # 80007000 <etext>
    8000007e:	2b1050ef          	jal	80005b2e <panic>

0000000080000082 <freerange>:
{
    80000082:	7179                	addi	sp,sp,-48
    80000084:	f406                	sd	ra,40(sp)
    80000086:	f022                	sd	s0,32(sp)
    80000088:	ec26                	sd	s1,24(sp)
    8000008a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    8000008c:	6785                	lui	a5,0x1
    8000008e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000092:	00e504b3          	add	s1,a0,a4
    80000096:	777d                	lui	a4,0xfffff
    80000098:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000009a:	94be                	add	s1,s1,a5
    8000009c:	0295e263          	bltu	a1,s1,800000c0 <freerange+0x3e>
    800000a0:	e84a                	sd	s2,16(sp)
    800000a2:	e44e                	sd	s3,8(sp)
    800000a4:	e052                	sd	s4,0(sp)
    800000a6:	892e                	mv	s2,a1
    kfree(p);
    800000a8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000aa:	6985                	lui	s3,0x1
    kfree(p);
    800000ac:	01448533          	add	a0,s1,s4
    800000b0:	f6dff0ef          	jal	8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000b4:	94ce                	add	s1,s1,s3
    800000b6:	fe997be3          	bgeu	s2,s1,800000ac <freerange+0x2a>
    800000ba:	6942                	ld	s2,16(sp)
    800000bc:	69a2                	ld	s3,8(sp)
    800000be:	6a02                	ld	s4,0(sp)
}
    800000c0:	70a2                	ld	ra,40(sp)
    800000c2:	7402                	ld	s0,32(sp)
    800000c4:	64e2                	ld	s1,24(sp)
    800000c6:	6145                	addi	sp,sp,48
    800000c8:	8082                	ret

00000000800000ca <kinit>:
{
    800000ca:	1141                	addi	sp,sp,-16
    800000cc:	e406                	sd	ra,8(sp)
    800000ce:	e022                	sd	s0,0(sp)
    800000d0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000d2:	00007597          	auipc	a1,0x7
    800000d6:	f3e58593          	addi	a1,a1,-194 # 80007010 <etext+0x10>
    800000da:	0000a517          	auipc	a0,0xa
    800000de:	30650513          	addi	a0,a0,774 # 8000a3e0 <kmem>
    800000e2:	489050ef          	jal	80005d6a <initlock>
  freerange(end, (void*)PHYSTOP);
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	0002f517          	auipc	a0,0x2f
    800000ee:	5fe50513          	addi	a0,a0,1534 # 8002f6e8 <end>
    800000f2:	f91ff0ef          	jal	80000082 <freerange>
}
    800000f6:	60a2                	ld	ra,8(sp)
    800000f8:	6402                	ld	s0,0(sp)
    800000fa:	0141                	addi	sp,sp,16
    800000fc:	8082                	ret

00000000800000fe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    800000fe:	1101                	addi	sp,sp,-32
    80000100:	ec06                	sd	ra,24(sp)
    80000102:	e822                	sd	s0,16(sp)
    80000104:	e426                	sd	s1,8(sp)
    80000106:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000108:	0000a497          	auipc	s1,0xa
    8000010c:	2d848493          	addi	s1,s1,728 # 8000a3e0 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	4d9050ef          	jal	80005dea <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if(r)
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	0000a517          	auipc	a0,0xa
    80000120:	2c450513          	addi	a0,a0,708 # 8000a3e0 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000126:	55d050ef          	jal	80005e82 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000012a:	6605                	lui	a2,0x1
    8000012c:	4595                	li	a1,5
    8000012e:	8526                	mv	a0,s1
    80000130:	01e000ef          	jal	8000014e <memset>
  return (void*)r;
}
    80000134:	8526                	mv	a0,s1
    80000136:	60e2                	ld	ra,24(sp)
    80000138:	6442                	ld	s0,16(sp)
    8000013a:	64a2                	ld	s1,8(sp)
    8000013c:	6105                	addi	sp,sp,32
    8000013e:	8082                	ret
  release(&kmem.lock);
    80000140:	0000a517          	auipc	a0,0xa
    80000144:	2a050513          	addi	a0,a0,672 # 8000a3e0 <kmem>
    80000148:	53b050ef          	jal	80005e82 <release>
  if(r)
    8000014c:	b7e5                	j	80000134 <kalloc+0x36>

000000008000014e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    8000014e:	1141                	addi	sp,sp,-16
    80000150:	e422                	sd	s0,8(sp)
    80000152:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000154:	ca19                	beqz	a2,8000016a <memset+0x1c>
    80000156:	87aa                	mv	a5,a0
    80000158:	1602                	slli	a2,a2,0x20
    8000015a:	9201                	srli	a2,a2,0x20
    8000015c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000160:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000164:	0785                	addi	a5,a5,1
    80000166:	fee79de3          	bne	a5,a4,80000160 <memset+0x12>
  }
  return dst;
}
    8000016a:	6422                	ld	s0,8(sp)
    8000016c:	0141                	addi	sp,sp,16
    8000016e:	8082                	ret

0000000080000170 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000170:	1141                	addi	sp,sp,-16
    80000172:	e422                	sd	s0,8(sp)
    80000174:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000176:	ca05                	beqz	a2,800001a6 <memcmp+0x36>
    80000178:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    8000017c:	1682                	slli	a3,a3,0x20
    8000017e:	9281                	srli	a3,a3,0x20
    80000180:	0685                	addi	a3,a3,1
    80000182:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000184:	00054783          	lbu	a5,0(a0)
    80000188:	0005c703          	lbu	a4,0(a1)
    8000018c:	00e79863          	bne	a5,a4,8000019c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000190:	0505                	addi	a0,a0,1
    80000192:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000194:	fed518e3          	bne	a0,a3,80000184 <memcmp+0x14>
  }

  return 0;
    80000198:	4501                	li	a0,0
    8000019a:	a019                	j	800001a0 <memcmp+0x30>
      return *s1 - *s2;
    8000019c:	40e7853b          	subw	a0,a5,a4
}
    800001a0:	6422                	ld	s0,8(sp)
    800001a2:	0141                	addi	sp,sp,16
    800001a4:	8082                	ret
  return 0;
    800001a6:	4501                	li	a0,0
    800001a8:	bfe5                	j	800001a0 <memcmp+0x30>

00000000800001aa <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800001aa:	1141                	addi	sp,sp,-16
    800001ac:	e422                	sd	s0,8(sp)
    800001ae:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800001b0:	c205                	beqz	a2,800001d0 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    800001b2:	02a5e263          	bltu	a1,a0,800001d6 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800001b6:	1602                	slli	a2,a2,0x20
    800001b8:	9201                	srli	a2,a2,0x20
    800001ba:	00c587b3          	add	a5,a1,a2
{
    800001be:	872a                	mv	a4,a0
      *d++ = *s++;
    800001c0:	0585                	addi	a1,a1,1
    800001c2:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffcf919>
    800001c4:	fff5c683          	lbu	a3,-1(a1)
    800001c8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800001cc:	feb79ae3          	bne	a5,a1,800001c0 <memmove+0x16>

  return dst;
}
    800001d0:	6422                	ld	s0,8(sp)
    800001d2:	0141                	addi	sp,sp,16
    800001d4:	8082                	ret
  if(s < d && s + n > d){
    800001d6:	02061693          	slli	a3,a2,0x20
    800001da:	9281                	srli	a3,a3,0x20
    800001dc:	00d58733          	add	a4,a1,a3
    800001e0:	fce57be3          	bgeu	a0,a4,800001b6 <memmove+0xc>
    d += n;
    800001e4:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    800001e6:	fff6079b          	addiw	a5,a2,-1
    800001ea:	1782                	slli	a5,a5,0x20
    800001ec:	9381                	srli	a5,a5,0x20
    800001ee:	fff7c793          	not	a5,a5
    800001f2:	97ba                	add	a5,a5,a4
      *--d = *--s;
    800001f4:	177d                	addi	a4,a4,-1
    800001f6:	16fd                	addi	a3,a3,-1
    800001f8:	00074603          	lbu	a2,0(a4)
    800001fc:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000200:	fef71ae3          	bne	a4,a5,800001f4 <memmove+0x4a>
    80000204:	b7f1                	j	800001d0 <memmove+0x26>

0000000080000206 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000206:	1141                	addi	sp,sp,-16
    80000208:	e406                	sd	ra,8(sp)
    8000020a:	e022                	sd	s0,0(sp)
    8000020c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000020e:	f9dff0ef          	jal	800001aa <memmove>
}
    80000212:	60a2                	ld	ra,8(sp)
    80000214:	6402                	ld	s0,0(sp)
    80000216:	0141                	addi	sp,sp,16
    80000218:	8082                	ret

000000008000021a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000021a:	1141                	addi	sp,sp,-16
    8000021c:	e422                	sd	s0,8(sp)
    8000021e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000220:	ce11                	beqz	a2,8000023c <strncmp+0x22>
    80000222:	00054783          	lbu	a5,0(a0)
    80000226:	cf89                	beqz	a5,80000240 <strncmp+0x26>
    80000228:	0005c703          	lbu	a4,0(a1)
    8000022c:	00f71a63          	bne	a4,a5,80000240 <strncmp+0x26>
    n--, p++, q++;
    80000230:	367d                	addiw	a2,a2,-1
    80000232:	0505                	addi	a0,a0,1
    80000234:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000236:	f675                	bnez	a2,80000222 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000238:	4501                	li	a0,0
    8000023a:	a801                	j	8000024a <strncmp+0x30>
    8000023c:	4501                	li	a0,0
    8000023e:	a031                	j	8000024a <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000240:	00054503          	lbu	a0,0(a0)
    80000244:	0005c783          	lbu	a5,0(a1)
    80000248:	9d1d                	subw	a0,a0,a5
}
    8000024a:	6422                	ld	s0,8(sp)
    8000024c:	0141                	addi	sp,sp,16
    8000024e:	8082                	ret

0000000080000250 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000250:	1141                	addi	sp,sp,-16
    80000252:	e422                	sd	s0,8(sp)
    80000254:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000256:	87aa                	mv	a5,a0
    80000258:	86b2                	mv	a3,a2
    8000025a:	367d                	addiw	a2,a2,-1
    8000025c:	02d05563          	blez	a3,80000286 <strncpy+0x36>
    80000260:	0785                	addi	a5,a5,1
    80000262:	0005c703          	lbu	a4,0(a1)
    80000266:	fee78fa3          	sb	a4,-1(a5)
    8000026a:	0585                	addi	a1,a1,1
    8000026c:	f775                	bnez	a4,80000258 <strncpy+0x8>
    ;
  while(n-- > 0)
    8000026e:	873e                	mv	a4,a5
    80000270:	9fb5                	addw	a5,a5,a3
    80000272:	37fd                	addiw	a5,a5,-1
    80000274:	00c05963          	blez	a2,80000286 <strncpy+0x36>
    *s++ = 0;
    80000278:	0705                	addi	a4,a4,1
    8000027a:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    8000027e:	40e786bb          	subw	a3,a5,a4
    80000282:	fed04be3          	bgtz	a3,80000278 <strncpy+0x28>
  return os;
}
    80000286:	6422                	ld	s0,8(sp)
    80000288:	0141                	addi	sp,sp,16
    8000028a:	8082                	ret

000000008000028c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    8000028c:	1141                	addi	sp,sp,-16
    8000028e:	e422                	sd	s0,8(sp)
    80000290:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000292:	02c05363          	blez	a2,800002b8 <safestrcpy+0x2c>
    80000296:	fff6069b          	addiw	a3,a2,-1
    8000029a:	1682                	slli	a3,a3,0x20
    8000029c:	9281                	srli	a3,a3,0x20
    8000029e:	96ae                	add	a3,a3,a1
    800002a0:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800002a2:	00d58963          	beq	a1,a3,800002b4 <safestrcpy+0x28>
    800002a6:	0585                	addi	a1,a1,1
    800002a8:	0785                	addi	a5,a5,1
    800002aa:	fff5c703          	lbu	a4,-1(a1)
    800002ae:	fee78fa3          	sb	a4,-1(a5)
    800002b2:	fb65                	bnez	a4,800002a2 <safestrcpy+0x16>
    ;
  *s = 0;
    800002b4:	00078023          	sb	zero,0(a5)
  return os;
}
    800002b8:	6422                	ld	s0,8(sp)
    800002ba:	0141                	addi	sp,sp,16
    800002bc:	8082                	ret

00000000800002be <strlen>:

int
strlen(const char *s)
{
    800002be:	1141                	addi	sp,sp,-16
    800002c0:	e422                	sd	s0,8(sp)
    800002c2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800002c4:	00054783          	lbu	a5,0(a0)
    800002c8:	cf91                	beqz	a5,800002e4 <strlen+0x26>
    800002ca:	0505                	addi	a0,a0,1
    800002cc:	87aa                	mv	a5,a0
    800002ce:	86be                	mv	a3,a5
    800002d0:	0785                	addi	a5,a5,1
    800002d2:	fff7c703          	lbu	a4,-1(a5)
    800002d6:	ff65                	bnez	a4,800002ce <strlen+0x10>
    800002d8:	40a6853b          	subw	a0,a3,a0
    800002dc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    800002de:	6422                	ld	s0,8(sp)
    800002e0:	0141                	addi	sp,sp,16
    800002e2:	8082                	ret
  for(n = 0; s[n]; n++)
    800002e4:	4501                	li	a0,0
    800002e6:	bfe5                	j	800002de <strlen+0x20>

00000000800002e8 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800002e8:	1141                	addi	sp,sp,-16
    800002ea:	e406                	sd	ra,8(sp)
    800002ec:	e022                	sd	s0,0(sp)
    800002ee:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800002f0:	25f000ef          	jal	80000d4e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800002f4:	0000a717          	auipc	a4,0xa
    800002f8:	0bc70713          	addi	a4,a4,188 # 8000a3b0 <started>
  if(cpuid() == 0){
    800002fc:	c51d                	beqz	a0,8000032a <main+0x42>
    while(started == 0)
    800002fe:	431c                	lw	a5,0(a4)
    80000300:	2781                	sext.w	a5,a5
    80000302:	dff5                	beqz	a5,800002fe <main+0x16>
      ;
    __sync_synchronize();
    80000304:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000308:	247000ef          	jal	80000d4e <cpuid>
    8000030c:	85aa                	mv	a1,a0
    8000030e:	00007517          	auipc	a0,0x7
    80000312:	d2a50513          	addi	a0,a0,-726 # 80007038 <etext+0x38>
    80000316:	532050ef          	jal	80005848 <printf>
    kvminithart();    // turn on paging
    8000031a:	080000ef          	jal	8000039a <kvminithart>
    trapinithart();   // install kernel trap vector
    8000031e:	7bc010ef          	jal	80001ada <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000322:	2a7040ef          	jal	80004dc8 <plicinithart>
  }

  scheduler();        
    80000326:	713000ef          	jal	80001238 <scheduler>
    consoleinit();
    8000032a:	448050ef          	jal	80005772 <consoleinit>
    printfinit();
    8000032e:	03d050ef          	jal	80005b6a <printfinit>
    printf("\n");
    80000332:	00007517          	auipc	a0,0x7
    80000336:	ce650513          	addi	a0,a0,-794 # 80007018 <etext+0x18>
    8000033a:	50e050ef          	jal	80005848 <printf>
    printf("xv6 kernel is booting\n");
    8000033e:	00007517          	auipc	a0,0x7
    80000342:	ce250513          	addi	a0,a0,-798 # 80007020 <etext+0x20>
    80000346:	502050ef          	jal	80005848 <printf>
    printf("\n");
    8000034a:	00007517          	auipc	a0,0x7
    8000034e:	cce50513          	addi	a0,a0,-818 # 80007018 <etext+0x18>
    80000352:	4f6050ef          	jal	80005848 <printf>
    kinit();         // physical page allocator
    80000356:	d75ff0ef          	jal	800000ca <kinit>
    kvminit();       // create kernel page table
    8000035a:	2ca000ef          	jal	80000624 <kvminit>
    kvminithart();   // turn on paging
    8000035e:	03c000ef          	jal	8000039a <kvminithart>
    procinit();      // process table
    80000362:	137000ef          	jal	80000c98 <procinit>
    trapinit();      // trap vectors
    80000366:	750010ef          	jal	80001ab6 <trapinit>
    trapinithart();  // install kernel trap vector
    8000036a:	770010ef          	jal	80001ada <trapinithart>
    plicinit();      // set up interrupt controller
    8000036e:	241040ef          	jal	80004dae <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000372:	257040ef          	jal	80004dc8 <plicinithart>
    binit();         // buffer cache
    80000376:	6ab010ef          	jal	80002220 <binit>
    iinit();         // inode table
    8000037a:	430020ef          	jal	800027aa <iinit>
    fileinit();      // file table
    8000037e:	322030ef          	jal	800036a0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000382:	337040ef          	jal	80004eb8 <virtio_disk_init>
    userinit();      // first user process
    80000386:	4cf000ef          	jal	80001054 <userinit>
    __sync_synchronize();
    8000038a:	0330000f          	fence	rw,rw
    started = 1;
    8000038e:	4785                	li	a5,1
    80000390:	0000a717          	auipc	a4,0xa
    80000394:	02f72023          	sw	a5,32(a4) # 8000a3b0 <started>
    80000398:	b779                	j	80000326 <main+0x3e>

000000008000039a <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    8000039a:	1141                	addi	sp,sp,-16
    8000039c:	e422                	sd	s0,8(sp)
    8000039e:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800003a0:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800003a4:	0000a797          	auipc	a5,0xa
    800003a8:	0147b783          	ld	a5,20(a5) # 8000a3b8 <kernel_pagetable>
    800003ac:	83b1                	srli	a5,a5,0xc
    800003ae:	577d                	li	a4,-1
    800003b0:	177e                	slli	a4,a4,0x3f
    800003b2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800003b4:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800003b8:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800003bc:	6422                	ld	s0,8(sp)
    800003be:	0141                	addi	sp,sp,16
    800003c0:	8082                	ret

00000000800003c2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800003c2:	7139                	addi	sp,sp,-64
    800003c4:	fc06                	sd	ra,56(sp)
    800003c6:	f822                	sd	s0,48(sp)
    800003c8:	f426                	sd	s1,40(sp)
    800003ca:	f04a                	sd	s2,32(sp)
    800003cc:	ec4e                	sd	s3,24(sp)
    800003ce:	e852                	sd	s4,16(sp)
    800003d0:	e456                	sd	s5,8(sp)
    800003d2:	e05a                	sd	s6,0(sp)
    800003d4:	0080                	addi	s0,sp,64
    800003d6:	84aa                	mv	s1,a0
    800003d8:	89ae                	mv	s3,a1
    800003da:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800003dc:	57fd                	li	a5,-1
    800003de:	83e9                	srli	a5,a5,0x1a
    800003e0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800003e2:	4b31                	li	s6,12
  if(va >= MAXVA)
    800003e4:	02b7fc63          	bgeu	a5,a1,8000041c <walk+0x5a>
    panic("walk");
    800003e8:	00007517          	auipc	a0,0x7
    800003ec:	c6850513          	addi	a0,a0,-920 # 80007050 <etext+0x50>
    800003f0:	73e050ef          	jal	80005b2e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800003f4:	060a8263          	beqz	s5,80000458 <walk+0x96>
    800003f8:	d07ff0ef          	jal	800000fe <kalloc>
    800003fc:	84aa                	mv	s1,a0
    800003fe:	c139                	beqz	a0,80000444 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000400:	6605                	lui	a2,0x1
    80000402:	4581                	li	a1,0
    80000404:	d4bff0ef          	jal	8000014e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000408:	00c4d793          	srli	a5,s1,0xc
    8000040c:	07aa                	slli	a5,a5,0xa
    8000040e:	0017e793          	ori	a5,a5,1
    80000412:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000416:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffcf90f>
    80000418:	036a0063          	beq	s4,s6,80000438 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    8000041c:	0149d933          	srl	s2,s3,s4
    80000420:	1ff97913          	andi	s2,s2,511
    80000424:	090e                	slli	s2,s2,0x3
    80000426:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000428:	00093483          	ld	s1,0(s2)
    8000042c:	0014f793          	andi	a5,s1,1
    80000430:	d3f1                	beqz	a5,800003f4 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000432:	80a9                	srli	s1,s1,0xa
    80000434:	04b2                	slli	s1,s1,0xc
    80000436:	b7c5                	j	80000416 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000438:	00c9d513          	srli	a0,s3,0xc
    8000043c:	1ff57513          	andi	a0,a0,511
    80000440:	050e                	slli	a0,a0,0x3
    80000442:	9526                	add	a0,a0,s1
}
    80000444:	70e2                	ld	ra,56(sp)
    80000446:	7442                	ld	s0,48(sp)
    80000448:	74a2                	ld	s1,40(sp)
    8000044a:	7902                	ld	s2,32(sp)
    8000044c:	69e2                	ld	s3,24(sp)
    8000044e:	6a42                	ld	s4,16(sp)
    80000450:	6aa2                	ld	s5,8(sp)
    80000452:	6b02                	ld	s6,0(sp)
    80000454:	6121                	addi	sp,sp,64
    80000456:	8082                	ret
        return 0;
    80000458:	4501                	li	a0,0
    8000045a:	b7ed                	j	80000444 <walk+0x82>

000000008000045c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000045c:	57fd                	li	a5,-1
    8000045e:	83e9                	srli	a5,a5,0x1a
    80000460:	00b7f463          	bgeu	a5,a1,80000468 <walkaddr+0xc>
    return 0;
    80000464:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000466:	8082                	ret
{
    80000468:	1141                	addi	sp,sp,-16
    8000046a:	e406                	sd	ra,8(sp)
    8000046c:	e022                	sd	s0,0(sp)
    8000046e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000470:	4601                	li	a2,0
    80000472:	f51ff0ef          	jal	800003c2 <walk>
  if(pte == 0)
    80000476:	c105                	beqz	a0,80000496 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000478:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000047a:	0117f693          	andi	a3,a5,17
    8000047e:	4745                	li	a4,17
    return 0;
    80000480:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000482:	00e68663          	beq	a3,a4,8000048e <walkaddr+0x32>
}
    80000486:	60a2                	ld	ra,8(sp)
    80000488:	6402                	ld	s0,0(sp)
    8000048a:	0141                	addi	sp,sp,16
    8000048c:	8082                	ret
  pa = PTE2PA(*pte);
    8000048e:	83a9                	srli	a5,a5,0xa
    80000490:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000494:	bfcd                	j	80000486 <walkaddr+0x2a>
    return 0;
    80000496:	4501                	li	a0,0
    80000498:	b7fd                	j	80000486 <walkaddr+0x2a>

000000008000049a <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000049a:	715d                	addi	sp,sp,-80
    8000049c:	e486                	sd	ra,72(sp)
    8000049e:	e0a2                	sd	s0,64(sp)
    800004a0:	fc26                	sd	s1,56(sp)
    800004a2:	f84a                	sd	s2,48(sp)
    800004a4:	f44e                	sd	s3,40(sp)
    800004a6:	f052                	sd	s4,32(sp)
    800004a8:	ec56                	sd	s5,24(sp)
    800004aa:	e85a                	sd	s6,16(sp)
    800004ac:	e45e                	sd	s7,8(sp)
    800004ae:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800004b0:	03459793          	slli	a5,a1,0x34
    800004b4:	e7a9                	bnez	a5,800004fe <mappages+0x64>
    800004b6:	8aaa                	mv	s5,a0
    800004b8:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800004ba:	03461793          	slli	a5,a2,0x34
    800004be:	e7b1                	bnez	a5,8000050a <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    800004c0:	ca39                	beqz	a2,80000516 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800004c2:	77fd                	lui	a5,0xfffff
    800004c4:	963e                	add	a2,a2,a5
    800004c6:	00b609b3          	add	s3,a2,a1
  a = va;
    800004ca:	892e                	mv	s2,a1
    800004cc:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800004d0:	6b85                	lui	s7,0x1
    800004d2:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    800004d6:	4605                	li	a2,1
    800004d8:	85ca                	mv	a1,s2
    800004da:	8556                	mv	a0,s5
    800004dc:	ee7ff0ef          	jal	800003c2 <walk>
    800004e0:	c539                	beqz	a0,8000052e <mappages+0x94>
    if(*pte & PTE_V)
    800004e2:	611c                	ld	a5,0(a0)
    800004e4:	8b85                	andi	a5,a5,1
    800004e6:	ef95                	bnez	a5,80000522 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800004e8:	80b1                	srli	s1,s1,0xc
    800004ea:	04aa                	slli	s1,s1,0xa
    800004ec:	0164e4b3          	or	s1,s1,s6
    800004f0:	0014e493          	ori	s1,s1,1
    800004f4:	e104                	sd	s1,0(a0)
    if(a == last)
    800004f6:	05390863          	beq	s2,s3,80000546 <mappages+0xac>
    a += PGSIZE;
    800004fa:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800004fc:	bfd9                	j	800004d2 <mappages+0x38>
    panic("mappages: va not aligned");
    800004fe:	00007517          	auipc	a0,0x7
    80000502:	b5a50513          	addi	a0,a0,-1190 # 80007058 <etext+0x58>
    80000506:	628050ef          	jal	80005b2e <panic>
    panic("mappages: size not aligned");
    8000050a:	00007517          	auipc	a0,0x7
    8000050e:	b6e50513          	addi	a0,a0,-1170 # 80007078 <etext+0x78>
    80000512:	61c050ef          	jal	80005b2e <panic>
    panic("mappages: size");
    80000516:	00007517          	auipc	a0,0x7
    8000051a:	b8250513          	addi	a0,a0,-1150 # 80007098 <etext+0x98>
    8000051e:	610050ef          	jal	80005b2e <panic>
      panic("mappages: remap");
    80000522:	00007517          	auipc	a0,0x7
    80000526:	b8650513          	addi	a0,a0,-1146 # 800070a8 <etext+0xa8>
    8000052a:	604050ef          	jal	80005b2e <panic>
      return -1;
    8000052e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80000530:	60a6                	ld	ra,72(sp)
    80000532:	6406                	ld	s0,64(sp)
    80000534:	74e2                	ld	s1,56(sp)
    80000536:	7942                	ld	s2,48(sp)
    80000538:	79a2                	ld	s3,40(sp)
    8000053a:	7a02                	ld	s4,32(sp)
    8000053c:	6ae2                	ld	s5,24(sp)
    8000053e:	6b42                	ld	s6,16(sp)
    80000540:	6ba2                	ld	s7,8(sp)
    80000542:	6161                	addi	sp,sp,80
    80000544:	8082                	ret
  return 0;
    80000546:	4501                	li	a0,0
    80000548:	b7e5                	j	80000530 <mappages+0x96>

000000008000054a <kvmmap>:
{
    8000054a:	1141                	addi	sp,sp,-16
    8000054c:	e406                	sd	ra,8(sp)
    8000054e:	e022                	sd	s0,0(sp)
    80000550:	0800                	addi	s0,sp,16
    80000552:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000554:	86b2                	mv	a3,a2
    80000556:	863e                	mv	a2,a5
    80000558:	f43ff0ef          	jal	8000049a <mappages>
    8000055c:	e509                	bnez	a0,80000566 <kvmmap+0x1c>
}
    8000055e:	60a2                	ld	ra,8(sp)
    80000560:	6402                	ld	s0,0(sp)
    80000562:	0141                	addi	sp,sp,16
    80000564:	8082                	ret
    panic("kvmmap");
    80000566:	00007517          	auipc	a0,0x7
    8000056a:	b5250513          	addi	a0,a0,-1198 # 800070b8 <etext+0xb8>
    8000056e:	5c0050ef          	jal	80005b2e <panic>

0000000080000572 <kvmmake>:
{
    80000572:	1101                	addi	sp,sp,-32
    80000574:	ec06                	sd	ra,24(sp)
    80000576:	e822                	sd	s0,16(sp)
    80000578:	e426                	sd	s1,8(sp)
    8000057a:	e04a                	sd	s2,0(sp)
    8000057c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000057e:	b81ff0ef          	jal	800000fe <kalloc>
    80000582:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000584:	6605                	lui	a2,0x1
    80000586:	4581                	li	a1,0
    80000588:	bc7ff0ef          	jal	8000014e <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000058c:	4719                	li	a4,6
    8000058e:	6685                	lui	a3,0x1
    80000590:	10000637          	lui	a2,0x10000
    80000594:	100005b7          	lui	a1,0x10000
    80000598:	8526                	mv	a0,s1
    8000059a:	fb1ff0ef          	jal	8000054a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000059e:	4719                	li	a4,6
    800005a0:	6685                	lui	a3,0x1
    800005a2:	10001637          	lui	a2,0x10001
    800005a6:	100015b7          	lui	a1,0x10001
    800005aa:	8526                	mv	a0,s1
    800005ac:	f9fff0ef          	jal	8000054a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800005b0:	4719                	li	a4,6
    800005b2:	040006b7          	lui	a3,0x4000
    800005b6:	0c000637          	lui	a2,0xc000
    800005ba:	0c0005b7          	lui	a1,0xc000
    800005be:	8526                	mv	a0,s1
    800005c0:	f8bff0ef          	jal	8000054a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800005c4:	00007917          	auipc	s2,0x7
    800005c8:	a3c90913          	addi	s2,s2,-1476 # 80007000 <etext>
    800005cc:	4729                	li	a4,10
    800005ce:	80007697          	auipc	a3,0x80007
    800005d2:	a3268693          	addi	a3,a3,-1486 # 7000 <_entry-0x7fff9000>
    800005d6:	4605                	li	a2,1
    800005d8:	067e                	slli	a2,a2,0x1f
    800005da:	85b2                	mv	a1,a2
    800005dc:	8526                	mv	a0,s1
    800005de:	f6dff0ef          	jal	8000054a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800005e2:	46c5                	li	a3,17
    800005e4:	06ee                	slli	a3,a3,0x1b
    800005e6:	4719                	li	a4,6
    800005e8:	412686b3          	sub	a3,a3,s2
    800005ec:	864a                	mv	a2,s2
    800005ee:	85ca                	mv	a1,s2
    800005f0:	8526                	mv	a0,s1
    800005f2:	f59ff0ef          	jal	8000054a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800005f6:	4729                	li	a4,10
    800005f8:	6685                	lui	a3,0x1
    800005fa:	00006617          	auipc	a2,0x6
    800005fe:	a0660613          	addi	a2,a2,-1530 # 80006000 <_trampoline>
    80000602:	040005b7          	lui	a1,0x4000
    80000606:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000608:	05b2                	slli	a1,a1,0xc
    8000060a:	8526                	mv	a0,s1
    8000060c:	f3fff0ef          	jal	8000054a <kvmmap>
  proc_mapstacks(kpgtbl);
    80000610:	8526                	mv	a0,s1
    80000612:	5ee000ef          	jal	80000c00 <proc_mapstacks>
}
    80000616:	8526                	mv	a0,s1
    80000618:	60e2                	ld	ra,24(sp)
    8000061a:	6442                	ld	s0,16(sp)
    8000061c:	64a2                	ld	s1,8(sp)
    8000061e:	6902                	ld	s2,0(sp)
    80000620:	6105                	addi	sp,sp,32
    80000622:	8082                	ret

0000000080000624 <kvminit>:
{
    80000624:	1141                	addi	sp,sp,-16
    80000626:	e406                	sd	ra,8(sp)
    80000628:	e022                	sd	s0,0(sp)
    8000062a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000062c:	f47ff0ef          	jal	80000572 <kvmmake>
    80000630:	0000a797          	auipc	a5,0xa
    80000634:	d8a7b423          	sd	a0,-632(a5) # 8000a3b8 <kernel_pagetable>
}
    80000638:	60a2                	ld	ra,8(sp)
    8000063a:	6402                	ld	s0,0(sp)
    8000063c:	0141                	addi	sp,sp,16
    8000063e:	8082                	ret

0000000080000640 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80000640:	1101                	addi	sp,sp,-32
    80000642:	ec06                	sd	ra,24(sp)
    80000644:	e822                	sd	s0,16(sp)
    80000646:	e426                	sd	s1,8(sp)
    80000648:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000064a:	ab5ff0ef          	jal	800000fe <kalloc>
    8000064e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000650:	c509                	beqz	a0,8000065a <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000652:	6605                	lui	a2,0x1
    80000654:	4581                	li	a1,0
    80000656:	af9ff0ef          	jal	8000014e <memset>
  return pagetable;
}
    8000065a:	8526                	mv	a0,s1
    8000065c:	60e2                	ld	ra,24(sp)
    8000065e:	6442                	ld	s0,16(sp)
    80000660:	64a2                	ld	s1,8(sp)
    80000662:	6105                	addi	sp,sp,32
    80000664:	8082                	ret

0000000080000666 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000666:	7139                	addi	sp,sp,-64
    80000668:	fc06                	sd	ra,56(sp)
    8000066a:	f822                	sd	s0,48(sp)
    8000066c:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000066e:	03459793          	slli	a5,a1,0x34
    80000672:	e38d                	bnez	a5,80000694 <uvmunmap+0x2e>
    80000674:	f04a                	sd	s2,32(sp)
    80000676:	ec4e                	sd	s3,24(sp)
    80000678:	e852                	sd	s4,16(sp)
    8000067a:	e456                	sd	s5,8(sp)
    8000067c:	e05a                	sd	s6,0(sp)
    8000067e:	8a2a                	mv	s4,a0
    80000680:	892e                	mv	s2,a1
    80000682:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000684:	0632                	slli	a2,a2,0xc
    80000686:	00b609b3          	add	s3,a2,a1
    8000068a:	6b05                	lui	s6,0x1
    8000068c:	0535f963          	bgeu	a1,s3,800006de <uvmunmap+0x78>
    80000690:	f426                	sd	s1,40(sp)
    80000692:	a015                	j	800006b6 <uvmunmap+0x50>
    80000694:	f426                	sd	s1,40(sp)
    80000696:	f04a                	sd	s2,32(sp)
    80000698:	ec4e                	sd	s3,24(sp)
    8000069a:	e852                	sd	s4,16(sp)
    8000069c:	e456                	sd	s5,8(sp)
    8000069e:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800006a0:	00007517          	auipc	a0,0x7
    800006a4:	a2050513          	addi	a0,a0,-1504 # 800070c0 <etext+0xc0>
    800006a8:	486050ef          	jal	80005b2e <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    800006ac:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800006b0:	995a                	add	s2,s2,s6
    800006b2:	03397563          	bgeu	s2,s3,800006dc <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800006b6:	4601                	li	a2,0
    800006b8:	85ca                	mv	a1,s2
    800006ba:	8552                	mv	a0,s4
    800006bc:	d07ff0ef          	jal	800003c2 <walk>
    800006c0:	84aa                	mv	s1,a0
    800006c2:	d57d                	beqz	a0,800006b0 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800006c4:	611c                	ld	a5,0(a0)
    800006c6:	0017f713          	andi	a4,a5,1
    800006ca:	d37d                	beqz	a4,800006b0 <uvmunmap+0x4a>
    if(do_free){
    800006cc:	fe0a80e3          	beqz	s5,800006ac <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800006d0:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800006d2:	00c79513          	slli	a0,a5,0xc
    800006d6:	947ff0ef          	jal	8000001c <kfree>
    800006da:	bfc9                	j	800006ac <uvmunmap+0x46>
    800006dc:	74a2                	ld	s1,40(sp)
    800006de:	7902                	ld	s2,32(sp)
    800006e0:	69e2                	ld	s3,24(sp)
    800006e2:	6a42                	ld	s4,16(sp)
    800006e4:	6aa2                	ld	s5,8(sp)
    800006e6:	6b02                	ld	s6,0(sp)
  }
}
    800006e8:	70e2                	ld	ra,56(sp)
    800006ea:	7442                	ld	s0,48(sp)
    800006ec:	6121                	addi	sp,sp,64
    800006ee:	8082                	ret

00000000800006f0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800006f0:	1101                	addi	sp,sp,-32
    800006f2:	ec06                	sd	ra,24(sp)
    800006f4:	e822                	sd	s0,16(sp)
    800006f6:	e426                	sd	s1,8(sp)
    800006f8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800006fa:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800006fc:	00b67d63          	bgeu	a2,a1,80000716 <uvmdealloc+0x26>
    80000700:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000702:	6785                	lui	a5,0x1
    80000704:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000706:	00f60733          	add	a4,a2,a5
    8000070a:	76fd                	lui	a3,0xfffff
    8000070c:	8f75                	and	a4,a4,a3
    8000070e:	97ae                	add	a5,a5,a1
    80000710:	8ff5                	and	a5,a5,a3
    80000712:	00f76863          	bltu	a4,a5,80000722 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80000716:	8526                	mv	a0,s1
    80000718:	60e2                	ld	ra,24(sp)
    8000071a:	6442                	ld	s0,16(sp)
    8000071c:	64a2                	ld	s1,8(sp)
    8000071e:	6105                	addi	sp,sp,32
    80000720:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000722:	8f99                	sub	a5,a5,a4
    80000724:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80000726:	4685                	li	a3,1
    80000728:	0007861b          	sext.w	a2,a5
    8000072c:	85ba                	mv	a1,a4
    8000072e:	f39ff0ef          	jal	80000666 <uvmunmap>
    80000732:	b7d5                	j	80000716 <uvmdealloc+0x26>

0000000080000734 <uvmalloc>:
  if(newsz < oldsz)
    80000734:	08b66f63          	bltu	a2,a1,800007d2 <uvmalloc+0x9e>
{
    80000738:	7139                	addi	sp,sp,-64
    8000073a:	fc06                	sd	ra,56(sp)
    8000073c:	f822                	sd	s0,48(sp)
    8000073e:	ec4e                	sd	s3,24(sp)
    80000740:	e852                	sd	s4,16(sp)
    80000742:	e456                	sd	s5,8(sp)
    80000744:	0080                	addi	s0,sp,64
    80000746:	8aaa                	mv	s5,a0
    80000748:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000074a:	6785                	lui	a5,0x1
    8000074c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000074e:	95be                	add	a1,a1,a5
    80000750:	77fd                	lui	a5,0xfffff
    80000752:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000756:	08c9f063          	bgeu	s3,a2,800007d6 <uvmalloc+0xa2>
    8000075a:	f426                	sd	s1,40(sp)
    8000075c:	f04a                	sd	s2,32(sp)
    8000075e:	e05a                	sd	s6,0(sp)
    80000760:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000762:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80000766:	999ff0ef          	jal	800000fe <kalloc>
    8000076a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000076c:	c515                	beqz	a0,80000798 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000076e:	6605                	lui	a2,0x1
    80000770:	4581                	li	a1,0
    80000772:	9ddff0ef          	jal	8000014e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000776:	875a                	mv	a4,s6
    80000778:	86a6                	mv	a3,s1
    8000077a:	6605                	lui	a2,0x1
    8000077c:	85ca                	mv	a1,s2
    8000077e:	8556                	mv	a0,s5
    80000780:	d1bff0ef          	jal	8000049a <mappages>
    80000784:	e915                	bnez	a0,800007b8 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000786:	6785                	lui	a5,0x1
    80000788:	993e                	add	s2,s2,a5
    8000078a:	fd496ee3          	bltu	s2,s4,80000766 <uvmalloc+0x32>
  return newsz;
    8000078e:	8552                	mv	a0,s4
    80000790:	74a2                	ld	s1,40(sp)
    80000792:	7902                	ld	s2,32(sp)
    80000794:	6b02                	ld	s6,0(sp)
    80000796:	a811                	j	800007aa <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    80000798:	864e                	mv	a2,s3
    8000079a:	85ca                	mv	a1,s2
    8000079c:	8556                	mv	a0,s5
    8000079e:	f53ff0ef          	jal	800006f0 <uvmdealloc>
      return 0;
    800007a2:	4501                	li	a0,0
    800007a4:	74a2                	ld	s1,40(sp)
    800007a6:	7902                	ld	s2,32(sp)
    800007a8:	6b02                	ld	s6,0(sp)
}
    800007aa:	70e2                	ld	ra,56(sp)
    800007ac:	7442                	ld	s0,48(sp)
    800007ae:	69e2                	ld	s3,24(sp)
    800007b0:	6a42                	ld	s4,16(sp)
    800007b2:	6aa2                	ld	s5,8(sp)
    800007b4:	6121                	addi	sp,sp,64
    800007b6:	8082                	ret
      kfree(mem);
    800007b8:	8526                	mv	a0,s1
    800007ba:	863ff0ef          	jal	8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800007be:	864e                	mv	a2,s3
    800007c0:	85ca                	mv	a1,s2
    800007c2:	8556                	mv	a0,s5
    800007c4:	f2dff0ef          	jal	800006f0 <uvmdealloc>
      return 0;
    800007c8:	4501                	li	a0,0
    800007ca:	74a2                	ld	s1,40(sp)
    800007cc:	7902                	ld	s2,32(sp)
    800007ce:	6b02                	ld	s6,0(sp)
    800007d0:	bfe9                	j	800007aa <uvmalloc+0x76>
    return oldsz;
    800007d2:	852e                	mv	a0,a1
}
    800007d4:	8082                	ret
  return newsz;
    800007d6:	8532                	mv	a0,a2
    800007d8:	bfc9                	j	800007aa <uvmalloc+0x76>

00000000800007da <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800007da:	7179                	addi	sp,sp,-48
    800007dc:	f406                	sd	ra,40(sp)
    800007de:	f022                	sd	s0,32(sp)
    800007e0:	ec26                	sd	s1,24(sp)
    800007e2:	e84a                	sd	s2,16(sp)
    800007e4:	e44e                	sd	s3,8(sp)
    800007e6:	e052                	sd	s4,0(sp)
    800007e8:	1800                	addi	s0,sp,48
    800007ea:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800007ec:	84aa                	mv	s1,a0
    800007ee:	6905                	lui	s2,0x1
    800007f0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800007f2:	4985                	li	s3,1
    800007f4:	a819                	j	8000080a <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800007f6:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800007f8:	00c79513          	slli	a0,a5,0xc
    800007fc:	fdfff0ef          	jal	800007da <freewalk>
      pagetable[i] = 0;
    80000800:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000804:	04a1                	addi	s1,s1,8
    80000806:	01248f63          	beq	s1,s2,80000824 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000080a:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000080c:	00f7f713          	andi	a4,a5,15
    80000810:	ff3703e3          	beq	a4,s3,800007f6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000814:	8b85                	andi	a5,a5,1
    80000816:	d7fd                	beqz	a5,80000804 <freewalk+0x2a>
      panic("freewalk: leaf");
    80000818:	00007517          	auipc	a0,0x7
    8000081c:	8c050513          	addi	a0,a0,-1856 # 800070d8 <etext+0xd8>
    80000820:	30e050ef          	jal	80005b2e <panic>
    }
  }
  kfree((void*)pagetable);
    80000824:	8552                	mv	a0,s4
    80000826:	ff6ff0ef          	jal	8000001c <kfree>
}
    8000082a:	70a2                	ld	ra,40(sp)
    8000082c:	7402                	ld	s0,32(sp)
    8000082e:	64e2                	ld	s1,24(sp)
    80000830:	6942                	ld	s2,16(sp)
    80000832:	69a2                	ld	s3,8(sp)
    80000834:	6a02                	ld	s4,0(sp)
    80000836:	6145                	addi	sp,sp,48
    80000838:	8082                	ret

000000008000083a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000083a:	1101                	addi	sp,sp,-32
    8000083c:	ec06                	sd	ra,24(sp)
    8000083e:	e822                	sd	s0,16(sp)
    80000840:	e426                	sd	s1,8(sp)
    80000842:	1000                	addi	s0,sp,32
    80000844:	84aa                	mv	s1,a0
  if(sz > 0)
    80000846:	e989                	bnez	a1,80000858 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80000848:	8526                	mv	a0,s1
    8000084a:	f91ff0ef          	jal	800007da <freewalk>
}
    8000084e:	60e2                	ld	ra,24(sp)
    80000850:	6442                	ld	s0,16(sp)
    80000852:	64a2                	ld	s1,8(sp)
    80000854:	6105                	addi	sp,sp,32
    80000856:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000858:	6785                	lui	a5,0x1
    8000085a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000085c:	95be                	add	a1,a1,a5
    8000085e:	4685                	li	a3,1
    80000860:	00c5d613          	srli	a2,a1,0xc
    80000864:	4581                	li	a1,0
    80000866:	e01ff0ef          	jal	80000666 <uvmunmap>
    8000086a:	bff9                	j	80000848 <uvmfree+0xe>

000000008000086c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000086c:	ce49                	beqz	a2,80000906 <uvmcopy+0x9a>
{
    8000086e:	715d                	addi	sp,sp,-80
    80000870:	e486                	sd	ra,72(sp)
    80000872:	e0a2                	sd	s0,64(sp)
    80000874:	fc26                	sd	s1,56(sp)
    80000876:	f84a                	sd	s2,48(sp)
    80000878:	f44e                	sd	s3,40(sp)
    8000087a:	f052                	sd	s4,32(sp)
    8000087c:	ec56                	sd	s5,24(sp)
    8000087e:	e85a                	sd	s6,16(sp)
    80000880:	e45e                	sd	s7,8(sp)
    80000882:	0880                	addi	s0,sp,80
    80000884:	8aaa                	mv	s5,a0
    80000886:	8b2e                	mv	s6,a1
    80000888:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000088a:	4481                	li	s1,0
    8000088c:	a029                	j	80000896 <uvmcopy+0x2a>
    8000088e:	6785                	lui	a5,0x1
    80000890:	94be                	add	s1,s1,a5
    80000892:	0544fe63          	bgeu	s1,s4,800008ee <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    80000896:	4601                	li	a2,0
    80000898:	85a6                	mv	a1,s1
    8000089a:	8556                	mv	a0,s5
    8000089c:	b27ff0ef          	jal	800003c2 <walk>
    800008a0:	d57d                	beqz	a0,8000088e <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800008a2:	6118                	ld	a4,0(a0)
    800008a4:	00177793          	andi	a5,a4,1
    800008a8:	d3fd                	beqz	a5,8000088e <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800008aa:	00a75593          	srli	a1,a4,0xa
    800008ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800008b2:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    800008b6:	849ff0ef          	jal	800000fe <kalloc>
    800008ba:	89aa                	mv	s3,a0
    800008bc:	c105                	beqz	a0,800008dc <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800008be:	6605                	lui	a2,0x1
    800008c0:	85de                	mv	a1,s7
    800008c2:	8e9ff0ef          	jal	800001aa <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800008c6:	874a                	mv	a4,s2
    800008c8:	86ce                	mv	a3,s3
    800008ca:	6605                	lui	a2,0x1
    800008cc:	85a6                	mv	a1,s1
    800008ce:	855a                	mv	a0,s6
    800008d0:	bcbff0ef          	jal	8000049a <mappages>
    800008d4:	dd4d                	beqz	a0,8000088e <uvmcopy+0x22>
      kfree(mem);
    800008d6:	854e                	mv	a0,s3
    800008d8:	f44ff0ef          	jal	8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800008dc:	4685                	li	a3,1
    800008de:	00c4d613          	srli	a2,s1,0xc
    800008e2:	4581                	li	a1,0
    800008e4:	855a                	mv	a0,s6
    800008e6:	d81ff0ef          	jal	80000666 <uvmunmap>
  return -1;
    800008ea:	557d                	li	a0,-1
    800008ec:	a011                	j	800008f0 <uvmcopy+0x84>
  return 0;
    800008ee:	4501                	li	a0,0
}
    800008f0:	60a6                	ld	ra,72(sp)
    800008f2:	6406                	ld	s0,64(sp)
    800008f4:	74e2                	ld	s1,56(sp)
    800008f6:	7942                	ld	s2,48(sp)
    800008f8:	79a2                	ld	s3,40(sp)
    800008fa:	7a02                	ld	s4,32(sp)
    800008fc:	6ae2                	ld	s5,24(sp)
    800008fe:	6b42                	ld	s6,16(sp)
    80000900:	6ba2                	ld	s7,8(sp)
    80000902:	6161                	addi	sp,sp,80
    80000904:	8082                	ret
  return 0;
    80000906:	4501                	li	a0,0
}
    80000908:	8082                	ret

000000008000090a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000090a:	1141                	addi	sp,sp,-16
    8000090c:	e406                	sd	ra,8(sp)
    8000090e:	e022                	sd	s0,0(sp)
    80000910:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000912:	4601                	li	a2,0
    80000914:	aafff0ef          	jal	800003c2 <walk>
  if(pte == 0)
    80000918:	c901                	beqz	a0,80000928 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000091a:	611c                	ld	a5,0(a0)
    8000091c:	9bbd                	andi	a5,a5,-17
    8000091e:	e11c                	sd	a5,0(a0)
}
    80000920:	60a2                	ld	ra,8(sp)
    80000922:	6402                	ld	s0,0(sp)
    80000924:	0141                	addi	sp,sp,16
    80000926:	8082                	ret
    panic("uvmclear");
    80000928:	00006517          	auipc	a0,0x6
    8000092c:	7c050513          	addi	a0,a0,1984 # 800070e8 <etext+0xe8>
    80000930:	1fe050ef          	jal	80005b2e <panic>

0000000080000934 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000934:	c6dd                	beqz	a3,800009e2 <copyinstr+0xae>
{
    80000936:	715d                	addi	sp,sp,-80
    80000938:	e486                	sd	ra,72(sp)
    8000093a:	e0a2                	sd	s0,64(sp)
    8000093c:	fc26                	sd	s1,56(sp)
    8000093e:	f84a                	sd	s2,48(sp)
    80000940:	f44e                	sd	s3,40(sp)
    80000942:	f052                	sd	s4,32(sp)
    80000944:	ec56                	sd	s5,24(sp)
    80000946:	e85a                	sd	s6,16(sp)
    80000948:	e45e                	sd	s7,8(sp)
    8000094a:	0880                	addi	s0,sp,80
    8000094c:	8a2a                	mv	s4,a0
    8000094e:	8b2e                	mv	s6,a1
    80000950:	8bb2                	mv	s7,a2
    80000952:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80000954:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000956:	6985                	lui	s3,0x1
    80000958:	a825                	j	80000990 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000095a:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000095e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000960:	37fd                	addiw	a5,a5,-1
    80000962:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000966:	60a6                	ld	ra,72(sp)
    80000968:	6406                	ld	s0,64(sp)
    8000096a:	74e2                	ld	s1,56(sp)
    8000096c:	7942                	ld	s2,48(sp)
    8000096e:	79a2                	ld	s3,40(sp)
    80000970:	7a02                	ld	s4,32(sp)
    80000972:	6ae2                	ld	s5,24(sp)
    80000974:	6b42                	ld	s6,16(sp)
    80000976:	6ba2                	ld	s7,8(sp)
    80000978:	6161                	addi	sp,sp,80
    8000097a:	8082                	ret
    8000097c:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80000980:	9742                	add	a4,a4,a6
      --max;
    80000982:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80000986:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    8000098a:	04e58463          	beq	a1,a4,800009d2 <copyinstr+0x9e>
{
    8000098e:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80000990:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000994:	85a6                	mv	a1,s1
    80000996:	8552                	mv	a0,s4
    80000998:	ac5ff0ef          	jal	8000045c <walkaddr>
    if(pa0 == 0)
    8000099c:	cd0d                	beqz	a0,800009d6 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000099e:	417486b3          	sub	a3,s1,s7
    800009a2:	96ce                	add	a3,a3,s3
    if(n > max)
    800009a4:	00d97363          	bgeu	s2,a3,800009aa <copyinstr+0x76>
    800009a8:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800009aa:	955e                	add	a0,a0,s7
    800009ac:	8d05                	sub	a0,a0,s1
    while(n > 0){
    800009ae:	c695                	beqz	a3,800009da <copyinstr+0xa6>
    800009b0:	87da                	mv	a5,s6
    800009b2:	885a                	mv	a6,s6
      if(*p == '\0'){
    800009b4:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800009b8:	96da                	add	a3,a3,s6
    800009ba:	85be                	mv	a1,a5
      if(*p == '\0'){
    800009bc:	00f60733          	add	a4,a2,a5
    800009c0:	00074703          	lbu	a4,0(a4)
    800009c4:	db59                	beqz	a4,8000095a <copyinstr+0x26>
        *dst = *p;
    800009c6:	00e78023          	sb	a4,0(a5)
      dst++;
    800009ca:	0785                	addi	a5,a5,1
    while(n > 0){
    800009cc:	fed797e3          	bne	a5,a3,800009ba <copyinstr+0x86>
    800009d0:	b775                	j	8000097c <copyinstr+0x48>
    800009d2:	4781                	li	a5,0
    800009d4:	b771                	j	80000960 <copyinstr+0x2c>
      return -1;
    800009d6:	557d                	li	a0,-1
    800009d8:	b779                	j	80000966 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800009da:	6b85                	lui	s7,0x1
    800009dc:	9ba6                	add	s7,s7,s1
    800009de:	87da                	mv	a5,s6
    800009e0:	b77d                	j	8000098e <copyinstr+0x5a>
  int got_null = 0;
    800009e2:	4781                	li	a5,0
  if(got_null){
    800009e4:	37fd                	addiw	a5,a5,-1
    800009e6:	0007851b          	sext.w	a0,a5
}
    800009ea:	8082                	ret

00000000800009ec <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800009ec:	1141                	addi	sp,sp,-16
    800009ee:	e406                	sd	ra,8(sp)
    800009f0:	e022                	sd	s0,0(sp)
    800009f2:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800009f4:	4601                	li	a2,0
    800009f6:	9cdff0ef          	jal	800003c2 <walk>
  if (pte == 0) {
    800009fa:	c519                	beqz	a0,80000a08 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800009fc:	6108                	ld	a0,0(a0)
    800009fe:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80000a00:	60a2                	ld	ra,8(sp)
    80000a02:	6402                	ld	s0,0(sp)
    80000a04:	0141                	addi	sp,sp,16
    80000a06:	8082                	ret
    return 0;
    80000a08:	4501                	li	a0,0
    80000a0a:	bfdd                	j	80000a00 <ismapped+0x14>

0000000080000a0c <vmfault>:
{
    80000a0c:	7179                	addi	sp,sp,-48
    80000a0e:	f406                	sd	ra,40(sp)
    80000a10:	f022                	sd	s0,32(sp)
    80000a12:	ec26                	sd	s1,24(sp)
    80000a14:	e44e                	sd	s3,8(sp)
    80000a16:	1800                	addi	s0,sp,48
    80000a18:	89aa                	mv	s3,a0
    80000a1a:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80000a1c:	35e000ef          	jal	80000d7a <myproc>
  if (va >= p->sz)
    80000a20:	653c                	ld	a5,72(a0)
    80000a22:	00f4ea63          	bltu	s1,a5,80000a36 <vmfault+0x2a>
    return 0;
    80000a26:	4981                	li	s3,0
}
    80000a28:	854e                	mv	a0,s3
    80000a2a:	70a2                	ld	ra,40(sp)
    80000a2c:	7402                	ld	s0,32(sp)
    80000a2e:	64e2                	ld	s1,24(sp)
    80000a30:	69a2                	ld	s3,8(sp)
    80000a32:	6145                	addi	sp,sp,48
    80000a34:	8082                	ret
    80000a36:	e84a                	sd	s2,16(sp)
    80000a38:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80000a3a:	77fd                	lui	a5,0xfffff
    80000a3c:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80000a3e:	85a6                	mv	a1,s1
    80000a40:	854e                	mv	a0,s3
    80000a42:	fabff0ef          	jal	800009ec <ismapped>
    return 0;
    80000a46:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80000a48:	c119                	beqz	a0,80000a4e <vmfault+0x42>
    80000a4a:	6942                	ld	s2,16(sp)
    80000a4c:	bff1                	j	80000a28 <vmfault+0x1c>
    80000a4e:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    80000a50:	eaeff0ef          	jal	800000fe <kalloc>
    80000a54:	8a2a                	mv	s4,a0
  if(mem == 0)
    80000a56:	c90d                	beqz	a0,80000a88 <vmfault+0x7c>
  mem = (uint64) kalloc();
    80000a58:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80000a5a:	6605                	lui	a2,0x1
    80000a5c:	4581                	li	a1,0
    80000a5e:	ef0ff0ef          	jal	8000014e <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80000a62:	4759                	li	a4,22
    80000a64:	86d2                	mv	a3,s4
    80000a66:	6605                	lui	a2,0x1
    80000a68:	85a6                	mv	a1,s1
    80000a6a:	05093503          	ld	a0,80(s2)
    80000a6e:	a2dff0ef          	jal	8000049a <mappages>
    80000a72:	e501                	bnez	a0,80000a7a <vmfault+0x6e>
    80000a74:	6942                	ld	s2,16(sp)
    80000a76:	6a02                	ld	s4,0(sp)
    80000a78:	bf45                	j	80000a28 <vmfault+0x1c>
    kfree((void *)mem);
    80000a7a:	8552                	mv	a0,s4
    80000a7c:	da0ff0ef          	jal	8000001c <kfree>
    return 0;
    80000a80:	4981                	li	s3,0
    80000a82:	6942                	ld	s2,16(sp)
    80000a84:	6a02                	ld	s4,0(sp)
    80000a86:	b74d                	j	80000a28 <vmfault+0x1c>
    80000a88:	6942                	ld	s2,16(sp)
    80000a8a:	6a02                	ld	s4,0(sp)
    80000a8c:	bf71                	j	80000a28 <vmfault+0x1c>

0000000080000a8e <copyout>:
  while(len > 0){
    80000a8e:	c2cd                	beqz	a3,80000b30 <copyout+0xa2>
{
    80000a90:	711d                	addi	sp,sp,-96
    80000a92:	ec86                	sd	ra,88(sp)
    80000a94:	e8a2                	sd	s0,80(sp)
    80000a96:	e4a6                	sd	s1,72(sp)
    80000a98:	f852                	sd	s4,48(sp)
    80000a9a:	f05a                	sd	s6,32(sp)
    80000a9c:	ec5e                	sd	s7,24(sp)
    80000a9e:	e862                	sd	s8,16(sp)
    80000aa0:	1080                	addi	s0,sp,96
    80000aa2:	8c2a                	mv	s8,a0
    80000aa4:	8b2e                	mv	s6,a1
    80000aa6:	8bb2                	mv	s7,a2
    80000aa8:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    80000aaa:	74fd                	lui	s1,0xfffff
    80000aac:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80000aae:	57fd                	li	a5,-1
    80000ab0:	83e9                	srli	a5,a5,0x1a
    80000ab2:	0897e163          	bltu	a5,s1,80000b34 <copyout+0xa6>
    80000ab6:	e0ca                	sd	s2,64(sp)
    80000ab8:	fc4e                	sd	s3,56(sp)
    80000aba:	f456                	sd	s5,40(sp)
    80000abc:	e466                	sd	s9,8(sp)
    80000abe:	e06a                	sd	s10,0(sp)
    80000ac0:	6d05                	lui	s10,0x1
    80000ac2:	8cbe                	mv	s9,a5
    80000ac4:	a015                	j	80000ae8 <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000ac6:	409b0533          	sub	a0,s6,s1
    80000aca:	0009861b          	sext.w	a2,s3
    80000ace:	85de                	mv	a1,s7
    80000ad0:	954a                	add	a0,a0,s2
    80000ad2:	ed8ff0ef          	jal	800001aa <memmove>
    len -= n;
    80000ad6:	413a0a33          	sub	s4,s4,s3
    src += n;
    80000ada:	9bce                	add	s7,s7,s3
  while(len > 0){
    80000adc:	040a0363          	beqz	s4,80000b22 <copyout+0x94>
    if(va0 >= MAXVA)
    80000ae0:	055cec63          	bltu	s9,s5,80000b38 <copyout+0xaa>
    80000ae4:	84d6                	mv	s1,s5
    80000ae6:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80000ae8:	85a6                	mv	a1,s1
    80000aea:	8562                	mv	a0,s8
    80000aec:	971ff0ef          	jal	8000045c <walkaddr>
    80000af0:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80000af2:	e901                	bnez	a0,80000b02 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80000af4:	4601                	li	a2,0
    80000af6:	85a6                	mv	a1,s1
    80000af8:	8562                	mv	a0,s8
    80000afa:	f13ff0ef          	jal	80000a0c <vmfault>
    80000afe:	892a                	mv	s2,a0
    80000b00:	c139                	beqz	a0,80000b46 <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80000b02:	4601                	li	a2,0
    80000b04:	85a6                	mv	a1,s1
    80000b06:	8562                	mv	a0,s8
    80000b08:	8bbff0ef          	jal	800003c2 <walk>
    if((*pte & PTE_W) == 0)
    80000b0c:	611c                	ld	a5,0(a0)
    80000b0e:	8b91                	andi	a5,a5,4
    80000b10:	c3b1                	beqz	a5,80000b54 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80000b12:	01a48ab3          	add	s5,s1,s10
    80000b16:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    80000b1a:	fb3a76e3          	bgeu	s4,s3,80000ac6 <copyout+0x38>
    80000b1e:	89d2                	mv	s3,s4
    80000b20:	b75d                	j	80000ac6 <copyout+0x38>
  return 0;
    80000b22:	4501                	li	a0,0
    80000b24:	6906                	ld	s2,64(sp)
    80000b26:	79e2                	ld	s3,56(sp)
    80000b28:	7aa2                	ld	s5,40(sp)
    80000b2a:	6ca2                	ld	s9,8(sp)
    80000b2c:	6d02                	ld	s10,0(sp)
    80000b2e:	a80d                	j	80000b60 <copyout+0xd2>
    80000b30:	4501                	li	a0,0
}
    80000b32:	8082                	ret
      return -1;
    80000b34:	557d                	li	a0,-1
    80000b36:	a02d                	j	80000b60 <copyout+0xd2>
    80000b38:	557d                	li	a0,-1
    80000b3a:	6906                	ld	s2,64(sp)
    80000b3c:	79e2                	ld	s3,56(sp)
    80000b3e:	7aa2                	ld	s5,40(sp)
    80000b40:	6ca2                	ld	s9,8(sp)
    80000b42:	6d02                	ld	s10,0(sp)
    80000b44:	a831                	j	80000b60 <copyout+0xd2>
        return -1;
    80000b46:	557d                	li	a0,-1
    80000b48:	6906                	ld	s2,64(sp)
    80000b4a:	79e2                	ld	s3,56(sp)
    80000b4c:	7aa2                	ld	s5,40(sp)
    80000b4e:	6ca2                	ld	s9,8(sp)
    80000b50:	6d02                	ld	s10,0(sp)
    80000b52:	a039                	j	80000b60 <copyout+0xd2>
      return -1;
    80000b54:	557d                	li	a0,-1
    80000b56:	6906                	ld	s2,64(sp)
    80000b58:	79e2                	ld	s3,56(sp)
    80000b5a:	7aa2                	ld	s5,40(sp)
    80000b5c:	6ca2                	ld	s9,8(sp)
    80000b5e:	6d02                	ld	s10,0(sp)
}
    80000b60:	60e6                	ld	ra,88(sp)
    80000b62:	6446                	ld	s0,80(sp)
    80000b64:	64a6                	ld	s1,72(sp)
    80000b66:	7a42                	ld	s4,48(sp)
    80000b68:	7b02                	ld	s6,32(sp)
    80000b6a:	6be2                	ld	s7,24(sp)
    80000b6c:	6c42                	ld	s8,16(sp)
    80000b6e:	6125                	addi	sp,sp,96
    80000b70:	8082                	ret

0000000080000b72 <copyin>:
  while(len > 0){
    80000b72:	c6c9                	beqz	a3,80000bfc <copyin+0x8a>
{
    80000b74:	715d                	addi	sp,sp,-80
    80000b76:	e486                	sd	ra,72(sp)
    80000b78:	e0a2                	sd	s0,64(sp)
    80000b7a:	fc26                	sd	s1,56(sp)
    80000b7c:	f84a                	sd	s2,48(sp)
    80000b7e:	f44e                	sd	s3,40(sp)
    80000b80:	f052                	sd	s4,32(sp)
    80000b82:	ec56                	sd	s5,24(sp)
    80000b84:	e85a                	sd	s6,16(sp)
    80000b86:	e45e                	sd	s7,8(sp)
    80000b88:	e062                	sd	s8,0(sp)
    80000b8a:	0880                	addi	s0,sp,80
    80000b8c:	8baa                	mv	s7,a0
    80000b8e:	8aae                	mv	s5,a1
    80000b90:	8932                	mv	s2,a2
    80000b92:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80000b94:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80000b96:	6b05                	lui	s6,0x1
    80000b98:	a035                	j	80000bc4 <copyin+0x52>
    80000b9a:	412984b3          	sub	s1,s3,s2
    80000b9e:	94da                	add	s1,s1,s6
    if(n > len)
    80000ba0:	009a7363          	bgeu	s4,s1,80000ba6 <copyin+0x34>
    80000ba4:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000ba6:	413905b3          	sub	a1,s2,s3
    80000baa:	0004861b          	sext.w	a2,s1
    80000bae:	95aa                	add	a1,a1,a0
    80000bb0:	8556                	mv	a0,s5
    80000bb2:	df8ff0ef          	jal	800001aa <memmove>
    len -= n;
    80000bb6:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80000bba:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80000bbc:	01698933          	add	s2,s3,s6
  while(len > 0){
    80000bc0:	020a0163          	beqz	s4,80000be2 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80000bc4:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80000bc8:	85ce                	mv	a1,s3
    80000bca:	855e                	mv	a0,s7
    80000bcc:	891ff0ef          	jal	8000045c <walkaddr>
    if(pa0 == 0) {
    80000bd0:	f569                	bnez	a0,80000b9a <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80000bd2:	4601                	li	a2,0
    80000bd4:	85ce                	mv	a1,s3
    80000bd6:	855e                	mv	a0,s7
    80000bd8:	e35ff0ef          	jal	80000a0c <vmfault>
    80000bdc:	fd5d                	bnez	a0,80000b9a <copyin+0x28>
        return -1;
    80000bde:	557d                	li	a0,-1
    80000be0:	a011                	j	80000be4 <copyin+0x72>
  return 0;
    80000be2:	4501                	li	a0,0
}
    80000be4:	60a6                	ld	ra,72(sp)
    80000be6:	6406                	ld	s0,64(sp)
    80000be8:	74e2                	ld	s1,56(sp)
    80000bea:	7942                	ld	s2,48(sp)
    80000bec:	79a2                	ld	s3,40(sp)
    80000bee:	7a02                	ld	s4,32(sp)
    80000bf0:	6ae2                	ld	s5,24(sp)
    80000bf2:	6b42                	ld	s6,16(sp)
    80000bf4:	6ba2                	ld	s7,8(sp)
    80000bf6:	6c02                	ld	s8,0(sp)
    80000bf8:	6161                	addi	sp,sp,80
    80000bfa:	8082                	ret
  return 0;
    80000bfc:	4501                	li	a0,0
}
    80000bfe:	8082                	ret

0000000080000c00 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000c00:	7139                	addi	sp,sp,-64
    80000c02:	fc06                	sd	ra,56(sp)
    80000c04:	f822                	sd	s0,48(sp)
    80000c06:	f426                	sd	s1,40(sp)
    80000c08:	f04a                	sd	s2,32(sp)
    80000c0a:	ec4e                	sd	s3,24(sp)
    80000c0c:	e852                	sd	s4,16(sp)
    80000c0e:	e456                	sd	s5,8(sp)
    80000c10:	e05a                	sd	s6,0(sp)
    80000c12:	0080                	addi	s0,sp,64
    80000c14:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c16:	0000a497          	auipc	s1,0xa
    80000c1a:	c1a48493          	addi	s1,s1,-998 # 8000a830 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000c1e:	8b26                	mv	s6,s1
    80000c20:	00e12937          	lui	s2,0xe12
    80000c24:	27f90913          	addi	s2,s2,639 # e1227f <_entry-0x7f1edd81>
    80000c28:	0936                	slli	s2,s2,0xd
    80000c2a:	2f390913          	addi	s2,s2,755
    80000c2e:	0932                	slli	s2,s2,0xc
    80000c30:	4a790913          	addi	s2,s2,1191
    80000c34:	093a                	slli	s2,s2,0xe
    80000c36:	24590913          	addi	s2,s2,581
    80000c3a:	040009b7          	lui	s3,0x4000
    80000c3e:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000c40:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c42:	0001ba97          	auipc	s5,0x1b
    80000c46:	5eea8a93          	addi	s5,s5,1518 # 8001c230 <tickslock>
    char *pa = kalloc();
    80000c4a:	cb4ff0ef          	jal	800000fe <kalloc>
    80000c4e:	862a                	mv	a2,a0
    if(pa == 0)
    80000c50:	cd15                	beqz	a0,80000c8c <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80000c52:	416485b3          	sub	a1,s1,s6
    80000c56:	858d                	srai	a1,a1,0x3
    80000c58:	032585b3          	mul	a1,a1,s2
    80000c5c:	2585                	addiw	a1,a1,1
    80000c5e:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000c62:	4719                	li	a4,6
    80000c64:	6685                	lui	a3,0x1
    80000c66:	40b985b3          	sub	a1,s3,a1
    80000c6a:	8552                	mv	a0,s4
    80000c6c:	8dfff0ef          	jal	8000054a <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c70:	46848493          	addi	s1,s1,1128
    80000c74:	fd549be3          	bne	s1,s5,80000c4a <proc_mapstacks+0x4a>
  }
}
    80000c78:	70e2                	ld	ra,56(sp)
    80000c7a:	7442                	ld	s0,48(sp)
    80000c7c:	74a2                	ld	s1,40(sp)
    80000c7e:	7902                	ld	s2,32(sp)
    80000c80:	69e2                	ld	s3,24(sp)
    80000c82:	6a42                	ld	s4,16(sp)
    80000c84:	6aa2                	ld	s5,8(sp)
    80000c86:	6b02                	ld	s6,0(sp)
    80000c88:	6121                	addi	sp,sp,64
    80000c8a:	8082                	ret
      panic("kalloc");
    80000c8c:	00006517          	auipc	a0,0x6
    80000c90:	46c50513          	addi	a0,a0,1132 # 800070f8 <etext+0xf8>
    80000c94:	69b040ef          	jal	80005b2e <panic>

0000000080000c98 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000c98:	7139                	addi	sp,sp,-64
    80000c9a:	fc06                	sd	ra,56(sp)
    80000c9c:	f822                	sd	s0,48(sp)
    80000c9e:	f426                	sd	s1,40(sp)
    80000ca0:	f04a                	sd	s2,32(sp)
    80000ca2:	ec4e                	sd	s3,24(sp)
    80000ca4:	e852                	sd	s4,16(sp)
    80000ca6:	e456                	sd	s5,8(sp)
    80000ca8:	e05a                	sd	s6,0(sp)
    80000caa:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000cac:	00006597          	auipc	a1,0x6
    80000cb0:	45458593          	addi	a1,a1,1108 # 80007100 <etext+0x100>
    80000cb4:	00009517          	auipc	a0,0x9
    80000cb8:	74c50513          	addi	a0,a0,1868 # 8000a400 <pid_lock>
    80000cbc:	0ae050ef          	jal	80005d6a <initlock>
  initlock(&wait_lock, "wait_lock");
    80000cc0:	00006597          	auipc	a1,0x6
    80000cc4:	44858593          	addi	a1,a1,1096 # 80007108 <etext+0x108>
    80000cc8:	00009517          	auipc	a0,0x9
    80000ccc:	75050513          	addi	a0,a0,1872 # 8000a418 <wait_lock>
    80000cd0:	09a050ef          	jal	80005d6a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cd4:	0000a497          	auipc	s1,0xa
    80000cd8:	b5c48493          	addi	s1,s1,-1188 # 8000a830 <proc>
      initlock(&p->lock, "proc");
    80000cdc:	00006b17          	auipc	s6,0x6
    80000ce0:	43cb0b13          	addi	s6,s6,1084 # 80007118 <etext+0x118>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000ce4:	8aa6                	mv	s5,s1
    80000ce6:	00e12937          	lui	s2,0xe12
    80000cea:	27f90913          	addi	s2,s2,639 # e1227f <_entry-0x7f1edd81>
    80000cee:	0936                	slli	s2,s2,0xd
    80000cf0:	2f390913          	addi	s2,s2,755
    80000cf4:	0932                	slli	s2,s2,0xc
    80000cf6:	4a790913          	addi	s2,s2,1191
    80000cfa:	093a                	slli	s2,s2,0xe
    80000cfc:	24590913          	addi	s2,s2,581
    80000d00:	040009b7          	lui	s3,0x4000
    80000d04:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000d06:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d08:	0001ba17          	auipc	s4,0x1b
    80000d0c:	528a0a13          	addi	s4,s4,1320 # 8001c230 <tickslock>
      initlock(&p->lock, "proc");
    80000d10:	85da                	mv	a1,s6
    80000d12:	8526                	mv	a0,s1
    80000d14:	056050ef          	jal	80005d6a <initlock>
      p->state = UNUSED;
    80000d18:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000d1c:	415487b3          	sub	a5,s1,s5
    80000d20:	878d                	srai	a5,a5,0x3
    80000d22:	032787b3          	mul	a5,a5,s2
    80000d26:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffcf919>
    80000d28:	00d7979b          	slliw	a5,a5,0xd
    80000d2c:	40f987b3          	sub	a5,s3,a5
    80000d30:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d32:	46848493          	addi	s1,s1,1128
    80000d36:	fd449de3          	bne	s1,s4,80000d10 <procinit+0x78>
  }
}
    80000d3a:	70e2                	ld	ra,56(sp)
    80000d3c:	7442                	ld	s0,48(sp)
    80000d3e:	74a2                	ld	s1,40(sp)
    80000d40:	7902                	ld	s2,32(sp)
    80000d42:	69e2                	ld	s3,24(sp)
    80000d44:	6a42                	ld	s4,16(sp)
    80000d46:	6aa2                	ld	s5,8(sp)
    80000d48:	6b02                	ld	s6,0(sp)
    80000d4a:	6121                	addi	sp,sp,64
    80000d4c:	8082                	ret

0000000080000d4e <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000d4e:	1141                	addi	sp,sp,-16
    80000d50:	e422                	sd	s0,8(sp)
    80000d52:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000d54:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000d56:	2501                	sext.w	a0,a0
    80000d58:	6422                	ld	s0,8(sp)
    80000d5a:	0141                	addi	sp,sp,16
    80000d5c:	8082                	ret

0000000080000d5e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000d5e:	1141                	addi	sp,sp,-16
    80000d60:	e422                	sd	s0,8(sp)
    80000d62:	0800                	addi	s0,sp,16
    80000d64:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000d66:	2781                	sext.w	a5,a5
    80000d68:	079e                	slli	a5,a5,0x7
  return c;
}
    80000d6a:	00009517          	auipc	a0,0x9
    80000d6e:	6c650513          	addi	a0,a0,1734 # 8000a430 <cpus>
    80000d72:	953e                	add	a0,a0,a5
    80000d74:	6422                	ld	s0,8(sp)
    80000d76:	0141                	addi	sp,sp,16
    80000d78:	8082                	ret

0000000080000d7a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000d7a:	1101                	addi	sp,sp,-32
    80000d7c:	ec06                	sd	ra,24(sp)
    80000d7e:	e822                	sd	s0,16(sp)
    80000d80:	e426                	sd	s1,8(sp)
    80000d82:	1000                	addi	s0,sp,32
  push_off();
    80000d84:	026050ef          	jal	80005daa <push_off>
    80000d88:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000d8a:	2781                	sext.w	a5,a5
    80000d8c:	079e                	slli	a5,a5,0x7
    80000d8e:	00009717          	auipc	a4,0x9
    80000d92:	67270713          	addi	a4,a4,1650 # 8000a400 <pid_lock>
    80000d96:	97ba                	add	a5,a5,a4
    80000d98:	7b84                	ld	s1,48(a5)
  pop_off();
    80000d9a:	094050ef          	jal	80005e2e <pop_off>
  return p;
}
    80000d9e:	8526                	mv	a0,s1
    80000da0:	60e2                	ld	ra,24(sp)
    80000da2:	6442                	ld	s0,16(sp)
    80000da4:	64a2                	ld	s1,8(sp)
    80000da6:	6105                	addi	sp,sp,32
    80000da8:	8082                	ret

0000000080000daa <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000daa:	7179                	addi	sp,sp,-48
    80000dac:	f406                	sd	ra,40(sp)
    80000dae:	f022                	sd	s0,32(sp)
    80000db0:	ec26                	sd	s1,24(sp)
    80000db2:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80000db4:	fc7ff0ef          	jal	80000d7a <myproc>
    80000db8:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80000dba:	0c8050ef          	jal	80005e82 <release>

  if (first) {
    80000dbe:	00009797          	auipc	a5,0x9
    80000dc2:	5c27a783          	lw	a5,1474(a5) # 8000a380 <first.1>
    80000dc6:	cf8d                	beqz	a5,80000e00 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80000dc8:	4505                	li	a0,1
    80000dca:	69d010ef          	jal	80002c66 <fsinit>

    first = 0;
    80000dce:	00009797          	auipc	a5,0x9
    80000dd2:	5a07a923          	sw	zero,1458(a5) # 8000a380 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80000dd6:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80000dda:	00006517          	auipc	a0,0x6
    80000dde:	34650513          	addi	a0,a0,838 # 80007120 <etext+0x120>
    80000de2:	fca43823          	sd	a0,-48(s0)
    80000de6:	fc043c23          	sd	zero,-40(s0)
    80000dea:	fd040593          	addi	a1,s0,-48
    80000dee:	779020ef          	jal	80003d66 <kexec>
    80000df2:	6cbc                	ld	a5,88(s1)
    80000df4:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80000df6:	6cbc                	ld	a5,88(s1)
    80000df8:	7bb8                	ld	a4,112(a5)
    80000dfa:	57fd                	li	a5,-1
    80000dfc:	02f70d63          	beq	a4,a5,80000e36 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80000e00:	4f3000ef          	jal	80001af2 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80000e04:	68a8                	ld	a0,80(s1)
    80000e06:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80000e08:	04000737          	lui	a4,0x4000
    80000e0c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80000e0e:	0732                	slli	a4,a4,0xc
    80000e10:	00005797          	auipc	a5,0x5
    80000e14:	28c78793          	addi	a5,a5,652 # 8000609c <userret>
    80000e18:	00005697          	auipc	a3,0x5
    80000e1c:	1e868693          	addi	a3,a3,488 # 80006000 <_trampoline>
    80000e20:	8f95                	sub	a5,a5,a3
    80000e22:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80000e24:	577d                	li	a4,-1
    80000e26:	177e                	slli	a4,a4,0x3f
    80000e28:	8d59                	or	a0,a0,a4
    80000e2a:	9782                	jalr	a5
}
    80000e2c:	70a2                	ld	ra,40(sp)
    80000e2e:	7402                	ld	s0,32(sp)
    80000e30:	64e2                	ld	s1,24(sp)
    80000e32:	6145                	addi	sp,sp,48
    80000e34:	8082                	ret
      panic("exec");
    80000e36:	00006517          	auipc	a0,0x6
    80000e3a:	2f250513          	addi	a0,a0,754 # 80007128 <etext+0x128>
    80000e3e:	4f1040ef          	jal	80005b2e <panic>

0000000080000e42 <allocpid>:
{
    80000e42:	1101                	addi	sp,sp,-32
    80000e44:	ec06                	sd	ra,24(sp)
    80000e46:	e822                	sd	s0,16(sp)
    80000e48:	e426                	sd	s1,8(sp)
    80000e4a:	e04a                	sd	s2,0(sp)
    80000e4c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000e4e:	00009917          	auipc	s2,0x9
    80000e52:	5b290913          	addi	s2,s2,1458 # 8000a400 <pid_lock>
    80000e56:	854a                	mv	a0,s2
    80000e58:	793040ef          	jal	80005dea <acquire>
  pid = nextpid;
    80000e5c:	00009797          	auipc	a5,0x9
    80000e60:	52878793          	addi	a5,a5,1320 # 8000a384 <nextpid>
    80000e64:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000e66:	0014871b          	addiw	a4,s1,1
    80000e6a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000e6c:	854a                	mv	a0,s2
    80000e6e:	014050ef          	jal	80005e82 <release>
}
    80000e72:	8526                	mv	a0,s1
    80000e74:	60e2                	ld	ra,24(sp)
    80000e76:	6442                	ld	s0,16(sp)
    80000e78:	64a2                	ld	s1,8(sp)
    80000e7a:	6902                	ld	s2,0(sp)
    80000e7c:	6105                	addi	sp,sp,32
    80000e7e:	8082                	ret

0000000080000e80 <proc_pagetable>:
{
    80000e80:	1101                	addi	sp,sp,-32
    80000e82:	ec06                	sd	ra,24(sp)
    80000e84:	e822                	sd	s0,16(sp)
    80000e86:	e426                	sd	s1,8(sp)
    80000e88:	e04a                	sd	s2,0(sp)
    80000e8a:	1000                	addi	s0,sp,32
    80000e8c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000e8e:	fb2ff0ef          	jal	80000640 <uvmcreate>
    80000e92:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000e94:	cd05                	beqz	a0,80000ecc <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000e96:	4729                	li	a4,10
    80000e98:	00005697          	auipc	a3,0x5
    80000e9c:	16868693          	addi	a3,a3,360 # 80006000 <_trampoline>
    80000ea0:	6605                	lui	a2,0x1
    80000ea2:	040005b7          	lui	a1,0x4000
    80000ea6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000ea8:	05b2                	slli	a1,a1,0xc
    80000eaa:	df0ff0ef          	jal	8000049a <mappages>
    80000eae:	02054663          	bltz	a0,80000eda <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000eb2:	4719                	li	a4,6
    80000eb4:	05893683          	ld	a3,88(s2)
    80000eb8:	6605                	lui	a2,0x1
    80000eba:	020005b7          	lui	a1,0x2000
    80000ebe:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000ec0:	05b6                	slli	a1,a1,0xd
    80000ec2:	8526                	mv	a0,s1
    80000ec4:	dd6ff0ef          	jal	8000049a <mappages>
    80000ec8:	00054f63          	bltz	a0,80000ee6 <proc_pagetable+0x66>
}
    80000ecc:	8526                	mv	a0,s1
    80000ece:	60e2                	ld	ra,24(sp)
    80000ed0:	6442                	ld	s0,16(sp)
    80000ed2:	64a2                	ld	s1,8(sp)
    80000ed4:	6902                	ld	s2,0(sp)
    80000ed6:	6105                	addi	sp,sp,32
    80000ed8:	8082                	ret
    uvmfree(pagetable, 0);
    80000eda:	4581                	li	a1,0
    80000edc:	8526                	mv	a0,s1
    80000ede:	95dff0ef          	jal	8000083a <uvmfree>
    return 0;
    80000ee2:	4481                	li	s1,0
    80000ee4:	b7e5                	j	80000ecc <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000ee6:	4681                	li	a3,0
    80000ee8:	4605                	li	a2,1
    80000eea:	040005b7          	lui	a1,0x4000
    80000eee:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000ef0:	05b2                	slli	a1,a1,0xc
    80000ef2:	8526                	mv	a0,s1
    80000ef4:	f72ff0ef          	jal	80000666 <uvmunmap>
    uvmfree(pagetable, 0);
    80000ef8:	4581                	li	a1,0
    80000efa:	8526                	mv	a0,s1
    80000efc:	93fff0ef          	jal	8000083a <uvmfree>
    return 0;
    80000f00:	4481                	li	s1,0
    80000f02:	b7e9                	j	80000ecc <proc_pagetable+0x4c>

0000000080000f04 <proc_freepagetable>:
{
    80000f04:	1101                	addi	sp,sp,-32
    80000f06:	ec06                	sd	ra,24(sp)
    80000f08:	e822                	sd	s0,16(sp)
    80000f0a:	e426                	sd	s1,8(sp)
    80000f0c:	e04a                	sd	s2,0(sp)
    80000f0e:	1000                	addi	s0,sp,32
    80000f10:	84aa                	mv	s1,a0
    80000f12:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000f14:	4681                	li	a3,0
    80000f16:	4605                	li	a2,1
    80000f18:	040005b7          	lui	a1,0x4000
    80000f1c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f1e:	05b2                	slli	a1,a1,0xc
    80000f20:	f46ff0ef          	jal	80000666 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000f24:	4681                	li	a3,0
    80000f26:	4605                	li	a2,1
    80000f28:	020005b7          	lui	a1,0x2000
    80000f2c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000f2e:	05b6                	slli	a1,a1,0xd
    80000f30:	8526                	mv	a0,s1
    80000f32:	f34ff0ef          	jal	80000666 <uvmunmap>
  uvmfree(pagetable, sz);
    80000f36:	85ca                	mv	a1,s2
    80000f38:	8526                	mv	a0,s1
    80000f3a:	901ff0ef          	jal	8000083a <uvmfree>
}
    80000f3e:	60e2                	ld	ra,24(sp)
    80000f40:	6442                	ld	s0,16(sp)
    80000f42:	64a2                	ld	s1,8(sp)
    80000f44:	6902                	ld	s2,0(sp)
    80000f46:	6105                	addi	sp,sp,32
    80000f48:	8082                	ret

0000000080000f4a <freeproc>:
{
    80000f4a:	1101                	addi	sp,sp,-32
    80000f4c:	ec06                	sd	ra,24(sp)
    80000f4e:	e822                	sd	s0,16(sp)
    80000f50:	e426                	sd	s1,8(sp)
    80000f52:	1000                	addi	s0,sp,32
    80000f54:	84aa                	mv	s1,a0
  if(p->trapframe)
    80000f56:	6d28                	ld	a0,88(a0)
    80000f58:	c119                	beqz	a0,80000f5e <freeproc+0x14>
    kfree((void*)p->trapframe);
    80000f5a:	8c2ff0ef          	jal	8000001c <kfree>
  p->trapframe = 0;
    80000f5e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80000f62:	68a8                	ld	a0,80(s1)
    80000f64:	c501                	beqz	a0,80000f6c <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80000f66:	64ac                	ld	a1,72(s1)
    80000f68:	f9dff0ef          	jal	80000f04 <proc_freepagetable>
  p->pagetable = 0;
    80000f6c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80000f70:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80000f74:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80000f78:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80000f7c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80000f80:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80000f84:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80000f88:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80000f8c:	0004ac23          	sw	zero,24(s1)
}
    80000f90:	60e2                	ld	ra,24(sp)
    80000f92:	6442                	ld	s0,16(sp)
    80000f94:	64a2                	ld	s1,8(sp)
    80000f96:	6105                	addi	sp,sp,32
    80000f98:	8082                	ret

0000000080000f9a <allocproc>:
{
    80000f9a:	1101                	addi	sp,sp,-32
    80000f9c:	ec06                	sd	ra,24(sp)
    80000f9e:	e822                	sd	s0,16(sp)
    80000fa0:	e426                	sd	s1,8(sp)
    80000fa2:	e04a                	sd	s2,0(sp)
    80000fa4:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fa6:	0000a497          	auipc	s1,0xa
    80000faa:	88a48493          	addi	s1,s1,-1910 # 8000a830 <proc>
    80000fae:	0001b917          	auipc	s2,0x1b
    80000fb2:	28290913          	addi	s2,s2,642 # 8001c230 <tickslock>
    acquire(&p->lock);
    80000fb6:	8526                	mv	a0,s1
    80000fb8:	633040ef          	jal	80005dea <acquire>
    if(p->state == UNUSED) {
    80000fbc:	4c9c                	lw	a5,24(s1)
    80000fbe:	cb91                	beqz	a5,80000fd2 <allocproc+0x38>
      release(&p->lock);
    80000fc0:	8526                	mv	a0,s1
    80000fc2:	6c1040ef          	jal	80005e82 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fc6:	46848493          	addi	s1,s1,1128
    80000fca:	ff2496e3          	bne	s1,s2,80000fb6 <allocproc+0x1c>
  return 0;
    80000fce:	4481                	li	s1,0
    80000fd0:	a899                	j	80001026 <allocproc+0x8c>
  p->pid = allocpid();
    80000fd2:	e71ff0ef          	jal	80000e42 <allocpid>
    80000fd6:	d888                	sw	a0,48(s1)
  p->state = USED;
    80000fd8:	4785                	li	a5,1
    80000fda:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80000fdc:	922ff0ef          	jal	800000fe <kalloc>
    80000fe0:	892a                	mv	s2,a0
    80000fe2:	eca8                	sd	a0,88(s1)
    80000fe4:	c921                	beqz	a0,80001034 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80000fe6:	8526                	mv	a0,s1
    80000fe8:	e99ff0ef          	jal	80000e80 <proc_pagetable>
    80000fec:	892a                	mv	s2,a0
    80000fee:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80000ff0:	c931                	beqz	a0,80001044 <allocproc+0xaa>
  memset(&p->context, 0, sizeof(p->context));
    80000ff2:	07000613          	li	a2,112
    80000ff6:	4581                	li	a1,0
    80000ff8:	06048513          	addi	a0,s1,96
    80000ffc:	952ff0ef          	jal	8000014e <memset>
  p->context.ra = (uint64)forkret;
    80001000:	00000797          	auipc	a5,0x0
    80001004:	daa78793          	addi	a5,a5,-598 # 80000daa <forkret>
    80001008:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    8000100a:	60bc                	ld	a5,64(s1)
    8000100c:	6705                	lui	a4,0x1
    8000100e:	97ba                	add	a5,a5,a4
    80001010:	f4bc                	sd	a5,104(s1)
  for (int i = 0; i < VMA_COUNT; i ++) {
    80001012:	16848793          	addi	a5,s1,360
    80001016:	46848713          	addi	a4,s1,1128
    p->vmas[i].is_used = 0;
    8000101a:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < VMA_COUNT; i ++) {
    8000101e:	03078793          	addi	a5,a5,48
    80001022:	fee79ce3          	bne	a5,a4,8000101a <allocproc+0x80>
}
    80001026:	8526                	mv	a0,s1
    80001028:	60e2                	ld	ra,24(sp)
    8000102a:	6442                	ld	s0,16(sp)
    8000102c:	64a2                	ld	s1,8(sp)
    8000102e:	6902                	ld	s2,0(sp)
    80001030:	6105                	addi	sp,sp,32
    80001032:	8082                	ret
    freeproc(p);
    80001034:	8526                	mv	a0,s1
    80001036:	f15ff0ef          	jal	80000f4a <freeproc>
    release(&p->lock);
    8000103a:	8526                	mv	a0,s1
    8000103c:	647040ef          	jal	80005e82 <release>
    return 0;
    80001040:	84ca                	mv	s1,s2
    80001042:	b7d5                	j	80001026 <allocproc+0x8c>
    freeproc(p);
    80001044:	8526                	mv	a0,s1
    80001046:	f05ff0ef          	jal	80000f4a <freeproc>
    release(&p->lock);
    8000104a:	8526                	mv	a0,s1
    8000104c:	637040ef          	jal	80005e82 <release>
    return 0;
    80001050:	84ca                	mv	s1,s2
    80001052:	bfd1                	j	80001026 <allocproc+0x8c>

0000000080001054 <userinit>:
{
    80001054:	1101                	addi	sp,sp,-32
    80001056:	ec06                	sd	ra,24(sp)
    80001058:	e822                	sd	s0,16(sp)
    8000105a:	e426                	sd	s1,8(sp)
    8000105c:	1000                	addi	s0,sp,32
  p = allocproc();
    8000105e:	f3dff0ef          	jal	80000f9a <allocproc>
    80001062:	84aa                	mv	s1,a0
  initproc = p;
    80001064:	00009797          	auipc	a5,0x9
    80001068:	34a7be23          	sd	a0,860(a5) # 8000a3c0 <initproc>
  p->cwd = namei("/");
    8000106c:	00006517          	auipc	a0,0x6
    80001070:	0c450513          	addi	a0,a0,196 # 80007130 <etext+0x130>
    80001074:	114020ef          	jal	80003188 <namei>
    80001078:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000107c:	478d                	li	a5,3
    8000107e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001080:	8526                	mv	a0,s1
    80001082:	601040ef          	jal	80005e82 <release>
}
    80001086:	60e2                	ld	ra,24(sp)
    80001088:	6442                	ld	s0,16(sp)
    8000108a:	64a2                	ld	s1,8(sp)
    8000108c:	6105                	addi	sp,sp,32
    8000108e:	8082                	ret

0000000080001090 <growproc>:
{
    80001090:	1101                	addi	sp,sp,-32
    80001092:	ec06                	sd	ra,24(sp)
    80001094:	e822                	sd	s0,16(sp)
    80001096:	e426                	sd	s1,8(sp)
    80001098:	e04a                	sd	s2,0(sp)
    8000109a:	1000                	addi	s0,sp,32
    8000109c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000109e:	cddff0ef          	jal	80000d7a <myproc>
    800010a2:	84aa                	mv	s1,a0
  sz = p->sz;
    800010a4:	652c                	ld	a1,72(a0)
  if(n > 0){
    800010a6:	01204c63          	bgtz	s2,800010be <growproc+0x2e>
  } else if(n < 0){
    800010aa:	02094463          	bltz	s2,800010d2 <growproc+0x42>
  p->sz = sz;
    800010ae:	e4ac                	sd	a1,72(s1)
  return 0;
    800010b0:	4501                	li	a0,0
}
    800010b2:	60e2                	ld	ra,24(sp)
    800010b4:	6442                	ld	s0,16(sp)
    800010b6:	64a2                	ld	s1,8(sp)
    800010b8:	6902                	ld	s2,0(sp)
    800010ba:	6105                	addi	sp,sp,32
    800010bc:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800010be:	4691                	li	a3,4
    800010c0:	00b90633          	add	a2,s2,a1
    800010c4:	6928                	ld	a0,80(a0)
    800010c6:	e6eff0ef          	jal	80000734 <uvmalloc>
    800010ca:	85aa                	mv	a1,a0
    800010cc:	f16d                	bnez	a0,800010ae <growproc+0x1e>
      return -1;
    800010ce:	557d                	li	a0,-1
    800010d0:	b7cd                	j	800010b2 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800010d2:	00b90633          	add	a2,s2,a1
    800010d6:	6928                	ld	a0,80(a0)
    800010d8:	e18ff0ef          	jal	800006f0 <uvmdealloc>
    800010dc:	85aa                	mv	a1,a0
    800010de:	bfc1                	j	800010ae <growproc+0x1e>

00000000800010e0 <kfork>:
{
    800010e0:	7139                	addi	sp,sp,-64
    800010e2:	fc06                	sd	ra,56(sp)
    800010e4:	f822                	sd	s0,48(sp)
    800010e6:	f04a                	sd	s2,32(sp)
    800010e8:	e852                	sd	s4,16(sp)
    800010ea:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800010ec:	c8fff0ef          	jal	80000d7a <myproc>
    800010f0:	8a2a                	mv	s4,a0
  if((np = allocproc()) == 0){
    800010f2:	ea9ff0ef          	jal	80000f9a <allocproc>
    800010f6:	12050f63          	beqz	a0,80001234 <kfork+0x154>
    800010fa:	ec4e                	sd	s3,24(sp)
    800010fc:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800010fe:	048a3603          	ld	a2,72(s4)
    80001102:	692c                	ld	a1,80(a0)
    80001104:	050a3503          	ld	a0,80(s4)
    80001108:	f64ff0ef          	jal	8000086c <uvmcopy>
    8000110c:	00054b63          	bltz	a0,80001122 <kfork+0x42>
    80001110:	f426                	sd	s1,40(sp)
    80001112:	e456                	sd	s5,8(sp)
    80001114:	168a0913          	addi	s2,s4,360
    80001118:	16898493          	addi	s1,s3,360
    8000111c:	46898a93          	addi	s5,s3,1128
    80001120:	a005                	j	80001140 <kfork+0x60>
    freeproc(np);
    80001122:	854e                	mv	a0,s3
    80001124:	e27ff0ef          	jal	80000f4a <freeproc>
    release(&np->lock);
    80001128:	854e                	mv	a0,s3
    8000112a:	559040ef          	jal	80005e82 <release>
    return -1;
    8000112e:	597d                	li	s2,-1
    80001130:	69e2                	ld	s3,24(sp)
    80001132:	a8d5                	j	80001226 <kfork+0x146>
  for (int i = 0; i < VMA_COUNT; i ++) {
    80001134:	03090913          	addi	s2,s2,48
    80001138:	03048493          	addi	s1,s1,48
    8000113c:	03548a63          	beq	s1,s5,80001170 <kfork+0x90>
    np->vmas[i] = p->vmas[i];
    80001140:	00093783          	ld	a5,0(s2)
    80001144:	00893503          	ld	a0,8(s2)
    80001148:	01093583          	ld	a1,16(s2)
    8000114c:	01893603          	ld	a2,24(s2)
    80001150:	02093683          	ld	a3,32(s2)
    80001154:	02893703          	ld	a4,40(s2)
    80001158:	e09c                	sd	a5,0(s1)
    8000115a:	e488                	sd	a0,8(s1)
    8000115c:	e88c                	sd	a1,16(s1)
    8000115e:	ec90                	sd	a2,24(s1)
    80001160:	f094                	sd	a3,32(s1)
    80001162:	f498                	sd	a4,40(s1)
    if (np->vmas[i].is_used) {
    80001164:	2781                	sext.w	a5,a5
    80001166:	d7f9                	beqz	a5,80001134 <kfork+0x54>
      filedup(np->vmas[i].file);
    80001168:	8536                	mv	a0,a3
    8000116a:	5b8020ef          	jal	80003722 <filedup>
    8000116e:	b7d9                	j	80001134 <kfork+0x54>
  np->sz = p->sz;
    80001170:	048a3783          	ld	a5,72(s4)
    80001174:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001178:	058a3683          	ld	a3,88(s4)
    8000117c:	87b6                	mv	a5,a3
    8000117e:	0589b703          	ld	a4,88(s3)
    80001182:	12068693          	addi	a3,a3,288
    80001186:	0007b803          	ld	a6,0(a5)
    8000118a:	6788                	ld	a0,8(a5)
    8000118c:	6b8c                	ld	a1,16(a5)
    8000118e:	6f90                	ld	a2,24(a5)
    80001190:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001194:	e708                	sd	a0,8(a4)
    80001196:	eb0c                	sd	a1,16(a4)
    80001198:	ef10                	sd	a2,24(a4)
    8000119a:	02078793          	addi	a5,a5,32
    8000119e:	02070713          	addi	a4,a4,32
    800011a2:	fed792e3          	bne	a5,a3,80001186 <kfork+0xa6>
  np->trapframe->a0 = 0;
    800011a6:	0589b783          	ld	a5,88(s3)
    800011aa:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800011ae:	0d0a0493          	addi	s1,s4,208
    800011b2:	0d098913          	addi	s2,s3,208
    800011b6:	150a0a93          	addi	s5,s4,336
    800011ba:	a029                	j	800011c4 <kfork+0xe4>
    800011bc:	04a1                	addi	s1,s1,8
    800011be:	0921                	addi	s2,s2,8
    800011c0:	01548963          	beq	s1,s5,800011d2 <kfork+0xf2>
    if(p->ofile[i])
    800011c4:	6088                	ld	a0,0(s1)
    800011c6:	d97d                	beqz	a0,800011bc <kfork+0xdc>
      np->ofile[i] = filedup(p->ofile[i]);
    800011c8:	55a020ef          	jal	80003722 <filedup>
    800011cc:	00a93023          	sd	a0,0(s2)
    800011d0:	b7f5                	j	800011bc <kfork+0xdc>
  np->cwd = idup(p->cwd);
    800011d2:	150a3503          	ld	a0,336(s4)
    800011d6:	766010ef          	jal	8000293c <idup>
    800011da:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800011de:	4641                	li	a2,16
    800011e0:	158a0593          	addi	a1,s4,344
    800011e4:	15898513          	addi	a0,s3,344
    800011e8:	8a4ff0ef          	jal	8000028c <safestrcpy>
  pid = np->pid;
    800011ec:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    800011f0:	854e                	mv	a0,s3
    800011f2:	491040ef          	jal	80005e82 <release>
  acquire(&wait_lock);
    800011f6:	00009497          	auipc	s1,0x9
    800011fa:	22248493          	addi	s1,s1,546 # 8000a418 <wait_lock>
    800011fe:	8526                	mv	a0,s1
    80001200:	3eb040ef          	jal	80005dea <acquire>
  np->parent = p;
    80001204:	0349bc23          	sd	s4,56(s3)
  release(&wait_lock);
    80001208:	8526                	mv	a0,s1
    8000120a:	479040ef          	jal	80005e82 <release>
  acquire(&np->lock);
    8000120e:	854e                	mv	a0,s3
    80001210:	3db040ef          	jal	80005dea <acquire>
  np->state = RUNNABLE;
    80001214:	478d                	li	a5,3
    80001216:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000121a:	854e                	mv	a0,s3
    8000121c:	467040ef          	jal	80005e82 <release>
  return pid;
    80001220:	74a2                	ld	s1,40(sp)
    80001222:	69e2                	ld	s3,24(sp)
    80001224:	6aa2                	ld	s5,8(sp)
}
    80001226:	854a                	mv	a0,s2
    80001228:	70e2                	ld	ra,56(sp)
    8000122a:	7442                	ld	s0,48(sp)
    8000122c:	7902                	ld	s2,32(sp)
    8000122e:	6a42                	ld	s4,16(sp)
    80001230:	6121                	addi	sp,sp,64
    80001232:	8082                	ret
    return -1;
    80001234:	597d                	li	s2,-1
    80001236:	bfc5                	j	80001226 <kfork+0x146>

0000000080001238 <scheduler>:
{
    80001238:	715d                	addi	sp,sp,-80
    8000123a:	e486                	sd	ra,72(sp)
    8000123c:	e0a2                	sd	s0,64(sp)
    8000123e:	fc26                	sd	s1,56(sp)
    80001240:	f84a                	sd	s2,48(sp)
    80001242:	f44e                	sd	s3,40(sp)
    80001244:	f052                	sd	s4,32(sp)
    80001246:	ec56                	sd	s5,24(sp)
    80001248:	e85a                	sd	s6,16(sp)
    8000124a:	e45e                	sd	s7,8(sp)
    8000124c:	e062                	sd	s8,0(sp)
    8000124e:	0880                	addi	s0,sp,80
    80001250:	8792                	mv	a5,tp
  int id = r_tp();
    80001252:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001254:	00779b13          	slli	s6,a5,0x7
    80001258:	00009717          	auipc	a4,0x9
    8000125c:	1a870713          	addi	a4,a4,424 # 8000a400 <pid_lock>
    80001260:	975a                	add	a4,a4,s6
    80001262:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001266:	00009717          	auipc	a4,0x9
    8000126a:	1d270713          	addi	a4,a4,466 # 8000a438 <cpus+0x8>
    8000126e:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001270:	4c11                	li	s8,4
        c->proc = p;
    80001272:	079e                	slli	a5,a5,0x7
    80001274:	00009a17          	auipc	s4,0x9
    80001278:	18ca0a13          	addi	s4,s4,396 # 8000a400 <pid_lock>
    8000127c:	9a3e                	add	s4,s4,a5
        found = 1;
    8000127e:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001280:	0001b997          	auipc	s3,0x1b
    80001284:	fb098993          	addi	s3,s3,-80 # 8001c230 <tickslock>
    80001288:	a83d                	j	800012c6 <scheduler+0x8e>
      release(&p->lock);
    8000128a:	8526                	mv	a0,s1
    8000128c:	3f7040ef          	jal	80005e82 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001290:	46848493          	addi	s1,s1,1128
    80001294:	03348563          	beq	s1,s3,800012be <scheduler+0x86>
      acquire(&p->lock);
    80001298:	8526                	mv	a0,s1
    8000129a:	351040ef          	jal	80005dea <acquire>
      if(p->state == RUNNABLE) {
    8000129e:	4c9c                	lw	a5,24(s1)
    800012a0:	ff2795e3          	bne	a5,s2,8000128a <scheduler+0x52>
        p->state = RUNNING;
    800012a4:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    800012a8:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800012ac:	06048593          	addi	a1,s1,96
    800012b0:	855a                	mv	a0,s6
    800012b2:	79a000ef          	jal	80001a4c <swtch>
        c->proc = 0;
    800012b6:	020a3823          	sd	zero,48(s4)
        found = 1;
    800012ba:	8ade                	mv	s5,s7
    800012bc:	b7f9                	j	8000128a <scheduler+0x52>
    if(found == 0) {
    800012be:	000a9463          	bnez	s5,800012c6 <scheduler+0x8e>
      asm volatile("wfi");
    800012c2:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012c6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800012ca:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800012ce:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012d2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800012d6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800012d8:	10079073          	csrw	sstatus,a5
    int found = 0;
    800012dc:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800012de:	00009497          	auipc	s1,0x9
    800012e2:	55248493          	addi	s1,s1,1362 # 8000a830 <proc>
      if(p->state == RUNNABLE) {
    800012e6:	490d                	li	s2,3
    800012e8:	bf45                	j	80001298 <scheduler+0x60>

00000000800012ea <sched>:
{
    800012ea:	7179                	addi	sp,sp,-48
    800012ec:	f406                	sd	ra,40(sp)
    800012ee:	f022                	sd	s0,32(sp)
    800012f0:	ec26                	sd	s1,24(sp)
    800012f2:	e84a                	sd	s2,16(sp)
    800012f4:	e44e                	sd	s3,8(sp)
    800012f6:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800012f8:	a83ff0ef          	jal	80000d7a <myproc>
    800012fc:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800012fe:	283040ef          	jal	80005d80 <holding>
    80001302:	c92d                	beqz	a0,80001374 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001304:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001306:	2781                	sext.w	a5,a5
    80001308:	079e                	slli	a5,a5,0x7
    8000130a:	00009717          	auipc	a4,0x9
    8000130e:	0f670713          	addi	a4,a4,246 # 8000a400 <pid_lock>
    80001312:	97ba                	add	a5,a5,a4
    80001314:	0a87a703          	lw	a4,168(a5)
    80001318:	4785                	li	a5,1
    8000131a:	06f71363          	bne	a4,a5,80001380 <sched+0x96>
  if(p->state == RUNNING)
    8000131e:	4c98                	lw	a4,24(s1)
    80001320:	4791                	li	a5,4
    80001322:	06f70563          	beq	a4,a5,8000138c <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001326:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000132a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000132c:	e7b5                	bnez	a5,80001398 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000132e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001330:	00009917          	auipc	s2,0x9
    80001334:	0d090913          	addi	s2,s2,208 # 8000a400 <pid_lock>
    80001338:	2781                	sext.w	a5,a5
    8000133a:	079e                	slli	a5,a5,0x7
    8000133c:	97ca                	add	a5,a5,s2
    8000133e:	0ac7a983          	lw	s3,172(a5)
    80001342:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001344:	2781                	sext.w	a5,a5
    80001346:	079e                	slli	a5,a5,0x7
    80001348:	00009597          	auipc	a1,0x9
    8000134c:	0f058593          	addi	a1,a1,240 # 8000a438 <cpus+0x8>
    80001350:	95be                	add	a1,a1,a5
    80001352:	06048513          	addi	a0,s1,96
    80001356:	6f6000ef          	jal	80001a4c <swtch>
    8000135a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000135c:	2781                	sext.w	a5,a5
    8000135e:	079e                	slli	a5,a5,0x7
    80001360:	993e                	add	s2,s2,a5
    80001362:	0b392623          	sw	s3,172(s2)
}
    80001366:	70a2                	ld	ra,40(sp)
    80001368:	7402                	ld	s0,32(sp)
    8000136a:	64e2                	ld	s1,24(sp)
    8000136c:	6942                	ld	s2,16(sp)
    8000136e:	69a2                	ld	s3,8(sp)
    80001370:	6145                	addi	sp,sp,48
    80001372:	8082                	ret
    panic("sched p->lock");
    80001374:	00006517          	auipc	a0,0x6
    80001378:	dc450513          	addi	a0,a0,-572 # 80007138 <etext+0x138>
    8000137c:	7b2040ef          	jal	80005b2e <panic>
    panic("sched locks");
    80001380:	00006517          	auipc	a0,0x6
    80001384:	dc850513          	addi	a0,a0,-568 # 80007148 <etext+0x148>
    80001388:	7a6040ef          	jal	80005b2e <panic>
    panic("sched RUNNING");
    8000138c:	00006517          	auipc	a0,0x6
    80001390:	dcc50513          	addi	a0,a0,-564 # 80007158 <etext+0x158>
    80001394:	79a040ef          	jal	80005b2e <panic>
    panic("sched interruptible");
    80001398:	00006517          	auipc	a0,0x6
    8000139c:	dd050513          	addi	a0,a0,-560 # 80007168 <etext+0x168>
    800013a0:	78e040ef          	jal	80005b2e <panic>

00000000800013a4 <yield>:
{
    800013a4:	1101                	addi	sp,sp,-32
    800013a6:	ec06                	sd	ra,24(sp)
    800013a8:	e822                	sd	s0,16(sp)
    800013aa:	e426                	sd	s1,8(sp)
    800013ac:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800013ae:	9cdff0ef          	jal	80000d7a <myproc>
    800013b2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800013b4:	237040ef          	jal	80005dea <acquire>
  p->state = RUNNABLE;
    800013b8:	478d                	li	a5,3
    800013ba:	cc9c                	sw	a5,24(s1)
  sched();
    800013bc:	f2fff0ef          	jal	800012ea <sched>
  release(&p->lock);
    800013c0:	8526                	mv	a0,s1
    800013c2:	2c1040ef          	jal	80005e82 <release>
}
    800013c6:	60e2                	ld	ra,24(sp)
    800013c8:	6442                	ld	s0,16(sp)
    800013ca:	64a2                	ld	s1,8(sp)
    800013cc:	6105                	addi	sp,sp,32
    800013ce:	8082                	ret

00000000800013d0 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800013d0:	7179                	addi	sp,sp,-48
    800013d2:	f406                	sd	ra,40(sp)
    800013d4:	f022                	sd	s0,32(sp)
    800013d6:	ec26                	sd	s1,24(sp)
    800013d8:	e84a                	sd	s2,16(sp)
    800013da:	e44e                	sd	s3,8(sp)
    800013dc:	1800                	addi	s0,sp,48
    800013de:	89aa                	mv	s3,a0
    800013e0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800013e2:	999ff0ef          	jal	80000d7a <myproc>
    800013e6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800013e8:	203040ef          	jal	80005dea <acquire>
  release(lk);
    800013ec:	854a                	mv	a0,s2
    800013ee:	295040ef          	jal	80005e82 <release>

  // Go to sleep.
  p->chan = chan;
    800013f2:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800013f6:	4789                	li	a5,2
    800013f8:	cc9c                	sw	a5,24(s1)

  sched();
    800013fa:	ef1ff0ef          	jal	800012ea <sched>

  // Tidy up.
  p->chan = 0;
    800013fe:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001402:	8526                	mv	a0,s1
    80001404:	27f040ef          	jal	80005e82 <release>
  acquire(lk);
    80001408:	854a                	mv	a0,s2
    8000140a:	1e1040ef          	jal	80005dea <acquire>
}
    8000140e:	70a2                	ld	ra,40(sp)
    80001410:	7402                	ld	s0,32(sp)
    80001412:	64e2                	ld	s1,24(sp)
    80001414:	6942                	ld	s2,16(sp)
    80001416:	69a2                	ld	s3,8(sp)
    80001418:	6145                	addi	sp,sp,48
    8000141a:	8082                	ret

000000008000141c <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000141c:	7139                	addi	sp,sp,-64
    8000141e:	fc06                	sd	ra,56(sp)
    80001420:	f822                	sd	s0,48(sp)
    80001422:	f426                	sd	s1,40(sp)
    80001424:	f04a                	sd	s2,32(sp)
    80001426:	ec4e                	sd	s3,24(sp)
    80001428:	e852                	sd	s4,16(sp)
    8000142a:	e456                	sd	s5,8(sp)
    8000142c:	0080                	addi	s0,sp,64
    8000142e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001430:	00009497          	auipc	s1,0x9
    80001434:	40048493          	addi	s1,s1,1024 # 8000a830 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001438:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000143a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000143c:	0001b917          	auipc	s2,0x1b
    80001440:	df490913          	addi	s2,s2,-524 # 8001c230 <tickslock>
    80001444:	a801                	j	80001454 <wakeup+0x38>
      }
      release(&p->lock);
    80001446:	8526                	mv	a0,s1
    80001448:	23b040ef          	jal	80005e82 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000144c:	46848493          	addi	s1,s1,1128
    80001450:	03248263          	beq	s1,s2,80001474 <wakeup+0x58>
    if(p != myproc()){
    80001454:	927ff0ef          	jal	80000d7a <myproc>
    80001458:	fea48ae3          	beq	s1,a0,8000144c <wakeup+0x30>
      acquire(&p->lock);
    8000145c:	8526                	mv	a0,s1
    8000145e:	18d040ef          	jal	80005dea <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001462:	4c9c                	lw	a5,24(s1)
    80001464:	ff3791e3          	bne	a5,s3,80001446 <wakeup+0x2a>
    80001468:	709c                	ld	a5,32(s1)
    8000146a:	fd479ee3          	bne	a5,s4,80001446 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000146e:	0154ac23          	sw	s5,24(s1)
    80001472:	bfd1                	j	80001446 <wakeup+0x2a>
    }
  }
}
    80001474:	70e2                	ld	ra,56(sp)
    80001476:	7442                	ld	s0,48(sp)
    80001478:	74a2                	ld	s1,40(sp)
    8000147a:	7902                	ld	s2,32(sp)
    8000147c:	69e2                	ld	s3,24(sp)
    8000147e:	6a42                	ld	s4,16(sp)
    80001480:	6aa2                	ld	s5,8(sp)
    80001482:	6121                	addi	sp,sp,64
    80001484:	8082                	ret

0000000080001486 <reparent>:
{
    80001486:	7179                	addi	sp,sp,-48
    80001488:	f406                	sd	ra,40(sp)
    8000148a:	f022                	sd	s0,32(sp)
    8000148c:	ec26                	sd	s1,24(sp)
    8000148e:	e84a                	sd	s2,16(sp)
    80001490:	e44e                	sd	s3,8(sp)
    80001492:	e052                	sd	s4,0(sp)
    80001494:	1800                	addi	s0,sp,48
    80001496:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001498:	00009497          	auipc	s1,0x9
    8000149c:	39848493          	addi	s1,s1,920 # 8000a830 <proc>
      pp->parent = initproc;
    800014a0:	00009a17          	auipc	s4,0x9
    800014a4:	f20a0a13          	addi	s4,s4,-224 # 8000a3c0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800014a8:	0001b997          	auipc	s3,0x1b
    800014ac:	d8898993          	addi	s3,s3,-632 # 8001c230 <tickslock>
    800014b0:	a029                	j	800014ba <reparent+0x34>
    800014b2:	46848493          	addi	s1,s1,1128
    800014b6:	01348b63          	beq	s1,s3,800014cc <reparent+0x46>
    if(pp->parent == p){
    800014ba:	7c9c                	ld	a5,56(s1)
    800014bc:	ff279be3          	bne	a5,s2,800014b2 <reparent+0x2c>
      pp->parent = initproc;
    800014c0:	000a3503          	ld	a0,0(s4)
    800014c4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800014c6:	f57ff0ef          	jal	8000141c <wakeup>
    800014ca:	b7e5                	j	800014b2 <reparent+0x2c>
}
    800014cc:	70a2                	ld	ra,40(sp)
    800014ce:	7402                	ld	s0,32(sp)
    800014d0:	64e2                	ld	s1,24(sp)
    800014d2:	6942                	ld	s2,16(sp)
    800014d4:	69a2                	ld	s3,8(sp)
    800014d6:	6a02                	ld	s4,0(sp)
    800014d8:	6145                	addi	sp,sp,48
    800014da:	8082                	ret

00000000800014dc <kexit>:
{
    800014dc:	7139                	addi	sp,sp,-64
    800014de:	fc06                	sd	ra,56(sp)
    800014e0:	f822                	sd	s0,48(sp)
    800014e2:	f426                	sd	s1,40(sp)
    800014e4:	f04a                	sd	s2,32(sp)
    800014e6:	ec4e                	sd	s3,24(sp)
    800014e8:	e852                	sd	s4,16(sp)
    800014ea:	0080                	addi	s0,sp,64
    800014ec:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800014ee:	88dff0ef          	jal	80000d7a <myproc>
    800014f2:	89aa                	mv	s3,a0
  if(p == initproc)
    800014f4:	00009797          	auipc	a5,0x9
    800014f8:	ecc7b783          	ld	a5,-308(a5) # 8000a3c0 <initproc>
    800014fc:	0d050493          	addi	s1,a0,208
    80001500:	15050913          	addi	s2,a0,336
    80001504:	00a78463          	beq	a5,a0,8000150c <kexit+0x30>
    80001508:	e456                	sd	s5,8(sp)
    8000150a:	a839                	j	80001528 <kexit+0x4c>
    8000150c:	e456                	sd	s5,8(sp)
    panic("init exiting");
    8000150e:	00006517          	auipc	a0,0x6
    80001512:	c7250513          	addi	a0,a0,-910 # 80007180 <etext+0x180>
    80001516:	618040ef          	jal	80005b2e <panic>
      fileclose(f);
    8000151a:	24e020ef          	jal	80003768 <fileclose>
      p->ofile[fd] = 0;
    8000151e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001522:	04a1                	addi	s1,s1,8
    80001524:	01248563          	beq	s1,s2,8000152e <kexit+0x52>
    if(p->ofile[fd]){
    80001528:	6088                	ld	a0,0(s1)
    8000152a:	f965                	bnez	a0,8000151a <kexit+0x3e>
    8000152c:	bfdd                	j	80001522 <kexit+0x46>
  begin_op();
    8000152e:	62f010ef          	jal	8000335c <begin_op>
  for (int i = 0; i < VMA_COUNT; i ++) {
    80001532:	16898493          	addi	s1,s3,360
    80001536:	46898a93          	addi	s5,s3,1128
    8000153a:	a081                	j	8000157a <kexit+0x9e>
          if (writei(ip, 1, vma->address, file_off, wlen) < 0) {
    8000153c:	00893603          	ld	a2,8(s2)
    80001540:	4585                	li	a1,1
    80001542:	0bd010ef          	jal	80002dfe <writei>
      fileclose(vma->file);
    80001546:	02093503          	ld	a0,32(s2)
    8000154a:	21e020ef          	jal	80003768 <fileclose>
      uvmunmap(p->pagetable, vma->address, vma->length / PGSIZE, 1);
    8000154e:	01092783          	lw	a5,16(s2)
    80001552:	41f7d61b          	sraiw	a2,a5,0x1f
    80001556:	0146561b          	srliw	a2,a2,0x14
    8000155a:	9e3d                	addw	a2,a2,a5
    8000155c:	4685                	li	a3,1
    8000155e:	40c6561b          	sraiw	a2,a2,0xc
    80001562:	00893583          	ld	a1,8(s2)
    80001566:	0509b503          	ld	a0,80(s3)
    8000156a:	8fcff0ef          	jal	80000666 <uvmunmap>
      vma->is_used = 0;
    8000156e:	00092023          	sw	zero,0(s2)
  for (int i = 0; i < VMA_COUNT; i ++) {
    80001572:	03048493          	addi	s1,s1,48
    80001576:	03548963          	beq	s1,s5,800015a8 <kexit+0xcc>
    if (vma->is_used) {
    8000157a:	8926                	mv	s2,s1
    8000157c:	409c                	lw	a5,0(s1)
    8000157e:	dbf5                	beqz	a5,80001572 <kexit+0x96>
      if ((vma->flags & MAP_SHARED) && (vma->prot & PROT_WRITE)) {
    80001580:	4c9c                	lw	a5,24(s1)
    80001582:	8b85                	andi	a5,a5,1
    80001584:	d3e9                	beqz	a5,80001546 <kexit+0x6a>
    80001586:	48dc                	lw	a5,20(s1)
    80001588:	8b89                	andi	a5,a5,2
    8000158a:	dfd5                	beqz	a5,80001546 <kexit+0x6a>
        struct inode *ip = vma->file->ip;
    8000158c:	709c                	ld	a5,32(s1)
    8000158e:	6f88                	ld	a0,24(a5)
        int file_sz = ip->size;
    80001590:	457c                	lw	a5,76(a0)
        int file_off = vma->offset;
    80001592:	5494                	lw	a3,40(s1)
        if (file_off < file_sz) {
    80001594:	faf6d9e3          	bge	a3,a5,80001546 <kexit+0x6a>
        int wlen = vma->length;
    80001598:	4898                	lw	a4,16(s1)
          if (file_off + wlen > file_sz)
    8000159a:	00e6863b          	addw	a2,a3,a4
    8000159e:	f8c7dfe3          	bge	a5,a2,8000153c <kexit+0x60>
            wlen = file_sz - file_off;
    800015a2:	40d7873b          	subw	a4,a5,a3
    800015a6:	bf59                	j	8000153c <kexit+0x60>
  iput(p->cwd);
    800015a8:	1509b503          	ld	a0,336(s3)
    800015ac:	548010ef          	jal	80002af4 <iput>
  end_op();
    800015b0:	617010ef          	jal	800033c6 <end_op>
  p->cwd = 0;
    800015b4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800015b8:	00009497          	auipc	s1,0x9
    800015bc:	e6048493          	addi	s1,s1,-416 # 8000a418 <wait_lock>
    800015c0:	8526                	mv	a0,s1
    800015c2:	029040ef          	jal	80005dea <acquire>
  reparent(p);
    800015c6:	854e                	mv	a0,s3
    800015c8:	ebfff0ef          	jal	80001486 <reparent>
  wakeup(p->parent);
    800015cc:	0389b503          	ld	a0,56(s3)
    800015d0:	e4dff0ef          	jal	8000141c <wakeup>
  acquire(&p->lock);
    800015d4:	854e                	mv	a0,s3
    800015d6:	015040ef          	jal	80005dea <acquire>
  p->xstate = status;
    800015da:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800015de:	4795                	li	a5,5
    800015e0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800015e4:	8526                	mv	a0,s1
    800015e6:	09d040ef          	jal	80005e82 <release>
  sched();
    800015ea:	d01ff0ef          	jal	800012ea <sched>
  panic("zombie exit");
    800015ee:	00006517          	auipc	a0,0x6
    800015f2:	ba250513          	addi	a0,a0,-1118 # 80007190 <etext+0x190>
    800015f6:	538040ef          	jal	80005b2e <panic>

00000000800015fa <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800015fa:	7179                	addi	sp,sp,-48
    800015fc:	f406                	sd	ra,40(sp)
    800015fe:	f022                	sd	s0,32(sp)
    80001600:	ec26                	sd	s1,24(sp)
    80001602:	e84a                	sd	s2,16(sp)
    80001604:	e44e                	sd	s3,8(sp)
    80001606:	1800                	addi	s0,sp,48
    80001608:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000160a:	00009497          	auipc	s1,0x9
    8000160e:	22648493          	addi	s1,s1,550 # 8000a830 <proc>
    80001612:	0001b997          	auipc	s3,0x1b
    80001616:	c1e98993          	addi	s3,s3,-994 # 8001c230 <tickslock>
    acquire(&p->lock);
    8000161a:	8526                	mv	a0,s1
    8000161c:	7ce040ef          	jal	80005dea <acquire>
    if(p->pid == pid){
    80001620:	589c                	lw	a5,48(s1)
    80001622:	01278b63          	beq	a5,s2,80001638 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001626:	8526                	mv	a0,s1
    80001628:	05b040ef          	jal	80005e82 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000162c:	46848493          	addi	s1,s1,1128
    80001630:	ff3495e3          	bne	s1,s3,8000161a <kkill+0x20>
  }
  return -1;
    80001634:	557d                	li	a0,-1
    80001636:	a819                	j	8000164c <kkill+0x52>
      p->killed = 1;
    80001638:	4785                	li	a5,1
    8000163a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000163c:	4c98                	lw	a4,24(s1)
    8000163e:	4789                	li	a5,2
    80001640:	00f70d63          	beq	a4,a5,8000165a <kkill+0x60>
      release(&p->lock);
    80001644:	8526                	mv	a0,s1
    80001646:	03d040ef          	jal	80005e82 <release>
      return 0;
    8000164a:	4501                	li	a0,0
}
    8000164c:	70a2                	ld	ra,40(sp)
    8000164e:	7402                	ld	s0,32(sp)
    80001650:	64e2                	ld	s1,24(sp)
    80001652:	6942                	ld	s2,16(sp)
    80001654:	69a2                	ld	s3,8(sp)
    80001656:	6145                	addi	sp,sp,48
    80001658:	8082                	ret
        p->state = RUNNABLE;
    8000165a:	478d                	li	a5,3
    8000165c:	cc9c                	sw	a5,24(s1)
    8000165e:	b7dd                	j	80001644 <kkill+0x4a>

0000000080001660 <setkilled>:

void
setkilled(struct proc *p)
{
    80001660:	1101                	addi	sp,sp,-32
    80001662:	ec06                	sd	ra,24(sp)
    80001664:	e822                	sd	s0,16(sp)
    80001666:	e426                	sd	s1,8(sp)
    80001668:	1000                	addi	s0,sp,32
    8000166a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000166c:	77e040ef          	jal	80005dea <acquire>
  p->killed = 1;
    80001670:	4785                	li	a5,1
    80001672:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001674:	8526                	mv	a0,s1
    80001676:	00d040ef          	jal	80005e82 <release>
}
    8000167a:	60e2                	ld	ra,24(sp)
    8000167c:	6442                	ld	s0,16(sp)
    8000167e:	64a2                	ld	s1,8(sp)
    80001680:	6105                	addi	sp,sp,32
    80001682:	8082                	ret

0000000080001684 <killed>:

int
killed(struct proc *p)
{
    80001684:	1101                	addi	sp,sp,-32
    80001686:	ec06                	sd	ra,24(sp)
    80001688:	e822                	sd	s0,16(sp)
    8000168a:	e426                	sd	s1,8(sp)
    8000168c:	e04a                	sd	s2,0(sp)
    8000168e:	1000                	addi	s0,sp,32
    80001690:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001692:	758040ef          	jal	80005dea <acquire>
  k = p->killed;
    80001696:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000169a:	8526                	mv	a0,s1
    8000169c:	7e6040ef          	jal	80005e82 <release>
  return k;
}
    800016a0:	854a                	mv	a0,s2
    800016a2:	60e2                	ld	ra,24(sp)
    800016a4:	6442                	ld	s0,16(sp)
    800016a6:	64a2                	ld	s1,8(sp)
    800016a8:	6902                	ld	s2,0(sp)
    800016aa:	6105                	addi	sp,sp,32
    800016ac:	8082                	ret

00000000800016ae <kwait>:
{
    800016ae:	715d                	addi	sp,sp,-80
    800016b0:	e486                	sd	ra,72(sp)
    800016b2:	e0a2                	sd	s0,64(sp)
    800016b4:	fc26                	sd	s1,56(sp)
    800016b6:	f84a                	sd	s2,48(sp)
    800016b8:	f44e                	sd	s3,40(sp)
    800016ba:	f052                	sd	s4,32(sp)
    800016bc:	ec56                	sd	s5,24(sp)
    800016be:	e85a                	sd	s6,16(sp)
    800016c0:	e45e                	sd	s7,8(sp)
    800016c2:	e062                	sd	s8,0(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800016c8:	eb2ff0ef          	jal	80000d7a <myproc>
    800016cc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800016ce:	00009517          	auipc	a0,0x9
    800016d2:	d4a50513          	addi	a0,a0,-694 # 8000a418 <wait_lock>
    800016d6:	714040ef          	jal	80005dea <acquire>
    havekids = 0;
    800016da:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800016dc:	4a15                	li	s4,5
        havekids = 1;
    800016de:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800016e0:	0001b997          	auipc	s3,0x1b
    800016e4:	b5098993          	addi	s3,s3,-1200 # 8001c230 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800016e8:	00009c17          	auipc	s8,0x9
    800016ec:	d30c0c13          	addi	s8,s8,-720 # 8000a418 <wait_lock>
    800016f0:	a871                	j	8000178c <kwait+0xde>
          pid = pp->pid;
    800016f2:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800016f6:	000b0c63          	beqz	s6,8000170e <kwait+0x60>
    800016fa:	4691                	li	a3,4
    800016fc:	02c48613          	addi	a2,s1,44
    80001700:	85da                	mv	a1,s6
    80001702:	05093503          	ld	a0,80(s2)
    80001706:	b88ff0ef          	jal	80000a8e <copyout>
    8000170a:	02054b63          	bltz	a0,80001740 <kwait+0x92>
          freeproc(pp);
    8000170e:	8526                	mv	a0,s1
    80001710:	83bff0ef          	jal	80000f4a <freeproc>
          release(&pp->lock);
    80001714:	8526                	mv	a0,s1
    80001716:	76c040ef          	jal	80005e82 <release>
          release(&wait_lock);
    8000171a:	00009517          	auipc	a0,0x9
    8000171e:	cfe50513          	addi	a0,a0,-770 # 8000a418 <wait_lock>
    80001722:	760040ef          	jal	80005e82 <release>
}
    80001726:	854e                	mv	a0,s3
    80001728:	60a6                	ld	ra,72(sp)
    8000172a:	6406                	ld	s0,64(sp)
    8000172c:	74e2                	ld	s1,56(sp)
    8000172e:	7942                	ld	s2,48(sp)
    80001730:	79a2                	ld	s3,40(sp)
    80001732:	7a02                	ld	s4,32(sp)
    80001734:	6ae2                	ld	s5,24(sp)
    80001736:	6b42                	ld	s6,16(sp)
    80001738:	6ba2                	ld	s7,8(sp)
    8000173a:	6c02                	ld	s8,0(sp)
    8000173c:	6161                	addi	sp,sp,80
    8000173e:	8082                	ret
            release(&pp->lock);
    80001740:	8526                	mv	a0,s1
    80001742:	740040ef          	jal	80005e82 <release>
            release(&wait_lock);
    80001746:	00009517          	auipc	a0,0x9
    8000174a:	cd250513          	addi	a0,a0,-814 # 8000a418 <wait_lock>
    8000174e:	734040ef          	jal	80005e82 <release>
            return -1;
    80001752:	59fd                	li	s3,-1
    80001754:	bfc9                	j	80001726 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001756:	46848493          	addi	s1,s1,1128
    8000175a:	03348063          	beq	s1,s3,8000177a <kwait+0xcc>
      if(pp->parent == p){
    8000175e:	7c9c                	ld	a5,56(s1)
    80001760:	ff279be3          	bne	a5,s2,80001756 <kwait+0xa8>
        acquire(&pp->lock);
    80001764:	8526                	mv	a0,s1
    80001766:	684040ef          	jal	80005dea <acquire>
        if(pp->state == ZOMBIE){
    8000176a:	4c9c                	lw	a5,24(s1)
    8000176c:	f94783e3          	beq	a5,s4,800016f2 <kwait+0x44>
        release(&pp->lock);
    80001770:	8526                	mv	a0,s1
    80001772:	710040ef          	jal	80005e82 <release>
        havekids = 1;
    80001776:	8756                	mv	a4,s5
    80001778:	bff9                	j	80001756 <kwait+0xa8>
    if(!havekids || killed(p)){
    8000177a:	cf19                	beqz	a4,80001798 <kwait+0xea>
    8000177c:	854a                	mv	a0,s2
    8000177e:	f07ff0ef          	jal	80001684 <killed>
    80001782:	e919                	bnez	a0,80001798 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001784:	85e2                	mv	a1,s8
    80001786:	854a                	mv	a0,s2
    80001788:	c49ff0ef          	jal	800013d0 <sleep>
    havekids = 0;
    8000178c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000178e:	00009497          	auipc	s1,0x9
    80001792:	0a248493          	addi	s1,s1,162 # 8000a830 <proc>
    80001796:	b7e1                	j	8000175e <kwait+0xb0>
      release(&wait_lock);
    80001798:	00009517          	auipc	a0,0x9
    8000179c:	c8050513          	addi	a0,a0,-896 # 8000a418 <wait_lock>
    800017a0:	6e2040ef          	jal	80005e82 <release>
      return -1;
    800017a4:	59fd                	li	s3,-1
    800017a6:	b741                	j	80001726 <kwait+0x78>

00000000800017a8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800017a8:	7179                	addi	sp,sp,-48
    800017aa:	f406                	sd	ra,40(sp)
    800017ac:	f022                	sd	s0,32(sp)
    800017ae:	ec26                	sd	s1,24(sp)
    800017b0:	e84a                	sd	s2,16(sp)
    800017b2:	e44e                	sd	s3,8(sp)
    800017b4:	e052                	sd	s4,0(sp)
    800017b6:	1800                	addi	s0,sp,48
    800017b8:	84aa                	mv	s1,a0
    800017ba:	892e                	mv	s2,a1
    800017bc:	89b2                	mv	s3,a2
    800017be:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800017c0:	dbaff0ef          	jal	80000d7a <myproc>
  if(user_dst){
    800017c4:	cc99                	beqz	s1,800017e2 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800017c6:	86d2                	mv	a3,s4
    800017c8:	864e                	mv	a2,s3
    800017ca:	85ca                	mv	a1,s2
    800017cc:	6928                	ld	a0,80(a0)
    800017ce:	ac0ff0ef          	jal	80000a8e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800017d2:	70a2                	ld	ra,40(sp)
    800017d4:	7402                	ld	s0,32(sp)
    800017d6:	64e2                	ld	s1,24(sp)
    800017d8:	6942                	ld	s2,16(sp)
    800017da:	69a2                	ld	s3,8(sp)
    800017dc:	6a02                	ld	s4,0(sp)
    800017de:	6145                	addi	sp,sp,48
    800017e0:	8082                	ret
    memmove((char *)dst, src, len);
    800017e2:	000a061b          	sext.w	a2,s4
    800017e6:	85ce                	mv	a1,s3
    800017e8:	854a                	mv	a0,s2
    800017ea:	9c1fe0ef          	jal	800001aa <memmove>
    return 0;
    800017ee:	8526                	mv	a0,s1
    800017f0:	b7cd                	j	800017d2 <either_copyout+0x2a>

00000000800017f2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800017f2:	7179                	addi	sp,sp,-48
    800017f4:	f406                	sd	ra,40(sp)
    800017f6:	f022                	sd	s0,32(sp)
    800017f8:	ec26                	sd	s1,24(sp)
    800017fa:	e84a                	sd	s2,16(sp)
    800017fc:	e44e                	sd	s3,8(sp)
    800017fe:	e052                	sd	s4,0(sp)
    80001800:	1800                	addi	s0,sp,48
    80001802:	892a                	mv	s2,a0
    80001804:	84ae                	mv	s1,a1
    80001806:	89b2                	mv	s3,a2
    80001808:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000180a:	d70ff0ef          	jal	80000d7a <myproc>
  if(user_src){
    8000180e:	cc99                	beqz	s1,8000182c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001810:	86d2                	mv	a3,s4
    80001812:	864e                	mv	a2,s3
    80001814:	85ca                	mv	a1,s2
    80001816:	6928                	ld	a0,80(a0)
    80001818:	b5aff0ef          	jal	80000b72 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000181c:	70a2                	ld	ra,40(sp)
    8000181e:	7402                	ld	s0,32(sp)
    80001820:	64e2                	ld	s1,24(sp)
    80001822:	6942                	ld	s2,16(sp)
    80001824:	69a2                	ld	s3,8(sp)
    80001826:	6a02                	ld	s4,0(sp)
    80001828:	6145                	addi	sp,sp,48
    8000182a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000182c:	000a061b          	sext.w	a2,s4
    80001830:	85ce                	mv	a1,s3
    80001832:	854a                	mv	a0,s2
    80001834:	977fe0ef          	jal	800001aa <memmove>
    return 0;
    80001838:	8526                	mv	a0,s1
    8000183a:	b7cd                	j	8000181c <either_copyin+0x2a>

000000008000183c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000183c:	715d                	addi	sp,sp,-80
    8000183e:	e486                	sd	ra,72(sp)
    80001840:	e0a2                	sd	s0,64(sp)
    80001842:	fc26                	sd	s1,56(sp)
    80001844:	f84a                	sd	s2,48(sp)
    80001846:	f44e                	sd	s3,40(sp)
    80001848:	f052                	sd	s4,32(sp)
    8000184a:	ec56                	sd	s5,24(sp)
    8000184c:	e85a                	sd	s6,16(sp)
    8000184e:	e45e                	sd	s7,8(sp)
    80001850:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001852:	00005517          	auipc	a0,0x5
    80001856:	7c650513          	addi	a0,a0,1990 # 80007018 <etext+0x18>
    8000185a:	7ef030ef          	jal	80005848 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000185e:	00009497          	auipc	s1,0x9
    80001862:	12a48493          	addi	s1,s1,298 # 8000a988 <proc+0x158>
    80001866:	0001b917          	auipc	s2,0x1b
    8000186a:	b2290913          	addi	s2,s2,-1246 # 8001c388 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000186e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001870:	00006997          	auipc	s3,0x6
    80001874:	93098993          	addi	s3,s3,-1744 # 800071a0 <etext+0x1a0>
    printf("%d %s %s", p->pid, state, p->name);
    80001878:	00006a97          	auipc	s5,0x6
    8000187c:	930a8a93          	addi	s5,s5,-1744 # 800071a8 <etext+0x1a8>
    printf("\n");
    80001880:	00005a17          	auipc	s4,0x5
    80001884:	798a0a13          	addi	s4,s4,1944 # 80007018 <etext+0x18>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001888:	00006b97          	auipc	s7,0x6
    8000188c:	f98b8b93          	addi	s7,s7,-104 # 80007820 <states.0>
    80001890:	a829                	j	800018aa <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80001892:	ed86a583          	lw	a1,-296(a3)
    80001896:	8556                	mv	a0,s5
    80001898:	7b1030ef          	jal	80005848 <printf>
    printf("\n");
    8000189c:	8552                	mv	a0,s4
    8000189e:	7ab030ef          	jal	80005848 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800018a2:	46848493          	addi	s1,s1,1128
    800018a6:	03248263          	beq	s1,s2,800018ca <procdump+0x8e>
    if(p->state == UNUSED)
    800018aa:	86a6                	mv	a3,s1
    800018ac:	ec04a783          	lw	a5,-320(s1)
    800018b0:	dbed                	beqz	a5,800018a2 <procdump+0x66>
      state = "???";
    800018b2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800018b4:	fcfb6fe3          	bltu	s6,a5,80001892 <procdump+0x56>
    800018b8:	02079713          	slli	a4,a5,0x20
    800018bc:	01d75793          	srli	a5,a4,0x1d
    800018c0:	97de                	add	a5,a5,s7
    800018c2:	6390                	ld	a2,0(a5)
    800018c4:	f679                	bnez	a2,80001892 <procdump+0x56>
      state = "???";
    800018c6:	864e                	mv	a2,s3
    800018c8:	b7e9                	j	80001892 <procdump+0x56>
  }
}
    800018ca:	60a6                	ld	ra,72(sp)
    800018cc:	6406                	ld	s0,64(sp)
    800018ce:	74e2                	ld	s1,56(sp)
    800018d0:	7942                	ld	s2,48(sp)
    800018d2:	79a2                	ld	s3,40(sp)
    800018d4:	7a02                	ld	s4,32(sp)
    800018d6:	6ae2                	ld	s5,24(sp)
    800018d8:	6b42                	ld	s6,16(sp)
    800018da:	6ba2                	ld	s7,8(sp)
    800018dc:	6161                	addi	sp,sp,80
    800018de:	8082                	ret

00000000800018e0 <mmap_alloc_page>:
int mmap_alloc_page(struct proc *p, uint64 va) {
    800018e0:	711d                	addi	sp,sp,-96
    800018e2:	ec86                	sd	ra,88(sp)
    800018e4:	e8a2                	sd	s0,80(sp)
    800018e6:	e4a6                	sd	s1,72(sp)
    800018e8:	e0ca                	sd	s2,64(sp)
    800018ea:	fc4e                	sd	s3,56(sp)
    800018ec:	f852                	sd	s4,48(sp)
    800018ee:	f456                	sd	s5,40(sp)
    800018f0:	1080                	addi	s0,sp,96
    800018f2:	89aa                	mv	s3,a0
    800018f4:	892e                	mv	s2,a1
  struct virtual_memory_area *vma = 0;
  for (int i = 0; i < VMA_COUNT; i ++) {
    800018f6:	16850793          	addi	a5,a0,360
    800018fa:	4701                	li	a4,0
    800018fc:	45c1                	li	a1,16
    800018fe:	a031                	j	8000190a <mmap_alloc_page+0x2a>
    80001900:	2705                	addiw	a4,a4,1
    80001902:	03078793          	addi	a5,a5,48
    80001906:	10b70863          	beq	a4,a1,80001a16 <mmap_alloc_page+0x136>
    if (p->vmas[i].is_used
    8000190a:	4394                	lw	a3,0(a5)
    8000190c:	daf5                	beqz	a3,80001900 <mmap_alloc_page+0x20>
    && p->vmas[i].address <= va && va < p->vmas[i].address + p->vmas[i].length) {
    8000190e:	6794                	ld	a3,8(a5)
    80001910:	fed968e3          	bltu	s2,a3,80001900 <mmap_alloc_page+0x20>
    80001914:	4b90                	lw	a2,16(a5)
    80001916:	96b2                	add	a3,a3,a2
    80001918:	fed974e3          	bgeu	s2,a3,80001900 <mmap_alloc_page+0x20>
      vma = &p->vmas[i];
    8000191c:	00171493          	slli	s1,a4,0x1
    80001920:	94ba                	add	s1,s1,a4
    80001922:	0492                	slli	s1,s1,0x4
    80001924:	16848493          	addi	s1,s1,360
    80001928:	94ce                	add	s1,s1,s3
      break;
    }
  }
  if (vma == 0) {
    8000192a:	0e048663          	beqz	s1,80001a16 <mmap_alloc_page+0x136>
    printf("mmap_alloc_page: no vma found, pid=%d va=0x%lx\n", p->pid, va);
    return -1;
  }
 
  printf("mmap_alloc_page: pid=%d va=0x%lx vma_addr=0x%lx len=%d prot=%d flags=%d off=%d ip=%p ip_size=%d file_off=%d\n",
    8000192e:	6494                	ld	a3,8(s1)
    80001930:	0284a883          	lw	a7,40(s1)
    80001934:	709c                	ld	a5,32(s1)
    80001936:	6f98                	ld	a4,24(a5)
         p->pid, va, vma->address, vma->length, vma->prot, vma->flags,
         vma->offset, vma->file->ip, vma->file->ip->size, (int)(va - vma->address + vma->offset));
    80001938:	011907bb          	addw	a5,s2,a7
  printf("mmap_alloc_page: pid=%d va=0x%lx vma_addr=0x%lx len=%d prot=%d flags=%d off=%d ip=%p ip_size=%d file_off=%d\n",
    8000193c:	9f95                	subw	a5,a5,a3
    8000193e:	e83e                	sd	a5,16(sp)
    80001940:	477c                	lw	a5,76(a4)
    80001942:	e43e                	sd	a5,8(sp)
    80001944:	e03a                	sd	a4,0(sp)
    80001946:	0184a803          	lw	a6,24(s1)
    8000194a:	48dc                	lw	a5,20(s1)
    8000194c:	4898                	lw	a4,16(s1)
    8000194e:	864a                	mv	a2,s2
    80001950:	0309a583          	lw	a1,48(s3)
    80001954:	00006517          	auipc	a0,0x6
    80001958:	89450513          	addi	a0,a0,-1900 # 800071e8 <etext+0x1e8>
    8000195c:	6ed030ef          	jal	80005848 <printf>

  uint64 pa = (uint64)kalloc();
    80001960:	f9efe0ef          	jal	800000fe <kalloc>
    80001964:	8a2a                	mv	s4,a0
  va = PGROUNDDOWN(va);
    80001966:	77fd                	lui	a5,0xfffff
    80001968:	00f97933          	and	s2,s2,a5
  if (pa == 0) {
    8000196c:	0c050e63          	beqz	a0,80001a48 <mmap_alloc_page+0x168>
    return -1;
  }
  memset((void*)pa, 0, PGSIZE);
    80001970:	6605                	lui	a2,0x1
    80001972:	4581                	li	a1,0
    80001974:	fdafe0ef          	jal	8000014e <memset>
 
  ilock(vma->file->ip);
    80001978:	709c                	ld	a5,32(s1)
    8000197a:	6f88                	ld	a0,24(a5)
    8000197c:	7f7000ef          	jal	80002972 <ilock>
  int file_off = va - vma->address + vma->offset;
    80001980:	5490                	lw	a2,40(s1)
    80001982:	0126063b          	addw	a2,a2,s2
    80001986:	649c                	ld	a5,8(s1)
    80001988:	9e1d                	subw	a2,a2,a5
    8000198a:	00060a9b          	sext.w	s5,a2
  printf("mmap_alloc_page: pid=%d reading file_off=%d\n", p->pid, file_off);
    8000198e:	8656                	mv	a2,s5
    80001990:	0309a583          	lw	a1,48(s3)
    80001994:	00006517          	auipc	a0,0x6
    80001998:	8c450513          	addi	a0,a0,-1852 # 80007258 <etext+0x258>
    8000199c:	6ad030ef          	jal	80005848 <printf>
  if (readi(vma->file->ip, 0, pa, file_off, PGSIZE) < 0) {
    800019a0:	709c                	ld	a5,32(s1)
    800019a2:	6705                	lui	a4,0x1
    800019a4:	86d6                	mv	a3,s5
    800019a6:	8652                	mv	a2,s4
    800019a8:	4581                	li	a1,0
    800019aa:	6f88                	ld	a0,24(a5)
    800019ac:	356010ef          	jal	80002d02 <readi>
    800019b0:	06054e63          	bltz	a0,80001a2c <mmap_alloc_page+0x14c>
    iunlock(vma->file->ip);
    kfree((void*)pa);
    return -1;
  }
  iunlock(vma->file->ip);
    800019b4:	709c                	ld	a5,32(s1)
    800019b6:	6f88                	ld	a0,24(a5)
    800019b8:	068010ef          	jal	80002a20 <iunlock>

  printf("mmap_alloc_page: pid=%d first_byte=0x%x\n", p->pid, ((uchar*)pa)[0]);
    800019bc:	000a4603          	lbu	a2,0(s4)
    800019c0:	0309a583          	lw	a1,48(s3)
    800019c4:	00006517          	auipc	a0,0x6
    800019c8:	8c450513          	addi	a0,a0,-1852 # 80007288 <etext+0x288>
    800019cc:	67d030ef          	jal	80005848 <printf>
 
  int pte_flags = PTE_U;
  if (vma->prot & PROT_READ)
    800019d0:	48dc                	lw	a5,20(s1)
    800019d2:	0017f693          	andi	a3,a5,1
    pte_flags |= PTE_R;
    800019d6:	4749                	li	a4,18
  if (vma->prot & PROT_READ)
    800019d8:	e291                	bnez	a3,800019dc <mmap_alloc_page+0xfc>
  int pte_flags = PTE_U;
    800019da:	4741                	li	a4,16
  if (vma->prot & PROT_WRITE)
    800019dc:	0027f693          	andi	a3,a5,2
    800019e0:	c299                	beqz	a3,800019e6 <mmap_alloc_page+0x106>
    pte_flags |= PTE_W;
    800019e2:	00476713          	ori	a4,a4,4
  if (vma->prot & PROT_EXEC)
    800019e6:	8b91                	andi	a5,a5,4
    800019e8:	c399                	beqz	a5,800019ee <mmap_alloc_page+0x10e>
    pte_flags |= PTE_X;
    800019ea:	00876713          	ori	a4,a4,8
 
  if (mappages(p->pagetable, va, PGSIZE, pa, pte_flags) < 0) {
    800019ee:	86d2                	mv	a3,s4
    800019f0:	6605                	lui	a2,0x1
    800019f2:	85ca                	mv	a1,s2
    800019f4:	0509b503          	ld	a0,80(s3)
    800019f8:	aa3fe0ef          	jal	8000049a <mappages>
    800019fc:	87aa                	mv	a5,a0
    kfree((void *)pa);
    return -1;
  }
 
  return 0;
    800019fe:	4501                	li	a0,0
  if (mappages(p->pagetable, va, PGSIZE, pa, pte_flags) < 0) {
    80001a00:	0207cf63          	bltz	a5,80001a3e <mmap_alloc_page+0x15e>
    80001a04:	60e6                	ld	ra,88(sp)
    80001a06:	6446                	ld	s0,80(sp)
    80001a08:	64a6                	ld	s1,72(sp)
    80001a0a:	6906                	ld	s2,64(sp)
    80001a0c:	79e2                	ld	s3,56(sp)
    80001a0e:	7a42                	ld	s4,48(sp)
    80001a10:	7aa2                	ld	s5,40(sp)
    80001a12:	6125                	addi	sp,sp,96
    80001a14:	8082                	ret
    printf("mmap_alloc_page: no vma found, pid=%d va=0x%lx\n", p->pid, va);
    80001a16:	864a                	mv	a2,s2
    80001a18:	0309a583          	lw	a1,48(s3)
    80001a1c:	00005517          	auipc	a0,0x5
    80001a20:	79c50513          	addi	a0,a0,1948 # 800071b8 <etext+0x1b8>
    80001a24:	625030ef          	jal	80005848 <printf>
    return -1;
    80001a28:	557d                	li	a0,-1
    80001a2a:	bfe9                	j	80001a04 <mmap_alloc_page+0x124>
    iunlock(vma->file->ip);
    80001a2c:	709c                	ld	a5,32(s1)
    80001a2e:	6f88                	ld	a0,24(a5)
    80001a30:	7f1000ef          	jal	80002a20 <iunlock>
    kfree((void*)pa);
    80001a34:	8552                	mv	a0,s4
    80001a36:	de6fe0ef          	jal	8000001c <kfree>
    return -1;
    80001a3a:	557d                	li	a0,-1
    80001a3c:	b7e1                	j	80001a04 <mmap_alloc_page+0x124>
    kfree((void *)pa);
    80001a3e:	8552                	mv	a0,s4
    80001a40:	ddcfe0ef          	jal	8000001c <kfree>
    return -1;
    80001a44:	557d                	li	a0,-1
    80001a46:	bf7d                	j	80001a04 <mmap_alloc_page+0x124>
    return -1;
    80001a48:	557d                	li	a0,-1
    80001a4a:	bf6d                	j	80001a04 <mmap_alloc_page+0x124>

0000000080001a4c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80001a4c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80001a50:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80001a54:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80001a56:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80001a58:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80001a5c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80001a60:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80001a64:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80001a68:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80001a6c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80001a70:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80001a74:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80001a78:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80001a7c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80001a80:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80001a84:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80001a88:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80001a8a:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80001a8c:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80001a90:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80001a94:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80001a98:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80001a9c:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80001aa0:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80001aa4:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80001aa8:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80001aac:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80001ab0:	0685bd83          	ld	s11,104(a1)
        
        ret
    80001ab4:	8082                	ret

0000000080001ab6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001ab6:	1141                	addi	sp,sp,-16
    80001ab8:	e406                	sd	ra,8(sp)
    80001aba:	e022                	sd	s0,0(sp)
    80001abc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001abe:	00006597          	auipc	a1,0x6
    80001ac2:	82a58593          	addi	a1,a1,-2006 # 800072e8 <etext+0x2e8>
    80001ac6:	0001a517          	auipc	a0,0x1a
    80001aca:	76a50513          	addi	a0,a0,1898 # 8001c230 <tickslock>
    80001ace:	29c040ef          	jal	80005d6a <initlock>
}
    80001ad2:	60a2                	ld	ra,8(sp)
    80001ad4:	6402                	ld	s0,0(sp)
    80001ad6:	0141                	addi	sp,sp,16
    80001ad8:	8082                	ret

0000000080001ada <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001ada:	1141                	addi	sp,sp,-16
    80001adc:	e422                	sd	s0,8(sp)
    80001ade:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001ae0:	00003797          	auipc	a5,0x3
    80001ae4:	27078793          	addi	a5,a5,624 # 80004d50 <kernelvec>
    80001ae8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001aec:	6422                	ld	s0,8(sp)
    80001aee:	0141                	addi	sp,sp,16
    80001af0:	8082                	ret

0000000080001af2 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80001af2:	1141                	addi	sp,sp,-16
    80001af4:	e406                	sd	ra,8(sp)
    80001af6:	e022                	sd	s0,0(sp)
    80001af8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001afa:	a80ff0ef          	jal	80000d7a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001afe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001b02:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b04:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001b08:	04000737          	lui	a4,0x4000
    80001b0c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001b0e:	0732                	slli	a4,a4,0xc
    80001b10:	00004797          	auipc	a5,0x4
    80001b14:	4f078793          	addi	a5,a5,1264 # 80006000 <_trampoline>
    80001b18:	00004697          	auipc	a3,0x4
    80001b1c:	4e868693          	addi	a3,a3,1256 # 80006000 <_trampoline>
    80001b20:	8f95                	sub	a5,a5,a3
    80001b22:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b24:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001b28:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001b2a:	18002773          	csrr	a4,satp
    80001b2e:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001b30:	6d38                	ld	a4,88(a0)
    80001b32:	613c                	ld	a5,64(a0)
    80001b34:	6685                	lui	a3,0x1
    80001b36:	97b6                	add	a5,a5,a3
    80001b38:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001b3a:	6d3c                	ld	a5,88(a0)
    80001b3c:	00000717          	auipc	a4,0x0
    80001b40:	0f870713          	addi	a4,a4,248 # 80001c34 <usertrap>
    80001b44:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001b46:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b48:	8712                	mv	a4,tp
    80001b4a:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b4c:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001b50:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001b54:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b58:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001b5c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001b5e:	6f9c                	ld	a5,24(a5)
    80001b60:	14179073          	csrw	sepc,a5
}
    80001b64:	60a2                	ld	ra,8(sp)
    80001b66:	6402                	ld	s0,0(sp)
    80001b68:	0141                	addi	sp,sp,16
    80001b6a:	8082                	ret

0000000080001b6c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001b6c:	1101                	addi	sp,sp,-32
    80001b6e:	ec06                	sd	ra,24(sp)
    80001b70:	e822                	sd	s0,16(sp)
    80001b72:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001b74:	9daff0ef          	jal	80000d4e <cpuid>
    80001b78:	cd11                	beqz	a0,80001b94 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001b7a:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001b7e:	000f4737          	lui	a4,0xf4
    80001b82:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001b86:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001b88:	14d79073          	csrw	stimecmp,a5
}
    80001b8c:	60e2                	ld	ra,24(sp)
    80001b8e:	6442                	ld	s0,16(sp)
    80001b90:	6105                	addi	sp,sp,32
    80001b92:	8082                	ret
    80001b94:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80001b96:	0001a497          	auipc	s1,0x1a
    80001b9a:	69a48493          	addi	s1,s1,1690 # 8001c230 <tickslock>
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	24a040ef          	jal	80005dea <acquire>
    ticks++;
    80001ba4:	00009517          	auipc	a0,0x9
    80001ba8:	82450513          	addi	a0,a0,-2012 # 8000a3c8 <ticks>
    80001bac:	411c                	lw	a5,0(a0)
    80001bae:	2785                	addiw	a5,a5,1
    80001bb0:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001bb2:	86bff0ef          	jal	8000141c <wakeup>
    release(&tickslock);
    80001bb6:	8526                	mv	a0,s1
    80001bb8:	2ca040ef          	jal	80005e82 <release>
    80001bbc:	64a2                	ld	s1,8(sp)
    80001bbe:	bf75                	j	80001b7a <clockintr+0xe>

0000000080001bc0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001bc0:	1101                	addi	sp,sp,-32
    80001bc2:	ec06                	sd	ra,24(sp)
    80001bc4:	e822                	sd	s0,16(sp)
    80001bc6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001bc8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001bcc:	57fd                	li	a5,-1
    80001bce:	17fe                	slli	a5,a5,0x3f
    80001bd0:	07a5                	addi	a5,a5,9
    80001bd2:	00f70c63          	beq	a4,a5,80001bea <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001bd6:	57fd                	li	a5,-1
    80001bd8:	17fe                	slli	a5,a5,0x3f
    80001bda:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001bdc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001bde:	04f70763          	beq	a4,a5,80001c2c <devintr+0x6c>
  }
}
    80001be2:	60e2                	ld	ra,24(sp)
    80001be4:	6442                	ld	s0,16(sp)
    80001be6:	6105                	addi	sp,sp,32
    80001be8:	8082                	ret
    80001bea:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80001bec:	210030ef          	jal	80004dfc <plic_claim>
    80001bf0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001bf2:	47a9                	li	a5,10
    80001bf4:	00f50963          	beq	a0,a5,80001c06 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80001bf8:	4785                	li	a5,1
    80001bfa:	00f50963          	beq	a0,a5,80001c0c <devintr+0x4c>
    return 1;
    80001bfe:	4505                	li	a0,1
    } else if(irq){
    80001c00:	e889                	bnez	s1,80001c12 <devintr+0x52>
    80001c02:	64a2                	ld	s1,8(sp)
    80001c04:	bff9                	j	80001be2 <devintr+0x22>
      uartintr();
    80001c06:	0f8040ef          	jal	80005cfe <uartintr>
    if(irq)
    80001c0a:	a819                	j	80001c20 <devintr+0x60>
      virtio_disk_intr();
    80001c0c:	6b6030ef          	jal	800052c2 <virtio_disk_intr>
    if(irq)
    80001c10:	a801                	j	80001c20 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80001c12:	85a6                	mv	a1,s1
    80001c14:	00005517          	auipc	a0,0x5
    80001c18:	6dc50513          	addi	a0,a0,1756 # 800072f0 <etext+0x2f0>
    80001c1c:	42d030ef          	jal	80005848 <printf>
      plic_complete(irq);
    80001c20:	8526                	mv	a0,s1
    80001c22:	1fa030ef          	jal	80004e1c <plic_complete>
    return 1;
    80001c26:	4505                	li	a0,1
    80001c28:	64a2                	ld	s1,8(sp)
    80001c2a:	bf65                	j	80001be2 <devintr+0x22>
    clockintr();
    80001c2c:	f41ff0ef          	jal	80001b6c <clockintr>
    return 2;
    80001c30:	4509                	li	a0,2
    80001c32:	bf45                	j	80001be2 <devintr+0x22>

0000000080001c34 <usertrap>:
{
    80001c34:	7179                	addi	sp,sp,-48
    80001c36:	f406                	sd	ra,40(sp)
    80001c38:	f022                	sd	s0,32(sp)
    80001c3a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c3c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001c40:	1007f793          	andi	a5,a5,256
    80001c44:	e3a5                	bnez	a5,80001ca4 <usertrap+0x70>
    80001c46:	ec26                	sd	s1,24(sp)
    80001c48:	e84a                	sd	s2,16(sp)
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001c4a:	00003797          	auipc	a5,0x3
    80001c4e:	10678793          	addi	a5,a5,262 # 80004d50 <kernelvec>
    80001c52:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001c56:	924ff0ef          	jal	80000d7a <myproc>
    80001c5a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001c5c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001c5e:	14102773          	csrr	a4,sepc
    80001c62:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001c64:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001c68:	47a1                	li	a5,8
    80001c6a:	04f70663          	beq	a4,a5,80001cb6 <usertrap+0x82>
  } else if((which_dev = devintr()) != 0){
    80001c6e:	f53ff0ef          	jal	80001bc0 <devintr>
    80001c72:	892a                	mv	s2,a0
    80001c74:	16051363          	bnez	a0,80001dda <usertrap+0x1a6>
    80001c78:	14202773          	csrr	a4,scause
  } else if (r_scause() == 13 || r_scause() == 15) {
    80001c7c:	47b5                	li	a5,13
    80001c7e:	00f70763          	beq	a4,a5,80001c8c <usertrap+0x58>
    80001c82:	14202773          	csrr	a4,scause
    80001c86:	47bd                	li	a5,15
    80001c88:	12f71263          	bne	a4,a5,80001dac <usertrap+0x178>
    80001c8c:	e44e                	sd	s3,8(sp)
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001c8e:	143029f3          	csrr	s3,stval
    if(va >= MAXVA){
    80001c92:	57fd                	li	a5,-1
    80001c94:	83e9                	srli	a5,a5,0x1a
    80001c96:	0737f563          	bgeu	a5,s3,80001d00 <usertrap+0xcc>
      setkilled(p);
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	9c5ff0ef          	jal	80001660 <setkilled>
    80001ca0:	69a2                	ld	s3,8(sp)
    80001ca2:	a80d                	j	80001cd4 <usertrap+0xa0>
    80001ca4:	ec26                	sd	s1,24(sp)
    80001ca6:	e84a                	sd	s2,16(sp)
    80001ca8:	e44e                	sd	s3,8(sp)
    panic("usertrap: not from user mode");
    80001caa:	00005517          	auipc	a0,0x5
    80001cae:	66650513          	addi	a0,a0,1638 # 80007310 <etext+0x310>
    80001cb2:	67d030ef          	jal	80005b2e <panic>
    if(killed(p))
    80001cb6:	9cfff0ef          	jal	80001684 <killed>
    80001cba:	ed1d                	bnez	a0,80001cf8 <usertrap+0xc4>
    p->trapframe->epc += 4;
    80001cbc:	6cb8                	ld	a4,88(s1)
    80001cbe:	6f1c                	ld	a5,24(a4)
    80001cc0:	0791                	addi	a5,a5,4
    80001cc2:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cc4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001cc8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ccc:	10079073          	csrw	sstatus,a5
    syscall();
    80001cd0:	314000ef          	jal	80001fe4 <syscall>
  if(killed(p))
    80001cd4:	8526                	mv	a0,s1
    80001cd6:	9afff0ef          	jal	80001684 <killed>
    80001cda:	10051563          	bnez	a0,80001de4 <usertrap+0x1b0>
  prepare_return();
    80001cde:	e15ff0ef          	jal	80001af2 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001ce2:	68a8                	ld	a0,80(s1)
    80001ce4:	8131                	srli	a0,a0,0xc
    80001ce6:	57fd                	li	a5,-1
    80001ce8:	17fe                	slli	a5,a5,0x3f
    80001cea:	8d5d                	or	a0,a0,a5
}
    80001cec:	64e2                	ld	s1,24(sp)
    80001cee:	6942                	ld	s2,16(sp)
    80001cf0:	70a2                	ld	ra,40(sp)
    80001cf2:	7402                	ld	s0,32(sp)
    80001cf4:	6145                	addi	sp,sp,48
    80001cf6:	8082                	ret
      kexit(-1);
    80001cf8:	557d                	li	a0,-1
    80001cfa:	fe2ff0ef          	jal	800014dc <kexit>
    80001cfe:	bf7d                	j	80001cbc <usertrap+0x88>
      pte_t *pte = walk(p->pagetable, va0, 0);
    80001d00:	4601                	li	a2,0
    80001d02:	75fd                	lui	a1,0xfffff
    80001d04:	00b9f5b3          	and	a1,s3,a1
    80001d08:	68a8                	ld	a0,80(s1)
    80001d0a:	eb8fe0ef          	jal	800003c2 <walk>
      if(pte && (*pte & PTE_V)){
    80001d0e:	c501                	beqz	a0,80001d16 <usertrap+0xe2>
    80001d10:	611c                	ld	a5,0(a0)
    80001d12:	8b85                	andi	a5,a5,1
    80001d14:	e791                	bnez	a5,80001d20 <usertrap+0xec>
    80001d16:	16848713          	addi	a4,s1,360
{
    80001d1a:	87ba                	mv	a5,a4
        for (int i = 0; i < VMA_COUNT; i++) {
    80001d1c:	45c1                	li	a1,16
    80001d1e:	a819                	j	80001d34 <usertrap+0x100>
        setkilled(p);
    80001d20:	8526                	mv	a0,s1
    80001d22:	93fff0ef          	jal	80001660 <setkilled>
    80001d26:	69a2                	ld	s3,8(sp)
    80001d28:	b775                	j	80001cd4 <usertrap+0xa0>
        for (int i = 0; i < VMA_COUNT; i++) {
    80001d2a:	2905                	addiw	s2,s2,1
    80001d2c:	03078793          	addi	a5,a5,48
    80001d30:	0cb90463          	beq	s2,a1,80001df8 <usertrap+0x1c4>
          if (p->vmas[i].is_used &&
    80001d34:	4394                	lw	a3,0(a5)
    80001d36:	daf5                	beqz	a3,80001d2a <usertrap+0xf6>
              p->vmas[i].address <= va && va < p->vmas[i].address + p->vmas[i].length) {
    80001d38:	6794                	ld	a3,8(a5)
          if (p->vmas[i].is_used &&
    80001d3a:	fed9e8e3          	bltu	s3,a3,80001d2a <usertrap+0xf6>
              p->vmas[i].address <= va && va < p->vmas[i].address + p->vmas[i].length) {
    80001d3e:	4b90                	lw	a2,16(a5)
    80001d40:	96b2                	add	a3,a3,a2
    80001d42:	fed9f4e3          	bgeu	s3,a3,80001d2a <usertrap+0xf6>
          if (mmap_alloc_page(p, va) != 0)
    80001d46:	85ce                	mv	a1,s3
    80001d48:	8526                	mv	a0,s1
    80001d4a:	b97ff0ef          	jal	800018e0 <mmap_alloc_page>
    80001d4e:	e119                	bnez	a0,80001d54 <usertrap+0x120>
    80001d50:	69a2                	ld	s3,8(sp)
    80001d52:	b749                	j	80001cd4 <usertrap+0xa0>
            setkilled(p);
    80001d54:	8526                	mv	a0,s1
    80001d56:	90bff0ef          	jal	80001660 <setkilled>
    80001d5a:	69a2                	ld	s3,8(sp)
    80001d5c:	bfa5                	j	80001cd4 <usertrap+0xa0>
          for (int i = 0; i < VMA_COUNT; i++) {
    80001d5e:	03070713          	addi	a4,a4,48
    80001d62:	00d70963          	beq	a4,a3,80001d74 <usertrap+0x140>
            if (p->vmas[i].is_used && p->vmas[i].address < mmap_min)
    80001d66:	431c                	lw	a5,0(a4)
    80001d68:	dbfd                	beqz	a5,80001d5e <usertrap+0x12a>
    80001d6a:	671c                	ld	a5,8(a4)
    80001d6c:	fec7f9e3          	bgeu	a5,a2,80001d5e <usertrap+0x12a>
    80001d70:	863e                	mv	a2,a5
    80001d72:	b7f5                	j	80001d5e <usertrap+0x12a>
          if (mmap_min == MAXVA || va < mmap_min) {
    80001d74:	4785                	li	a5,1
    80001d76:	179a                	slli	a5,a5,0x26
    80001d78:	00f60463          	beq	a2,a5,80001d80 <usertrap+0x14c>
    80001d7c:	02c9f363          	bgeu	s3,a2,80001da2 <usertrap+0x16e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d80:	14202673          	csrr	a2,scause
            if (vmfault(p->pagetable, va, /*read*/ r_scause() == 13 ? 1 : 0) == 0)
    80001d84:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80001d86:	00163613          	seqz	a2,a2
    80001d8a:	85ce                	mv	a1,s3
    80001d8c:	68a8                	ld	a0,80(s1)
    80001d8e:	c7ffe0ef          	jal	80000a0c <vmfault>
    80001d92:	c119                	beqz	a0,80001d98 <usertrap+0x164>
    80001d94:	69a2                	ld	s3,8(sp)
    80001d96:	bf3d                	j	80001cd4 <usertrap+0xa0>
              setkilled(p);
    80001d98:	8526                	mv	a0,s1
    80001d9a:	8c7ff0ef          	jal	80001660 <setkilled>
    80001d9e:	69a2                	ld	s3,8(sp)
    80001da0:	bf15                	j	80001cd4 <usertrap+0xa0>
            setkilled(p);
    80001da2:	8526                	mv	a0,s1
    80001da4:	8bdff0ef          	jal	80001660 <setkilled>
    80001da8:	69a2                	ld	s3,8(sp)
    80001daa:	b72d                	j	80001cd4 <usertrap+0xa0>
    80001dac:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001db0:	5890                	lw	a2,48(s1)
    80001db2:	00005517          	auipc	a0,0x5
    80001db6:	57e50513          	addi	a0,a0,1406 # 80007330 <etext+0x330>
    80001dba:	28f030ef          	jal	80005848 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001dbe:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001dc2:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001dc6:	00005517          	auipc	a0,0x5
    80001dca:	59a50513          	addi	a0,a0,1434 # 80007360 <etext+0x360>
    80001dce:	27b030ef          	jal	80005848 <printf>
    setkilled(p);
    80001dd2:	8526                	mv	a0,s1
    80001dd4:	88dff0ef          	jal	80001660 <setkilled>
    80001dd8:	bdf5                	j	80001cd4 <usertrap+0xa0>
  if(killed(p))
    80001dda:	8526                	mv	a0,s1
    80001ddc:	8a9ff0ef          	jal	80001684 <killed>
    80001de0:	c511                	beqz	a0,80001dec <usertrap+0x1b8>
    80001de2:	a011                	j	80001de6 <usertrap+0x1b2>
    80001de4:	4901                	li	s2,0
    kexit(-1);
    80001de6:	557d                	li	a0,-1
    80001de8:	ef4ff0ef          	jal	800014dc <kexit>
  if(which_dev == 2)
    80001dec:	4789                	li	a5,2
    80001dee:	eef918e3          	bne	s2,a5,80001cde <usertrap+0xaa>
    yield();
    80001df2:	db2ff0ef          	jal	800013a4 <yield>
    80001df6:	b5e5                	j	80001cde <usertrap+0xaa>
        if (vma) {
    80001df8:	46848693          	addi	a3,s1,1128
          uint64 mmap_min = MAXVA;
    80001dfc:	4605                	li	a2,1
    80001dfe:	161a                	slli	a2,a2,0x26
    80001e00:	b79d                	j	80001d66 <usertrap+0x132>

0000000080001e02 <kerneltrap>:
{
    80001e02:	7179                	addi	sp,sp,-48
    80001e04:	f406                	sd	ra,40(sp)
    80001e06:	f022                	sd	s0,32(sp)
    80001e08:	ec26                	sd	s1,24(sp)
    80001e0a:	e84a                	sd	s2,16(sp)
    80001e0c:	e44e                	sd	s3,8(sp)
    80001e0e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e10:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e14:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e18:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001e1c:	1004f793          	andi	a5,s1,256
    80001e20:	c795                	beqz	a5,80001e4c <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e22:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e26:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001e28:	eb85                	bnez	a5,80001e58 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001e2a:	d97ff0ef          	jal	80001bc0 <devintr>
    80001e2e:	c91d                	beqz	a0,80001e64 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001e30:	4789                	li	a5,2
    80001e32:	04f50a63          	beq	a0,a5,80001e86 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001e36:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e3a:	10049073          	csrw	sstatus,s1
}
    80001e3e:	70a2                	ld	ra,40(sp)
    80001e40:	7402                	ld	s0,32(sp)
    80001e42:	64e2                	ld	s1,24(sp)
    80001e44:	6942                	ld	s2,16(sp)
    80001e46:	69a2                	ld	s3,8(sp)
    80001e48:	6145                	addi	sp,sp,48
    80001e4a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001e4c:	00005517          	auipc	a0,0x5
    80001e50:	53c50513          	addi	a0,a0,1340 # 80007388 <etext+0x388>
    80001e54:	4db030ef          	jal	80005b2e <panic>
    panic("kerneltrap: interrupts enabled");
    80001e58:	00005517          	auipc	a0,0x5
    80001e5c:	55850513          	addi	a0,a0,1368 # 800073b0 <etext+0x3b0>
    80001e60:	4cf030ef          	jal	80005b2e <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e64:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e68:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001e6c:	85ce                	mv	a1,s3
    80001e6e:	00005517          	auipc	a0,0x5
    80001e72:	56250513          	addi	a0,a0,1378 # 800073d0 <etext+0x3d0>
    80001e76:	1d3030ef          	jal	80005848 <printf>
    panic("kerneltrap");
    80001e7a:	00005517          	auipc	a0,0x5
    80001e7e:	57e50513          	addi	a0,a0,1406 # 800073f8 <etext+0x3f8>
    80001e82:	4ad030ef          	jal	80005b2e <panic>
  if(which_dev == 2 && myproc() != 0)
    80001e86:	ef5fe0ef          	jal	80000d7a <myproc>
    80001e8a:	d555                	beqz	a0,80001e36 <kerneltrap+0x34>
    yield();
    80001e8c:	d18ff0ef          	jal	800013a4 <yield>
    80001e90:	b75d                	j	80001e36 <kerneltrap+0x34>

0000000080001e92 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001e92:	1101                	addi	sp,sp,-32
    80001e94:	ec06                	sd	ra,24(sp)
    80001e96:	e822                	sd	s0,16(sp)
    80001e98:	e426                	sd	s1,8(sp)
    80001e9a:	1000                	addi	s0,sp,32
    80001e9c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e9e:	eddfe0ef          	jal	80000d7a <myproc>
  switch (n) {
    80001ea2:	4795                	li	a5,5
    80001ea4:	0497e163          	bltu	a5,s1,80001ee6 <argraw+0x54>
    80001ea8:	048a                	slli	s1,s1,0x2
    80001eaa:	00006717          	auipc	a4,0x6
    80001eae:	9a670713          	addi	a4,a4,-1626 # 80007850 <states.0+0x30>
    80001eb2:	94ba                	add	s1,s1,a4
    80001eb4:	409c                	lw	a5,0(s1)
    80001eb6:	97ba                	add	a5,a5,a4
    80001eb8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001eba:	6d3c                	ld	a5,88(a0)
    80001ebc:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001ebe:	60e2                	ld	ra,24(sp)
    80001ec0:	6442                	ld	s0,16(sp)
    80001ec2:	64a2                	ld	s1,8(sp)
    80001ec4:	6105                	addi	sp,sp,32
    80001ec6:	8082                	ret
    return p->trapframe->a1;
    80001ec8:	6d3c                	ld	a5,88(a0)
    80001eca:	7fa8                	ld	a0,120(a5)
    80001ecc:	bfcd                	j	80001ebe <argraw+0x2c>
    return p->trapframe->a2;
    80001ece:	6d3c                	ld	a5,88(a0)
    80001ed0:	63c8                	ld	a0,128(a5)
    80001ed2:	b7f5                	j	80001ebe <argraw+0x2c>
    return p->trapframe->a3;
    80001ed4:	6d3c                	ld	a5,88(a0)
    80001ed6:	67c8                	ld	a0,136(a5)
    80001ed8:	b7dd                	j	80001ebe <argraw+0x2c>
    return p->trapframe->a4;
    80001eda:	6d3c                	ld	a5,88(a0)
    80001edc:	6bc8                	ld	a0,144(a5)
    80001ede:	b7c5                	j	80001ebe <argraw+0x2c>
    return p->trapframe->a5;
    80001ee0:	6d3c                	ld	a5,88(a0)
    80001ee2:	6fc8                	ld	a0,152(a5)
    80001ee4:	bfe9                	j	80001ebe <argraw+0x2c>
  panic("argraw");
    80001ee6:	00005517          	auipc	a0,0x5
    80001eea:	52250513          	addi	a0,a0,1314 # 80007408 <etext+0x408>
    80001eee:	441030ef          	jal	80005b2e <panic>

0000000080001ef2 <fetchaddr>:
{
    80001ef2:	1101                	addi	sp,sp,-32
    80001ef4:	ec06                	sd	ra,24(sp)
    80001ef6:	e822                	sd	s0,16(sp)
    80001ef8:	e426                	sd	s1,8(sp)
    80001efa:	e04a                	sd	s2,0(sp)
    80001efc:	1000                	addi	s0,sp,32
    80001efe:	84aa                	mv	s1,a0
    80001f00:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f02:	e79fe0ef          	jal	80000d7a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001f06:	653c                	ld	a5,72(a0)
    80001f08:	02f4f663          	bgeu	s1,a5,80001f34 <fetchaddr+0x42>
    80001f0c:	00848713          	addi	a4,s1,8
    80001f10:	02e7e463          	bltu	a5,a4,80001f38 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001f14:	46a1                	li	a3,8
    80001f16:	8626                	mv	a2,s1
    80001f18:	85ca                	mv	a1,s2
    80001f1a:	6928                	ld	a0,80(a0)
    80001f1c:	c57fe0ef          	jal	80000b72 <copyin>
    80001f20:	00a03533          	snez	a0,a0
    80001f24:	40a00533          	neg	a0,a0
}
    80001f28:	60e2                	ld	ra,24(sp)
    80001f2a:	6442                	ld	s0,16(sp)
    80001f2c:	64a2                	ld	s1,8(sp)
    80001f2e:	6902                	ld	s2,0(sp)
    80001f30:	6105                	addi	sp,sp,32
    80001f32:	8082                	ret
    return -1;
    80001f34:	557d                	li	a0,-1
    80001f36:	bfcd                	j	80001f28 <fetchaddr+0x36>
    80001f38:	557d                	li	a0,-1
    80001f3a:	b7fd                	j	80001f28 <fetchaddr+0x36>

0000000080001f3c <fetchstr>:
{
    80001f3c:	7179                	addi	sp,sp,-48
    80001f3e:	f406                	sd	ra,40(sp)
    80001f40:	f022                	sd	s0,32(sp)
    80001f42:	ec26                	sd	s1,24(sp)
    80001f44:	e84a                	sd	s2,16(sp)
    80001f46:	e44e                	sd	s3,8(sp)
    80001f48:	1800                	addi	s0,sp,48
    80001f4a:	892a                	mv	s2,a0
    80001f4c:	84ae                	mv	s1,a1
    80001f4e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001f50:	e2bfe0ef          	jal	80000d7a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001f54:	86ce                	mv	a3,s3
    80001f56:	864a                	mv	a2,s2
    80001f58:	85a6                	mv	a1,s1
    80001f5a:	6928                	ld	a0,80(a0)
    80001f5c:	9d9fe0ef          	jal	80000934 <copyinstr>
    80001f60:	00054c63          	bltz	a0,80001f78 <fetchstr+0x3c>
  return strlen(buf);
    80001f64:	8526                	mv	a0,s1
    80001f66:	b58fe0ef          	jal	800002be <strlen>
}
    80001f6a:	70a2                	ld	ra,40(sp)
    80001f6c:	7402                	ld	s0,32(sp)
    80001f6e:	64e2                	ld	s1,24(sp)
    80001f70:	6942                	ld	s2,16(sp)
    80001f72:	69a2                	ld	s3,8(sp)
    80001f74:	6145                	addi	sp,sp,48
    80001f76:	8082                	ret
    return -1;
    80001f78:	557d                	li	a0,-1
    80001f7a:	bfc5                	j	80001f6a <fetchstr+0x2e>

0000000080001f7c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001f7c:	1101                	addi	sp,sp,-32
    80001f7e:	ec06                	sd	ra,24(sp)
    80001f80:	e822                	sd	s0,16(sp)
    80001f82:	e426                	sd	s1,8(sp)
    80001f84:	1000                	addi	s0,sp,32
    80001f86:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001f88:	f0bff0ef          	jal	80001e92 <argraw>
    80001f8c:	c088                	sw	a0,0(s1)
}
    80001f8e:	60e2                	ld	ra,24(sp)
    80001f90:	6442                	ld	s0,16(sp)
    80001f92:	64a2                	ld	s1,8(sp)
    80001f94:	6105                	addi	sp,sp,32
    80001f96:	8082                	ret

0000000080001f98 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001f98:	1101                	addi	sp,sp,-32
    80001f9a:	ec06                	sd	ra,24(sp)
    80001f9c:	e822                	sd	s0,16(sp)
    80001f9e:	e426                	sd	s1,8(sp)
    80001fa0:	1000                	addi	s0,sp,32
    80001fa2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001fa4:	eefff0ef          	jal	80001e92 <argraw>
    80001fa8:	e088                	sd	a0,0(s1)
}
    80001faa:	60e2                	ld	ra,24(sp)
    80001fac:	6442                	ld	s0,16(sp)
    80001fae:	64a2                	ld	s1,8(sp)
    80001fb0:	6105                	addi	sp,sp,32
    80001fb2:	8082                	ret

0000000080001fb4 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001fb4:	7179                	addi	sp,sp,-48
    80001fb6:	f406                	sd	ra,40(sp)
    80001fb8:	f022                	sd	s0,32(sp)
    80001fba:	ec26                	sd	s1,24(sp)
    80001fbc:	e84a                	sd	s2,16(sp)
    80001fbe:	1800                	addi	s0,sp,48
    80001fc0:	84ae                	mv	s1,a1
    80001fc2:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001fc4:	fd840593          	addi	a1,s0,-40
    80001fc8:	fd1ff0ef          	jal	80001f98 <argaddr>
  return fetchstr(addr, buf, max);
    80001fcc:	864a                	mv	a2,s2
    80001fce:	85a6                	mv	a1,s1
    80001fd0:	fd843503          	ld	a0,-40(s0)
    80001fd4:	f69ff0ef          	jal	80001f3c <fetchstr>
}
    80001fd8:	70a2                	ld	ra,40(sp)
    80001fda:	7402                	ld	s0,32(sp)
    80001fdc:	64e2                	ld	s1,24(sp)
    80001fde:	6942                	ld	s2,16(sp)
    80001fe0:	6145                	addi	sp,sp,48
    80001fe2:	8082                	ret

0000000080001fe4 <syscall>:
[SYS_munmap]  sys_munmap,
};

void
syscall(void)
{
    80001fe4:	1101                	addi	sp,sp,-32
    80001fe6:	ec06                	sd	ra,24(sp)
    80001fe8:	e822                	sd	s0,16(sp)
    80001fea:	e426                	sd	s1,8(sp)
    80001fec:	e04a                	sd	s2,0(sp)
    80001fee:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001ff0:	d8bfe0ef          	jal	80000d7a <myproc>
    80001ff4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001ff6:	05853903          	ld	s2,88(a0)
    80001ffa:	0a893783          	ld	a5,168(s2)
    80001ffe:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002002:	37fd                	addiw	a5,a5,-1
    80002004:	4759                	li	a4,22
    80002006:	00f76f63          	bltu	a4,a5,80002024 <syscall+0x40>
    8000200a:	00369713          	slli	a4,a3,0x3
    8000200e:	00006797          	auipc	a5,0x6
    80002012:	85a78793          	addi	a5,a5,-1958 # 80007868 <syscalls>
    80002016:	97ba                	add	a5,a5,a4
    80002018:	639c                	ld	a5,0(a5)
    8000201a:	c789                	beqz	a5,80002024 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000201c:	9782                	jalr	a5
    8000201e:	06a93823          	sd	a0,112(s2)
    80002022:	a829                	j	8000203c <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002024:	15848613          	addi	a2,s1,344
    80002028:	588c                	lw	a1,48(s1)
    8000202a:	00005517          	auipc	a0,0x5
    8000202e:	3e650513          	addi	a0,a0,998 # 80007410 <etext+0x410>
    80002032:	017030ef          	jal	80005848 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002036:	6cbc                	ld	a5,88(s1)
    80002038:	577d                	li	a4,-1
    8000203a:	fbb8                	sd	a4,112(a5)
  }
}
    8000203c:	60e2                	ld	ra,24(sp)
    8000203e:	6442                	ld	s0,16(sp)
    80002040:	64a2                	ld	s1,8(sp)
    80002042:	6902                	ld	s2,0(sp)
    80002044:	6105                	addi	sp,sp,32
    80002046:	8082                	ret

0000000080002048 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002048:	1101                	addi	sp,sp,-32
    8000204a:	ec06                	sd	ra,24(sp)
    8000204c:	e822                	sd	s0,16(sp)
    8000204e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002050:	fec40593          	addi	a1,s0,-20
    80002054:	4501                	li	a0,0
    80002056:	f27ff0ef          	jal	80001f7c <argint>
  kexit(n);
    8000205a:	fec42503          	lw	a0,-20(s0)
    8000205e:	c7eff0ef          	jal	800014dc <kexit>
  return 0;  // not reached
}
    80002062:	4501                	li	a0,0
    80002064:	60e2                	ld	ra,24(sp)
    80002066:	6442                	ld	s0,16(sp)
    80002068:	6105                	addi	sp,sp,32
    8000206a:	8082                	ret

000000008000206c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000206c:	1141                	addi	sp,sp,-16
    8000206e:	e406                	sd	ra,8(sp)
    80002070:	e022                	sd	s0,0(sp)
    80002072:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002074:	d07fe0ef          	jal	80000d7a <myproc>
}
    80002078:	5908                	lw	a0,48(a0)
    8000207a:	60a2                	ld	ra,8(sp)
    8000207c:	6402                	ld	s0,0(sp)
    8000207e:	0141                	addi	sp,sp,16
    80002080:	8082                	ret

0000000080002082 <sys_fork>:

uint64
sys_fork(void)
{
    80002082:	1141                	addi	sp,sp,-16
    80002084:	e406                	sd	ra,8(sp)
    80002086:	e022                	sd	s0,0(sp)
    80002088:	0800                	addi	s0,sp,16
  return kfork();
    8000208a:	856ff0ef          	jal	800010e0 <kfork>
}
    8000208e:	60a2                	ld	ra,8(sp)
    80002090:	6402                	ld	s0,0(sp)
    80002092:	0141                	addi	sp,sp,16
    80002094:	8082                	ret

0000000080002096 <sys_wait>:

uint64
sys_wait(void)
{
    80002096:	1101                	addi	sp,sp,-32
    80002098:	ec06                	sd	ra,24(sp)
    8000209a:	e822                	sd	s0,16(sp)
    8000209c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000209e:	fe840593          	addi	a1,s0,-24
    800020a2:	4501                	li	a0,0
    800020a4:	ef5ff0ef          	jal	80001f98 <argaddr>
  return kwait(p);
    800020a8:	fe843503          	ld	a0,-24(s0)
    800020ac:	e02ff0ef          	jal	800016ae <kwait>
}
    800020b0:	60e2                	ld	ra,24(sp)
    800020b2:	6442                	ld	s0,16(sp)
    800020b4:	6105                	addi	sp,sp,32
    800020b6:	8082                	ret

00000000800020b8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800020b8:	7179                	addi	sp,sp,-48
    800020ba:	f406                	sd	ra,40(sp)
    800020bc:	f022                	sd	s0,32(sp)
    800020be:	ec26                	sd	s1,24(sp)
    800020c0:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800020c2:	fd840593          	addi	a1,s0,-40
    800020c6:	4501                	li	a0,0
    800020c8:	eb5ff0ef          	jal	80001f7c <argint>
  argint(1, &t);
    800020cc:	fdc40593          	addi	a1,s0,-36
    800020d0:	4505                	li	a0,1
    800020d2:	eabff0ef          	jal	80001f7c <argint>
  addr = myproc()->sz;
    800020d6:	ca5fe0ef          	jal	80000d7a <myproc>
    800020da:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    800020dc:	fdc42703          	lw	a4,-36(s0)
    800020e0:	4785                	li	a5,1
    800020e2:	02f70163          	beq	a4,a5,80002104 <sys_sbrk+0x4c>
    800020e6:	fd842783          	lw	a5,-40(s0)
    800020ea:	0007cd63          	bltz	a5,80002104 <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800020ee:	97a6                	add	a5,a5,s1
    800020f0:	0297e863          	bltu	a5,s1,80002120 <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    800020f4:	c87fe0ef          	jal	80000d7a <myproc>
    800020f8:	fd842703          	lw	a4,-40(s0)
    800020fc:	653c                	ld	a5,72(a0)
    800020fe:	97ba                	add	a5,a5,a4
    80002100:	e53c                	sd	a5,72(a0)
    80002102:	a039                	j	80002110 <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80002104:	fd842503          	lw	a0,-40(s0)
    80002108:	f89fe0ef          	jal	80001090 <growproc>
    8000210c:	00054863          	bltz	a0,8000211c <sys_sbrk+0x64>
  }
  return addr;
}
    80002110:	8526                	mv	a0,s1
    80002112:	70a2                	ld	ra,40(sp)
    80002114:	7402                	ld	s0,32(sp)
    80002116:	64e2                	ld	s1,24(sp)
    80002118:	6145                	addi	sp,sp,48
    8000211a:	8082                	ret
      return -1;
    8000211c:	54fd                	li	s1,-1
    8000211e:	bfcd                	j	80002110 <sys_sbrk+0x58>
      return -1;
    80002120:	54fd                	li	s1,-1
    80002122:	b7fd                	j	80002110 <sys_sbrk+0x58>

0000000080002124 <sys_pause>:

uint64
sys_pause(void)
{
    80002124:	7139                	addi	sp,sp,-64
    80002126:	fc06                	sd	ra,56(sp)
    80002128:	f822                	sd	s0,48(sp)
    8000212a:	f04a                	sd	s2,32(sp)
    8000212c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000212e:	fcc40593          	addi	a1,s0,-52
    80002132:	4501                	li	a0,0
    80002134:	e49ff0ef          	jal	80001f7c <argint>
  if(n < 0)
    80002138:	fcc42783          	lw	a5,-52(s0)
    8000213c:	0607c763          	bltz	a5,800021aa <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002140:	0001a517          	auipc	a0,0x1a
    80002144:	0f050513          	addi	a0,a0,240 # 8001c230 <tickslock>
    80002148:	4a3030ef          	jal	80005dea <acquire>
  ticks0 = ticks;
    8000214c:	00008917          	auipc	s2,0x8
    80002150:	27c92903          	lw	s2,636(s2) # 8000a3c8 <ticks>
  while(ticks - ticks0 < n){
    80002154:	fcc42783          	lw	a5,-52(s0)
    80002158:	cf8d                	beqz	a5,80002192 <sys_pause+0x6e>
    8000215a:	f426                	sd	s1,40(sp)
    8000215c:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000215e:	0001a997          	auipc	s3,0x1a
    80002162:	0d298993          	addi	s3,s3,210 # 8001c230 <tickslock>
    80002166:	00008497          	auipc	s1,0x8
    8000216a:	26248493          	addi	s1,s1,610 # 8000a3c8 <ticks>
    if(killed(myproc())){
    8000216e:	c0dfe0ef          	jal	80000d7a <myproc>
    80002172:	d12ff0ef          	jal	80001684 <killed>
    80002176:	ed0d                	bnez	a0,800021b0 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002178:	85ce                	mv	a1,s3
    8000217a:	8526                	mv	a0,s1
    8000217c:	a54ff0ef          	jal	800013d0 <sleep>
  while(ticks - ticks0 < n){
    80002180:	409c                	lw	a5,0(s1)
    80002182:	412787bb          	subw	a5,a5,s2
    80002186:	fcc42703          	lw	a4,-52(s0)
    8000218a:	fee7e2e3          	bltu	a5,a4,8000216e <sys_pause+0x4a>
    8000218e:	74a2                	ld	s1,40(sp)
    80002190:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002192:	0001a517          	auipc	a0,0x1a
    80002196:	09e50513          	addi	a0,a0,158 # 8001c230 <tickslock>
    8000219a:	4e9030ef          	jal	80005e82 <release>
  return 0;
    8000219e:	4501                	li	a0,0
}
    800021a0:	70e2                	ld	ra,56(sp)
    800021a2:	7442                	ld	s0,48(sp)
    800021a4:	7902                	ld	s2,32(sp)
    800021a6:	6121                	addi	sp,sp,64
    800021a8:	8082                	ret
    n = 0;
    800021aa:	fc042623          	sw	zero,-52(s0)
    800021ae:	bf49                	j	80002140 <sys_pause+0x1c>
      release(&tickslock);
    800021b0:	0001a517          	auipc	a0,0x1a
    800021b4:	08050513          	addi	a0,a0,128 # 8001c230 <tickslock>
    800021b8:	4cb030ef          	jal	80005e82 <release>
      return -1;
    800021bc:	557d                	li	a0,-1
    800021be:	74a2                	ld	s1,40(sp)
    800021c0:	69e2                	ld	s3,24(sp)
    800021c2:	bff9                	j	800021a0 <sys_pause+0x7c>

00000000800021c4 <sys_kill>:

uint64
sys_kill(void)
{
    800021c4:	1101                	addi	sp,sp,-32
    800021c6:	ec06                	sd	ra,24(sp)
    800021c8:	e822                	sd	s0,16(sp)
    800021ca:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800021cc:	fec40593          	addi	a1,s0,-20
    800021d0:	4501                	li	a0,0
    800021d2:	dabff0ef          	jal	80001f7c <argint>
  return kkill(pid);
    800021d6:	fec42503          	lw	a0,-20(s0)
    800021da:	c20ff0ef          	jal	800015fa <kkill>
}
    800021de:	60e2                	ld	ra,24(sp)
    800021e0:	6442                	ld	s0,16(sp)
    800021e2:	6105                	addi	sp,sp,32
    800021e4:	8082                	ret

00000000800021e6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800021e6:	1101                	addi	sp,sp,-32
    800021e8:	ec06                	sd	ra,24(sp)
    800021ea:	e822                	sd	s0,16(sp)
    800021ec:	e426                	sd	s1,8(sp)
    800021ee:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800021f0:	0001a517          	auipc	a0,0x1a
    800021f4:	04050513          	addi	a0,a0,64 # 8001c230 <tickslock>
    800021f8:	3f3030ef          	jal	80005dea <acquire>
  xticks = ticks;
    800021fc:	00008497          	auipc	s1,0x8
    80002200:	1cc4a483          	lw	s1,460(s1) # 8000a3c8 <ticks>
  release(&tickslock);
    80002204:	0001a517          	auipc	a0,0x1a
    80002208:	02c50513          	addi	a0,a0,44 # 8001c230 <tickslock>
    8000220c:	477030ef          	jal	80005e82 <release>
  return xticks;
}
    80002210:	02049513          	slli	a0,s1,0x20
    80002214:	9101                	srli	a0,a0,0x20
    80002216:	60e2                	ld	ra,24(sp)
    80002218:	6442                	ld	s0,16(sp)
    8000221a:	64a2                	ld	s1,8(sp)
    8000221c:	6105                	addi	sp,sp,32
    8000221e:	8082                	ret

0000000080002220 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002220:	7179                	addi	sp,sp,-48
    80002222:	f406                	sd	ra,40(sp)
    80002224:	f022                	sd	s0,32(sp)
    80002226:	ec26                	sd	s1,24(sp)
    80002228:	e84a                	sd	s2,16(sp)
    8000222a:	e44e                	sd	s3,8(sp)
    8000222c:	e052                	sd	s4,0(sp)
    8000222e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002230:	00005597          	auipc	a1,0x5
    80002234:	20058593          	addi	a1,a1,512 # 80007430 <etext+0x430>
    80002238:	0001a517          	auipc	a0,0x1a
    8000223c:	01050513          	addi	a0,a0,16 # 8001c248 <bcache>
    80002240:	32b030ef          	jal	80005d6a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002244:	00022797          	auipc	a5,0x22
    80002248:	00478793          	addi	a5,a5,4 # 80024248 <bcache+0x8000>
    8000224c:	00022717          	auipc	a4,0x22
    80002250:	26470713          	addi	a4,a4,612 # 800244b0 <bcache+0x8268>
    80002254:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002258:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000225c:	0001a497          	auipc	s1,0x1a
    80002260:	00448493          	addi	s1,s1,4 # 8001c260 <bcache+0x18>
    b->next = bcache.head.next;
    80002264:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002266:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002268:	00005a17          	auipc	s4,0x5
    8000226c:	1d0a0a13          	addi	s4,s4,464 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    80002270:	2b893783          	ld	a5,696(s2)
    80002274:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002276:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000227a:	85d2                	mv	a1,s4
    8000227c:	01048513          	addi	a0,s1,16
    80002280:	322010ef          	jal	800035a2 <initsleeplock>
    bcache.head.next->prev = b;
    80002284:	2b893783          	ld	a5,696(s2)
    80002288:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000228a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000228e:	45848493          	addi	s1,s1,1112
    80002292:	fd349fe3          	bne	s1,s3,80002270 <binit+0x50>
  }
}
    80002296:	70a2                	ld	ra,40(sp)
    80002298:	7402                	ld	s0,32(sp)
    8000229a:	64e2                	ld	s1,24(sp)
    8000229c:	6942                	ld	s2,16(sp)
    8000229e:	69a2                	ld	s3,8(sp)
    800022a0:	6a02                	ld	s4,0(sp)
    800022a2:	6145                	addi	sp,sp,48
    800022a4:	8082                	ret

00000000800022a6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800022a6:	7179                	addi	sp,sp,-48
    800022a8:	f406                	sd	ra,40(sp)
    800022aa:	f022                	sd	s0,32(sp)
    800022ac:	ec26                	sd	s1,24(sp)
    800022ae:	e84a                	sd	s2,16(sp)
    800022b0:	e44e                	sd	s3,8(sp)
    800022b2:	1800                	addi	s0,sp,48
    800022b4:	892a                	mv	s2,a0
    800022b6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800022b8:	0001a517          	auipc	a0,0x1a
    800022bc:	f9050513          	addi	a0,a0,-112 # 8001c248 <bcache>
    800022c0:	32b030ef          	jal	80005dea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800022c4:	00022497          	auipc	s1,0x22
    800022c8:	23c4b483          	ld	s1,572(s1) # 80024500 <bcache+0x82b8>
    800022cc:	00022797          	auipc	a5,0x22
    800022d0:	1e478793          	addi	a5,a5,484 # 800244b0 <bcache+0x8268>
    800022d4:	02f48b63          	beq	s1,a5,8000230a <bread+0x64>
    800022d8:	873e                	mv	a4,a5
    800022da:	a021                	j	800022e2 <bread+0x3c>
    800022dc:	68a4                	ld	s1,80(s1)
    800022de:	02e48663          	beq	s1,a4,8000230a <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800022e2:	449c                	lw	a5,8(s1)
    800022e4:	ff279ce3          	bne	a5,s2,800022dc <bread+0x36>
    800022e8:	44dc                	lw	a5,12(s1)
    800022ea:	ff3799e3          	bne	a5,s3,800022dc <bread+0x36>
      b->refcnt++;
    800022ee:	40bc                	lw	a5,64(s1)
    800022f0:	2785                	addiw	a5,a5,1
    800022f2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800022f4:	0001a517          	auipc	a0,0x1a
    800022f8:	f5450513          	addi	a0,a0,-172 # 8001c248 <bcache>
    800022fc:	387030ef          	jal	80005e82 <release>
      acquiresleep(&b->lock);
    80002300:	01048513          	addi	a0,s1,16
    80002304:	2d4010ef          	jal	800035d8 <acquiresleep>
      return b;
    80002308:	a889                	j	8000235a <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000230a:	00022497          	auipc	s1,0x22
    8000230e:	1ee4b483          	ld	s1,494(s1) # 800244f8 <bcache+0x82b0>
    80002312:	00022797          	auipc	a5,0x22
    80002316:	19e78793          	addi	a5,a5,414 # 800244b0 <bcache+0x8268>
    8000231a:	00f48863          	beq	s1,a5,8000232a <bread+0x84>
    8000231e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002320:	40bc                	lw	a5,64(s1)
    80002322:	cb91                	beqz	a5,80002336 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002324:	64a4                	ld	s1,72(s1)
    80002326:	fee49de3          	bne	s1,a4,80002320 <bread+0x7a>
  panic("bget: no buffers");
    8000232a:	00005517          	auipc	a0,0x5
    8000232e:	11650513          	addi	a0,a0,278 # 80007440 <etext+0x440>
    80002332:	7fc030ef          	jal	80005b2e <panic>
      b->dev = dev;
    80002336:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000233a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000233e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002342:	4785                	li	a5,1
    80002344:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002346:	0001a517          	auipc	a0,0x1a
    8000234a:	f0250513          	addi	a0,a0,-254 # 8001c248 <bcache>
    8000234e:	335030ef          	jal	80005e82 <release>
      acquiresleep(&b->lock);
    80002352:	01048513          	addi	a0,s1,16
    80002356:	282010ef          	jal	800035d8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000235a:	409c                	lw	a5,0(s1)
    8000235c:	cb89                	beqz	a5,8000236e <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000235e:	8526                	mv	a0,s1
    80002360:	70a2                	ld	ra,40(sp)
    80002362:	7402                	ld	s0,32(sp)
    80002364:	64e2                	ld	s1,24(sp)
    80002366:	6942                	ld	s2,16(sp)
    80002368:	69a2                	ld	s3,8(sp)
    8000236a:	6145                	addi	sp,sp,48
    8000236c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000236e:	4581                	li	a1,0
    80002370:	8526                	mv	a0,s1
    80002372:	53f020ef          	jal	800050b0 <virtio_disk_rw>
    b->valid = 1;
    80002376:	4785                	li	a5,1
    80002378:	c09c                	sw	a5,0(s1)
  return b;
    8000237a:	b7d5                	j	8000235e <bread+0xb8>

000000008000237c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000237c:	1101                	addi	sp,sp,-32
    8000237e:	ec06                	sd	ra,24(sp)
    80002380:	e822                	sd	s0,16(sp)
    80002382:	e426                	sd	s1,8(sp)
    80002384:	1000                	addi	s0,sp,32
    80002386:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002388:	0541                	addi	a0,a0,16
    8000238a:	2cc010ef          	jal	80003656 <holdingsleep>
    8000238e:	c911                	beqz	a0,800023a2 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002390:	4585                	li	a1,1
    80002392:	8526                	mv	a0,s1
    80002394:	51d020ef          	jal	800050b0 <virtio_disk_rw>
}
    80002398:	60e2                	ld	ra,24(sp)
    8000239a:	6442                	ld	s0,16(sp)
    8000239c:	64a2                	ld	s1,8(sp)
    8000239e:	6105                	addi	sp,sp,32
    800023a0:	8082                	ret
    panic("bwrite");
    800023a2:	00005517          	auipc	a0,0x5
    800023a6:	0b650513          	addi	a0,a0,182 # 80007458 <etext+0x458>
    800023aa:	784030ef          	jal	80005b2e <panic>

00000000800023ae <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800023ae:	1101                	addi	sp,sp,-32
    800023b0:	ec06                	sd	ra,24(sp)
    800023b2:	e822                	sd	s0,16(sp)
    800023b4:	e426                	sd	s1,8(sp)
    800023b6:	e04a                	sd	s2,0(sp)
    800023b8:	1000                	addi	s0,sp,32
    800023ba:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800023bc:	01050913          	addi	s2,a0,16
    800023c0:	854a                	mv	a0,s2
    800023c2:	294010ef          	jal	80003656 <holdingsleep>
    800023c6:	c135                	beqz	a0,8000242a <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    800023c8:	854a                	mv	a0,s2
    800023ca:	254010ef          	jal	8000361e <releasesleep>

  acquire(&bcache.lock);
    800023ce:	0001a517          	auipc	a0,0x1a
    800023d2:	e7a50513          	addi	a0,a0,-390 # 8001c248 <bcache>
    800023d6:	215030ef          	jal	80005dea <acquire>
  b->refcnt--;
    800023da:	40bc                	lw	a5,64(s1)
    800023dc:	37fd                	addiw	a5,a5,-1
    800023de:	0007871b          	sext.w	a4,a5
    800023e2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800023e4:	e71d                	bnez	a4,80002412 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800023e6:	68b8                	ld	a4,80(s1)
    800023e8:	64bc                	ld	a5,72(s1)
    800023ea:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800023ec:	68b8                	ld	a4,80(s1)
    800023ee:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800023f0:	00022797          	auipc	a5,0x22
    800023f4:	e5878793          	addi	a5,a5,-424 # 80024248 <bcache+0x8000>
    800023f8:	2b87b703          	ld	a4,696(a5)
    800023fc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800023fe:	00022717          	auipc	a4,0x22
    80002402:	0b270713          	addi	a4,a4,178 # 800244b0 <bcache+0x8268>
    80002406:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002408:	2b87b703          	ld	a4,696(a5)
    8000240c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000240e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002412:	0001a517          	auipc	a0,0x1a
    80002416:	e3650513          	addi	a0,a0,-458 # 8001c248 <bcache>
    8000241a:	269030ef          	jal	80005e82 <release>
}
    8000241e:	60e2                	ld	ra,24(sp)
    80002420:	6442                	ld	s0,16(sp)
    80002422:	64a2                	ld	s1,8(sp)
    80002424:	6902                	ld	s2,0(sp)
    80002426:	6105                	addi	sp,sp,32
    80002428:	8082                	ret
    panic("brelse");
    8000242a:	00005517          	auipc	a0,0x5
    8000242e:	03650513          	addi	a0,a0,54 # 80007460 <etext+0x460>
    80002432:	6fc030ef          	jal	80005b2e <panic>

0000000080002436 <bpin>:

void
bpin(struct buf *b) {
    80002436:	1101                	addi	sp,sp,-32
    80002438:	ec06                	sd	ra,24(sp)
    8000243a:	e822                	sd	s0,16(sp)
    8000243c:	e426                	sd	s1,8(sp)
    8000243e:	1000                	addi	s0,sp,32
    80002440:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002442:	0001a517          	auipc	a0,0x1a
    80002446:	e0650513          	addi	a0,a0,-506 # 8001c248 <bcache>
    8000244a:	1a1030ef          	jal	80005dea <acquire>
  b->refcnt++;
    8000244e:	40bc                	lw	a5,64(s1)
    80002450:	2785                	addiw	a5,a5,1
    80002452:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002454:	0001a517          	auipc	a0,0x1a
    80002458:	df450513          	addi	a0,a0,-524 # 8001c248 <bcache>
    8000245c:	227030ef          	jal	80005e82 <release>
}
    80002460:	60e2                	ld	ra,24(sp)
    80002462:	6442                	ld	s0,16(sp)
    80002464:	64a2                	ld	s1,8(sp)
    80002466:	6105                	addi	sp,sp,32
    80002468:	8082                	ret

000000008000246a <bunpin>:

void
bunpin(struct buf *b) {
    8000246a:	1101                	addi	sp,sp,-32
    8000246c:	ec06                	sd	ra,24(sp)
    8000246e:	e822                	sd	s0,16(sp)
    80002470:	e426                	sd	s1,8(sp)
    80002472:	1000                	addi	s0,sp,32
    80002474:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002476:	0001a517          	auipc	a0,0x1a
    8000247a:	dd250513          	addi	a0,a0,-558 # 8001c248 <bcache>
    8000247e:	16d030ef          	jal	80005dea <acquire>
  b->refcnt--;
    80002482:	40bc                	lw	a5,64(s1)
    80002484:	37fd                	addiw	a5,a5,-1
    80002486:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002488:	0001a517          	auipc	a0,0x1a
    8000248c:	dc050513          	addi	a0,a0,-576 # 8001c248 <bcache>
    80002490:	1f3030ef          	jal	80005e82 <release>
}
    80002494:	60e2                	ld	ra,24(sp)
    80002496:	6442                	ld	s0,16(sp)
    80002498:	64a2                	ld	s1,8(sp)
    8000249a:	6105                	addi	sp,sp,32
    8000249c:	8082                	ret

000000008000249e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000249e:	1101                	addi	sp,sp,-32
    800024a0:	ec06                	sd	ra,24(sp)
    800024a2:	e822                	sd	s0,16(sp)
    800024a4:	e426                	sd	s1,8(sp)
    800024a6:	e04a                	sd	s2,0(sp)
    800024a8:	1000                	addi	s0,sp,32
    800024aa:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800024ac:	00d5d59b          	srliw	a1,a1,0xd
    800024b0:	00022797          	auipc	a5,0x22
    800024b4:	4747a783          	lw	a5,1140(a5) # 80024924 <sb+0x1c>
    800024b8:	9dbd                	addw	a1,a1,a5
    800024ba:	dedff0ef          	jal	800022a6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800024be:	0074f713          	andi	a4,s1,7
    800024c2:	4785                	li	a5,1
    800024c4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800024c8:	14ce                	slli	s1,s1,0x33
    800024ca:	90d9                	srli	s1,s1,0x36
    800024cc:	00950733          	add	a4,a0,s1
    800024d0:	05874703          	lbu	a4,88(a4)
    800024d4:	00e7f6b3          	and	a3,a5,a4
    800024d8:	c29d                	beqz	a3,800024fe <bfree+0x60>
    800024da:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800024dc:	94aa                	add	s1,s1,a0
    800024de:	fff7c793          	not	a5,a5
    800024e2:	8f7d                	and	a4,a4,a5
    800024e4:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800024e8:	7f9000ef          	jal	800034e0 <log_write>
  brelse(bp);
    800024ec:	854a                	mv	a0,s2
    800024ee:	ec1ff0ef          	jal	800023ae <brelse>
}
    800024f2:	60e2                	ld	ra,24(sp)
    800024f4:	6442                	ld	s0,16(sp)
    800024f6:	64a2                	ld	s1,8(sp)
    800024f8:	6902                	ld	s2,0(sp)
    800024fa:	6105                	addi	sp,sp,32
    800024fc:	8082                	ret
    panic("freeing free block");
    800024fe:	00005517          	auipc	a0,0x5
    80002502:	f6a50513          	addi	a0,a0,-150 # 80007468 <etext+0x468>
    80002506:	628030ef          	jal	80005b2e <panic>

000000008000250a <balloc>:
{
    8000250a:	711d                	addi	sp,sp,-96
    8000250c:	ec86                	sd	ra,88(sp)
    8000250e:	e8a2                	sd	s0,80(sp)
    80002510:	e4a6                	sd	s1,72(sp)
    80002512:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002514:	00022797          	auipc	a5,0x22
    80002518:	3f87a783          	lw	a5,1016(a5) # 8002490c <sb+0x4>
    8000251c:	0e078f63          	beqz	a5,8000261a <balloc+0x110>
    80002520:	e0ca                	sd	s2,64(sp)
    80002522:	fc4e                	sd	s3,56(sp)
    80002524:	f852                	sd	s4,48(sp)
    80002526:	f456                	sd	s5,40(sp)
    80002528:	f05a                	sd	s6,32(sp)
    8000252a:	ec5e                	sd	s7,24(sp)
    8000252c:	e862                	sd	s8,16(sp)
    8000252e:	e466                	sd	s9,8(sp)
    80002530:	8baa                	mv	s7,a0
    80002532:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002534:	00022b17          	auipc	s6,0x22
    80002538:	3d4b0b13          	addi	s6,s6,980 # 80024908 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000253c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000253e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002540:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002542:	6c89                	lui	s9,0x2
    80002544:	a0b5                	j	800025b0 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002546:	97ca                	add	a5,a5,s2
    80002548:	8e55                	or	a2,a2,a3
    8000254a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000254e:	854a                	mv	a0,s2
    80002550:	791000ef          	jal	800034e0 <log_write>
        brelse(bp);
    80002554:	854a                	mv	a0,s2
    80002556:	e59ff0ef          	jal	800023ae <brelse>
  bp = bread(dev, bno);
    8000255a:	85a6                	mv	a1,s1
    8000255c:	855e                	mv	a0,s7
    8000255e:	d49ff0ef          	jal	800022a6 <bread>
    80002562:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002564:	40000613          	li	a2,1024
    80002568:	4581                	li	a1,0
    8000256a:	05850513          	addi	a0,a0,88
    8000256e:	be1fd0ef          	jal	8000014e <memset>
  log_write(bp);
    80002572:	854a                	mv	a0,s2
    80002574:	76d000ef          	jal	800034e0 <log_write>
  brelse(bp);
    80002578:	854a                	mv	a0,s2
    8000257a:	e35ff0ef          	jal	800023ae <brelse>
}
    8000257e:	6906                	ld	s2,64(sp)
    80002580:	79e2                	ld	s3,56(sp)
    80002582:	7a42                	ld	s4,48(sp)
    80002584:	7aa2                	ld	s5,40(sp)
    80002586:	7b02                	ld	s6,32(sp)
    80002588:	6be2                	ld	s7,24(sp)
    8000258a:	6c42                	ld	s8,16(sp)
    8000258c:	6ca2                	ld	s9,8(sp)
}
    8000258e:	8526                	mv	a0,s1
    80002590:	60e6                	ld	ra,88(sp)
    80002592:	6446                	ld	s0,80(sp)
    80002594:	64a6                	ld	s1,72(sp)
    80002596:	6125                	addi	sp,sp,96
    80002598:	8082                	ret
    brelse(bp);
    8000259a:	854a                	mv	a0,s2
    8000259c:	e13ff0ef          	jal	800023ae <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800025a0:	015c87bb          	addw	a5,s9,s5
    800025a4:	00078a9b          	sext.w	s5,a5
    800025a8:	004b2703          	lw	a4,4(s6)
    800025ac:	04eaff63          	bgeu	s5,a4,8000260a <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800025b0:	41fad79b          	sraiw	a5,s5,0x1f
    800025b4:	0137d79b          	srliw	a5,a5,0x13
    800025b8:	015787bb          	addw	a5,a5,s5
    800025bc:	40d7d79b          	sraiw	a5,a5,0xd
    800025c0:	01cb2583          	lw	a1,28(s6)
    800025c4:	9dbd                	addw	a1,a1,a5
    800025c6:	855e                	mv	a0,s7
    800025c8:	cdfff0ef          	jal	800022a6 <bread>
    800025cc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800025ce:	004b2503          	lw	a0,4(s6)
    800025d2:	000a849b          	sext.w	s1,s5
    800025d6:	8762                	mv	a4,s8
    800025d8:	fca4f1e3          	bgeu	s1,a0,8000259a <balloc+0x90>
      m = 1 << (bi % 8);
    800025dc:	00777693          	andi	a3,a4,7
    800025e0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800025e4:	41f7579b          	sraiw	a5,a4,0x1f
    800025e8:	01d7d79b          	srliw	a5,a5,0x1d
    800025ec:	9fb9                	addw	a5,a5,a4
    800025ee:	4037d79b          	sraiw	a5,a5,0x3
    800025f2:	00f90633          	add	a2,s2,a5
    800025f6:	05864603          	lbu	a2,88(a2)
    800025fa:	00c6f5b3          	and	a1,a3,a2
    800025fe:	d5a1                	beqz	a1,80002546 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002600:	2705                	addiw	a4,a4,1
    80002602:	2485                	addiw	s1,s1,1
    80002604:	fd471ae3          	bne	a4,s4,800025d8 <balloc+0xce>
    80002608:	bf49                	j	8000259a <balloc+0x90>
    8000260a:	6906                	ld	s2,64(sp)
    8000260c:	79e2                	ld	s3,56(sp)
    8000260e:	7a42                	ld	s4,48(sp)
    80002610:	7aa2                	ld	s5,40(sp)
    80002612:	7b02                	ld	s6,32(sp)
    80002614:	6be2                	ld	s7,24(sp)
    80002616:	6c42                	ld	s8,16(sp)
    80002618:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000261a:	00005517          	auipc	a0,0x5
    8000261e:	e6650513          	addi	a0,a0,-410 # 80007480 <etext+0x480>
    80002622:	226030ef          	jal	80005848 <printf>
  return 0;
    80002626:	4481                	li	s1,0
    80002628:	b79d                	j	8000258e <balloc+0x84>

000000008000262a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000262a:	7179                	addi	sp,sp,-48
    8000262c:	f406                	sd	ra,40(sp)
    8000262e:	f022                	sd	s0,32(sp)
    80002630:	ec26                	sd	s1,24(sp)
    80002632:	e84a                	sd	s2,16(sp)
    80002634:	e44e                	sd	s3,8(sp)
    80002636:	1800                	addi	s0,sp,48
    80002638:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000263a:	47ad                	li	a5,11
    8000263c:	02b7e663          	bltu	a5,a1,80002668 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002640:	02059793          	slli	a5,a1,0x20
    80002644:	01e7d593          	srli	a1,a5,0x1e
    80002648:	00b504b3          	add	s1,a0,a1
    8000264c:	0504a903          	lw	s2,80(s1)
    80002650:	06091a63          	bnez	s2,800026c4 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002654:	4108                	lw	a0,0(a0)
    80002656:	eb5ff0ef          	jal	8000250a <balloc>
    8000265a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000265e:	06090363          	beqz	s2,800026c4 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002662:	0524a823          	sw	s2,80(s1)
    80002666:	a8b9                	j	800026c4 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002668:	ff45849b          	addiw	s1,a1,-12
    8000266c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002670:	0ff00793          	li	a5,255
    80002674:	06e7ee63          	bltu	a5,a4,800026f0 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002678:	08052903          	lw	s2,128(a0)
    8000267c:	00091d63          	bnez	s2,80002696 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002680:	4108                	lw	a0,0(a0)
    80002682:	e89ff0ef          	jal	8000250a <balloc>
    80002686:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000268a:	02090d63          	beqz	s2,800026c4 <bmap+0x9a>
    8000268e:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002690:	0929a023          	sw	s2,128(s3)
    80002694:	a011                	j	80002698 <bmap+0x6e>
    80002696:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002698:	85ca                	mv	a1,s2
    8000269a:	0009a503          	lw	a0,0(s3)
    8000269e:	c09ff0ef          	jal	800022a6 <bread>
    800026a2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800026a4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800026a8:	02049713          	slli	a4,s1,0x20
    800026ac:	01e75593          	srli	a1,a4,0x1e
    800026b0:	00b784b3          	add	s1,a5,a1
    800026b4:	0004a903          	lw	s2,0(s1)
    800026b8:	00090e63          	beqz	s2,800026d4 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800026bc:	8552                	mv	a0,s4
    800026be:	cf1ff0ef          	jal	800023ae <brelse>
    return addr;
    800026c2:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800026c4:	854a                	mv	a0,s2
    800026c6:	70a2                	ld	ra,40(sp)
    800026c8:	7402                	ld	s0,32(sp)
    800026ca:	64e2                	ld	s1,24(sp)
    800026cc:	6942                	ld	s2,16(sp)
    800026ce:	69a2                	ld	s3,8(sp)
    800026d0:	6145                	addi	sp,sp,48
    800026d2:	8082                	ret
      addr = balloc(ip->dev);
    800026d4:	0009a503          	lw	a0,0(s3)
    800026d8:	e33ff0ef          	jal	8000250a <balloc>
    800026dc:	0005091b          	sext.w	s2,a0
      if(addr){
    800026e0:	fc090ee3          	beqz	s2,800026bc <bmap+0x92>
        a[bn] = addr;
    800026e4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800026e8:	8552                	mv	a0,s4
    800026ea:	5f7000ef          	jal	800034e0 <log_write>
    800026ee:	b7f9                	j	800026bc <bmap+0x92>
    800026f0:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800026f2:	00005517          	auipc	a0,0x5
    800026f6:	da650513          	addi	a0,a0,-602 # 80007498 <etext+0x498>
    800026fa:	434030ef          	jal	80005b2e <panic>

00000000800026fe <iget>:
{
    800026fe:	7179                	addi	sp,sp,-48
    80002700:	f406                	sd	ra,40(sp)
    80002702:	f022                	sd	s0,32(sp)
    80002704:	ec26                	sd	s1,24(sp)
    80002706:	e84a                	sd	s2,16(sp)
    80002708:	e44e                	sd	s3,8(sp)
    8000270a:	e052                	sd	s4,0(sp)
    8000270c:	1800                	addi	s0,sp,48
    8000270e:	89aa                	mv	s3,a0
    80002710:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002712:	00022517          	auipc	a0,0x22
    80002716:	21650513          	addi	a0,a0,534 # 80024928 <itable>
    8000271a:	6d0030ef          	jal	80005dea <acquire>
  empty = 0;
    8000271e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002720:	00022497          	auipc	s1,0x22
    80002724:	22048493          	addi	s1,s1,544 # 80024940 <itable+0x18>
    80002728:	00024697          	auipc	a3,0x24
    8000272c:	ca868693          	addi	a3,a3,-856 # 800263d0 <log>
    80002730:	a039                	j	8000273e <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002732:	02090963          	beqz	s2,80002764 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002736:	08848493          	addi	s1,s1,136
    8000273a:	02d48863          	beq	s1,a3,8000276a <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000273e:	449c                	lw	a5,8(s1)
    80002740:	fef059e3          	blez	a5,80002732 <iget+0x34>
    80002744:	4098                	lw	a4,0(s1)
    80002746:	ff3716e3          	bne	a4,s3,80002732 <iget+0x34>
    8000274a:	40d8                	lw	a4,4(s1)
    8000274c:	ff4713e3          	bne	a4,s4,80002732 <iget+0x34>
      ip->ref++;
    80002750:	2785                	addiw	a5,a5,1
    80002752:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002754:	00022517          	auipc	a0,0x22
    80002758:	1d450513          	addi	a0,a0,468 # 80024928 <itable>
    8000275c:	726030ef          	jal	80005e82 <release>
      return ip;
    80002760:	8926                	mv	s2,s1
    80002762:	a02d                	j	8000278c <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002764:	fbe9                	bnez	a5,80002736 <iget+0x38>
      empty = ip;
    80002766:	8926                	mv	s2,s1
    80002768:	b7f9                	j	80002736 <iget+0x38>
  if(empty == 0)
    8000276a:	02090a63          	beqz	s2,8000279e <iget+0xa0>
  ip->dev = dev;
    8000276e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002772:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002776:	4785                	li	a5,1
    80002778:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000277c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002780:	00022517          	auipc	a0,0x22
    80002784:	1a850513          	addi	a0,a0,424 # 80024928 <itable>
    80002788:	6fa030ef          	jal	80005e82 <release>
}
    8000278c:	854a                	mv	a0,s2
    8000278e:	70a2                	ld	ra,40(sp)
    80002790:	7402                	ld	s0,32(sp)
    80002792:	64e2                	ld	s1,24(sp)
    80002794:	6942                	ld	s2,16(sp)
    80002796:	69a2                	ld	s3,8(sp)
    80002798:	6a02                	ld	s4,0(sp)
    8000279a:	6145                	addi	sp,sp,48
    8000279c:	8082                	ret
    panic("iget: no inodes");
    8000279e:	00005517          	auipc	a0,0x5
    800027a2:	d1250513          	addi	a0,a0,-750 # 800074b0 <etext+0x4b0>
    800027a6:	388030ef          	jal	80005b2e <panic>

00000000800027aa <iinit>:
{
    800027aa:	7179                	addi	sp,sp,-48
    800027ac:	f406                	sd	ra,40(sp)
    800027ae:	f022                	sd	s0,32(sp)
    800027b0:	ec26                	sd	s1,24(sp)
    800027b2:	e84a                	sd	s2,16(sp)
    800027b4:	e44e                	sd	s3,8(sp)
    800027b6:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800027b8:	00005597          	auipc	a1,0x5
    800027bc:	d0858593          	addi	a1,a1,-760 # 800074c0 <etext+0x4c0>
    800027c0:	00022517          	auipc	a0,0x22
    800027c4:	16850513          	addi	a0,a0,360 # 80024928 <itable>
    800027c8:	5a2030ef          	jal	80005d6a <initlock>
  for(i = 0; i < NINODE; i++) {
    800027cc:	00022497          	auipc	s1,0x22
    800027d0:	18448493          	addi	s1,s1,388 # 80024950 <itable+0x28>
    800027d4:	00024997          	auipc	s3,0x24
    800027d8:	c0c98993          	addi	s3,s3,-1012 # 800263e0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800027dc:	00005917          	auipc	s2,0x5
    800027e0:	cec90913          	addi	s2,s2,-788 # 800074c8 <etext+0x4c8>
    800027e4:	85ca                	mv	a1,s2
    800027e6:	8526                	mv	a0,s1
    800027e8:	5bb000ef          	jal	800035a2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800027ec:	08848493          	addi	s1,s1,136
    800027f0:	ff349ae3          	bne	s1,s3,800027e4 <iinit+0x3a>
}
    800027f4:	70a2                	ld	ra,40(sp)
    800027f6:	7402                	ld	s0,32(sp)
    800027f8:	64e2                	ld	s1,24(sp)
    800027fa:	6942                	ld	s2,16(sp)
    800027fc:	69a2                	ld	s3,8(sp)
    800027fe:	6145                	addi	sp,sp,48
    80002800:	8082                	ret

0000000080002802 <ialloc>:
{
    80002802:	7139                	addi	sp,sp,-64
    80002804:	fc06                	sd	ra,56(sp)
    80002806:	f822                	sd	s0,48(sp)
    80002808:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000280a:	00022717          	auipc	a4,0x22
    8000280e:	10a72703          	lw	a4,266(a4) # 80024914 <sb+0xc>
    80002812:	4785                	li	a5,1
    80002814:	06e7f063          	bgeu	a5,a4,80002874 <ialloc+0x72>
    80002818:	f426                	sd	s1,40(sp)
    8000281a:	f04a                	sd	s2,32(sp)
    8000281c:	ec4e                	sd	s3,24(sp)
    8000281e:	e852                	sd	s4,16(sp)
    80002820:	e456                	sd	s5,8(sp)
    80002822:	e05a                	sd	s6,0(sp)
    80002824:	8aaa                	mv	s5,a0
    80002826:	8b2e                	mv	s6,a1
    80002828:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000282a:	00022a17          	auipc	s4,0x22
    8000282e:	0dea0a13          	addi	s4,s4,222 # 80024908 <sb>
    80002832:	00495593          	srli	a1,s2,0x4
    80002836:	018a2783          	lw	a5,24(s4)
    8000283a:	9dbd                	addw	a1,a1,a5
    8000283c:	8556                	mv	a0,s5
    8000283e:	a69ff0ef          	jal	800022a6 <bread>
    80002842:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002844:	05850993          	addi	s3,a0,88
    80002848:	00f97793          	andi	a5,s2,15
    8000284c:	079a                	slli	a5,a5,0x6
    8000284e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002850:	00099783          	lh	a5,0(s3)
    80002854:	cb9d                	beqz	a5,8000288a <ialloc+0x88>
    brelse(bp);
    80002856:	b59ff0ef          	jal	800023ae <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000285a:	0905                	addi	s2,s2,1
    8000285c:	00ca2703          	lw	a4,12(s4)
    80002860:	0009079b          	sext.w	a5,s2
    80002864:	fce7e7e3          	bltu	a5,a4,80002832 <ialloc+0x30>
    80002868:	74a2                	ld	s1,40(sp)
    8000286a:	7902                	ld	s2,32(sp)
    8000286c:	69e2                	ld	s3,24(sp)
    8000286e:	6a42                	ld	s4,16(sp)
    80002870:	6aa2                	ld	s5,8(sp)
    80002872:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80002874:	00005517          	auipc	a0,0x5
    80002878:	c5c50513          	addi	a0,a0,-932 # 800074d0 <etext+0x4d0>
    8000287c:	7cd020ef          	jal	80005848 <printf>
  return 0;
    80002880:	4501                	li	a0,0
}
    80002882:	70e2                	ld	ra,56(sp)
    80002884:	7442                	ld	s0,48(sp)
    80002886:	6121                	addi	sp,sp,64
    80002888:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000288a:	04000613          	li	a2,64
    8000288e:	4581                	li	a1,0
    80002890:	854e                	mv	a0,s3
    80002892:	8bdfd0ef          	jal	8000014e <memset>
      dip->type = type;
    80002896:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000289a:	8526                	mv	a0,s1
    8000289c:	445000ef          	jal	800034e0 <log_write>
      brelse(bp);
    800028a0:	8526                	mv	a0,s1
    800028a2:	b0dff0ef          	jal	800023ae <brelse>
      return iget(dev, inum);
    800028a6:	0009059b          	sext.w	a1,s2
    800028aa:	8556                	mv	a0,s5
    800028ac:	e53ff0ef          	jal	800026fe <iget>
    800028b0:	74a2                	ld	s1,40(sp)
    800028b2:	7902                	ld	s2,32(sp)
    800028b4:	69e2                	ld	s3,24(sp)
    800028b6:	6a42                	ld	s4,16(sp)
    800028b8:	6aa2                	ld	s5,8(sp)
    800028ba:	6b02                	ld	s6,0(sp)
    800028bc:	b7d9                	j	80002882 <ialloc+0x80>

00000000800028be <iupdate>:
{
    800028be:	1101                	addi	sp,sp,-32
    800028c0:	ec06                	sd	ra,24(sp)
    800028c2:	e822                	sd	s0,16(sp)
    800028c4:	e426                	sd	s1,8(sp)
    800028c6:	e04a                	sd	s2,0(sp)
    800028c8:	1000                	addi	s0,sp,32
    800028ca:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800028cc:	415c                	lw	a5,4(a0)
    800028ce:	0047d79b          	srliw	a5,a5,0x4
    800028d2:	00022597          	auipc	a1,0x22
    800028d6:	04e5a583          	lw	a1,78(a1) # 80024920 <sb+0x18>
    800028da:	9dbd                	addw	a1,a1,a5
    800028dc:	4108                	lw	a0,0(a0)
    800028de:	9c9ff0ef          	jal	800022a6 <bread>
    800028e2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800028e4:	05850793          	addi	a5,a0,88
    800028e8:	40d8                	lw	a4,4(s1)
    800028ea:	8b3d                	andi	a4,a4,15
    800028ec:	071a                	slli	a4,a4,0x6
    800028ee:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800028f0:	04449703          	lh	a4,68(s1)
    800028f4:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800028f8:	04649703          	lh	a4,70(s1)
    800028fc:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002900:	04849703          	lh	a4,72(s1)
    80002904:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002908:	04a49703          	lh	a4,74(s1)
    8000290c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002910:	44f8                	lw	a4,76(s1)
    80002912:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002914:	03400613          	li	a2,52
    80002918:	05048593          	addi	a1,s1,80
    8000291c:	00c78513          	addi	a0,a5,12
    80002920:	88bfd0ef          	jal	800001aa <memmove>
  log_write(bp);
    80002924:	854a                	mv	a0,s2
    80002926:	3bb000ef          	jal	800034e0 <log_write>
  brelse(bp);
    8000292a:	854a                	mv	a0,s2
    8000292c:	a83ff0ef          	jal	800023ae <brelse>
}
    80002930:	60e2                	ld	ra,24(sp)
    80002932:	6442                	ld	s0,16(sp)
    80002934:	64a2                	ld	s1,8(sp)
    80002936:	6902                	ld	s2,0(sp)
    80002938:	6105                	addi	sp,sp,32
    8000293a:	8082                	ret

000000008000293c <idup>:
{
    8000293c:	1101                	addi	sp,sp,-32
    8000293e:	ec06                	sd	ra,24(sp)
    80002940:	e822                	sd	s0,16(sp)
    80002942:	e426                	sd	s1,8(sp)
    80002944:	1000                	addi	s0,sp,32
    80002946:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002948:	00022517          	auipc	a0,0x22
    8000294c:	fe050513          	addi	a0,a0,-32 # 80024928 <itable>
    80002950:	49a030ef          	jal	80005dea <acquire>
  ip->ref++;
    80002954:	449c                	lw	a5,8(s1)
    80002956:	2785                	addiw	a5,a5,1
    80002958:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000295a:	00022517          	auipc	a0,0x22
    8000295e:	fce50513          	addi	a0,a0,-50 # 80024928 <itable>
    80002962:	520030ef          	jal	80005e82 <release>
}
    80002966:	8526                	mv	a0,s1
    80002968:	60e2                	ld	ra,24(sp)
    8000296a:	6442                	ld	s0,16(sp)
    8000296c:	64a2                	ld	s1,8(sp)
    8000296e:	6105                	addi	sp,sp,32
    80002970:	8082                	ret

0000000080002972 <ilock>:
{
    80002972:	1101                	addi	sp,sp,-32
    80002974:	ec06                	sd	ra,24(sp)
    80002976:	e822                	sd	s0,16(sp)
    80002978:	e426                	sd	s1,8(sp)
    8000297a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000297c:	cd19                	beqz	a0,8000299a <ilock+0x28>
    8000297e:	84aa                	mv	s1,a0
    80002980:	451c                	lw	a5,8(a0)
    80002982:	00f05c63          	blez	a5,8000299a <ilock+0x28>
  acquiresleep(&ip->lock);
    80002986:	0541                	addi	a0,a0,16
    80002988:	451000ef          	jal	800035d8 <acquiresleep>
  if(ip->valid == 0){
    8000298c:	40bc                	lw	a5,64(s1)
    8000298e:	cf89                	beqz	a5,800029a8 <ilock+0x36>
}
    80002990:	60e2                	ld	ra,24(sp)
    80002992:	6442                	ld	s0,16(sp)
    80002994:	64a2                	ld	s1,8(sp)
    80002996:	6105                	addi	sp,sp,32
    80002998:	8082                	ret
    8000299a:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000299c:	00005517          	auipc	a0,0x5
    800029a0:	b4c50513          	addi	a0,a0,-1204 # 800074e8 <etext+0x4e8>
    800029a4:	18a030ef          	jal	80005b2e <panic>
    800029a8:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800029aa:	40dc                	lw	a5,4(s1)
    800029ac:	0047d79b          	srliw	a5,a5,0x4
    800029b0:	00022597          	auipc	a1,0x22
    800029b4:	f705a583          	lw	a1,-144(a1) # 80024920 <sb+0x18>
    800029b8:	9dbd                	addw	a1,a1,a5
    800029ba:	4088                	lw	a0,0(s1)
    800029bc:	8ebff0ef          	jal	800022a6 <bread>
    800029c0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800029c2:	05850593          	addi	a1,a0,88
    800029c6:	40dc                	lw	a5,4(s1)
    800029c8:	8bbd                	andi	a5,a5,15
    800029ca:	079a                	slli	a5,a5,0x6
    800029cc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800029ce:	00059783          	lh	a5,0(a1)
    800029d2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800029d6:	00259783          	lh	a5,2(a1)
    800029da:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800029de:	00459783          	lh	a5,4(a1)
    800029e2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800029e6:	00659783          	lh	a5,6(a1)
    800029ea:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800029ee:	459c                	lw	a5,8(a1)
    800029f0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800029f2:	03400613          	li	a2,52
    800029f6:	05b1                	addi	a1,a1,12
    800029f8:	05048513          	addi	a0,s1,80
    800029fc:	faefd0ef          	jal	800001aa <memmove>
    brelse(bp);
    80002a00:	854a                	mv	a0,s2
    80002a02:	9adff0ef          	jal	800023ae <brelse>
    ip->valid = 1;
    80002a06:	4785                	li	a5,1
    80002a08:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002a0a:	04449783          	lh	a5,68(s1)
    80002a0e:	c399                	beqz	a5,80002a14 <ilock+0xa2>
    80002a10:	6902                	ld	s2,0(sp)
    80002a12:	bfbd                	j	80002990 <ilock+0x1e>
      panic("ilock: no type");
    80002a14:	00005517          	auipc	a0,0x5
    80002a18:	adc50513          	addi	a0,a0,-1316 # 800074f0 <etext+0x4f0>
    80002a1c:	112030ef          	jal	80005b2e <panic>

0000000080002a20 <iunlock>:
{
    80002a20:	1101                	addi	sp,sp,-32
    80002a22:	ec06                	sd	ra,24(sp)
    80002a24:	e822                	sd	s0,16(sp)
    80002a26:	e426                	sd	s1,8(sp)
    80002a28:	e04a                	sd	s2,0(sp)
    80002a2a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002a2c:	c505                	beqz	a0,80002a54 <iunlock+0x34>
    80002a2e:	84aa                	mv	s1,a0
    80002a30:	01050913          	addi	s2,a0,16
    80002a34:	854a                	mv	a0,s2
    80002a36:	421000ef          	jal	80003656 <holdingsleep>
    80002a3a:	cd09                	beqz	a0,80002a54 <iunlock+0x34>
    80002a3c:	449c                	lw	a5,8(s1)
    80002a3e:	00f05b63          	blez	a5,80002a54 <iunlock+0x34>
  releasesleep(&ip->lock);
    80002a42:	854a                	mv	a0,s2
    80002a44:	3db000ef          	jal	8000361e <releasesleep>
}
    80002a48:	60e2                	ld	ra,24(sp)
    80002a4a:	6442                	ld	s0,16(sp)
    80002a4c:	64a2                	ld	s1,8(sp)
    80002a4e:	6902                	ld	s2,0(sp)
    80002a50:	6105                	addi	sp,sp,32
    80002a52:	8082                	ret
    panic("iunlock");
    80002a54:	00005517          	auipc	a0,0x5
    80002a58:	aac50513          	addi	a0,a0,-1364 # 80007500 <etext+0x500>
    80002a5c:	0d2030ef          	jal	80005b2e <panic>

0000000080002a60 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002a60:	7179                	addi	sp,sp,-48
    80002a62:	f406                	sd	ra,40(sp)
    80002a64:	f022                	sd	s0,32(sp)
    80002a66:	ec26                	sd	s1,24(sp)
    80002a68:	e84a                	sd	s2,16(sp)
    80002a6a:	e44e                	sd	s3,8(sp)
    80002a6c:	1800                	addi	s0,sp,48
    80002a6e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002a70:	05050493          	addi	s1,a0,80
    80002a74:	08050913          	addi	s2,a0,128
    80002a78:	a021                	j	80002a80 <itrunc+0x20>
    80002a7a:	0491                	addi	s1,s1,4
    80002a7c:	01248b63          	beq	s1,s2,80002a92 <itrunc+0x32>
    if(ip->addrs[i]){
    80002a80:	408c                	lw	a1,0(s1)
    80002a82:	dde5                	beqz	a1,80002a7a <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80002a84:	0009a503          	lw	a0,0(s3)
    80002a88:	a17ff0ef          	jal	8000249e <bfree>
      ip->addrs[i] = 0;
    80002a8c:	0004a023          	sw	zero,0(s1)
    80002a90:	b7ed                	j	80002a7a <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002a92:	0809a583          	lw	a1,128(s3)
    80002a96:	ed89                	bnez	a1,80002ab0 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002a98:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002a9c:	854e                	mv	a0,s3
    80002a9e:	e21ff0ef          	jal	800028be <iupdate>
}
    80002aa2:	70a2                	ld	ra,40(sp)
    80002aa4:	7402                	ld	s0,32(sp)
    80002aa6:	64e2                	ld	s1,24(sp)
    80002aa8:	6942                	ld	s2,16(sp)
    80002aaa:	69a2                	ld	s3,8(sp)
    80002aac:	6145                	addi	sp,sp,48
    80002aae:	8082                	ret
    80002ab0:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002ab2:	0009a503          	lw	a0,0(s3)
    80002ab6:	ff0ff0ef          	jal	800022a6 <bread>
    80002aba:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002abc:	05850493          	addi	s1,a0,88
    80002ac0:	45850913          	addi	s2,a0,1112
    80002ac4:	a021                	j	80002acc <itrunc+0x6c>
    80002ac6:	0491                	addi	s1,s1,4
    80002ac8:	01248963          	beq	s1,s2,80002ada <itrunc+0x7a>
      if(a[j])
    80002acc:	408c                	lw	a1,0(s1)
    80002ace:	dde5                	beqz	a1,80002ac6 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80002ad0:	0009a503          	lw	a0,0(s3)
    80002ad4:	9cbff0ef          	jal	8000249e <bfree>
    80002ad8:	b7fd                	j	80002ac6 <itrunc+0x66>
    brelse(bp);
    80002ada:	8552                	mv	a0,s4
    80002adc:	8d3ff0ef          	jal	800023ae <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002ae0:	0809a583          	lw	a1,128(s3)
    80002ae4:	0009a503          	lw	a0,0(s3)
    80002ae8:	9b7ff0ef          	jal	8000249e <bfree>
    ip->addrs[NDIRECT] = 0;
    80002aec:	0809a023          	sw	zero,128(s3)
    80002af0:	6a02                	ld	s4,0(sp)
    80002af2:	b75d                	j	80002a98 <itrunc+0x38>

0000000080002af4 <iput>:
{
    80002af4:	1101                	addi	sp,sp,-32
    80002af6:	ec06                	sd	ra,24(sp)
    80002af8:	e822                	sd	s0,16(sp)
    80002afa:	e426                	sd	s1,8(sp)
    80002afc:	1000                	addi	s0,sp,32
    80002afe:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002b00:	00022517          	auipc	a0,0x22
    80002b04:	e2850513          	addi	a0,a0,-472 # 80024928 <itable>
    80002b08:	2e2030ef          	jal	80005dea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002b0c:	4498                	lw	a4,8(s1)
    80002b0e:	4785                	li	a5,1
    80002b10:	02f70063          	beq	a4,a5,80002b30 <iput+0x3c>
  ip->ref--;
    80002b14:	449c                	lw	a5,8(s1)
    80002b16:	37fd                	addiw	a5,a5,-1
    80002b18:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002b1a:	00022517          	auipc	a0,0x22
    80002b1e:	e0e50513          	addi	a0,a0,-498 # 80024928 <itable>
    80002b22:	360030ef          	jal	80005e82 <release>
}
    80002b26:	60e2                	ld	ra,24(sp)
    80002b28:	6442                	ld	s0,16(sp)
    80002b2a:	64a2                	ld	s1,8(sp)
    80002b2c:	6105                	addi	sp,sp,32
    80002b2e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002b30:	40bc                	lw	a5,64(s1)
    80002b32:	d3ed                	beqz	a5,80002b14 <iput+0x20>
    80002b34:	04a49783          	lh	a5,74(s1)
    80002b38:	fff1                	bnez	a5,80002b14 <iput+0x20>
    80002b3a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80002b3c:	01048913          	addi	s2,s1,16
    80002b40:	854a                	mv	a0,s2
    80002b42:	297000ef          	jal	800035d8 <acquiresleep>
    release(&itable.lock);
    80002b46:	00022517          	auipc	a0,0x22
    80002b4a:	de250513          	addi	a0,a0,-542 # 80024928 <itable>
    80002b4e:	334030ef          	jal	80005e82 <release>
    itrunc(ip);
    80002b52:	8526                	mv	a0,s1
    80002b54:	f0dff0ef          	jal	80002a60 <itrunc>
    ip->type = 0;
    80002b58:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002b5c:	8526                	mv	a0,s1
    80002b5e:	d61ff0ef          	jal	800028be <iupdate>
    ip->valid = 0;
    80002b62:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002b66:	854a                	mv	a0,s2
    80002b68:	2b7000ef          	jal	8000361e <releasesleep>
    acquire(&itable.lock);
    80002b6c:	00022517          	auipc	a0,0x22
    80002b70:	dbc50513          	addi	a0,a0,-580 # 80024928 <itable>
    80002b74:	276030ef          	jal	80005dea <acquire>
    80002b78:	6902                	ld	s2,0(sp)
    80002b7a:	bf69                	j	80002b14 <iput+0x20>

0000000080002b7c <iunlockput>:
{
    80002b7c:	1101                	addi	sp,sp,-32
    80002b7e:	ec06                	sd	ra,24(sp)
    80002b80:	e822                	sd	s0,16(sp)
    80002b82:	e426                	sd	s1,8(sp)
    80002b84:	1000                	addi	s0,sp,32
    80002b86:	84aa                	mv	s1,a0
  iunlock(ip);
    80002b88:	e99ff0ef          	jal	80002a20 <iunlock>
  iput(ip);
    80002b8c:	8526                	mv	a0,s1
    80002b8e:	f67ff0ef          	jal	80002af4 <iput>
}
    80002b92:	60e2                	ld	ra,24(sp)
    80002b94:	6442                	ld	s0,16(sp)
    80002b96:	64a2                	ld	s1,8(sp)
    80002b98:	6105                	addi	sp,sp,32
    80002b9a:	8082                	ret

0000000080002b9c <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002b9c:	00022717          	auipc	a4,0x22
    80002ba0:	d7872703          	lw	a4,-648(a4) # 80024914 <sb+0xc>
    80002ba4:	4785                	li	a5,1
    80002ba6:	0ae7ff63          	bgeu	a5,a4,80002c64 <ireclaim+0xc8>
{
    80002baa:	7139                	addi	sp,sp,-64
    80002bac:	fc06                	sd	ra,56(sp)
    80002bae:	f822                	sd	s0,48(sp)
    80002bb0:	f426                	sd	s1,40(sp)
    80002bb2:	f04a                	sd	s2,32(sp)
    80002bb4:	ec4e                	sd	s3,24(sp)
    80002bb6:	e852                	sd	s4,16(sp)
    80002bb8:	e456                	sd	s5,8(sp)
    80002bba:	e05a                	sd	s6,0(sp)
    80002bbc:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002bbe:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80002bc0:	00050a1b          	sext.w	s4,a0
    80002bc4:	00022a97          	auipc	s5,0x22
    80002bc8:	d44a8a93          	addi	s5,s5,-700 # 80024908 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80002bcc:	00005b17          	auipc	s6,0x5
    80002bd0:	93cb0b13          	addi	s6,s6,-1732 # 80007508 <etext+0x508>
    80002bd4:	a099                	j	80002c1a <ireclaim+0x7e>
    80002bd6:	85ce                	mv	a1,s3
    80002bd8:	855a                	mv	a0,s6
    80002bda:	46f020ef          	jal	80005848 <printf>
      ip = iget(dev, inum);
    80002bde:	85ce                	mv	a1,s3
    80002be0:	8552                	mv	a0,s4
    80002be2:	b1dff0ef          	jal	800026fe <iget>
    80002be6:	89aa                	mv	s3,a0
    brelse(bp);
    80002be8:	854a                	mv	a0,s2
    80002bea:	fc4ff0ef          	jal	800023ae <brelse>
    if (ip) {
    80002bee:	00098f63          	beqz	s3,80002c0c <ireclaim+0x70>
      begin_op();
    80002bf2:	76a000ef          	jal	8000335c <begin_op>
      ilock(ip);
    80002bf6:	854e                	mv	a0,s3
    80002bf8:	d7bff0ef          	jal	80002972 <ilock>
      iunlock(ip);
    80002bfc:	854e                	mv	a0,s3
    80002bfe:	e23ff0ef          	jal	80002a20 <iunlock>
      iput(ip);
    80002c02:	854e                	mv	a0,s3
    80002c04:	ef1ff0ef          	jal	80002af4 <iput>
      end_op();
    80002c08:	7be000ef          	jal	800033c6 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002c0c:	0485                	addi	s1,s1,1
    80002c0e:	00caa703          	lw	a4,12(s5)
    80002c12:	0004879b          	sext.w	a5,s1
    80002c16:	02e7fd63          	bgeu	a5,a4,80002c50 <ireclaim+0xb4>
    80002c1a:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80002c1e:	0044d593          	srli	a1,s1,0x4
    80002c22:	018aa783          	lw	a5,24(s5)
    80002c26:	9dbd                	addw	a1,a1,a5
    80002c28:	8552                	mv	a0,s4
    80002c2a:	e7cff0ef          	jal	800022a6 <bread>
    80002c2e:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80002c30:	05850793          	addi	a5,a0,88
    80002c34:	00f9f713          	andi	a4,s3,15
    80002c38:	071a                	slli	a4,a4,0x6
    80002c3a:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80002c3c:	00079703          	lh	a4,0(a5)
    80002c40:	c701                	beqz	a4,80002c48 <ireclaim+0xac>
    80002c42:	00679783          	lh	a5,6(a5)
    80002c46:	dbc1                	beqz	a5,80002bd6 <ireclaim+0x3a>
    brelse(bp);
    80002c48:	854a                	mv	a0,s2
    80002c4a:	f64ff0ef          	jal	800023ae <brelse>
    if (ip) {
    80002c4e:	bf7d                	j	80002c0c <ireclaim+0x70>
}
    80002c50:	70e2                	ld	ra,56(sp)
    80002c52:	7442                	ld	s0,48(sp)
    80002c54:	74a2                	ld	s1,40(sp)
    80002c56:	7902                	ld	s2,32(sp)
    80002c58:	69e2                	ld	s3,24(sp)
    80002c5a:	6a42                	ld	s4,16(sp)
    80002c5c:	6aa2                	ld	s5,8(sp)
    80002c5e:	6b02                	ld	s6,0(sp)
    80002c60:	6121                	addi	sp,sp,64
    80002c62:	8082                	ret
    80002c64:	8082                	ret

0000000080002c66 <fsinit>:
fsinit(int dev) {
    80002c66:	7179                	addi	sp,sp,-48
    80002c68:	f406                	sd	ra,40(sp)
    80002c6a:	f022                	sd	s0,32(sp)
    80002c6c:	ec26                	sd	s1,24(sp)
    80002c6e:	e84a                	sd	s2,16(sp)
    80002c70:	e44e                	sd	s3,8(sp)
    80002c72:	1800                	addi	s0,sp,48
    80002c74:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80002c76:	4585                	li	a1,1
    80002c78:	e2eff0ef          	jal	800022a6 <bread>
    80002c7c:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002c7e:	00022997          	auipc	s3,0x22
    80002c82:	c8a98993          	addi	s3,s3,-886 # 80024908 <sb>
    80002c86:	02000613          	li	a2,32
    80002c8a:	05850593          	addi	a1,a0,88
    80002c8e:	854e                	mv	a0,s3
    80002c90:	d1afd0ef          	jal	800001aa <memmove>
  brelse(bp);
    80002c94:	854a                	mv	a0,s2
    80002c96:	f18ff0ef          	jal	800023ae <brelse>
  if(sb.magic != FSMAGIC)
    80002c9a:	0009a703          	lw	a4,0(s3)
    80002c9e:	102037b7          	lui	a5,0x10203
    80002ca2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002ca6:	02f71363          	bne	a4,a5,80002ccc <fsinit+0x66>
  initlog(dev, &sb);
    80002caa:	00022597          	auipc	a1,0x22
    80002cae:	c5e58593          	addi	a1,a1,-930 # 80024908 <sb>
    80002cb2:	8526                	mv	a0,s1
    80002cb4:	62a000ef          	jal	800032de <initlog>
  ireclaim(dev);
    80002cb8:	8526                	mv	a0,s1
    80002cba:	ee3ff0ef          	jal	80002b9c <ireclaim>
}
    80002cbe:	70a2                	ld	ra,40(sp)
    80002cc0:	7402                	ld	s0,32(sp)
    80002cc2:	64e2                	ld	s1,24(sp)
    80002cc4:	6942                	ld	s2,16(sp)
    80002cc6:	69a2                	ld	s3,8(sp)
    80002cc8:	6145                	addi	sp,sp,48
    80002cca:	8082                	ret
    panic("invalid file system");
    80002ccc:	00005517          	auipc	a0,0x5
    80002cd0:	85c50513          	addi	a0,a0,-1956 # 80007528 <etext+0x528>
    80002cd4:	65b020ef          	jal	80005b2e <panic>

0000000080002cd8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002cd8:	1141                	addi	sp,sp,-16
    80002cda:	e422                	sd	s0,8(sp)
    80002cdc:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002cde:	411c                	lw	a5,0(a0)
    80002ce0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002ce2:	415c                	lw	a5,4(a0)
    80002ce4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002ce6:	04451783          	lh	a5,68(a0)
    80002cea:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002cee:	04a51783          	lh	a5,74(a0)
    80002cf2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002cf6:	04c56783          	lwu	a5,76(a0)
    80002cfa:	e99c                	sd	a5,16(a1)
}
    80002cfc:	6422                	ld	s0,8(sp)
    80002cfe:	0141                	addi	sp,sp,16
    80002d00:	8082                	ret

0000000080002d02 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002d02:	457c                	lw	a5,76(a0)
    80002d04:	0ed7eb63          	bltu	a5,a3,80002dfa <readi+0xf8>
{
    80002d08:	7159                	addi	sp,sp,-112
    80002d0a:	f486                	sd	ra,104(sp)
    80002d0c:	f0a2                	sd	s0,96(sp)
    80002d0e:	eca6                	sd	s1,88(sp)
    80002d10:	e0d2                	sd	s4,64(sp)
    80002d12:	fc56                	sd	s5,56(sp)
    80002d14:	f85a                	sd	s6,48(sp)
    80002d16:	f45e                	sd	s7,40(sp)
    80002d18:	1880                	addi	s0,sp,112
    80002d1a:	8b2a                	mv	s6,a0
    80002d1c:	8bae                	mv	s7,a1
    80002d1e:	8a32                	mv	s4,a2
    80002d20:	84b6                	mv	s1,a3
    80002d22:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002d24:	9f35                	addw	a4,a4,a3
    return 0;
    80002d26:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002d28:	0cd76063          	bltu	a4,a3,80002de8 <readi+0xe6>
    80002d2c:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80002d2e:	00e7f463          	bgeu	a5,a4,80002d36 <readi+0x34>
    n = ip->size - off;
    80002d32:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002d36:	080a8f63          	beqz	s5,80002dd4 <readi+0xd2>
    80002d3a:	e8ca                	sd	s2,80(sp)
    80002d3c:	f062                	sd	s8,32(sp)
    80002d3e:	ec66                	sd	s9,24(sp)
    80002d40:	e86a                	sd	s10,16(sp)
    80002d42:	e46e                	sd	s11,8(sp)
    80002d44:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002d46:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002d4a:	5c7d                	li	s8,-1
    80002d4c:	a80d                	j	80002d7e <readi+0x7c>
    80002d4e:	020d1d93          	slli	s11,s10,0x20
    80002d52:	020ddd93          	srli	s11,s11,0x20
    80002d56:	05890613          	addi	a2,s2,88
    80002d5a:	86ee                	mv	a3,s11
    80002d5c:	963a                	add	a2,a2,a4
    80002d5e:	85d2                	mv	a1,s4
    80002d60:	855e                	mv	a0,s7
    80002d62:	a47fe0ef          	jal	800017a8 <either_copyout>
    80002d66:	05850763          	beq	a0,s8,80002db4 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002d6a:	854a                	mv	a0,s2
    80002d6c:	e42ff0ef          	jal	800023ae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002d70:	013d09bb          	addw	s3,s10,s3
    80002d74:	009d04bb          	addw	s1,s10,s1
    80002d78:	9a6e                	add	s4,s4,s11
    80002d7a:	0559f763          	bgeu	s3,s5,80002dc8 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80002d7e:	00a4d59b          	srliw	a1,s1,0xa
    80002d82:	855a                	mv	a0,s6
    80002d84:	8a7ff0ef          	jal	8000262a <bmap>
    80002d88:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002d8c:	c5b1                	beqz	a1,80002dd8 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80002d8e:	000b2503          	lw	a0,0(s6)
    80002d92:	d14ff0ef          	jal	800022a6 <bread>
    80002d96:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002d98:	3ff4f713          	andi	a4,s1,1023
    80002d9c:	40ec87bb          	subw	a5,s9,a4
    80002da0:	413a86bb          	subw	a3,s5,s3
    80002da4:	8d3e                	mv	s10,a5
    80002da6:	2781                	sext.w	a5,a5
    80002da8:	0006861b          	sext.w	a2,a3
    80002dac:	faf671e3          	bgeu	a2,a5,80002d4e <readi+0x4c>
    80002db0:	8d36                	mv	s10,a3
    80002db2:	bf71                	j	80002d4e <readi+0x4c>
      brelse(bp);
    80002db4:	854a                	mv	a0,s2
    80002db6:	df8ff0ef          	jal	800023ae <brelse>
      tot = -1;
    80002dba:	59fd                	li	s3,-1
      break;
    80002dbc:	6946                	ld	s2,80(sp)
    80002dbe:	7c02                	ld	s8,32(sp)
    80002dc0:	6ce2                	ld	s9,24(sp)
    80002dc2:	6d42                	ld	s10,16(sp)
    80002dc4:	6da2                	ld	s11,8(sp)
    80002dc6:	a831                	j	80002de2 <readi+0xe0>
    80002dc8:	6946                	ld	s2,80(sp)
    80002dca:	7c02                	ld	s8,32(sp)
    80002dcc:	6ce2                	ld	s9,24(sp)
    80002dce:	6d42                	ld	s10,16(sp)
    80002dd0:	6da2                	ld	s11,8(sp)
    80002dd2:	a801                	j	80002de2 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002dd4:	89d6                	mv	s3,s5
    80002dd6:	a031                	j	80002de2 <readi+0xe0>
    80002dd8:	6946                	ld	s2,80(sp)
    80002dda:	7c02                	ld	s8,32(sp)
    80002ddc:	6ce2                	ld	s9,24(sp)
    80002dde:	6d42                	ld	s10,16(sp)
    80002de0:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002de2:	0009851b          	sext.w	a0,s3
    80002de6:	69a6                	ld	s3,72(sp)
}
    80002de8:	70a6                	ld	ra,104(sp)
    80002dea:	7406                	ld	s0,96(sp)
    80002dec:	64e6                	ld	s1,88(sp)
    80002dee:	6a06                	ld	s4,64(sp)
    80002df0:	7ae2                	ld	s5,56(sp)
    80002df2:	7b42                	ld	s6,48(sp)
    80002df4:	7ba2                	ld	s7,40(sp)
    80002df6:	6165                	addi	sp,sp,112
    80002df8:	8082                	ret
    return 0;
    80002dfa:	4501                	li	a0,0
}
    80002dfc:	8082                	ret

0000000080002dfe <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002dfe:	457c                	lw	a5,76(a0)
    80002e00:	10d7e063          	bltu	a5,a3,80002f00 <writei+0x102>
{
    80002e04:	7159                	addi	sp,sp,-112
    80002e06:	f486                	sd	ra,104(sp)
    80002e08:	f0a2                	sd	s0,96(sp)
    80002e0a:	e8ca                	sd	s2,80(sp)
    80002e0c:	e0d2                	sd	s4,64(sp)
    80002e0e:	fc56                	sd	s5,56(sp)
    80002e10:	f85a                	sd	s6,48(sp)
    80002e12:	f45e                	sd	s7,40(sp)
    80002e14:	1880                	addi	s0,sp,112
    80002e16:	8aaa                	mv	s5,a0
    80002e18:	8bae                	mv	s7,a1
    80002e1a:	8a32                	mv	s4,a2
    80002e1c:	8936                	mv	s2,a3
    80002e1e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002e20:	00e687bb          	addw	a5,a3,a4
    80002e24:	0ed7e063          	bltu	a5,a3,80002f04 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002e28:	00043737          	lui	a4,0x43
    80002e2c:	0cf76e63          	bltu	a4,a5,80002f08 <writei+0x10a>
    80002e30:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002e32:	0a0b0f63          	beqz	s6,80002ef0 <writei+0xf2>
    80002e36:	eca6                	sd	s1,88(sp)
    80002e38:	f062                	sd	s8,32(sp)
    80002e3a:	ec66                	sd	s9,24(sp)
    80002e3c:	e86a                	sd	s10,16(sp)
    80002e3e:	e46e                	sd	s11,8(sp)
    80002e40:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002e42:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002e46:	5c7d                	li	s8,-1
    80002e48:	a825                	j	80002e80 <writei+0x82>
    80002e4a:	020d1d93          	slli	s11,s10,0x20
    80002e4e:	020ddd93          	srli	s11,s11,0x20
    80002e52:	05848513          	addi	a0,s1,88
    80002e56:	86ee                	mv	a3,s11
    80002e58:	8652                	mv	a2,s4
    80002e5a:	85de                	mv	a1,s7
    80002e5c:	953a                	add	a0,a0,a4
    80002e5e:	995fe0ef          	jal	800017f2 <either_copyin>
    80002e62:	05850a63          	beq	a0,s8,80002eb6 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002e66:	8526                	mv	a0,s1
    80002e68:	678000ef          	jal	800034e0 <log_write>
    brelse(bp);
    80002e6c:	8526                	mv	a0,s1
    80002e6e:	d40ff0ef          	jal	800023ae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002e72:	013d09bb          	addw	s3,s10,s3
    80002e76:	012d093b          	addw	s2,s10,s2
    80002e7a:	9a6e                	add	s4,s4,s11
    80002e7c:	0569f063          	bgeu	s3,s6,80002ebc <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002e80:	00a9559b          	srliw	a1,s2,0xa
    80002e84:	8556                	mv	a0,s5
    80002e86:	fa4ff0ef          	jal	8000262a <bmap>
    80002e8a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002e8e:	c59d                	beqz	a1,80002ebc <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002e90:	000aa503          	lw	a0,0(s5)
    80002e94:	c12ff0ef          	jal	800022a6 <bread>
    80002e98:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002e9a:	3ff97713          	andi	a4,s2,1023
    80002e9e:	40ec87bb          	subw	a5,s9,a4
    80002ea2:	413b06bb          	subw	a3,s6,s3
    80002ea6:	8d3e                	mv	s10,a5
    80002ea8:	2781                	sext.w	a5,a5
    80002eaa:	0006861b          	sext.w	a2,a3
    80002eae:	f8f67ee3          	bgeu	a2,a5,80002e4a <writei+0x4c>
    80002eb2:	8d36                	mv	s10,a3
    80002eb4:	bf59                	j	80002e4a <writei+0x4c>
      brelse(bp);
    80002eb6:	8526                	mv	a0,s1
    80002eb8:	cf6ff0ef          	jal	800023ae <brelse>
  }

  if(off > ip->size)
    80002ebc:	04caa783          	lw	a5,76(s5)
    80002ec0:	0327fa63          	bgeu	a5,s2,80002ef4 <writei+0xf6>
    ip->size = off;
    80002ec4:	052aa623          	sw	s2,76(s5)
    80002ec8:	64e6                	ld	s1,88(sp)
    80002eca:	7c02                	ld	s8,32(sp)
    80002ecc:	6ce2                	ld	s9,24(sp)
    80002ece:	6d42                	ld	s10,16(sp)
    80002ed0:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002ed2:	8556                	mv	a0,s5
    80002ed4:	9ebff0ef          	jal	800028be <iupdate>

  return tot;
    80002ed8:	0009851b          	sext.w	a0,s3
    80002edc:	69a6                	ld	s3,72(sp)
}
    80002ede:	70a6                	ld	ra,104(sp)
    80002ee0:	7406                	ld	s0,96(sp)
    80002ee2:	6946                	ld	s2,80(sp)
    80002ee4:	6a06                	ld	s4,64(sp)
    80002ee6:	7ae2                	ld	s5,56(sp)
    80002ee8:	7b42                	ld	s6,48(sp)
    80002eea:	7ba2                	ld	s7,40(sp)
    80002eec:	6165                	addi	sp,sp,112
    80002eee:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002ef0:	89da                	mv	s3,s6
    80002ef2:	b7c5                	j	80002ed2 <writei+0xd4>
    80002ef4:	64e6                	ld	s1,88(sp)
    80002ef6:	7c02                	ld	s8,32(sp)
    80002ef8:	6ce2                	ld	s9,24(sp)
    80002efa:	6d42                	ld	s10,16(sp)
    80002efc:	6da2                	ld	s11,8(sp)
    80002efe:	bfd1                	j	80002ed2 <writei+0xd4>
    return -1;
    80002f00:	557d                	li	a0,-1
}
    80002f02:	8082                	ret
    return -1;
    80002f04:	557d                	li	a0,-1
    80002f06:	bfe1                	j	80002ede <writei+0xe0>
    return -1;
    80002f08:	557d                	li	a0,-1
    80002f0a:	bfd1                	j	80002ede <writei+0xe0>

0000000080002f0c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002f0c:	1141                	addi	sp,sp,-16
    80002f0e:	e406                	sd	ra,8(sp)
    80002f10:	e022                	sd	s0,0(sp)
    80002f12:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002f14:	4639                	li	a2,14
    80002f16:	b04fd0ef          	jal	8000021a <strncmp>
}
    80002f1a:	60a2                	ld	ra,8(sp)
    80002f1c:	6402                	ld	s0,0(sp)
    80002f1e:	0141                	addi	sp,sp,16
    80002f20:	8082                	ret

0000000080002f22 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002f22:	7139                	addi	sp,sp,-64
    80002f24:	fc06                	sd	ra,56(sp)
    80002f26:	f822                	sd	s0,48(sp)
    80002f28:	f426                	sd	s1,40(sp)
    80002f2a:	f04a                	sd	s2,32(sp)
    80002f2c:	ec4e                	sd	s3,24(sp)
    80002f2e:	e852                	sd	s4,16(sp)
    80002f30:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002f32:	04451703          	lh	a4,68(a0)
    80002f36:	4785                	li	a5,1
    80002f38:	00f71a63          	bne	a4,a5,80002f4c <dirlookup+0x2a>
    80002f3c:	892a                	mv	s2,a0
    80002f3e:	89ae                	mv	s3,a1
    80002f40:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f42:	457c                	lw	a5,76(a0)
    80002f44:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002f46:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f48:	e39d                	bnez	a5,80002f6e <dirlookup+0x4c>
    80002f4a:	a095                	j	80002fae <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002f4c:	00004517          	auipc	a0,0x4
    80002f50:	5f450513          	addi	a0,a0,1524 # 80007540 <etext+0x540>
    80002f54:	3db020ef          	jal	80005b2e <panic>
      panic("dirlookup read");
    80002f58:	00004517          	auipc	a0,0x4
    80002f5c:	60050513          	addi	a0,a0,1536 # 80007558 <etext+0x558>
    80002f60:	3cf020ef          	jal	80005b2e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002f64:	24c1                	addiw	s1,s1,16
    80002f66:	04c92783          	lw	a5,76(s2)
    80002f6a:	04f4f163          	bgeu	s1,a5,80002fac <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002f6e:	4741                	li	a4,16
    80002f70:	86a6                	mv	a3,s1
    80002f72:	fc040613          	addi	a2,s0,-64
    80002f76:	4581                	li	a1,0
    80002f78:	854a                	mv	a0,s2
    80002f7a:	d89ff0ef          	jal	80002d02 <readi>
    80002f7e:	47c1                	li	a5,16
    80002f80:	fcf51ce3          	bne	a0,a5,80002f58 <dirlookup+0x36>
    if(de.inum == 0)
    80002f84:	fc045783          	lhu	a5,-64(s0)
    80002f88:	dff1                	beqz	a5,80002f64 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002f8a:	fc240593          	addi	a1,s0,-62
    80002f8e:	854e                	mv	a0,s3
    80002f90:	f7dff0ef          	jal	80002f0c <namecmp>
    80002f94:	f961                	bnez	a0,80002f64 <dirlookup+0x42>
      if(poff)
    80002f96:	000a0463          	beqz	s4,80002f9e <dirlookup+0x7c>
        *poff = off;
    80002f9a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002f9e:	fc045583          	lhu	a1,-64(s0)
    80002fa2:	00092503          	lw	a0,0(s2)
    80002fa6:	f58ff0ef          	jal	800026fe <iget>
    80002faa:	a011                	j	80002fae <dirlookup+0x8c>
  return 0;
    80002fac:	4501                	li	a0,0
}
    80002fae:	70e2                	ld	ra,56(sp)
    80002fb0:	7442                	ld	s0,48(sp)
    80002fb2:	74a2                	ld	s1,40(sp)
    80002fb4:	7902                	ld	s2,32(sp)
    80002fb6:	69e2                	ld	s3,24(sp)
    80002fb8:	6a42                	ld	s4,16(sp)
    80002fba:	6121                	addi	sp,sp,64
    80002fbc:	8082                	ret

0000000080002fbe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002fbe:	711d                	addi	sp,sp,-96
    80002fc0:	ec86                	sd	ra,88(sp)
    80002fc2:	e8a2                	sd	s0,80(sp)
    80002fc4:	e4a6                	sd	s1,72(sp)
    80002fc6:	e0ca                	sd	s2,64(sp)
    80002fc8:	fc4e                	sd	s3,56(sp)
    80002fca:	f852                	sd	s4,48(sp)
    80002fcc:	f456                	sd	s5,40(sp)
    80002fce:	f05a                	sd	s6,32(sp)
    80002fd0:	ec5e                	sd	s7,24(sp)
    80002fd2:	e862                	sd	s8,16(sp)
    80002fd4:	e466                	sd	s9,8(sp)
    80002fd6:	1080                	addi	s0,sp,96
    80002fd8:	84aa                	mv	s1,a0
    80002fda:	8b2e                	mv	s6,a1
    80002fdc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002fde:	00054703          	lbu	a4,0(a0)
    80002fe2:	02f00793          	li	a5,47
    80002fe6:	00f70e63          	beq	a4,a5,80003002 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002fea:	d91fd0ef          	jal	80000d7a <myproc>
    80002fee:	15053503          	ld	a0,336(a0)
    80002ff2:	94bff0ef          	jal	8000293c <idup>
    80002ff6:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002ff8:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002ffc:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002ffe:	4b85                	li	s7,1
    80003000:	a871                	j	8000309c <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003002:	4585                	li	a1,1
    80003004:	4505                	li	a0,1
    80003006:	ef8ff0ef          	jal	800026fe <iget>
    8000300a:	8a2a                	mv	s4,a0
    8000300c:	b7f5                	j	80002ff8 <namex+0x3a>
      iunlockput(ip);
    8000300e:	8552                	mv	a0,s4
    80003010:	b6dff0ef          	jal	80002b7c <iunlockput>
      return 0;
    80003014:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003016:	8552                	mv	a0,s4
    80003018:	60e6                	ld	ra,88(sp)
    8000301a:	6446                	ld	s0,80(sp)
    8000301c:	64a6                	ld	s1,72(sp)
    8000301e:	6906                	ld	s2,64(sp)
    80003020:	79e2                	ld	s3,56(sp)
    80003022:	7a42                	ld	s4,48(sp)
    80003024:	7aa2                	ld	s5,40(sp)
    80003026:	7b02                	ld	s6,32(sp)
    80003028:	6be2                	ld	s7,24(sp)
    8000302a:	6c42                	ld	s8,16(sp)
    8000302c:	6ca2                	ld	s9,8(sp)
    8000302e:	6125                	addi	sp,sp,96
    80003030:	8082                	ret
      iunlock(ip);
    80003032:	8552                	mv	a0,s4
    80003034:	9edff0ef          	jal	80002a20 <iunlock>
      return ip;
    80003038:	bff9                	j	80003016 <namex+0x58>
      iunlockput(ip);
    8000303a:	8552                	mv	a0,s4
    8000303c:	b41ff0ef          	jal	80002b7c <iunlockput>
      return 0;
    80003040:	8a4e                	mv	s4,s3
    80003042:	bfd1                	j	80003016 <namex+0x58>
  len = path - s;
    80003044:	40998633          	sub	a2,s3,s1
    80003048:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000304c:	099c5063          	bge	s8,s9,800030cc <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003050:	4639                	li	a2,14
    80003052:	85a6                	mv	a1,s1
    80003054:	8556                	mv	a0,s5
    80003056:	954fd0ef          	jal	800001aa <memmove>
    8000305a:	84ce                	mv	s1,s3
  while(*path == '/')
    8000305c:	0004c783          	lbu	a5,0(s1)
    80003060:	01279763          	bne	a5,s2,8000306e <namex+0xb0>
    path++;
    80003064:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003066:	0004c783          	lbu	a5,0(s1)
    8000306a:	ff278de3          	beq	a5,s2,80003064 <namex+0xa6>
    ilock(ip);
    8000306e:	8552                	mv	a0,s4
    80003070:	903ff0ef          	jal	80002972 <ilock>
    if(ip->type != T_DIR){
    80003074:	044a1783          	lh	a5,68(s4)
    80003078:	f9779be3          	bne	a5,s7,8000300e <namex+0x50>
    if(nameiparent && *path == '\0'){
    8000307c:	000b0563          	beqz	s6,80003086 <namex+0xc8>
    80003080:	0004c783          	lbu	a5,0(s1)
    80003084:	d7dd                	beqz	a5,80003032 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003086:	4601                	li	a2,0
    80003088:	85d6                	mv	a1,s5
    8000308a:	8552                	mv	a0,s4
    8000308c:	e97ff0ef          	jal	80002f22 <dirlookup>
    80003090:	89aa                	mv	s3,a0
    80003092:	d545                	beqz	a0,8000303a <namex+0x7c>
    iunlockput(ip);
    80003094:	8552                	mv	a0,s4
    80003096:	ae7ff0ef          	jal	80002b7c <iunlockput>
    ip = next;
    8000309a:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000309c:	0004c783          	lbu	a5,0(s1)
    800030a0:	01279763          	bne	a5,s2,800030ae <namex+0xf0>
    path++;
    800030a4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800030a6:	0004c783          	lbu	a5,0(s1)
    800030aa:	ff278de3          	beq	a5,s2,800030a4 <namex+0xe6>
  if(*path == 0)
    800030ae:	cb8d                	beqz	a5,800030e0 <namex+0x122>
  while(*path != '/' && *path != 0)
    800030b0:	0004c783          	lbu	a5,0(s1)
    800030b4:	89a6                	mv	s3,s1
  len = path - s;
    800030b6:	4c81                	li	s9,0
    800030b8:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800030ba:	01278963          	beq	a5,s2,800030cc <namex+0x10e>
    800030be:	d3d9                	beqz	a5,80003044 <namex+0x86>
    path++;
    800030c0:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800030c2:	0009c783          	lbu	a5,0(s3)
    800030c6:	ff279ce3          	bne	a5,s2,800030be <namex+0x100>
    800030ca:	bfad                	j	80003044 <namex+0x86>
    memmove(name, s, len);
    800030cc:	2601                	sext.w	a2,a2
    800030ce:	85a6                	mv	a1,s1
    800030d0:	8556                	mv	a0,s5
    800030d2:	8d8fd0ef          	jal	800001aa <memmove>
    name[len] = 0;
    800030d6:	9cd6                	add	s9,s9,s5
    800030d8:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800030dc:	84ce                	mv	s1,s3
    800030de:	bfbd                	j	8000305c <namex+0x9e>
  if(nameiparent){
    800030e0:	f20b0be3          	beqz	s6,80003016 <namex+0x58>
    iput(ip);
    800030e4:	8552                	mv	a0,s4
    800030e6:	a0fff0ef          	jal	80002af4 <iput>
    return 0;
    800030ea:	4a01                	li	s4,0
    800030ec:	b72d                	j	80003016 <namex+0x58>

00000000800030ee <dirlink>:
{
    800030ee:	7139                	addi	sp,sp,-64
    800030f0:	fc06                	sd	ra,56(sp)
    800030f2:	f822                	sd	s0,48(sp)
    800030f4:	f04a                	sd	s2,32(sp)
    800030f6:	ec4e                	sd	s3,24(sp)
    800030f8:	e852                	sd	s4,16(sp)
    800030fa:	0080                	addi	s0,sp,64
    800030fc:	892a                	mv	s2,a0
    800030fe:	8a2e                	mv	s4,a1
    80003100:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003102:	4601                	li	a2,0
    80003104:	e1fff0ef          	jal	80002f22 <dirlookup>
    80003108:	e535                	bnez	a0,80003174 <dirlink+0x86>
    8000310a:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000310c:	04c92483          	lw	s1,76(s2)
    80003110:	c48d                	beqz	s1,8000313a <dirlink+0x4c>
    80003112:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003114:	4741                	li	a4,16
    80003116:	86a6                	mv	a3,s1
    80003118:	fc040613          	addi	a2,s0,-64
    8000311c:	4581                	li	a1,0
    8000311e:	854a                	mv	a0,s2
    80003120:	be3ff0ef          	jal	80002d02 <readi>
    80003124:	47c1                	li	a5,16
    80003126:	04f51b63          	bne	a0,a5,8000317c <dirlink+0x8e>
    if(de.inum == 0)
    8000312a:	fc045783          	lhu	a5,-64(s0)
    8000312e:	c791                	beqz	a5,8000313a <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003130:	24c1                	addiw	s1,s1,16
    80003132:	04c92783          	lw	a5,76(s2)
    80003136:	fcf4efe3          	bltu	s1,a5,80003114 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    8000313a:	4639                	li	a2,14
    8000313c:	85d2                	mv	a1,s4
    8000313e:	fc240513          	addi	a0,s0,-62
    80003142:	90efd0ef          	jal	80000250 <strncpy>
  de.inum = inum;
    80003146:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000314a:	4741                	li	a4,16
    8000314c:	86a6                	mv	a3,s1
    8000314e:	fc040613          	addi	a2,s0,-64
    80003152:	4581                	li	a1,0
    80003154:	854a                	mv	a0,s2
    80003156:	ca9ff0ef          	jal	80002dfe <writei>
    8000315a:	1541                	addi	a0,a0,-16
    8000315c:	00a03533          	snez	a0,a0
    80003160:	40a00533          	neg	a0,a0
    80003164:	74a2                	ld	s1,40(sp)
}
    80003166:	70e2                	ld	ra,56(sp)
    80003168:	7442                	ld	s0,48(sp)
    8000316a:	7902                	ld	s2,32(sp)
    8000316c:	69e2                	ld	s3,24(sp)
    8000316e:	6a42                	ld	s4,16(sp)
    80003170:	6121                	addi	sp,sp,64
    80003172:	8082                	ret
    iput(ip);
    80003174:	981ff0ef          	jal	80002af4 <iput>
    return -1;
    80003178:	557d                	li	a0,-1
    8000317a:	b7f5                	j	80003166 <dirlink+0x78>
      panic("dirlink read");
    8000317c:	00004517          	auipc	a0,0x4
    80003180:	3ec50513          	addi	a0,a0,1004 # 80007568 <etext+0x568>
    80003184:	1ab020ef          	jal	80005b2e <panic>

0000000080003188 <namei>:

struct inode*
namei(char *path)
{
    80003188:	1101                	addi	sp,sp,-32
    8000318a:	ec06                	sd	ra,24(sp)
    8000318c:	e822                	sd	s0,16(sp)
    8000318e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003190:	fe040613          	addi	a2,s0,-32
    80003194:	4581                	li	a1,0
    80003196:	e29ff0ef          	jal	80002fbe <namex>
}
    8000319a:	60e2                	ld	ra,24(sp)
    8000319c:	6442                	ld	s0,16(sp)
    8000319e:	6105                	addi	sp,sp,32
    800031a0:	8082                	ret

00000000800031a2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800031a2:	1141                	addi	sp,sp,-16
    800031a4:	e406                	sd	ra,8(sp)
    800031a6:	e022                	sd	s0,0(sp)
    800031a8:	0800                	addi	s0,sp,16
    800031aa:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800031ac:	4585                	li	a1,1
    800031ae:	e11ff0ef          	jal	80002fbe <namex>
}
    800031b2:	60a2                	ld	ra,8(sp)
    800031b4:	6402                	ld	s0,0(sp)
    800031b6:	0141                	addi	sp,sp,16
    800031b8:	8082                	ret

00000000800031ba <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800031ba:	1101                	addi	sp,sp,-32
    800031bc:	ec06                	sd	ra,24(sp)
    800031be:	e822                	sd	s0,16(sp)
    800031c0:	e426                	sd	s1,8(sp)
    800031c2:	e04a                	sd	s2,0(sp)
    800031c4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800031c6:	00023917          	auipc	s2,0x23
    800031ca:	20a90913          	addi	s2,s2,522 # 800263d0 <log>
    800031ce:	01892583          	lw	a1,24(s2)
    800031d2:	02492503          	lw	a0,36(s2)
    800031d6:	8d0ff0ef          	jal	800022a6 <bread>
    800031da:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800031dc:	02892603          	lw	a2,40(s2)
    800031e0:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800031e2:	00c05f63          	blez	a2,80003200 <write_head+0x46>
    800031e6:	00023717          	auipc	a4,0x23
    800031ea:	21670713          	addi	a4,a4,534 # 800263fc <log+0x2c>
    800031ee:	87aa                	mv	a5,a0
    800031f0:	060a                	slli	a2,a2,0x2
    800031f2:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800031f4:	4314                	lw	a3,0(a4)
    800031f6:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800031f8:	0711                	addi	a4,a4,4
    800031fa:	0791                	addi	a5,a5,4
    800031fc:	fec79ce3          	bne	a5,a2,800031f4 <write_head+0x3a>
  }
  bwrite(buf);
    80003200:	8526                	mv	a0,s1
    80003202:	97aff0ef          	jal	8000237c <bwrite>
  brelse(buf);
    80003206:	8526                	mv	a0,s1
    80003208:	9a6ff0ef          	jal	800023ae <brelse>
}
    8000320c:	60e2                	ld	ra,24(sp)
    8000320e:	6442                	ld	s0,16(sp)
    80003210:	64a2                	ld	s1,8(sp)
    80003212:	6902                	ld	s2,0(sp)
    80003214:	6105                	addi	sp,sp,32
    80003216:	8082                	ret

0000000080003218 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003218:	00023797          	auipc	a5,0x23
    8000321c:	1e07a783          	lw	a5,480(a5) # 800263f8 <log+0x28>
    80003220:	0af05e63          	blez	a5,800032dc <install_trans+0xc4>
{
    80003224:	715d                	addi	sp,sp,-80
    80003226:	e486                	sd	ra,72(sp)
    80003228:	e0a2                	sd	s0,64(sp)
    8000322a:	fc26                	sd	s1,56(sp)
    8000322c:	f84a                	sd	s2,48(sp)
    8000322e:	f44e                	sd	s3,40(sp)
    80003230:	f052                	sd	s4,32(sp)
    80003232:	ec56                	sd	s5,24(sp)
    80003234:	e85a                	sd	s6,16(sp)
    80003236:	e45e                	sd	s7,8(sp)
    80003238:	0880                	addi	s0,sp,80
    8000323a:	8b2a                	mv	s6,a0
    8000323c:	00023a97          	auipc	s5,0x23
    80003240:	1c0a8a93          	addi	s5,s5,448 # 800263fc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003244:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003246:	00004b97          	auipc	s7,0x4
    8000324a:	332b8b93          	addi	s7,s7,818 # 80007578 <etext+0x578>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000324e:	00023a17          	auipc	s4,0x23
    80003252:	182a0a13          	addi	s4,s4,386 # 800263d0 <log>
    80003256:	a025                	j	8000327e <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003258:	000aa603          	lw	a2,0(s5)
    8000325c:	85ce                	mv	a1,s3
    8000325e:	855e                	mv	a0,s7
    80003260:	5e8020ef          	jal	80005848 <printf>
    80003264:	a839                	j	80003282 <install_trans+0x6a>
    brelse(lbuf);
    80003266:	854a                	mv	a0,s2
    80003268:	946ff0ef          	jal	800023ae <brelse>
    brelse(dbuf);
    8000326c:	8526                	mv	a0,s1
    8000326e:	940ff0ef          	jal	800023ae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003272:	2985                	addiw	s3,s3,1
    80003274:	0a91                	addi	s5,s5,4
    80003276:	028a2783          	lw	a5,40(s4)
    8000327a:	04f9d663          	bge	s3,a5,800032c6 <install_trans+0xae>
    if(recovering) {
    8000327e:	fc0b1de3          	bnez	s6,80003258 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003282:	018a2583          	lw	a1,24(s4)
    80003286:	013585bb          	addw	a1,a1,s3
    8000328a:	2585                	addiw	a1,a1,1
    8000328c:	024a2503          	lw	a0,36(s4)
    80003290:	816ff0ef          	jal	800022a6 <bread>
    80003294:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003296:	000aa583          	lw	a1,0(s5)
    8000329a:	024a2503          	lw	a0,36(s4)
    8000329e:	808ff0ef          	jal	800022a6 <bread>
    800032a2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800032a4:	40000613          	li	a2,1024
    800032a8:	05890593          	addi	a1,s2,88
    800032ac:	05850513          	addi	a0,a0,88
    800032b0:	efbfc0ef          	jal	800001aa <memmove>
    bwrite(dbuf);  // write dst to disk
    800032b4:	8526                	mv	a0,s1
    800032b6:	8c6ff0ef          	jal	8000237c <bwrite>
    if(recovering == 0)
    800032ba:	fa0b16e3          	bnez	s6,80003266 <install_trans+0x4e>
      bunpin(dbuf);
    800032be:	8526                	mv	a0,s1
    800032c0:	9aaff0ef          	jal	8000246a <bunpin>
    800032c4:	b74d                	j	80003266 <install_trans+0x4e>
}
    800032c6:	60a6                	ld	ra,72(sp)
    800032c8:	6406                	ld	s0,64(sp)
    800032ca:	74e2                	ld	s1,56(sp)
    800032cc:	7942                	ld	s2,48(sp)
    800032ce:	79a2                	ld	s3,40(sp)
    800032d0:	7a02                	ld	s4,32(sp)
    800032d2:	6ae2                	ld	s5,24(sp)
    800032d4:	6b42                	ld	s6,16(sp)
    800032d6:	6ba2                	ld	s7,8(sp)
    800032d8:	6161                	addi	sp,sp,80
    800032da:	8082                	ret
    800032dc:	8082                	ret

00000000800032de <initlog>:
{
    800032de:	7179                	addi	sp,sp,-48
    800032e0:	f406                	sd	ra,40(sp)
    800032e2:	f022                	sd	s0,32(sp)
    800032e4:	ec26                	sd	s1,24(sp)
    800032e6:	e84a                	sd	s2,16(sp)
    800032e8:	e44e                	sd	s3,8(sp)
    800032ea:	1800                	addi	s0,sp,48
    800032ec:	892a                	mv	s2,a0
    800032ee:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800032f0:	00023497          	auipc	s1,0x23
    800032f4:	0e048493          	addi	s1,s1,224 # 800263d0 <log>
    800032f8:	00004597          	auipc	a1,0x4
    800032fc:	2a058593          	addi	a1,a1,672 # 80007598 <etext+0x598>
    80003300:	8526                	mv	a0,s1
    80003302:	269020ef          	jal	80005d6a <initlock>
  log.start = sb->logstart;
    80003306:	0149a583          	lw	a1,20(s3)
    8000330a:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    8000330c:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003310:	854a                	mv	a0,s2
    80003312:	f95fe0ef          	jal	800022a6 <bread>
  log.lh.n = lh->n;
    80003316:	4d30                	lw	a2,88(a0)
    80003318:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000331a:	00c05f63          	blez	a2,80003338 <initlog+0x5a>
    8000331e:	87aa                	mv	a5,a0
    80003320:	00023717          	auipc	a4,0x23
    80003324:	0dc70713          	addi	a4,a4,220 # 800263fc <log+0x2c>
    80003328:	060a                	slli	a2,a2,0x2
    8000332a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000332c:	4ff4                	lw	a3,92(a5)
    8000332e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003330:	0791                	addi	a5,a5,4
    80003332:	0711                	addi	a4,a4,4
    80003334:	fec79ce3          	bne	a5,a2,8000332c <initlog+0x4e>
  brelse(buf);
    80003338:	876ff0ef          	jal	800023ae <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000333c:	4505                	li	a0,1
    8000333e:	edbff0ef          	jal	80003218 <install_trans>
  log.lh.n = 0;
    80003342:	00023797          	auipc	a5,0x23
    80003346:	0a07ab23          	sw	zero,182(a5) # 800263f8 <log+0x28>
  write_head(); // clear the log
    8000334a:	e71ff0ef          	jal	800031ba <write_head>
}
    8000334e:	70a2                	ld	ra,40(sp)
    80003350:	7402                	ld	s0,32(sp)
    80003352:	64e2                	ld	s1,24(sp)
    80003354:	6942                	ld	s2,16(sp)
    80003356:	69a2                	ld	s3,8(sp)
    80003358:	6145                	addi	sp,sp,48
    8000335a:	8082                	ret

000000008000335c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000335c:	1101                	addi	sp,sp,-32
    8000335e:	ec06                	sd	ra,24(sp)
    80003360:	e822                	sd	s0,16(sp)
    80003362:	e426                	sd	s1,8(sp)
    80003364:	e04a                	sd	s2,0(sp)
    80003366:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003368:	00023517          	auipc	a0,0x23
    8000336c:	06850513          	addi	a0,a0,104 # 800263d0 <log>
    80003370:	27b020ef          	jal	80005dea <acquire>
  while(1){
    if(log.committing){
    80003374:	00023497          	auipc	s1,0x23
    80003378:	05c48493          	addi	s1,s1,92 # 800263d0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000337c:	4979                	li	s2,30
    8000337e:	a029                	j	80003388 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003380:	85a6                	mv	a1,s1
    80003382:	8526                	mv	a0,s1
    80003384:	84cfe0ef          	jal	800013d0 <sleep>
    if(log.committing){
    80003388:	509c                	lw	a5,32(s1)
    8000338a:	fbfd                	bnez	a5,80003380 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000338c:	4cd8                	lw	a4,28(s1)
    8000338e:	2705                	addiw	a4,a4,1
    80003390:	0027179b          	slliw	a5,a4,0x2
    80003394:	9fb9                	addw	a5,a5,a4
    80003396:	0017979b          	slliw	a5,a5,0x1
    8000339a:	5494                	lw	a3,40(s1)
    8000339c:	9fb5                	addw	a5,a5,a3
    8000339e:	00f95763          	bge	s2,a5,800033ac <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800033a2:	85a6                	mv	a1,s1
    800033a4:	8526                	mv	a0,s1
    800033a6:	82afe0ef          	jal	800013d0 <sleep>
    800033aa:	bff9                	j	80003388 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800033ac:	00023517          	auipc	a0,0x23
    800033b0:	02450513          	addi	a0,a0,36 # 800263d0 <log>
    800033b4:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    800033b6:	2cd020ef          	jal	80005e82 <release>
      break;
    }
  }
}
    800033ba:	60e2                	ld	ra,24(sp)
    800033bc:	6442                	ld	s0,16(sp)
    800033be:	64a2                	ld	s1,8(sp)
    800033c0:	6902                	ld	s2,0(sp)
    800033c2:	6105                	addi	sp,sp,32
    800033c4:	8082                	ret

00000000800033c6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800033c6:	7139                	addi	sp,sp,-64
    800033c8:	fc06                	sd	ra,56(sp)
    800033ca:	f822                	sd	s0,48(sp)
    800033cc:	f426                	sd	s1,40(sp)
    800033ce:	f04a                	sd	s2,32(sp)
    800033d0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800033d2:	00023497          	auipc	s1,0x23
    800033d6:	ffe48493          	addi	s1,s1,-2 # 800263d0 <log>
    800033da:	8526                	mv	a0,s1
    800033dc:	20f020ef          	jal	80005dea <acquire>
  log.outstanding -= 1;
    800033e0:	4cdc                	lw	a5,28(s1)
    800033e2:	37fd                	addiw	a5,a5,-1
    800033e4:	0007891b          	sext.w	s2,a5
    800033e8:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800033ea:	509c                	lw	a5,32(s1)
    800033ec:	ef9d                	bnez	a5,8000342a <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    800033ee:	04091763          	bnez	s2,8000343c <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800033f2:	00023497          	auipc	s1,0x23
    800033f6:	fde48493          	addi	s1,s1,-34 # 800263d0 <log>
    800033fa:	4785                	li	a5,1
    800033fc:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800033fe:	8526                	mv	a0,s1
    80003400:	283020ef          	jal	80005e82 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003404:	549c                	lw	a5,40(s1)
    80003406:	04f04b63          	bgtz	a5,8000345c <end_op+0x96>
    acquire(&log.lock);
    8000340a:	00023497          	auipc	s1,0x23
    8000340e:	fc648493          	addi	s1,s1,-58 # 800263d0 <log>
    80003412:	8526                	mv	a0,s1
    80003414:	1d7020ef          	jal	80005dea <acquire>
    log.committing = 0;
    80003418:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    8000341c:	8526                	mv	a0,s1
    8000341e:	ffffd0ef          	jal	8000141c <wakeup>
    release(&log.lock);
    80003422:	8526                	mv	a0,s1
    80003424:	25f020ef          	jal	80005e82 <release>
}
    80003428:	a025                	j	80003450 <end_op+0x8a>
    8000342a:	ec4e                	sd	s3,24(sp)
    8000342c:	e852                	sd	s4,16(sp)
    8000342e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003430:	00004517          	auipc	a0,0x4
    80003434:	17050513          	addi	a0,a0,368 # 800075a0 <etext+0x5a0>
    80003438:	6f6020ef          	jal	80005b2e <panic>
    wakeup(&log);
    8000343c:	00023497          	auipc	s1,0x23
    80003440:	f9448493          	addi	s1,s1,-108 # 800263d0 <log>
    80003444:	8526                	mv	a0,s1
    80003446:	fd7fd0ef          	jal	8000141c <wakeup>
  release(&log.lock);
    8000344a:	8526                	mv	a0,s1
    8000344c:	237020ef          	jal	80005e82 <release>
}
    80003450:	70e2                	ld	ra,56(sp)
    80003452:	7442                	ld	s0,48(sp)
    80003454:	74a2                	ld	s1,40(sp)
    80003456:	7902                	ld	s2,32(sp)
    80003458:	6121                	addi	sp,sp,64
    8000345a:	8082                	ret
    8000345c:	ec4e                	sd	s3,24(sp)
    8000345e:	e852                	sd	s4,16(sp)
    80003460:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003462:	00023a97          	auipc	s5,0x23
    80003466:	f9aa8a93          	addi	s5,s5,-102 # 800263fc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000346a:	00023a17          	auipc	s4,0x23
    8000346e:	f66a0a13          	addi	s4,s4,-154 # 800263d0 <log>
    80003472:	018a2583          	lw	a1,24(s4)
    80003476:	012585bb          	addw	a1,a1,s2
    8000347a:	2585                	addiw	a1,a1,1
    8000347c:	024a2503          	lw	a0,36(s4)
    80003480:	e27fe0ef          	jal	800022a6 <bread>
    80003484:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003486:	000aa583          	lw	a1,0(s5)
    8000348a:	024a2503          	lw	a0,36(s4)
    8000348e:	e19fe0ef          	jal	800022a6 <bread>
    80003492:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003494:	40000613          	li	a2,1024
    80003498:	05850593          	addi	a1,a0,88
    8000349c:	05848513          	addi	a0,s1,88
    800034a0:	d0bfc0ef          	jal	800001aa <memmove>
    bwrite(to);  // write the log
    800034a4:	8526                	mv	a0,s1
    800034a6:	ed7fe0ef          	jal	8000237c <bwrite>
    brelse(from);
    800034aa:	854e                	mv	a0,s3
    800034ac:	f03fe0ef          	jal	800023ae <brelse>
    brelse(to);
    800034b0:	8526                	mv	a0,s1
    800034b2:	efdfe0ef          	jal	800023ae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800034b6:	2905                	addiw	s2,s2,1
    800034b8:	0a91                	addi	s5,s5,4
    800034ba:	028a2783          	lw	a5,40(s4)
    800034be:	faf94ae3          	blt	s2,a5,80003472 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800034c2:	cf9ff0ef          	jal	800031ba <write_head>
    install_trans(0); // Now install writes to home locations
    800034c6:	4501                	li	a0,0
    800034c8:	d51ff0ef          	jal	80003218 <install_trans>
    log.lh.n = 0;
    800034cc:	00023797          	auipc	a5,0x23
    800034d0:	f207a623          	sw	zero,-212(a5) # 800263f8 <log+0x28>
    write_head();    // Erase the transaction from the log
    800034d4:	ce7ff0ef          	jal	800031ba <write_head>
    800034d8:	69e2                	ld	s3,24(sp)
    800034da:	6a42                	ld	s4,16(sp)
    800034dc:	6aa2                	ld	s5,8(sp)
    800034de:	b735                	j	8000340a <end_op+0x44>

00000000800034e0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800034e0:	1101                	addi	sp,sp,-32
    800034e2:	ec06                	sd	ra,24(sp)
    800034e4:	e822                	sd	s0,16(sp)
    800034e6:	e426                	sd	s1,8(sp)
    800034e8:	e04a                	sd	s2,0(sp)
    800034ea:	1000                	addi	s0,sp,32
    800034ec:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800034ee:	00023917          	auipc	s2,0x23
    800034f2:	ee290913          	addi	s2,s2,-286 # 800263d0 <log>
    800034f6:	854a                	mv	a0,s2
    800034f8:	0f3020ef          	jal	80005dea <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800034fc:	02892603          	lw	a2,40(s2)
    80003500:	47f5                	li	a5,29
    80003502:	04c7cc63          	blt	a5,a2,8000355a <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003506:	00023797          	auipc	a5,0x23
    8000350a:	ee67a783          	lw	a5,-282(a5) # 800263ec <log+0x1c>
    8000350e:	04f05c63          	blez	a5,80003566 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003512:	4781                	li	a5,0
    80003514:	04c05f63          	blez	a2,80003572 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003518:	44cc                	lw	a1,12(s1)
    8000351a:	00023717          	auipc	a4,0x23
    8000351e:	ee270713          	addi	a4,a4,-286 # 800263fc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003522:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003524:	4314                	lw	a3,0(a4)
    80003526:	04b68663          	beq	a3,a1,80003572 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    8000352a:	2785                	addiw	a5,a5,1
    8000352c:	0711                	addi	a4,a4,4
    8000352e:	fef61be3          	bne	a2,a5,80003524 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003532:	0621                	addi	a2,a2,8
    80003534:	060a                	slli	a2,a2,0x2
    80003536:	00023797          	auipc	a5,0x23
    8000353a:	e9a78793          	addi	a5,a5,-358 # 800263d0 <log>
    8000353e:	97b2                	add	a5,a5,a2
    80003540:	44d8                	lw	a4,12(s1)
    80003542:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003544:	8526                	mv	a0,s1
    80003546:	ef1fe0ef          	jal	80002436 <bpin>
    log.lh.n++;
    8000354a:	00023717          	auipc	a4,0x23
    8000354e:	e8670713          	addi	a4,a4,-378 # 800263d0 <log>
    80003552:	571c                	lw	a5,40(a4)
    80003554:	2785                	addiw	a5,a5,1
    80003556:	d71c                	sw	a5,40(a4)
    80003558:	a80d                	j	8000358a <log_write+0xaa>
    panic("too big a transaction");
    8000355a:	00004517          	auipc	a0,0x4
    8000355e:	05650513          	addi	a0,a0,86 # 800075b0 <etext+0x5b0>
    80003562:	5cc020ef          	jal	80005b2e <panic>
    panic("log_write outside of trans");
    80003566:	00004517          	auipc	a0,0x4
    8000356a:	06250513          	addi	a0,a0,98 # 800075c8 <etext+0x5c8>
    8000356e:	5c0020ef          	jal	80005b2e <panic>
  log.lh.block[i] = b->blockno;
    80003572:	00878693          	addi	a3,a5,8
    80003576:	068a                	slli	a3,a3,0x2
    80003578:	00023717          	auipc	a4,0x23
    8000357c:	e5870713          	addi	a4,a4,-424 # 800263d0 <log>
    80003580:	9736                	add	a4,a4,a3
    80003582:	44d4                	lw	a3,12(s1)
    80003584:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003586:	faf60fe3          	beq	a2,a5,80003544 <log_write+0x64>
  }
  release(&log.lock);
    8000358a:	00023517          	auipc	a0,0x23
    8000358e:	e4650513          	addi	a0,a0,-442 # 800263d0 <log>
    80003592:	0f1020ef          	jal	80005e82 <release>
}
    80003596:	60e2                	ld	ra,24(sp)
    80003598:	6442                	ld	s0,16(sp)
    8000359a:	64a2                	ld	s1,8(sp)
    8000359c:	6902                	ld	s2,0(sp)
    8000359e:	6105                	addi	sp,sp,32
    800035a0:	8082                	ret

00000000800035a2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800035a2:	1101                	addi	sp,sp,-32
    800035a4:	ec06                	sd	ra,24(sp)
    800035a6:	e822                	sd	s0,16(sp)
    800035a8:	e426                	sd	s1,8(sp)
    800035aa:	e04a                	sd	s2,0(sp)
    800035ac:	1000                	addi	s0,sp,32
    800035ae:	84aa                	mv	s1,a0
    800035b0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800035b2:	00004597          	auipc	a1,0x4
    800035b6:	03658593          	addi	a1,a1,54 # 800075e8 <etext+0x5e8>
    800035ba:	0521                	addi	a0,a0,8
    800035bc:	7ae020ef          	jal	80005d6a <initlock>
  lk->name = name;
    800035c0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800035c4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800035c8:	0204a423          	sw	zero,40(s1)
}
    800035cc:	60e2                	ld	ra,24(sp)
    800035ce:	6442                	ld	s0,16(sp)
    800035d0:	64a2                	ld	s1,8(sp)
    800035d2:	6902                	ld	s2,0(sp)
    800035d4:	6105                	addi	sp,sp,32
    800035d6:	8082                	ret

00000000800035d8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800035d8:	1101                	addi	sp,sp,-32
    800035da:	ec06                	sd	ra,24(sp)
    800035dc:	e822                	sd	s0,16(sp)
    800035de:	e426                	sd	s1,8(sp)
    800035e0:	e04a                	sd	s2,0(sp)
    800035e2:	1000                	addi	s0,sp,32
    800035e4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800035e6:	00850913          	addi	s2,a0,8
    800035ea:	854a                	mv	a0,s2
    800035ec:	7fe020ef          	jal	80005dea <acquire>
  while (lk->locked) {
    800035f0:	409c                	lw	a5,0(s1)
    800035f2:	c799                	beqz	a5,80003600 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800035f4:	85ca                	mv	a1,s2
    800035f6:	8526                	mv	a0,s1
    800035f8:	dd9fd0ef          	jal	800013d0 <sleep>
  while (lk->locked) {
    800035fc:	409c                	lw	a5,0(s1)
    800035fe:	fbfd                	bnez	a5,800035f4 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003600:	4785                	li	a5,1
    80003602:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003604:	f76fd0ef          	jal	80000d7a <myproc>
    80003608:	591c                	lw	a5,48(a0)
    8000360a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000360c:	854a                	mv	a0,s2
    8000360e:	075020ef          	jal	80005e82 <release>
}
    80003612:	60e2                	ld	ra,24(sp)
    80003614:	6442                	ld	s0,16(sp)
    80003616:	64a2                	ld	s1,8(sp)
    80003618:	6902                	ld	s2,0(sp)
    8000361a:	6105                	addi	sp,sp,32
    8000361c:	8082                	ret

000000008000361e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000361e:	1101                	addi	sp,sp,-32
    80003620:	ec06                	sd	ra,24(sp)
    80003622:	e822                	sd	s0,16(sp)
    80003624:	e426                	sd	s1,8(sp)
    80003626:	e04a                	sd	s2,0(sp)
    80003628:	1000                	addi	s0,sp,32
    8000362a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000362c:	00850913          	addi	s2,a0,8
    80003630:	854a                	mv	a0,s2
    80003632:	7b8020ef          	jal	80005dea <acquire>
  lk->locked = 0;
    80003636:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000363a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000363e:	8526                	mv	a0,s1
    80003640:	dddfd0ef          	jal	8000141c <wakeup>
  release(&lk->lk);
    80003644:	854a                	mv	a0,s2
    80003646:	03d020ef          	jal	80005e82 <release>
}
    8000364a:	60e2                	ld	ra,24(sp)
    8000364c:	6442                	ld	s0,16(sp)
    8000364e:	64a2                	ld	s1,8(sp)
    80003650:	6902                	ld	s2,0(sp)
    80003652:	6105                	addi	sp,sp,32
    80003654:	8082                	ret

0000000080003656 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003656:	7179                	addi	sp,sp,-48
    80003658:	f406                	sd	ra,40(sp)
    8000365a:	f022                	sd	s0,32(sp)
    8000365c:	ec26                	sd	s1,24(sp)
    8000365e:	e84a                	sd	s2,16(sp)
    80003660:	1800                	addi	s0,sp,48
    80003662:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003664:	00850913          	addi	s2,a0,8
    80003668:	854a                	mv	a0,s2
    8000366a:	780020ef          	jal	80005dea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000366e:	409c                	lw	a5,0(s1)
    80003670:	ef81                	bnez	a5,80003688 <holdingsleep+0x32>
    80003672:	4481                	li	s1,0
  release(&lk->lk);
    80003674:	854a                	mv	a0,s2
    80003676:	00d020ef          	jal	80005e82 <release>
  return r;
}
    8000367a:	8526                	mv	a0,s1
    8000367c:	70a2                	ld	ra,40(sp)
    8000367e:	7402                	ld	s0,32(sp)
    80003680:	64e2                	ld	s1,24(sp)
    80003682:	6942                	ld	s2,16(sp)
    80003684:	6145                	addi	sp,sp,48
    80003686:	8082                	ret
    80003688:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000368a:	0284a983          	lw	s3,40(s1)
    8000368e:	eecfd0ef          	jal	80000d7a <myproc>
    80003692:	5904                	lw	s1,48(a0)
    80003694:	413484b3          	sub	s1,s1,s3
    80003698:	0014b493          	seqz	s1,s1
    8000369c:	69a2                	ld	s3,8(sp)
    8000369e:	bfd9                	j	80003674 <holdingsleep+0x1e>

00000000800036a0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800036a0:	1141                	addi	sp,sp,-16
    800036a2:	e406                	sd	ra,8(sp)
    800036a4:	e022                	sd	s0,0(sp)
    800036a6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800036a8:	00004597          	auipc	a1,0x4
    800036ac:	f5058593          	addi	a1,a1,-176 # 800075f8 <etext+0x5f8>
    800036b0:	00023517          	auipc	a0,0x23
    800036b4:	e6850513          	addi	a0,a0,-408 # 80026518 <ftable>
    800036b8:	6b2020ef          	jal	80005d6a <initlock>
}
    800036bc:	60a2                	ld	ra,8(sp)
    800036be:	6402                	ld	s0,0(sp)
    800036c0:	0141                	addi	sp,sp,16
    800036c2:	8082                	ret

00000000800036c4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800036c4:	1101                	addi	sp,sp,-32
    800036c6:	ec06                	sd	ra,24(sp)
    800036c8:	e822                	sd	s0,16(sp)
    800036ca:	e426                	sd	s1,8(sp)
    800036cc:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800036ce:	00023517          	auipc	a0,0x23
    800036d2:	e4a50513          	addi	a0,a0,-438 # 80026518 <ftable>
    800036d6:	714020ef          	jal	80005dea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800036da:	00023497          	auipc	s1,0x23
    800036de:	e5648493          	addi	s1,s1,-426 # 80026530 <ftable+0x18>
    800036e2:	00024717          	auipc	a4,0x24
    800036e6:	dee70713          	addi	a4,a4,-530 # 800274d0 <disk>
    if(f->ref == 0){
    800036ea:	40dc                	lw	a5,4(s1)
    800036ec:	cf89                	beqz	a5,80003706 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800036ee:	02848493          	addi	s1,s1,40
    800036f2:	fee49ce3          	bne	s1,a4,800036ea <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800036f6:	00023517          	auipc	a0,0x23
    800036fa:	e2250513          	addi	a0,a0,-478 # 80026518 <ftable>
    800036fe:	784020ef          	jal	80005e82 <release>
  return 0;
    80003702:	4481                	li	s1,0
    80003704:	a809                	j	80003716 <filealloc+0x52>
      f->ref = 1;
    80003706:	4785                	li	a5,1
    80003708:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000370a:	00023517          	auipc	a0,0x23
    8000370e:	e0e50513          	addi	a0,a0,-498 # 80026518 <ftable>
    80003712:	770020ef          	jal	80005e82 <release>
}
    80003716:	8526                	mv	a0,s1
    80003718:	60e2                	ld	ra,24(sp)
    8000371a:	6442                	ld	s0,16(sp)
    8000371c:	64a2                	ld	s1,8(sp)
    8000371e:	6105                	addi	sp,sp,32
    80003720:	8082                	ret

0000000080003722 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003722:	1101                	addi	sp,sp,-32
    80003724:	ec06                	sd	ra,24(sp)
    80003726:	e822                	sd	s0,16(sp)
    80003728:	e426                	sd	s1,8(sp)
    8000372a:	1000                	addi	s0,sp,32
    8000372c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000372e:	00023517          	auipc	a0,0x23
    80003732:	dea50513          	addi	a0,a0,-534 # 80026518 <ftable>
    80003736:	6b4020ef          	jal	80005dea <acquire>
  if(f->ref < 1)
    8000373a:	40dc                	lw	a5,4(s1)
    8000373c:	02f05063          	blez	a5,8000375c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003740:	2785                	addiw	a5,a5,1
    80003742:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003744:	00023517          	auipc	a0,0x23
    80003748:	dd450513          	addi	a0,a0,-556 # 80026518 <ftable>
    8000374c:	736020ef          	jal	80005e82 <release>
  return f;
}
    80003750:	8526                	mv	a0,s1
    80003752:	60e2                	ld	ra,24(sp)
    80003754:	6442                	ld	s0,16(sp)
    80003756:	64a2                	ld	s1,8(sp)
    80003758:	6105                	addi	sp,sp,32
    8000375a:	8082                	ret
    panic("filedup");
    8000375c:	00004517          	auipc	a0,0x4
    80003760:	ea450513          	addi	a0,a0,-348 # 80007600 <etext+0x600>
    80003764:	3ca020ef          	jal	80005b2e <panic>

0000000080003768 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003768:	7139                	addi	sp,sp,-64
    8000376a:	fc06                	sd	ra,56(sp)
    8000376c:	f822                	sd	s0,48(sp)
    8000376e:	f426                	sd	s1,40(sp)
    80003770:	0080                	addi	s0,sp,64
    80003772:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003774:	00023517          	auipc	a0,0x23
    80003778:	da450513          	addi	a0,a0,-604 # 80026518 <ftable>
    8000377c:	66e020ef          	jal	80005dea <acquire>
  if(f->ref < 1)
    80003780:	40dc                	lw	a5,4(s1)
    80003782:	04f05a63          	blez	a5,800037d6 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003786:	37fd                	addiw	a5,a5,-1
    80003788:	0007871b          	sext.w	a4,a5
    8000378c:	c0dc                	sw	a5,4(s1)
    8000378e:	04e04e63          	bgtz	a4,800037ea <fileclose+0x82>
    80003792:	f04a                	sd	s2,32(sp)
    80003794:	ec4e                	sd	s3,24(sp)
    80003796:	e852                	sd	s4,16(sp)
    80003798:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000379a:	0004a903          	lw	s2,0(s1)
    8000379e:	0094ca83          	lbu	s5,9(s1)
    800037a2:	0104ba03          	ld	s4,16(s1)
    800037a6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800037aa:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800037ae:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800037b2:	00023517          	auipc	a0,0x23
    800037b6:	d6650513          	addi	a0,a0,-666 # 80026518 <ftable>
    800037ba:	6c8020ef          	jal	80005e82 <release>

  if(ff.type == FD_PIPE){
    800037be:	4785                	li	a5,1
    800037c0:	04f90063          	beq	s2,a5,80003800 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800037c4:	3979                	addiw	s2,s2,-2
    800037c6:	4785                	li	a5,1
    800037c8:	0527f563          	bgeu	a5,s2,80003812 <fileclose+0xaa>
    800037cc:	7902                	ld	s2,32(sp)
    800037ce:	69e2                	ld	s3,24(sp)
    800037d0:	6a42                	ld	s4,16(sp)
    800037d2:	6aa2                	ld	s5,8(sp)
    800037d4:	a00d                	j	800037f6 <fileclose+0x8e>
    800037d6:	f04a                	sd	s2,32(sp)
    800037d8:	ec4e                	sd	s3,24(sp)
    800037da:	e852                	sd	s4,16(sp)
    800037dc:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800037de:	00004517          	auipc	a0,0x4
    800037e2:	e2a50513          	addi	a0,a0,-470 # 80007608 <etext+0x608>
    800037e6:	348020ef          	jal	80005b2e <panic>
    release(&ftable.lock);
    800037ea:	00023517          	auipc	a0,0x23
    800037ee:	d2e50513          	addi	a0,a0,-722 # 80026518 <ftable>
    800037f2:	690020ef          	jal	80005e82 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800037f6:	70e2                	ld	ra,56(sp)
    800037f8:	7442                	ld	s0,48(sp)
    800037fa:	74a2                	ld	s1,40(sp)
    800037fc:	6121                	addi	sp,sp,64
    800037fe:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003800:	85d6                	mv	a1,s5
    80003802:	8552                	mv	a0,s4
    80003804:	336000ef          	jal	80003b3a <pipeclose>
    80003808:	7902                	ld	s2,32(sp)
    8000380a:	69e2                	ld	s3,24(sp)
    8000380c:	6a42                	ld	s4,16(sp)
    8000380e:	6aa2                	ld	s5,8(sp)
    80003810:	b7dd                	j	800037f6 <fileclose+0x8e>
    begin_op();
    80003812:	b4bff0ef          	jal	8000335c <begin_op>
    iput(ff.ip);
    80003816:	854e                	mv	a0,s3
    80003818:	adcff0ef          	jal	80002af4 <iput>
    end_op();
    8000381c:	babff0ef          	jal	800033c6 <end_op>
    80003820:	7902                	ld	s2,32(sp)
    80003822:	69e2                	ld	s3,24(sp)
    80003824:	6a42                	ld	s4,16(sp)
    80003826:	6aa2                	ld	s5,8(sp)
    80003828:	b7f9                	j	800037f6 <fileclose+0x8e>

000000008000382a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000382a:	715d                	addi	sp,sp,-80
    8000382c:	e486                	sd	ra,72(sp)
    8000382e:	e0a2                	sd	s0,64(sp)
    80003830:	fc26                	sd	s1,56(sp)
    80003832:	f44e                	sd	s3,40(sp)
    80003834:	0880                	addi	s0,sp,80
    80003836:	84aa                	mv	s1,a0
    80003838:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000383a:	d40fd0ef          	jal	80000d7a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000383e:	409c                	lw	a5,0(s1)
    80003840:	37f9                	addiw	a5,a5,-2
    80003842:	4705                	li	a4,1
    80003844:	04f76063          	bltu	a4,a5,80003884 <filestat+0x5a>
    80003848:	f84a                	sd	s2,48(sp)
    8000384a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000384c:	6c88                	ld	a0,24(s1)
    8000384e:	924ff0ef          	jal	80002972 <ilock>
    stati(f->ip, &st);
    80003852:	fb840593          	addi	a1,s0,-72
    80003856:	6c88                	ld	a0,24(s1)
    80003858:	c80ff0ef          	jal	80002cd8 <stati>
    iunlock(f->ip);
    8000385c:	6c88                	ld	a0,24(s1)
    8000385e:	9c2ff0ef          	jal	80002a20 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003862:	46e1                	li	a3,24
    80003864:	fb840613          	addi	a2,s0,-72
    80003868:	85ce                	mv	a1,s3
    8000386a:	05093503          	ld	a0,80(s2)
    8000386e:	a20fd0ef          	jal	80000a8e <copyout>
    80003872:	41f5551b          	sraiw	a0,a0,0x1f
    80003876:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80003878:	60a6                	ld	ra,72(sp)
    8000387a:	6406                	ld	s0,64(sp)
    8000387c:	74e2                	ld	s1,56(sp)
    8000387e:	79a2                	ld	s3,40(sp)
    80003880:	6161                	addi	sp,sp,80
    80003882:	8082                	ret
  return -1;
    80003884:	557d                	li	a0,-1
    80003886:	bfcd                	j	80003878 <filestat+0x4e>

0000000080003888 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003888:	7179                	addi	sp,sp,-48
    8000388a:	f406                	sd	ra,40(sp)
    8000388c:	f022                	sd	s0,32(sp)
    8000388e:	e84a                	sd	s2,16(sp)
    80003890:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003892:	00854783          	lbu	a5,8(a0)
    80003896:	cfd1                	beqz	a5,80003932 <fileread+0xaa>
    80003898:	ec26                	sd	s1,24(sp)
    8000389a:	e44e                	sd	s3,8(sp)
    8000389c:	84aa                	mv	s1,a0
    8000389e:	89ae                	mv	s3,a1
    800038a0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800038a2:	411c                	lw	a5,0(a0)
    800038a4:	4705                	li	a4,1
    800038a6:	04e78363          	beq	a5,a4,800038ec <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800038aa:	470d                	li	a4,3
    800038ac:	04e78763          	beq	a5,a4,800038fa <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800038b0:	4709                	li	a4,2
    800038b2:	06e79a63          	bne	a5,a4,80003926 <fileread+0x9e>
    ilock(f->ip);
    800038b6:	6d08                	ld	a0,24(a0)
    800038b8:	8baff0ef          	jal	80002972 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800038bc:	874a                	mv	a4,s2
    800038be:	5094                	lw	a3,32(s1)
    800038c0:	864e                	mv	a2,s3
    800038c2:	4585                	li	a1,1
    800038c4:	6c88                	ld	a0,24(s1)
    800038c6:	c3cff0ef          	jal	80002d02 <readi>
    800038ca:	892a                	mv	s2,a0
    800038cc:	00a05563          	blez	a0,800038d6 <fileread+0x4e>
      f->off += r;
    800038d0:	509c                	lw	a5,32(s1)
    800038d2:	9fa9                	addw	a5,a5,a0
    800038d4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800038d6:	6c88                	ld	a0,24(s1)
    800038d8:	948ff0ef          	jal	80002a20 <iunlock>
    800038dc:	64e2                	ld	s1,24(sp)
    800038de:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800038e0:	854a                	mv	a0,s2
    800038e2:	70a2                	ld	ra,40(sp)
    800038e4:	7402                	ld	s0,32(sp)
    800038e6:	6942                	ld	s2,16(sp)
    800038e8:	6145                	addi	sp,sp,48
    800038ea:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800038ec:	6908                	ld	a0,16(a0)
    800038ee:	388000ef          	jal	80003c76 <piperead>
    800038f2:	892a                	mv	s2,a0
    800038f4:	64e2                	ld	s1,24(sp)
    800038f6:	69a2                	ld	s3,8(sp)
    800038f8:	b7e5                	j	800038e0 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800038fa:	02451783          	lh	a5,36(a0)
    800038fe:	03079693          	slli	a3,a5,0x30
    80003902:	92c1                	srli	a3,a3,0x30
    80003904:	4725                	li	a4,9
    80003906:	02d76863          	bltu	a4,a3,80003936 <fileread+0xae>
    8000390a:	0792                	slli	a5,a5,0x4
    8000390c:	00023717          	auipc	a4,0x23
    80003910:	b6c70713          	addi	a4,a4,-1172 # 80026478 <devsw>
    80003914:	97ba                	add	a5,a5,a4
    80003916:	639c                	ld	a5,0(a5)
    80003918:	c39d                	beqz	a5,8000393e <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000391a:	4505                	li	a0,1
    8000391c:	9782                	jalr	a5
    8000391e:	892a                	mv	s2,a0
    80003920:	64e2                	ld	s1,24(sp)
    80003922:	69a2                	ld	s3,8(sp)
    80003924:	bf75                	j	800038e0 <fileread+0x58>
    panic("fileread");
    80003926:	00004517          	auipc	a0,0x4
    8000392a:	cf250513          	addi	a0,a0,-782 # 80007618 <etext+0x618>
    8000392e:	200020ef          	jal	80005b2e <panic>
    return -1;
    80003932:	597d                	li	s2,-1
    80003934:	b775                	j	800038e0 <fileread+0x58>
      return -1;
    80003936:	597d                	li	s2,-1
    80003938:	64e2                	ld	s1,24(sp)
    8000393a:	69a2                	ld	s3,8(sp)
    8000393c:	b755                	j	800038e0 <fileread+0x58>
    8000393e:	597d                	li	s2,-1
    80003940:	64e2                	ld	s1,24(sp)
    80003942:	69a2                	ld	s3,8(sp)
    80003944:	bf71                	j	800038e0 <fileread+0x58>

0000000080003946 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80003946:	00954783          	lbu	a5,9(a0)
    8000394a:	10078b63          	beqz	a5,80003a60 <filewrite+0x11a>
{
    8000394e:	715d                	addi	sp,sp,-80
    80003950:	e486                	sd	ra,72(sp)
    80003952:	e0a2                	sd	s0,64(sp)
    80003954:	f84a                	sd	s2,48(sp)
    80003956:	f052                	sd	s4,32(sp)
    80003958:	e85a                	sd	s6,16(sp)
    8000395a:	0880                	addi	s0,sp,80
    8000395c:	892a                	mv	s2,a0
    8000395e:	8b2e                	mv	s6,a1
    80003960:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003962:	411c                	lw	a5,0(a0)
    80003964:	4705                	li	a4,1
    80003966:	02e78763          	beq	a5,a4,80003994 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000396a:	470d                	li	a4,3
    8000396c:	02e78863          	beq	a5,a4,8000399c <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003970:	4709                	li	a4,2
    80003972:	0ce79c63          	bne	a5,a4,80003a4a <filewrite+0x104>
    80003976:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003978:	0ac05863          	blez	a2,80003a28 <filewrite+0xe2>
    8000397c:	fc26                	sd	s1,56(sp)
    8000397e:	ec56                	sd	s5,24(sp)
    80003980:	e45e                	sd	s7,8(sp)
    80003982:	e062                	sd	s8,0(sp)
    int i = 0;
    80003984:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80003986:	6b85                	lui	s7,0x1
    80003988:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000398c:	6c05                	lui	s8,0x1
    8000398e:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80003992:	a8b5                	j	80003a0e <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80003994:	6908                	ld	a0,16(a0)
    80003996:	1fc000ef          	jal	80003b92 <pipewrite>
    8000399a:	a04d                	j	80003a3c <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000399c:	02451783          	lh	a5,36(a0)
    800039a0:	03079693          	slli	a3,a5,0x30
    800039a4:	92c1                	srli	a3,a3,0x30
    800039a6:	4725                	li	a4,9
    800039a8:	0ad76e63          	bltu	a4,a3,80003a64 <filewrite+0x11e>
    800039ac:	0792                	slli	a5,a5,0x4
    800039ae:	00023717          	auipc	a4,0x23
    800039b2:	aca70713          	addi	a4,a4,-1334 # 80026478 <devsw>
    800039b6:	97ba                	add	a5,a5,a4
    800039b8:	679c                	ld	a5,8(a5)
    800039ba:	c7dd                	beqz	a5,80003a68 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800039bc:	4505                	li	a0,1
    800039be:	9782                	jalr	a5
    800039c0:	a8b5                	j	80003a3c <filewrite+0xf6>
      if(n1 > max)
    800039c2:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800039c6:	997ff0ef          	jal	8000335c <begin_op>
      ilock(f->ip);
    800039ca:	01893503          	ld	a0,24(s2)
    800039ce:	fa5fe0ef          	jal	80002972 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800039d2:	8756                	mv	a4,s5
    800039d4:	02092683          	lw	a3,32(s2)
    800039d8:	01698633          	add	a2,s3,s6
    800039dc:	4585                	li	a1,1
    800039de:	01893503          	ld	a0,24(s2)
    800039e2:	c1cff0ef          	jal	80002dfe <writei>
    800039e6:	84aa                	mv	s1,a0
    800039e8:	00a05763          	blez	a0,800039f6 <filewrite+0xb0>
        f->off += r;
    800039ec:	02092783          	lw	a5,32(s2)
    800039f0:	9fa9                	addw	a5,a5,a0
    800039f2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800039f6:	01893503          	ld	a0,24(s2)
    800039fa:	826ff0ef          	jal	80002a20 <iunlock>
      end_op();
    800039fe:	9c9ff0ef          	jal	800033c6 <end_op>

      if(r != n1){
    80003a02:	029a9563          	bne	s5,s1,80003a2c <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80003a06:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003a0a:	0149da63          	bge	s3,s4,80003a1e <filewrite+0xd8>
      int n1 = n - i;
    80003a0e:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80003a12:	0004879b          	sext.w	a5,s1
    80003a16:	fafbd6e3          	bge	s7,a5,800039c2 <filewrite+0x7c>
    80003a1a:	84e2                	mv	s1,s8
    80003a1c:	b75d                	j	800039c2 <filewrite+0x7c>
    80003a1e:	74e2                	ld	s1,56(sp)
    80003a20:	6ae2                	ld	s5,24(sp)
    80003a22:	6ba2                	ld	s7,8(sp)
    80003a24:	6c02                	ld	s8,0(sp)
    80003a26:	a039                	j	80003a34 <filewrite+0xee>
    int i = 0;
    80003a28:	4981                	li	s3,0
    80003a2a:	a029                	j	80003a34 <filewrite+0xee>
    80003a2c:	74e2                	ld	s1,56(sp)
    80003a2e:	6ae2                	ld	s5,24(sp)
    80003a30:	6ba2                	ld	s7,8(sp)
    80003a32:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80003a34:	033a1c63          	bne	s4,s3,80003a6c <filewrite+0x126>
    80003a38:	8552                	mv	a0,s4
    80003a3a:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003a3c:	60a6                	ld	ra,72(sp)
    80003a3e:	6406                	ld	s0,64(sp)
    80003a40:	7942                	ld	s2,48(sp)
    80003a42:	7a02                	ld	s4,32(sp)
    80003a44:	6b42                	ld	s6,16(sp)
    80003a46:	6161                	addi	sp,sp,80
    80003a48:	8082                	ret
    80003a4a:	fc26                	sd	s1,56(sp)
    80003a4c:	f44e                	sd	s3,40(sp)
    80003a4e:	ec56                	sd	s5,24(sp)
    80003a50:	e45e                	sd	s7,8(sp)
    80003a52:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80003a54:	00004517          	auipc	a0,0x4
    80003a58:	bd450513          	addi	a0,a0,-1068 # 80007628 <etext+0x628>
    80003a5c:	0d2020ef          	jal	80005b2e <panic>
    return -1;
    80003a60:	557d                	li	a0,-1
}
    80003a62:	8082                	ret
      return -1;
    80003a64:	557d                	li	a0,-1
    80003a66:	bfd9                	j	80003a3c <filewrite+0xf6>
    80003a68:	557d                	li	a0,-1
    80003a6a:	bfc9                	j	80003a3c <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80003a6c:	557d                	li	a0,-1
    80003a6e:	79a2                	ld	s3,40(sp)
    80003a70:	b7f1                	j	80003a3c <filewrite+0xf6>

0000000080003a72 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003a72:	7179                	addi	sp,sp,-48
    80003a74:	f406                	sd	ra,40(sp)
    80003a76:	f022                	sd	s0,32(sp)
    80003a78:	ec26                	sd	s1,24(sp)
    80003a7a:	e052                	sd	s4,0(sp)
    80003a7c:	1800                	addi	s0,sp,48
    80003a7e:	84aa                	mv	s1,a0
    80003a80:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003a82:	0005b023          	sd	zero,0(a1)
    80003a86:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003a8a:	c3bff0ef          	jal	800036c4 <filealloc>
    80003a8e:	e088                	sd	a0,0(s1)
    80003a90:	c549                	beqz	a0,80003b1a <pipealloc+0xa8>
    80003a92:	c33ff0ef          	jal	800036c4 <filealloc>
    80003a96:	00aa3023          	sd	a0,0(s4)
    80003a9a:	cd25                	beqz	a0,80003b12 <pipealloc+0xa0>
    80003a9c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003a9e:	e60fc0ef          	jal	800000fe <kalloc>
    80003aa2:	892a                	mv	s2,a0
    80003aa4:	c12d                	beqz	a0,80003b06 <pipealloc+0x94>
    80003aa6:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80003aa8:	4985                	li	s3,1
    80003aaa:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003aae:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003ab2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003ab6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003aba:	00004597          	auipc	a1,0x4
    80003abe:	b7e58593          	addi	a1,a1,-1154 # 80007638 <etext+0x638>
    80003ac2:	2a8020ef          	jal	80005d6a <initlock>
  (*f0)->type = FD_PIPE;
    80003ac6:	609c                	ld	a5,0(s1)
    80003ac8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003acc:	609c                	ld	a5,0(s1)
    80003ace:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003ad2:	609c                	ld	a5,0(s1)
    80003ad4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003ad8:	609c                	ld	a5,0(s1)
    80003ada:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003ade:	000a3783          	ld	a5,0(s4)
    80003ae2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003ae6:	000a3783          	ld	a5,0(s4)
    80003aea:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003aee:	000a3783          	ld	a5,0(s4)
    80003af2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003af6:	000a3783          	ld	a5,0(s4)
    80003afa:	0127b823          	sd	s2,16(a5)
  return 0;
    80003afe:	4501                	li	a0,0
    80003b00:	6942                	ld	s2,16(sp)
    80003b02:	69a2                	ld	s3,8(sp)
    80003b04:	a01d                	j	80003b2a <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003b06:	6088                	ld	a0,0(s1)
    80003b08:	c119                	beqz	a0,80003b0e <pipealloc+0x9c>
    80003b0a:	6942                	ld	s2,16(sp)
    80003b0c:	a029                	j	80003b16 <pipealloc+0xa4>
    80003b0e:	6942                	ld	s2,16(sp)
    80003b10:	a029                	j	80003b1a <pipealloc+0xa8>
    80003b12:	6088                	ld	a0,0(s1)
    80003b14:	c10d                	beqz	a0,80003b36 <pipealloc+0xc4>
    fileclose(*f0);
    80003b16:	c53ff0ef          	jal	80003768 <fileclose>
  if(*f1)
    80003b1a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003b1e:	557d                	li	a0,-1
  if(*f1)
    80003b20:	c789                	beqz	a5,80003b2a <pipealloc+0xb8>
    fileclose(*f1);
    80003b22:	853e                	mv	a0,a5
    80003b24:	c45ff0ef          	jal	80003768 <fileclose>
  return -1;
    80003b28:	557d                	li	a0,-1
}
    80003b2a:	70a2                	ld	ra,40(sp)
    80003b2c:	7402                	ld	s0,32(sp)
    80003b2e:	64e2                	ld	s1,24(sp)
    80003b30:	6a02                	ld	s4,0(sp)
    80003b32:	6145                	addi	sp,sp,48
    80003b34:	8082                	ret
  return -1;
    80003b36:	557d                	li	a0,-1
    80003b38:	bfcd                	j	80003b2a <pipealloc+0xb8>

0000000080003b3a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003b3a:	1101                	addi	sp,sp,-32
    80003b3c:	ec06                	sd	ra,24(sp)
    80003b3e:	e822                	sd	s0,16(sp)
    80003b40:	e426                	sd	s1,8(sp)
    80003b42:	e04a                	sd	s2,0(sp)
    80003b44:	1000                	addi	s0,sp,32
    80003b46:	84aa                	mv	s1,a0
    80003b48:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003b4a:	2a0020ef          	jal	80005dea <acquire>
  if(writable){
    80003b4e:	02090763          	beqz	s2,80003b7c <pipeclose+0x42>
    pi->writeopen = 0;
    80003b52:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003b56:	21848513          	addi	a0,s1,536
    80003b5a:	8c3fd0ef          	jal	8000141c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003b5e:	2204b783          	ld	a5,544(s1)
    80003b62:	e785                	bnez	a5,80003b8a <pipeclose+0x50>
    release(&pi->lock);
    80003b64:	8526                	mv	a0,s1
    80003b66:	31c020ef          	jal	80005e82 <release>
    kfree((char*)pi);
    80003b6a:	8526                	mv	a0,s1
    80003b6c:	cb0fc0ef          	jal	8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003b70:	60e2                	ld	ra,24(sp)
    80003b72:	6442                	ld	s0,16(sp)
    80003b74:	64a2                	ld	s1,8(sp)
    80003b76:	6902                	ld	s2,0(sp)
    80003b78:	6105                	addi	sp,sp,32
    80003b7a:	8082                	ret
    pi->readopen = 0;
    80003b7c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003b80:	21c48513          	addi	a0,s1,540
    80003b84:	899fd0ef          	jal	8000141c <wakeup>
    80003b88:	bfd9                	j	80003b5e <pipeclose+0x24>
    release(&pi->lock);
    80003b8a:	8526                	mv	a0,s1
    80003b8c:	2f6020ef          	jal	80005e82 <release>
}
    80003b90:	b7c5                	j	80003b70 <pipeclose+0x36>

0000000080003b92 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003b92:	711d                	addi	sp,sp,-96
    80003b94:	ec86                	sd	ra,88(sp)
    80003b96:	e8a2                	sd	s0,80(sp)
    80003b98:	e4a6                	sd	s1,72(sp)
    80003b9a:	e0ca                	sd	s2,64(sp)
    80003b9c:	fc4e                	sd	s3,56(sp)
    80003b9e:	f852                	sd	s4,48(sp)
    80003ba0:	f456                	sd	s5,40(sp)
    80003ba2:	1080                	addi	s0,sp,96
    80003ba4:	84aa                	mv	s1,a0
    80003ba6:	8aae                	mv	s5,a1
    80003ba8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003baa:	9d0fd0ef          	jal	80000d7a <myproc>
    80003bae:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003bb0:	8526                	mv	a0,s1
    80003bb2:	238020ef          	jal	80005dea <acquire>
  while(i < n){
    80003bb6:	0b405a63          	blez	s4,80003c6a <pipewrite+0xd8>
    80003bba:	f05a                	sd	s6,32(sp)
    80003bbc:	ec5e                	sd	s7,24(sp)
    80003bbe:	e862                	sd	s8,16(sp)
  int i = 0;
    80003bc0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003bc2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003bc4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003bc8:	21c48b93          	addi	s7,s1,540
    80003bcc:	a81d                	j	80003c02 <pipewrite+0x70>
      release(&pi->lock);
    80003bce:	8526                	mv	a0,s1
    80003bd0:	2b2020ef          	jal	80005e82 <release>
      return -1;
    80003bd4:	597d                	li	s2,-1
    80003bd6:	7b02                	ld	s6,32(sp)
    80003bd8:	6be2                	ld	s7,24(sp)
    80003bda:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003bdc:	854a                	mv	a0,s2
    80003bde:	60e6                	ld	ra,88(sp)
    80003be0:	6446                	ld	s0,80(sp)
    80003be2:	64a6                	ld	s1,72(sp)
    80003be4:	6906                	ld	s2,64(sp)
    80003be6:	79e2                	ld	s3,56(sp)
    80003be8:	7a42                	ld	s4,48(sp)
    80003bea:	7aa2                	ld	s5,40(sp)
    80003bec:	6125                	addi	sp,sp,96
    80003bee:	8082                	ret
      wakeup(&pi->nread);
    80003bf0:	8562                	mv	a0,s8
    80003bf2:	82bfd0ef          	jal	8000141c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003bf6:	85a6                	mv	a1,s1
    80003bf8:	855e                	mv	a0,s7
    80003bfa:	fd6fd0ef          	jal	800013d0 <sleep>
  while(i < n){
    80003bfe:	05495b63          	bge	s2,s4,80003c54 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80003c02:	2204a783          	lw	a5,544(s1)
    80003c06:	d7e1                	beqz	a5,80003bce <pipewrite+0x3c>
    80003c08:	854e                	mv	a0,s3
    80003c0a:	a7bfd0ef          	jal	80001684 <killed>
    80003c0e:	f161                	bnez	a0,80003bce <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003c10:	2184a783          	lw	a5,536(s1)
    80003c14:	21c4a703          	lw	a4,540(s1)
    80003c18:	2007879b          	addiw	a5,a5,512
    80003c1c:	fcf70ae3          	beq	a4,a5,80003bf0 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003c20:	4685                	li	a3,1
    80003c22:	01590633          	add	a2,s2,s5
    80003c26:	faf40593          	addi	a1,s0,-81
    80003c2a:	0509b503          	ld	a0,80(s3)
    80003c2e:	f45fc0ef          	jal	80000b72 <copyin>
    80003c32:	03650e63          	beq	a0,s6,80003c6e <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003c36:	21c4a783          	lw	a5,540(s1)
    80003c3a:	0017871b          	addiw	a4,a5,1
    80003c3e:	20e4ae23          	sw	a4,540(s1)
    80003c42:	1ff7f793          	andi	a5,a5,511
    80003c46:	97a6                	add	a5,a5,s1
    80003c48:	faf44703          	lbu	a4,-81(s0)
    80003c4c:	00e78c23          	sb	a4,24(a5)
      i++;
    80003c50:	2905                	addiw	s2,s2,1
    80003c52:	b775                	j	80003bfe <pipewrite+0x6c>
    80003c54:	7b02                	ld	s6,32(sp)
    80003c56:	6be2                	ld	s7,24(sp)
    80003c58:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80003c5a:	21848513          	addi	a0,s1,536
    80003c5e:	fbefd0ef          	jal	8000141c <wakeup>
  release(&pi->lock);
    80003c62:	8526                	mv	a0,s1
    80003c64:	21e020ef          	jal	80005e82 <release>
  return i;
    80003c68:	bf95                	j	80003bdc <pipewrite+0x4a>
  int i = 0;
    80003c6a:	4901                	li	s2,0
    80003c6c:	b7fd                	j	80003c5a <pipewrite+0xc8>
    80003c6e:	7b02                	ld	s6,32(sp)
    80003c70:	6be2                	ld	s7,24(sp)
    80003c72:	6c42                	ld	s8,16(sp)
    80003c74:	b7dd                	j	80003c5a <pipewrite+0xc8>

0000000080003c76 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003c76:	715d                	addi	sp,sp,-80
    80003c78:	e486                	sd	ra,72(sp)
    80003c7a:	e0a2                	sd	s0,64(sp)
    80003c7c:	fc26                	sd	s1,56(sp)
    80003c7e:	f84a                	sd	s2,48(sp)
    80003c80:	f44e                	sd	s3,40(sp)
    80003c82:	f052                	sd	s4,32(sp)
    80003c84:	ec56                	sd	s5,24(sp)
    80003c86:	0880                	addi	s0,sp,80
    80003c88:	84aa                	mv	s1,a0
    80003c8a:	892e                	mv	s2,a1
    80003c8c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003c8e:	8ecfd0ef          	jal	80000d7a <myproc>
    80003c92:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003c94:	8526                	mv	a0,s1
    80003c96:	154020ef          	jal	80005dea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003c9a:	2184a703          	lw	a4,536(s1)
    80003c9e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003ca2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003ca6:	02f71563          	bne	a4,a5,80003cd0 <piperead+0x5a>
    80003caa:	2244a783          	lw	a5,548(s1)
    80003cae:	cb85                	beqz	a5,80003cde <piperead+0x68>
    if(killed(pr)){
    80003cb0:	8552                	mv	a0,s4
    80003cb2:	9d3fd0ef          	jal	80001684 <killed>
    80003cb6:	ed19                	bnez	a0,80003cd4 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003cb8:	85a6                	mv	a1,s1
    80003cba:	854e                	mv	a0,s3
    80003cbc:	f14fd0ef          	jal	800013d0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003cc0:	2184a703          	lw	a4,536(s1)
    80003cc4:	21c4a783          	lw	a5,540(s1)
    80003cc8:	fef701e3          	beq	a4,a5,80003caa <piperead+0x34>
    80003ccc:	e85a                	sd	s6,16(sp)
    80003cce:	a809                	j	80003ce0 <piperead+0x6a>
    80003cd0:	e85a                	sd	s6,16(sp)
    80003cd2:	a039                	j	80003ce0 <piperead+0x6a>
      release(&pi->lock);
    80003cd4:	8526                	mv	a0,s1
    80003cd6:	1ac020ef          	jal	80005e82 <release>
      return -1;
    80003cda:	59fd                	li	s3,-1
    80003cdc:	a8b1                	j	80003d38 <piperead+0xc2>
    80003cde:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003ce0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003ce2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003ce4:	05505263          	blez	s5,80003d28 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80003ce8:	2184a783          	lw	a5,536(s1)
    80003cec:	21c4a703          	lw	a4,540(s1)
    80003cf0:	02f70c63          	beq	a4,a5,80003d28 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003cf4:	0017871b          	addiw	a4,a5,1
    80003cf8:	20e4ac23          	sw	a4,536(s1)
    80003cfc:	1ff7f793          	andi	a5,a5,511
    80003d00:	97a6                	add	a5,a5,s1
    80003d02:	0187c783          	lbu	a5,24(a5)
    80003d06:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003d0a:	4685                	li	a3,1
    80003d0c:	fbf40613          	addi	a2,s0,-65
    80003d10:	85ca                	mv	a1,s2
    80003d12:	050a3503          	ld	a0,80(s4)
    80003d16:	d79fc0ef          	jal	80000a8e <copyout>
    80003d1a:	01650763          	beq	a0,s6,80003d28 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003d1e:	2985                	addiw	s3,s3,1
    80003d20:	0905                	addi	s2,s2,1
    80003d22:	fd3a93e3          	bne	s5,s3,80003ce8 <piperead+0x72>
    80003d26:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003d28:	21c48513          	addi	a0,s1,540
    80003d2c:	ef0fd0ef          	jal	8000141c <wakeup>
  release(&pi->lock);
    80003d30:	8526                	mv	a0,s1
    80003d32:	150020ef          	jal	80005e82 <release>
    80003d36:	6b42                	ld	s6,16(sp)
  return i;
}
    80003d38:	854e                	mv	a0,s3
    80003d3a:	60a6                	ld	ra,72(sp)
    80003d3c:	6406                	ld	s0,64(sp)
    80003d3e:	74e2                	ld	s1,56(sp)
    80003d40:	7942                	ld	s2,48(sp)
    80003d42:	79a2                	ld	s3,40(sp)
    80003d44:	7a02                	ld	s4,32(sp)
    80003d46:	6ae2                	ld	s5,24(sp)
    80003d48:	6161                	addi	sp,sp,80
    80003d4a:	8082                	ret

0000000080003d4c <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80003d4c:	1141                	addi	sp,sp,-16
    80003d4e:	e422                	sd	s0,8(sp)
    80003d50:	0800                	addi	s0,sp,16
    80003d52:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003d54:	8905                	andi	a0,a0,1
    80003d56:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003d58:	8b89                	andi	a5,a5,2
    80003d5a:	c399                	beqz	a5,80003d60 <flags2perm+0x14>
      perm |= PTE_W;
    80003d5c:	00456513          	ori	a0,a0,4
    return perm;
}
    80003d60:	6422                	ld	s0,8(sp)
    80003d62:	0141                	addi	sp,sp,16
    80003d64:	8082                	ret

0000000080003d66 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80003d66:	df010113          	addi	sp,sp,-528
    80003d6a:	20113423          	sd	ra,520(sp)
    80003d6e:	20813023          	sd	s0,512(sp)
    80003d72:	ffa6                	sd	s1,504(sp)
    80003d74:	fbca                	sd	s2,496(sp)
    80003d76:	0c00                	addi	s0,sp,528
    80003d78:	892a                	mv	s2,a0
    80003d7a:	dea43c23          	sd	a0,-520(s0)
    80003d7e:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003d82:	ff9fc0ef          	jal	80000d7a <myproc>
    80003d86:	84aa                	mv	s1,a0

  begin_op();
    80003d88:	dd4ff0ef          	jal	8000335c <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80003d8c:	854a                	mv	a0,s2
    80003d8e:	bfaff0ef          	jal	80003188 <namei>
    80003d92:	c931                	beqz	a0,80003de6 <kexec+0x80>
    80003d94:	f3d2                	sd	s4,480(sp)
    80003d96:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003d98:	bdbfe0ef          	jal	80002972 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003d9c:	04000713          	li	a4,64
    80003da0:	4681                	li	a3,0
    80003da2:	e5040613          	addi	a2,s0,-432
    80003da6:	4581                	li	a1,0
    80003da8:	8552                	mv	a0,s4
    80003daa:	f59fe0ef          	jal	80002d02 <readi>
    80003dae:	04000793          	li	a5,64
    80003db2:	00f51a63          	bne	a0,a5,80003dc6 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80003db6:	e5042703          	lw	a4,-432(s0)
    80003dba:	464c47b7          	lui	a5,0x464c4
    80003dbe:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003dc2:	02f70663          	beq	a4,a5,80003dee <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003dc6:	8552                	mv	a0,s4
    80003dc8:	db5fe0ef          	jal	80002b7c <iunlockput>
    end_op();
    80003dcc:	dfaff0ef          	jal	800033c6 <end_op>
  }
  return -1;
    80003dd0:	557d                	li	a0,-1
    80003dd2:	7a1e                	ld	s4,480(sp)
}
    80003dd4:	20813083          	ld	ra,520(sp)
    80003dd8:	20013403          	ld	s0,512(sp)
    80003ddc:	74fe                	ld	s1,504(sp)
    80003dde:	795e                	ld	s2,496(sp)
    80003de0:	21010113          	addi	sp,sp,528
    80003de4:	8082                	ret
    end_op();
    80003de6:	de0ff0ef          	jal	800033c6 <end_op>
    return -1;
    80003dea:	557d                	li	a0,-1
    80003dec:	b7e5                	j	80003dd4 <kexec+0x6e>
    80003dee:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80003df0:	8526                	mv	a0,s1
    80003df2:	88efd0ef          	jal	80000e80 <proc_pagetable>
    80003df6:	8b2a                	mv	s6,a0
    80003df8:	2c050b63          	beqz	a0,800040ce <kexec+0x368>
    80003dfc:	f7ce                	sd	s3,488(sp)
    80003dfe:	efd6                	sd	s5,472(sp)
    80003e00:	e7de                	sd	s7,456(sp)
    80003e02:	e3e2                	sd	s8,448(sp)
    80003e04:	ff66                	sd	s9,440(sp)
    80003e06:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003e08:	e7042d03          	lw	s10,-400(s0)
    80003e0c:	e8845783          	lhu	a5,-376(s0)
    80003e10:	12078963          	beqz	a5,80003f42 <kexec+0x1dc>
    80003e14:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003e16:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003e18:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003e1a:	6c85                	lui	s9,0x1
    80003e1c:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003e20:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003e24:	6a85                	lui	s5,0x1
    80003e26:	a085                	j	80003e86 <kexec+0x120>
      panic("loadseg: address should exist");
    80003e28:	00004517          	auipc	a0,0x4
    80003e2c:	81850513          	addi	a0,a0,-2024 # 80007640 <etext+0x640>
    80003e30:	4ff010ef          	jal	80005b2e <panic>
    if(sz - i < PGSIZE)
    80003e34:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003e36:	8726                	mv	a4,s1
    80003e38:	012c06bb          	addw	a3,s8,s2
    80003e3c:	4581                	li	a1,0
    80003e3e:	8552                	mv	a0,s4
    80003e40:	ec3fe0ef          	jal	80002d02 <readi>
    80003e44:	2501                	sext.w	a0,a0
    80003e46:	24a49a63          	bne	s1,a0,8000409a <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003e4a:	012a893b          	addw	s2,s5,s2
    80003e4e:	03397363          	bgeu	s2,s3,80003e74 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003e52:	02091593          	slli	a1,s2,0x20
    80003e56:	9181                	srli	a1,a1,0x20
    80003e58:	95de                	add	a1,a1,s7
    80003e5a:	855a                	mv	a0,s6
    80003e5c:	e00fc0ef          	jal	8000045c <walkaddr>
    80003e60:	862a                	mv	a2,a0
    if(pa == 0)
    80003e62:	d179                	beqz	a0,80003e28 <kexec+0xc2>
    if(sz - i < PGSIZE)
    80003e64:	412984bb          	subw	s1,s3,s2
    80003e68:	0004879b          	sext.w	a5,s1
    80003e6c:	fcfcf4e3          	bgeu	s9,a5,80003e34 <kexec+0xce>
    80003e70:	84d6                	mv	s1,s5
    80003e72:	b7c9                	j	80003e34 <kexec+0xce>
    sz = sz1;
    80003e74:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003e78:	2d85                	addiw	s11,s11,1
    80003e7a:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80003e7e:	e8845783          	lhu	a5,-376(s0)
    80003e82:	08fdd063          	bge	s11,a5,80003f02 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003e86:	2d01                	sext.w	s10,s10
    80003e88:	03800713          	li	a4,56
    80003e8c:	86ea                	mv	a3,s10
    80003e8e:	e1840613          	addi	a2,s0,-488
    80003e92:	4581                	li	a1,0
    80003e94:	8552                	mv	a0,s4
    80003e96:	e6dfe0ef          	jal	80002d02 <readi>
    80003e9a:	03800793          	li	a5,56
    80003e9e:	1cf51663          	bne	a0,a5,8000406a <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80003ea2:	e1842783          	lw	a5,-488(s0)
    80003ea6:	4705                	li	a4,1
    80003ea8:	fce798e3          	bne	a5,a4,80003e78 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80003eac:	e4043483          	ld	s1,-448(s0)
    80003eb0:	e3843783          	ld	a5,-456(s0)
    80003eb4:	1af4ef63          	bltu	s1,a5,80004072 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003eb8:	e2843783          	ld	a5,-472(s0)
    80003ebc:	94be                	add	s1,s1,a5
    80003ebe:	1af4ee63          	bltu	s1,a5,8000407a <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003ec2:	df043703          	ld	a4,-528(s0)
    80003ec6:	8ff9                	and	a5,a5,a4
    80003ec8:	1a079d63          	bnez	a5,80004082 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003ecc:	e1c42503          	lw	a0,-484(s0)
    80003ed0:	e7dff0ef          	jal	80003d4c <flags2perm>
    80003ed4:	86aa                	mv	a3,a0
    80003ed6:	8626                	mv	a2,s1
    80003ed8:	85ca                	mv	a1,s2
    80003eda:	855a                	mv	a0,s6
    80003edc:	859fc0ef          	jal	80000734 <uvmalloc>
    80003ee0:	e0a43423          	sd	a0,-504(s0)
    80003ee4:	1a050363          	beqz	a0,8000408a <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003ee8:	e2843b83          	ld	s7,-472(s0)
    80003eec:	e2042c03          	lw	s8,-480(s0)
    80003ef0:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003ef4:	00098463          	beqz	s3,80003efc <kexec+0x196>
    80003ef8:	4901                	li	s2,0
    80003efa:	bfa1                	j	80003e52 <kexec+0xec>
    sz = sz1;
    80003efc:	e0843903          	ld	s2,-504(s0)
    80003f00:	bfa5                	j	80003e78 <kexec+0x112>
    80003f02:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80003f04:	8552                	mv	a0,s4
    80003f06:	c77fe0ef          	jal	80002b7c <iunlockput>
  end_op();
    80003f0a:	cbcff0ef          	jal	800033c6 <end_op>
  p = myproc();
    80003f0e:	e6dfc0ef          	jal	80000d7a <myproc>
    80003f12:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003f14:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80003f18:	6985                	lui	s3,0x1
    80003f1a:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003f1c:	99ca                	add	s3,s3,s2
    80003f1e:	77fd                	lui	a5,0xfffff
    80003f20:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003f24:	4691                	li	a3,4
    80003f26:	6609                	lui	a2,0x2
    80003f28:	964e                	add	a2,a2,s3
    80003f2a:	85ce                	mv	a1,s3
    80003f2c:	855a                	mv	a0,s6
    80003f2e:	807fc0ef          	jal	80000734 <uvmalloc>
    80003f32:	892a                	mv	s2,a0
    80003f34:	e0a43423          	sd	a0,-504(s0)
    80003f38:	e519                	bnez	a0,80003f46 <kexec+0x1e0>
  if(pagetable)
    80003f3a:	e1343423          	sd	s3,-504(s0)
    80003f3e:	4a01                	li	s4,0
    80003f40:	aab1                	j	8000409c <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003f42:	4901                	li	s2,0
    80003f44:	b7c1                	j	80003f04 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003f46:	75f9                	lui	a1,0xffffe
    80003f48:	95aa                	add	a1,a1,a0
    80003f4a:	855a                	mv	a0,s6
    80003f4c:	9bffc0ef          	jal	8000090a <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003f50:	7bfd                	lui	s7,0xfffff
    80003f52:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003f54:	e0043783          	ld	a5,-512(s0)
    80003f58:	6388                	ld	a0,0(a5)
    80003f5a:	cd39                	beqz	a0,80003fb8 <kexec+0x252>
    80003f5c:	e9040993          	addi	s3,s0,-368
    80003f60:	f9040c13          	addi	s8,s0,-112
    80003f64:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003f66:	b58fc0ef          	jal	800002be <strlen>
    80003f6a:	0015079b          	addiw	a5,a0,1
    80003f6e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003f72:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003f76:	11796e63          	bltu	s2,s7,80004092 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003f7a:	e0043d03          	ld	s10,-512(s0)
    80003f7e:	000d3a03          	ld	s4,0(s10)
    80003f82:	8552                	mv	a0,s4
    80003f84:	b3afc0ef          	jal	800002be <strlen>
    80003f88:	0015069b          	addiw	a3,a0,1
    80003f8c:	8652                	mv	a2,s4
    80003f8e:	85ca                	mv	a1,s2
    80003f90:	855a                	mv	a0,s6
    80003f92:	afdfc0ef          	jal	80000a8e <copyout>
    80003f96:	10054063          	bltz	a0,80004096 <kexec+0x330>
    ustack[argc] = sp;
    80003f9a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003f9e:	0485                	addi	s1,s1,1
    80003fa0:	008d0793          	addi	a5,s10,8
    80003fa4:	e0f43023          	sd	a5,-512(s0)
    80003fa8:	008d3503          	ld	a0,8(s10)
    80003fac:	c909                	beqz	a0,80003fbe <kexec+0x258>
    if(argc >= MAXARG)
    80003fae:	09a1                	addi	s3,s3,8
    80003fb0:	fb899be3          	bne	s3,s8,80003f66 <kexec+0x200>
  ip = 0;
    80003fb4:	4a01                	li	s4,0
    80003fb6:	a0dd                	j	8000409c <kexec+0x336>
  sp = sz;
    80003fb8:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003fbc:	4481                	li	s1,0
  ustack[argc] = 0;
    80003fbe:	00349793          	slli	a5,s1,0x3
    80003fc2:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffcf8a8>
    80003fc6:	97a2                	add	a5,a5,s0
    80003fc8:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003fcc:	00148693          	addi	a3,s1,1
    80003fd0:	068e                	slli	a3,a3,0x3
    80003fd2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003fd6:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003fda:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003fde:	f5796ee3          	bltu	s2,s7,80003f3a <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003fe2:	e9040613          	addi	a2,s0,-368
    80003fe6:	85ca                	mv	a1,s2
    80003fe8:	855a                	mv	a0,s6
    80003fea:	aa5fc0ef          	jal	80000a8e <copyout>
    80003fee:	0e054263          	bltz	a0,800040d2 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80003ff2:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003ff6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003ffa:	df843783          	ld	a5,-520(s0)
    80003ffe:	0007c703          	lbu	a4,0(a5)
    80004002:	cf11                	beqz	a4,8000401e <kexec+0x2b8>
    80004004:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004006:	02f00693          	li	a3,47
    8000400a:	a039                	j	80004018 <kexec+0x2b2>
      last = s+1;
    8000400c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004010:	0785                	addi	a5,a5,1
    80004012:	fff7c703          	lbu	a4,-1(a5)
    80004016:	c701                	beqz	a4,8000401e <kexec+0x2b8>
    if(*s == '/')
    80004018:	fed71ce3          	bne	a4,a3,80004010 <kexec+0x2aa>
    8000401c:	bfc5                	j	8000400c <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    8000401e:	4641                	li	a2,16
    80004020:	df843583          	ld	a1,-520(s0)
    80004024:	158a8513          	addi	a0,s5,344
    80004028:	a64fc0ef          	jal	8000028c <safestrcpy>
  oldpagetable = p->pagetable;
    8000402c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004030:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004034:	e0843783          	ld	a5,-504(s0)
    80004038:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    8000403c:	058ab783          	ld	a5,88(s5)
    80004040:	e6843703          	ld	a4,-408(s0)
    80004044:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004046:	058ab783          	ld	a5,88(s5)
    8000404a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000404e:	85e6                	mv	a1,s9
    80004050:	eb5fc0ef          	jal	80000f04 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004054:	0004851b          	sext.w	a0,s1
    80004058:	79be                	ld	s3,488(sp)
    8000405a:	7a1e                	ld	s4,480(sp)
    8000405c:	6afe                	ld	s5,472(sp)
    8000405e:	6b5e                	ld	s6,464(sp)
    80004060:	6bbe                	ld	s7,456(sp)
    80004062:	6c1e                	ld	s8,448(sp)
    80004064:	7cfa                	ld	s9,440(sp)
    80004066:	7d5a                	ld	s10,432(sp)
    80004068:	b3b5                	j	80003dd4 <kexec+0x6e>
    8000406a:	e1243423          	sd	s2,-504(s0)
    8000406e:	7dba                	ld	s11,424(sp)
    80004070:	a035                	j	8000409c <kexec+0x336>
    80004072:	e1243423          	sd	s2,-504(s0)
    80004076:	7dba                	ld	s11,424(sp)
    80004078:	a015                	j	8000409c <kexec+0x336>
    8000407a:	e1243423          	sd	s2,-504(s0)
    8000407e:	7dba                	ld	s11,424(sp)
    80004080:	a831                	j	8000409c <kexec+0x336>
    80004082:	e1243423          	sd	s2,-504(s0)
    80004086:	7dba                	ld	s11,424(sp)
    80004088:	a811                	j	8000409c <kexec+0x336>
    8000408a:	e1243423          	sd	s2,-504(s0)
    8000408e:	7dba                	ld	s11,424(sp)
    80004090:	a031                	j	8000409c <kexec+0x336>
  ip = 0;
    80004092:	4a01                	li	s4,0
    80004094:	a021                	j	8000409c <kexec+0x336>
    80004096:	4a01                	li	s4,0
  if(pagetable)
    80004098:	a011                	j	8000409c <kexec+0x336>
    8000409a:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    8000409c:	e0843583          	ld	a1,-504(s0)
    800040a0:	855a                	mv	a0,s6
    800040a2:	e63fc0ef          	jal	80000f04 <proc_freepagetable>
  return -1;
    800040a6:	557d                	li	a0,-1
  if(ip){
    800040a8:	000a1b63          	bnez	s4,800040be <kexec+0x358>
    800040ac:	79be                	ld	s3,488(sp)
    800040ae:	7a1e                	ld	s4,480(sp)
    800040b0:	6afe                	ld	s5,472(sp)
    800040b2:	6b5e                	ld	s6,464(sp)
    800040b4:	6bbe                	ld	s7,456(sp)
    800040b6:	6c1e                	ld	s8,448(sp)
    800040b8:	7cfa                	ld	s9,440(sp)
    800040ba:	7d5a                	ld	s10,432(sp)
    800040bc:	bb21                	j	80003dd4 <kexec+0x6e>
    800040be:	79be                	ld	s3,488(sp)
    800040c0:	6afe                	ld	s5,472(sp)
    800040c2:	6b5e                	ld	s6,464(sp)
    800040c4:	6bbe                	ld	s7,456(sp)
    800040c6:	6c1e                	ld	s8,448(sp)
    800040c8:	7cfa                	ld	s9,440(sp)
    800040ca:	7d5a                	ld	s10,432(sp)
    800040cc:	b9ed                	j	80003dc6 <kexec+0x60>
    800040ce:	6b5e                	ld	s6,464(sp)
    800040d0:	b9dd                	j	80003dc6 <kexec+0x60>
  sz = sz1;
    800040d2:	e0843983          	ld	s3,-504(s0)
    800040d6:	b595                	j	80003f3a <kexec+0x1d4>

00000000800040d8 <argfd>:
}
// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800040d8:	7179                	addi	sp,sp,-48
    800040da:	f406                	sd	ra,40(sp)
    800040dc:	f022                	sd	s0,32(sp)
    800040de:	ec26                	sd	s1,24(sp)
    800040e0:	e84a                	sd	s2,16(sp)
    800040e2:	1800                	addi	s0,sp,48
    800040e4:	892e                	mv	s2,a1
    800040e6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800040e8:	fdc40593          	addi	a1,s0,-36
    800040ec:	e91fd0ef          	jal	80001f7c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800040f0:	fdc42703          	lw	a4,-36(s0)
    800040f4:	47bd                	li	a5,15
    800040f6:	02e7e963          	bltu	a5,a4,80004128 <argfd+0x50>
    800040fa:	c81fc0ef          	jal	80000d7a <myproc>
    800040fe:	fdc42703          	lw	a4,-36(s0)
    80004102:	01a70793          	addi	a5,a4,26
    80004106:	078e                	slli	a5,a5,0x3
    80004108:	953e                	add	a0,a0,a5
    8000410a:	611c                	ld	a5,0(a0)
    8000410c:	c385                	beqz	a5,8000412c <argfd+0x54>
    return -1;
  if(pfd)
    8000410e:	00090463          	beqz	s2,80004116 <argfd+0x3e>
    *pfd = fd;
    80004112:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004116:	4501                	li	a0,0
  if(pf)
    80004118:	c091                	beqz	s1,8000411c <argfd+0x44>
    *pf = f;
    8000411a:	e09c                	sd	a5,0(s1)
}
    8000411c:	70a2                	ld	ra,40(sp)
    8000411e:	7402                	ld	s0,32(sp)
    80004120:	64e2                	ld	s1,24(sp)
    80004122:	6942                	ld	s2,16(sp)
    80004124:	6145                	addi	sp,sp,48
    80004126:	8082                	ret
    return -1;
    80004128:	557d                	li	a0,-1
    8000412a:	bfcd                	j	8000411c <argfd+0x44>
    8000412c:	557d                	li	a0,-1
    8000412e:	b7fd                	j	8000411c <argfd+0x44>

0000000080004130 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004130:	1101                	addi	sp,sp,-32
    80004132:	ec06                	sd	ra,24(sp)
    80004134:	e822                	sd	s0,16(sp)
    80004136:	e426                	sd	s1,8(sp)
    80004138:	1000                	addi	s0,sp,32
    8000413a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000413c:	c3ffc0ef          	jal	80000d7a <myproc>
    80004140:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004142:	0d050793          	addi	a5,a0,208
    80004146:	4501                	li	a0,0
    80004148:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000414a:	6398                	ld	a4,0(a5)
    8000414c:	cb19                	beqz	a4,80004162 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000414e:	2505                	addiw	a0,a0,1
    80004150:	07a1                	addi	a5,a5,8
    80004152:	fed51ce3          	bne	a0,a3,8000414a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004156:	557d                	li	a0,-1
}
    80004158:	60e2                	ld	ra,24(sp)
    8000415a:	6442                	ld	s0,16(sp)
    8000415c:	64a2                	ld	s1,8(sp)
    8000415e:	6105                	addi	sp,sp,32
    80004160:	8082                	ret
      p->ofile[fd] = f;
    80004162:	01a50793          	addi	a5,a0,26
    80004166:	078e                	slli	a5,a5,0x3
    80004168:	963e                	add	a2,a2,a5
    8000416a:	e204                	sd	s1,0(a2)
      return fd;
    8000416c:	b7f5                	j	80004158 <fdalloc+0x28>

000000008000416e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000416e:	715d                	addi	sp,sp,-80
    80004170:	e486                	sd	ra,72(sp)
    80004172:	e0a2                	sd	s0,64(sp)
    80004174:	fc26                	sd	s1,56(sp)
    80004176:	f84a                	sd	s2,48(sp)
    80004178:	f44e                	sd	s3,40(sp)
    8000417a:	ec56                	sd	s5,24(sp)
    8000417c:	e85a                	sd	s6,16(sp)
    8000417e:	0880                	addi	s0,sp,80
    80004180:	8b2e                	mv	s6,a1
    80004182:	89b2                	mv	s3,a2
    80004184:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004186:	fb040593          	addi	a1,s0,-80
    8000418a:	818ff0ef          	jal	800031a2 <nameiparent>
    8000418e:	84aa                	mv	s1,a0
    80004190:	10050a63          	beqz	a0,800042a4 <create+0x136>
    return 0;

  ilock(dp);
    80004194:	fdefe0ef          	jal	80002972 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004198:	4601                	li	a2,0
    8000419a:	fb040593          	addi	a1,s0,-80
    8000419e:	8526                	mv	a0,s1
    800041a0:	d83fe0ef          	jal	80002f22 <dirlookup>
    800041a4:	8aaa                	mv	s5,a0
    800041a6:	c129                	beqz	a0,800041e8 <create+0x7a>
    iunlockput(dp);
    800041a8:	8526                	mv	a0,s1
    800041aa:	9d3fe0ef          	jal	80002b7c <iunlockput>
    ilock(ip);
    800041ae:	8556                	mv	a0,s5
    800041b0:	fc2fe0ef          	jal	80002972 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800041b4:	4789                	li	a5,2
    800041b6:	02fb1463          	bne	s6,a5,800041de <create+0x70>
    800041ba:	044ad783          	lhu	a5,68(s5)
    800041be:	37f9                	addiw	a5,a5,-2
    800041c0:	17c2                	slli	a5,a5,0x30
    800041c2:	93c1                	srli	a5,a5,0x30
    800041c4:	4705                	li	a4,1
    800041c6:	00f76c63          	bltu	a4,a5,800041de <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800041ca:	8556                	mv	a0,s5
    800041cc:	60a6                	ld	ra,72(sp)
    800041ce:	6406                	ld	s0,64(sp)
    800041d0:	74e2                	ld	s1,56(sp)
    800041d2:	7942                	ld	s2,48(sp)
    800041d4:	79a2                	ld	s3,40(sp)
    800041d6:	6ae2                	ld	s5,24(sp)
    800041d8:	6b42                	ld	s6,16(sp)
    800041da:	6161                	addi	sp,sp,80
    800041dc:	8082                	ret
    iunlockput(ip);
    800041de:	8556                	mv	a0,s5
    800041e0:	99dfe0ef          	jal	80002b7c <iunlockput>
    return 0;
    800041e4:	4a81                	li	s5,0
    800041e6:	b7d5                	j	800041ca <create+0x5c>
    800041e8:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800041ea:	85da                	mv	a1,s6
    800041ec:	4088                	lw	a0,0(s1)
    800041ee:	e14fe0ef          	jal	80002802 <ialloc>
    800041f2:	8a2a                	mv	s4,a0
    800041f4:	cd15                	beqz	a0,80004230 <create+0xc2>
  ilock(ip);
    800041f6:	f7cfe0ef          	jal	80002972 <ilock>
  ip->major = major;
    800041fa:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800041fe:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004202:	4905                	li	s2,1
    80004204:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004208:	8552                	mv	a0,s4
    8000420a:	eb4fe0ef          	jal	800028be <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000420e:	032b0763          	beq	s6,s2,8000423c <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004212:	004a2603          	lw	a2,4(s4)
    80004216:	fb040593          	addi	a1,s0,-80
    8000421a:	8526                	mv	a0,s1
    8000421c:	ed3fe0ef          	jal	800030ee <dirlink>
    80004220:	06054563          	bltz	a0,8000428a <create+0x11c>
  iunlockput(dp);
    80004224:	8526                	mv	a0,s1
    80004226:	957fe0ef          	jal	80002b7c <iunlockput>
  return ip;
    8000422a:	8ad2                	mv	s5,s4
    8000422c:	7a02                	ld	s4,32(sp)
    8000422e:	bf71                	j	800041ca <create+0x5c>
    iunlockput(dp);
    80004230:	8526                	mv	a0,s1
    80004232:	94bfe0ef          	jal	80002b7c <iunlockput>
    return 0;
    80004236:	8ad2                	mv	s5,s4
    80004238:	7a02                	ld	s4,32(sp)
    8000423a:	bf41                	j	800041ca <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000423c:	004a2603          	lw	a2,4(s4)
    80004240:	00003597          	auipc	a1,0x3
    80004244:	42058593          	addi	a1,a1,1056 # 80007660 <etext+0x660>
    80004248:	8552                	mv	a0,s4
    8000424a:	ea5fe0ef          	jal	800030ee <dirlink>
    8000424e:	02054e63          	bltz	a0,8000428a <create+0x11c>
    80004252:	40d0                	lw	a2,4(s1)
    80004254:	00003597          	auipc	a1,0x3
    80004258:	41458593          	addi	a1,a1,1044 # 80007668 <etext+0x668>
    8000425c:	8552                	mv	a0,s4
    8000425e:	e91fe0ef          	jal	800030ee <dirlink>
    80004262:	02054463          	bltz	a0,8000428a <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004266:	004a2603          	lw	a2,4(s4)
    8000426a:	fb040593          	addi	a1,s0,-80
    8000426e:	8526                	mv	a0,s1
    80004270:	e7ffe0ef          	jal	800030ee <dirlink>
    80004274:	00054b63          	bltz	a0,8000428a <create+0x11c>
    dp->nlink++;  // for ".."
    80004278:	04a4d783          	lhu	a5,74(s1)
    8000427c:	2785                	addiw	a5,a5,1
    8000427e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004282:	8526                	mv	a0,s1
    80004284:	e3afe0ef          	jal	800028be <iupdate>
    80004288:	bf71                	j	80004224 <create+0xb6>
  ip->nlink = 0;
    8000428a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000428e:	8552                	mv	a0,s4
    80004290:	e2efe0ef          	jal	800028be <iupdate>
  iunlockput(ip);
    80004294:	8552                	mv	a0,s4
    80004296:	8e7fe0ef          	jal	80002b7c <iunlockput>
  iunlockput(dp);
    8000429a:	8526                	mv	a0,s1
    8000429c:	8e1fe0ef          	jal	80002b7c <iunlockput>
  return 0;
    800042a0:	7a02                	ld	s4,32(sp)
    800042a2:	b725                	j	800041ca <create+0x5c>
    return 0;
    800042a4:	8aaa                	mv	s5,a0
    800042a6:	b715                	j	800041ca <create+0x5c>

00000000800042a8 <sys_mmap>:
uint64 sys_mmap(void) {
    800042a8:	715d                	addi	sp,sp,-80
    800042aa:	e486                	sd	ra,72(sp)
    800042ac:	e0a2                	sd	s0,64(sp)
    800042ae:	0880                	addi	s0,sp,80
  argaddr(0, &addr);
    800042b0:	fd840593          	addi	a1,s0,-40
    800042b4:	4501                	li	a0,0
    800042b6:	ce3fd0ef          	jal	80001f98 <argaddr>
  argint(1, &len);
    800042ba:	fd440593          	addi	a1,s0,-44
    800042be:	4505                	li	a0,1
    800042c0:	cbdfd0ef          	jal	80001f7c <argint>
  argint(2, &prot);
    800042c4:	fd040593          	addi	a1,s0,-48
    800042c8:	4509                	li	a0,2
    800042ca:	cb3fd0ef          	jal	80001f7c <argint>
  argint(3, &flags);
    800042ce:	fcc40593          	addi	a1,s0,-52
    800042d2:	450d                	li	a0,3
    800042d4:	ca9fd0ef          	jal	80001f7c <argint>
  if (argfd(4, &fd, &file) < 0)
    800042d8:	fc040613          	addi	a2,s0,-64
    800042dc:	fc840593          	addi	a1,s0,-56
    800042e0:	4511                	li	a0,4
    800042e2:	df7ff0ef          	jal	800040d8 <argfd>
    return -1;
    800042e6:	577d                	li	a4,-1
  if (argfd(4, &fd, &file) < 0)
    800042e8:	0c054b63          	bltz	a0,800043be <sys_mmap+0x116>
    800042ec:	f84a                	sd	s2,48(sp)
  argint(5, &offset);
    800042ee:	fbc40593          	addi	a1,s0,-68
    800042f2:	4515                	li	a0,5
    800042f4:	c89fd0ef          	jal	80001f7c <argint>
  struct proc *p = myproc();
    800042f8:	a83fc0ef          	jal	80000d7a <myproc>
    800042fc:	892a                	mv	s2,a0
  for (int i = 0; i < VMA_COUNT; i ++) {
    800042fe:	16850713          	addi	a4,a0,360
    80004302:	4781                	li	a5,0
    80004304:	4641                	li	a2,16
    if (!p->vmas[i].is_used) {
    80004306:	4314                	lw	a3,0(a4)
    80004308:	ca89                	beqz	a3,8000431a <sys_mmap+0x72>
  for (int i = 0; i < VMA_COUNT; i ++) {
    8000430a:	2785                	addiw	a5,a5,1
    8000430c:	03070713          	addi	a4,a4,48
    80004310:	fec79be3          	bne	a5,a2,80004306 <sys_mmap+0x5e>
    return -1;
    80004314:	577d                	li	a4,-1
    80004316:	7942                	ld	s2,48(sp)
    80004318:	a05d                	j	800043be <sys_mmap+0x116>
    8000431a:	fc26                	sd	s1,56(sp)
      vma = &p->vmas[i];
    8000431c:	00179493          	slli	s1,a5,0x1
    80004320:	94be                	add	s1,s1,a5
    80004322:	0492                	slli	s1,s1,0x4
    80004324:	16848493          	addi	s1,s1,360
    80004328:	94ca                	add	s1,s1,s2
  if (vma == 0) {
    8000432a:	ccd9                	beqz	s1,800043c8 <sys_mmap+0x120>
  if (!file->readable && (prot & PROT_READ))
    8000432c:	fc043503          	ld	a0,-64(s0)
    80004330:	00854783          	lbu	a5,8(a0)
    80004334:	e791                	bnez	a5,80004340 <sys_mmap+0x98>
    80004336:	fd042783          	lw	a5,-48(s0)
    8000433a:	8b85                	andi	a5,a5,1
    return -1;
    8000433c:	577d                	li	a4,-1
  if (!file->readable && (prot & PROT_READ))
    8000433e:	ebc9                	bnez	a5,800043d0 <sys_mmap+0x128>
  if (!file->writable && (prot & PROT_WRITE) && (flags & MAP_SHARED))
    80004340:	00954783          	lbu	a5,9(a0)
    80004344:	eb91                	bnez	a5,80004358 <sys_mmap+0xb0>
    80004346:	fd042783          	lw	a5,-48(s0)
    8000434a:	8b89                	andi	a5,a5,2
    8000434c:	c791                	beqz	a5,80004358 <sys_mmap+0xb0>
    8000434e:	fcc42783          	lw	a5,-52(s0)
    80004352:	8b85                	andi	a5,a5,1
    return -1;
    80004354:	577d                	li	a4,-1
  if (!file->writable && (prot & PROT_WRITE) && (flags & MAP_SHARED))
    80004356:	e3c1                	bnez	a5,800043d6 <sys_mmap+0x12e>
  len = PGROUNDUP(len);
    80004358:	fd442703          	lw	a4,-44(s0)
    8000435c:	6785                	lui	a5,0x1
    8000435e:	37fd                	addiw	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004360:	9fb9                	addw	a5,a5,a4
    80004362:	777d                	lui	a4,0xfffff
    80004364:	8ff9                	and	a5,a5,a4
    80004366:	2781                	sext.w	a5,a5
    80004368:	fcf42a23          	sw	a5,-44(s0)
  if (p->sz + len >= MAXVA) 
    8000436c:	04893703          	ld	a4,72(s2)
    80004370:	97ba                	add	a5,a5,a4
    80004372:	56fd                	li	a3,-1
    80004374:	82e9                	srli	a3,a3,0x1a
    return -1;
    80004376:	577d                	li	a4,-1
  if (p->sz + len >= MAXVA) 
    80004378:	06f6e263          	bltu	a3,a5,800043dc <sys_mmap+0x134>
  vma->is_used = 1;
    8000437c:	4785                	li	a5,1
    8000437e:	c09c                	sw	a5,0(s1)
  vma->address = p->sz;
    80004380:	04893783          	ld	a5,72(s2)
    80004384:	e49c                	sd	a5,8(s1)
  vma->length = len;
    80004386:	fd442783          	lw	a5,-44(s0)
    8000438a:	c89c                	sw	a5,16(s1)
  vma->prot = prot;
    8000438c:	fd042783          	lw	a5,-48(s0)
    80004390:	c8dc                	sw	a5,20(s1)
  vma->flags = flags;
    80004392:	fcc42783          	lw	a5,-52(s0)
    80004396:	cc9c                	sw	a5,24(s1)
  vma->fd = fd;
    80004398:	fc842783          	lw	a5,-56(s0)
    8000439c:	ccdc                	sw	a5,28(s1)
  vma->file = file;
    8000439e:	f088                	sd	a0,32(s1)
  vma->offset = offset;
    800043a0:	fbc42783          	lw	a5,-68(s0)
    800043a4:	d49c                	sw	a5,40(s1)
  filedup(file);
    800043a6:	b7cff0ef          	jal	80003722 <filedup>
  p->sz += len;
    800043aa:	fd442703          	lw	a4,-44(s0)
    800043ae:	04893783          	ld	a5,72(s2)
    800043b2:	97ba                	add	a5,a5,a4
    800043b4:	04f93423          	sd	a5,72(s2)
  return vma->address;
    800043b8:	6498                	ld	a4,8(s1)
    800043ba:	74e2                	ld	s1,56(sp)
    800043bc:	7942                	ld	s2,48(sp)
}
    800043be:	853a                	mv	a0,a4
    800043c0:	60a6                	ld	ra,72(sp)
    800043c2:	6406                	ld	s0,64(sp)
    800043c4:	6161                	addi	sp,sp,80
    800043c6:	8082                	ret
    return -1;
    800043c8:	577d                	li	a4,-1
    800043ca:	74e2                	ld	s1,56(sp)
    800043cc:	7942                	ld	s2,48(sp)
    800043ce:	bfc5                	j	800043be <sys_mmap+0x116>
    800043d0:	74e2                	ld	s1,56(sp)
    800043d2:	7942                	ld	s2,48(sp)
    800043d4:	b7ed                	j	800043be <sys_mmap+0x116>
    800043d6:	74e2                	ld	s1,56(sp)
    800043d8:	7942                	ld	s2,48(sp)
    800043da:	b7d5                	j	800043be <sys_mmap+0x116>
    800043dc:	74e2                	ld	s1,56(sp)
    800043de:	7942                	ld	s2,48(sp)
    800043e0:	bff9                	j	800043be <sys_mmap+0x116>

00000000800043e2 <sys_munmap>:
uint64 sys_munmap(void) {
    800043e2:	7179                	addi	sp,sp,-48
    800043e4:	f406                	sd	ra,40(sp)
    800043e6:	f022                	sd	s0,32(sp)
    800043e8:	e84a                	sd	s2,16(sp)
    800043ea:	1800                	addi	s0,sp,48
  argaddr(0, &addr);
    800043ec:	fd840593          	addi	a1,s0,-40
    800043f0:	4501                	li	a0,0
    800043f2:	ba7fd0ef          	jal	80001f98 <argaddr>
  argint(1, &len);
    800043f6:	fd440593          	addi	a1,s0,-44
    800043fa:	4505                	li	a0,1
    800043fc:	b81fd0ef          	jal	80001f7c <argint>
  struct proc *p = myproc();
    80004400:	97bfc0ef          	jal	80000d7a <myproc>
    80004404:	892a                	mv	s2,a0
    if (p->vmas[i].is_used && p->vmas[i].address <= addr && addr < p->vmas[i].address + p->vmas[i].length) {
    80004406:	fd843803          	ld	a6,-40(s0)
    8000440a:	16850793          	addi	a5,a0,360
  for (int i = 0; i < VMA_COUNT; i ++) {
    8000440e:	4701                	li	a4,0
    80004410:	45c1                	li	a1,16
    80004412:	a031                	j	8000441e <sys_munmap+0x3c>
    80004414:	2705                	addiw	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffcf919>
    80004416:	03078793          	addi	a5,a5,48
    8000441a:	0cb70b63          	beq	a4,a1,800044f0 <sys_munmap+0x10e>
    if (p->vmas[i].is_used && p->vmas[i].address <= addr && addr < p->vmas[i].address + p->vmas[i].length) {
    8000441e:	4394                	lw	a3,0(a5)
    80004420:	daf5                	beqz	a3,80004414 <sys_munmap+0x32>
    80004422:	6794                	ld	a3,8(a5)
    80004424:	fed868e3          	bltu	a6,a3,80004414 <sys_munmap+0x32>
    80004428:	4b90                	lw	a2,16(a5)
    8000442a:	96b2                	add	a3,a3,a2
    8000442c:	fed874e3          	bgeu	a6,a3,80004414 <sys_munmap+0x32>
    80004430:	ec26                	sd	s1,24(sp)
      vma = &p->vmas[i];
    80004432:	00171493          	slli	s1,a4,0x1
    80004436:	94ba                	add	s1,s1,a4
    80004438:	0492                	slli	s1,s1,0x4
    8000443a:	16848493          	addi	s1,s1,360
    8000443e:	94ca                	add	s1,s1,s2
  if (vma == 0) {
    80004440:	c0ed                	beqz	s1,80004522 <sys_munmap+0x140>
  addr = PGROUNDDOWN(addr);
    80004442:	77fd                	lui	a5,0xfffff
    80004444:	00f87833          	and	a6,a6,a5
    80004448:	fd043c23          	sd	a6,-40(s0)
  len = PGROUNDUP(len);
    8000444c:	fd442703          	lw	a4,-44(s0)
    80004450:	6785                	lui	a5,0x1
    80004452:	37fd                	addiw	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004454:	9fb9                	addw	a5,a5,a4
    80004456:	777d                	lui	a4,0xfffff
    80004458:	8ff9                	and	a5,a5,a4
    8000445a:	fcf42a23          	sw	a5,-44(s0)
  begin_op();
    8000445e:	efffe0ef          	jal	8000335c <begin_op>
  if ((vma->flags & MAP_SHARED) && (vma->prot & PROT_WRITE)) {
    80004462:	4c9c                	lw	a5,24(s1)
    80004464:	8b85                	andi	a5,a5,1
    80004466:	cf85                	beqz	a5,8000449e <sys_munmap+0xbc>
    80004468:	48dc                	lw	a5,20(s1)
    8000446a:	8b89                	andi	a5,a5,2
    8000446c:	cb8d                	beqz	a5,8000449e <sys_munmap+0xbc>
    struct inode *ip = vma->file->ip;
    8000446e:	709c                	ld	a5,32(s1)
    80004470:	6f88                	ld	a0,24(a5)
    int file_sz = ip->size;
    80004472:	456c                	lw	a1,76(a0)
    int file_off = vma->offset + (addr - vma->address);
    80004474:	fd843603          	ld	a2,-40(s0)
    80004478:	549c                	lw	a5,40(s1)
    8000447a:	9fb1                	addw	a5,a5,a2
    8000447c:	6498                	ld	a4,8(s1)
    8000447e:	9f99                	subw	a5,a5,a4
    80004480:	0007869b          	sext.w	a3,a5
    if (file_off < file_sz) {
    80004484:	00b6dd63          	bge	a3,a1,8000449e <sys_munmap+0xbc>
    int wlen = len;
    80004488:	fd442703          	lw	a4,-44(s0)
      if (file_off + wlen > file_sz)
    8000448c:	00e7883b          	addw	a6,a5,a4
    80004490:	0105d463          	bge	a1,a6,80004498 <sys_munmap+0xb6>
        wlen = file_sz - file_off;
    80004494:	40f5873b          	subw	a4,a1,a5
      if (writei(ip, 1, addr, file_off, wlen) < 0) {
    80004498:	4585                	li	a1,1
    8000449a:	965fe0ef          	jal	80002dfe <writei>
  uvmunmap(p->pagetable, addr, len / PGSIZE, 1);
    8000449e:	fd442783          	lw	a5,-44(s0)
    800044a2:	41f7d61b          	sraiw	a2,a5,0x1f
    800044a6:	0146561b          	srliw	a2,a2,0x14
    800044aa:	9e3d                	addw	a2,a2,a5
    800044ac:	4685                	li	a3,1
    800044ae:	40c6561b          	sraiw	a2,a2,0xc
    800044b2:	fd843583          	ld	a1,-40(s0)
    800044b6:	05093503          	ld	a0,80(s2)
    800044ba:	9acfc0ef          	jal	80000666 <uvmunmap>
  if (addr == vma->address) {
    800044be:	649c                	ld	a5,8(s1)
    800044c0:	fd843703          	ld	a4,-40(s0)
    800044c4:	02e78863          	beq	a5,a4,800044f4 <sys_munmap+0x112>
  } else if (addr + len == vma->address + vma->length) {
    800044c8:	fd442603          	lw	a2,-44(s0)
    800044cc:	4894                	lw	a3,16(s1)
    800044ce:	9732                	add	a4,a4,a2
    800044d0:	97b6                	add	a5,a5,a3
    800044d2:	02f71c63          	bne	a4,a5,8000450a <sys_munmap+0x128>
    vma->length -= len;
    800044d6:	9e91                	subw	a3,a3,a2
    800044d8:	c894                	sw	a3,16(s1)
  if (vma->length == 0) {
    800044da:	489c                	lw	a5,16(s1)
    800044dc:	cf8d                	beqz	a5,80004516 <sys_munmap+0x134>
  end_op();
    800044de:	ee9fe0ef          	jal	800033c6 <end_op>
  return 0;
    800044e2:	4501                	li	a0,0
    800044e4:	64e2                	ld	s1,24(sp)
}
    800044e6:	70a2                	ld	ra,40(sp)
    800044e8:	7402                	ld	s0,32(sp)
    800044ea:	6942                	ld	s2,16(sp)
    800044ec:	6145                	addi	sp,sp,48
    800044ee:	8082                	ret
    return -1;
    800044f0:	557d                	li	a0,-1
    800044f2:	bfd5                	j	800044e6 <sys_munmap+0x104>
    vma->address += len;
    800044f4:	fd442703          	lw	a4,-44(s0)
    800044f8:	97ba                	add	a5,a5,a4
    800044fa:	e49c                	sd	a5,8(s1)
    vma->length -= len;
    800044fc:	489c                	lw	a5,16(s1)
    800044fe:	9f99                	subw	a5,a5,a4
    80004500:	c89c                	sw	a5,16(s1)
    vma->offset += len;
    80004502:	549c                	lw	a5,40(s1)
    80004504:	9fb9                	addw	a5,a5,a4
    80004506:	d49c                	sw	a5,40(s1)
    80004508:	bfc9                	j	800044da <sys_munmap+0xf8>
    panic("munmap: wtf");
    8000450a:	00003517          	auipc	a0,0x3
    8000450e:	16650513          	addi	a0,a0,358 # 80007670 <etext+0x670>
    80004512:	61c010ef          	jal	80005b2e <panic>
    fileclose(vma->file);
    80004516:	7088                	ld	a0,32(s1)
    80004518:	a50ff0ef          	jal	80003768 <fileclose>
    vma->is_used = 0;
    8000451c:	0004a023          	sw	zero,0(s1)
    80004520:	bf7d                	j	800044de <sys_munmap+0xfc>
    return -1;
    80004522:	557d                	li	a0,-1
    80004524:	64e2                	ld	s1,24(sp)
    80004526:	b7c1                	j	800044e6 <sys_munmap+0x104>

0000000080004528 <sys_dup>:
{
    80004528:	7179                	addi	sp,sp,-48
    8000452a:	f406                	sd	ra,40(sp)
    8000452c:	f022                	sd	s0,32(sp)
    8000452e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004530:	fd840613          	addi	a2,s0,-40
    80004534:	4581                	li	a1,0
    80004536:	4501                	li	a0,0
    80004538:	ba1ff0ef          	jal	800040d8 <argfd>
    return -1;
    8000453c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000453e:	02054363          	bltz	a0,80004564 <sys_dup+0x3c>
    80004542:	ec26                	sd	s1,24(sp)
    80004544:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004546:	fd843903          	ld	s2,-40(s0)
    8000454a:	854a                	mv	a0,s2
    8000454c:	be5ff0ef          	jal	80004130 <fdalloc>
    80004550:	84aa                	mv	s1,a0
    return -1;
    80004552:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004554:	00054d63          	bltz	a0,8000456e <sys_dup+0x46>
  filedup(f);
    80004558:	854a                	mv	a0,s2
    8000455a:	9c8ff0ef          	jal	80003722 <filedup>
  return fd;
    8000455e:	87a6                	mv	a5,s1
    80004560:	64e2                	ld	s1,24(sp)
    80004562:	6942                	ld	s2,16(sp)
}
    80004564:	853e                	mv	a0,a5
    80004566:	70a2                	ld	ra,40(sp)
    80004568:	7402                	ld	s0,32(sp)
    8000456a:	6145                	addi	sp,sp,48
    8000456c:	8082                	ret
    8000456e:	64e2                	ld	s1,24(sp)
    80004570:	6942                	ld	s2,16(sp)
    80004572:	bfcd                	j	80004564 <sys_dup+0x3c>

0000000080004574 <sys_read>:
{
    80004574:	7179                	addi	sp,sp,-48
    80004576:	f406                	sd	ra,40(sp)
    80004578:	f022                	sd	s0,32(sp)
    8000457a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000457c:	fd840593          	addi	a1,s0,-40
    80004580:	4505                	li	a0,1
    80004582:	a17fd0ef          	jal	80001f98 <argaddr>
  argint(2, &n);
    80004586:	fe440593          	addi	a1,s0,-28
    8000458a:	4509                	li	a0,2
    8000458c:	9f1fd0ef          	jal	80001f7c <argint>
  if(argfd(0, 0, &f) < 0)
    80004590:	fe840613          	addi	a2,s0,-24
    80004594:	4581                	li	a1,0
    80004596:	4501                	li	a0,0
    80004598:	b41ff0ef          	jal	800040d8 <argfd>
    8000459c:	87aa                	mv	a5,a0
    return -1;
    8000459e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800045a0:	0007ca63          	bltz	a5,800045b4 <sys_read+0x40>
  return fileread(f, p, n);
    800045a4:	fe442603          	lw	a2,-28(s0)
    800045a8:	fd843583          	ld	a1,-40(s0)
    800045ac:	fe843503          	ld	a0,-24(s0)
    800045b0:	ad8ff0ef          	jal	80003888 <fileread>
}
    800045b4:	70a2                	ld	ra,40(sp)
    800045b6:	7402                	ld	s0,32(sp)
    800045b8:	6145                	addi	sp,sp,48
    800045ba:	8082                	ret

00000000800045bc <sys_write>:
{
    800045bc:	7179                	addi	sp,sp,-48
    800045be:	f406                	sd	ra,40(sp)
    800045c0:	f022                	sd	s0,32(sp)
    800045c2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800045c4:	fd840593          	addi	a1,s0,-40
    800045c8:	4505                	li	a0,1
    800045ca:	9cffd0ef          	jal	80001f98 <argaddr>
  argint(2, &n);
    800045ce:	fe440593          	addi	a1,s0,-28
    800045d2:	4509                	li	a0,2
    800045d4:	9a9fd0ef          	jal	80001f7c <argint>
  if(argfd(0, 0, &f) < 0)
    800045d8:	fe840613          	addi	a2,s0,-24
    800045dc:	4581                	li	a1,0
    800045de:	4501                	li	a0,0
    800045e0:	af9ff0ef          	jal	800040d8 <argfd>
    800045e4:	87aa                	mv	a5,a0
    return -1;
    800045e6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800045e8:	0007ca63          	bltz	a5,800045fc <sys_write+0x40>
  return filewrite(f, p, n);
    800045ec:	fe442603          	lw	a2,-28(s0)
    800045f0:	fd843583          	ld	a1,-40(s0)
    800045f4:	fe843503          	ld	a0,-24(s0)
    800045f8:	b4eff0ef          	jal	80003946 <filewrite>
}
    800045fc:	70a2                	ld	ra,40(sp)
    800045fe:	7402                	ld	s0,32(sp)
    80004600:	6145                	addi	sp,sp,48
    80004602:	8082                	ret

0000000080004604 <sys_close>:
{
    80004604:	1101                	addi	sp,sp,-32
    80004606:	ec06                	sd	ra,24(sp)
    80004608:	e822                	sd	s0,16(sp)
    8000460a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000460c:	fe040613          	addi	a2,s0,-32
    80004610:	fec40593          	addi	a1,s0,-20
    80004614:	4501                	li	a0,0
    80004616:	ac3ff0ef          	jal	800040d8 <argfd>
    return -1;
    8000461a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000461c:	02054063          	bltz	a0,8000463c <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004620:	f5afc0ef          	jal	80000d7a <myproc>
    80004624:	fec42783          	lw	a5,-20(s0)
    80004628:	07e9                	addi	a5,a5,26
    8000462a:	078e                	slli	a5,a5,0x3
    8000462c:	953e                	add	a0,a0,a5
    8000462e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004632:	fe043503          	ld	a0,-32(s0)
    80004636:	932ff0ef          	jal	80003768 <fileclose>
  return 0;
    8000463a:	4781                	li	a5,0
}
    8000463c:	853e                	mv	a0,a5
    8000463e:	60e2                	ld	ra,24(sp)
    80004640:	6442                	ld	s0,16(sp)
    80004642:	6105                	addi	sp,sp,32
    80004644:	8082                	ret

0000000080004646 <sys_fstat>:
{
    80004646:	1101                	addi	sp,sp,-32
    80004648:	ec06                	sd	ra,24(sp)
    8000464a:	e822                	sd	s0,16(sp)
    8000464c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000464e:	fe040593          	addi	a1,s0,-32
    80004652:	4505                	li	a0,1
    80004654:	945fd0ef          	jal	80001f98 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004658:	fe840613          	addi	a2,s0,-24
    8000465c:	4581                	li	a1,0
    8000465e:	4501                	li	a0,0
    80004660:	a79ff0ef          	jal	800040d8 <argfd>
    80004664:	87aa                	mv	a5,a0
    return -1;
    80004666:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004668:	0007c863          	bltz	a5,80004678 <sys_fstat+0x32>
  return filestat(f, st);
    8000466c:	fe043583          	ld	a1,-32(s0)
    80004670:	fe843503          	ld	a0,-24(s0)
    80004674:	9b6ff0ef          	jal	8000382a <filestat>
}
    80004678:	60e2                	ld	ra,24(sp)
    8000467a:	6442                	ld	s0,16(sp)
    8000467c:	6105                	addi	sp,sp,32
    8000467e:	8082                	ret

0000000080004680 <sys_link>:
{
    80004680:	7169                	addi	sp,sp,-304
    80004682:	f606                	sd	ra,296(sp)
    80004684:	f222                	sd	s0,288(sp)
    80004686:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004688:	08000613          	li	a2,128
    8000468c:	ed040593          	addi	a1,s0,-304
    80004690:	4501                	li	a0,0
    80004692:	923fd0ef          	jal	80001fb4 <argstr>
    return -1;
    80004696:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004698:	0c054e63          	bltz	a0,80004774 <sys_link+0xf4>
    8000469c:	08000613          	li	a2,128
    800046a0:	f5040593          	addi	a1,s0,-176
    800046a4:	4505                	li	a0,1
    800046a6:	90ffd0ef          	jal	80001fb4 <argstr>
    return -1;
    800046aa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800046ac:	0c054463          	bltz	a0,80004774 <sys_link+0xf4>
    800046b0:	ee26                	sd	s1,280(sp)
  begin_op();
    800046b2:	cabfe0ef          	jal	8000335c <begin_op>
  if((ip = namei(old)) == 0){
    800046b6:	ed040513          	addi	a0,s0,-304
    800046ba:	acffe0ef          	jal	80003188 <namei>
    800046be:	84aa                	mv	s1,a0
    800046c0:	c53d                	beqz	a0,8000472e <sys_link+0xae>
  ilock(ip);
    800046c2:	ab0fe0ef          	jal	80002972 <ilock>
  if(ip->type == T_DIR){
    800046c6:	04449703          	lh	a4,68(s1)
    800046ca:	4785                	li	a5,1
    800046cc:	06f70663          	beq	a4,a5,80004738 <sys_link+0xb8>
    800046d0:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800046d2:	04a4d783          	lhu	a5,74(s1)
    800046d6:	2785                	addiw	a5,a5,1
    800046d8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800046dc:	8526                	mv	a0,s1
    800046de:	9e0fe0ef          	jal	800028be <iupdate>
  iunlock(ip);
    800046e2:	8526                	mv	a0,s1
    800046e4:	b3cfe0ef          	jal	80002a20 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800046e8:	fd040593          	addi	a1,s0,-48
    800046ec:	f5040513          	addi	a0,s0,-176
    800046f0:	ab3fe0ef          	jal	800031a2 <nameiparent>
    800046f4:	892a                	mv	s2,a0
    800046f6:	cd21                	beqz	a0,8000474e <sys_link+0xce>
  ilock(dp);
    800046f8:	a7afe0ef          	jal	80002972 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800046fc:	00092703          	lw	a4,0(s2)
    80004700:	409c                	lw	a5,0(s1)
    80004702:	04f71363          	bne	a4,a5,80004748 <sys_link+0xc8>
    80004706:	40d0                	lw	a2,4(s1)
    80004708:	fd040593          	addi	a1,s0,-48
    8000470c:	854a                	mv	a0,s2
    8000470e:	9e1fe0ef          	jal	800030ee <dirlink>
    80004712:	02054b63          	bltz	a0,80004748 <sys_link+0xc8>
  iunlockput(dp);
    80004716:	854a                	mv	a0,s2
    80004718:	c64fe0ef          	jal	80002b7c <iunlockput>
  iput(ip);
    8000471c:	8526                	mv	a0,s1
    8000471e:	bd6fe0ef          	jal	80002af4 <iput>
  end_op();
    80004722:	ca5fe0ef          	jal	800033c6 <end_op>
  return 0;
    80004726:	4781                	li	a5,0
    80004728:	64f2                	ld	s1,280(sp)
    8000472a:	6952                	ld	s2,272(sp)
    8000472c:	a0a1                	j	80004774 <sys_link+0xf4>
    end_op();
    8000472e:	c99fe0ef          	jal	800033c6 <end_op>
    return -1;
    80004732:	57fd                	li	a5,-1
    80004734:	64f2                	ld	s1,280(sp)
    80004736:	a83d                	j	80004774 <sys_link+0xf4>
    iunlockput(ip);
    80004738:	8526                	mv	a0,s1
    8000473a:	c42fe0ef          	jal	80002b7c <iunlockput>
    end_op();
    8000473e:	c89fe0ef          	jal	800033c6 <end_op>
    return -1;
    80004742:	57fd                	li	a5,-1
    80004744:	64f2                	ld	s1,280(sp)
    80004746:	a03d                	j	80004774 <sys_link+0xf4>
    iunlockput(dp);
    80004748:	854a                	mv	a0,s2
    8000474a:	c32fe0ef          	jal	80002b7c <iunlockput>
  ilock(ip);
    8000474e:	8526                	mv	a0,s1
    80004750:	a22fe0ef          	jal	80002972 <ilock>
  ip->nlink--;
    80004754:	04a4d783          	lhu	a5,74(s1)
    80004758:	37fd                	addiw	a5,a5,-1
    8000475a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000475e:	8526                	mv	a0,s1
    80004760:	95efe0ef          	jal	800028be <iupdate>
  iunlockput(ip);
    80004764:	8526                	mv	a0,s1
    80004766:	c16fe0ef          	jal	80002b7c <iunlockput>
  end_op();
    8000476a:	c5dfe0ef          	jal	800033c6 <end_op>
  return -1;
    8000476e:	57fd                	li	a5,-1
    80004770:	64f2                	ld	s1,280(sp)
    80004772:	6952                	ld	s2,272(sp)
}
    80004774:	853e                	mv	a0,a5
    80004776:	70b2                	ld	ra,296(sp)
    80004778:	7412                	ld	s0,288(sp)
    8000477a:	6155                	addi	sp,sp,304
    8000477c:	8082                	ret

000000008000477e <sys_unlink>:
{
    8000477e:	7151                	addi	sp,sp,-240
    80004780:	f586                	sd	ra,232(sp)
    80004782:	f1a2                	sd	s0,224(sp)
    80004784:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004786:	08000613          	li	a2,128
    8000478a:	f3040593          	addi	a1,s0,-208
    8000478e:	4501                	li	a0,0
    80004790:	825fd0ef          	jal	80001fb4 <argstr>
    80004794:	16054063          	bltz	a0,800048f4 <sys_unlink+0x176>
    80004798:	eda6                	sd	s1,216(sp)
  begin_op();
    8000479a:	bc3fe0ef          	jal	8000335c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000479e:	fb040593          	addi	a1,s0,-80
    800047a2:	f3040513          	addi	a0,s0,-208
    800047a6:	9fdfe0ef          	jal	800031a2 <nameiparent>
    800047aa:	84aa                	mv	s1,a0
    800047ac:	c945                	beqz	a0,8000485c <sys_unlink+0xde>
  ilock(dp);
    800047ae:	9c4fe0ef          	jal	80002972 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800047b2:	00003597          	auipc	a1,0x3
    800047b6:	eae58593          	addi	a1,a1,-338 # 80007660 <etext+0x660>
    800047ba:	fb040513          	addi	a0,s0,-80
    800047be:	f4efe0ef          	jal	80002f0c <namecmp>
    800047c2:	10050e63          	beqz	a0,800048de <sys_unlink+0x160>
    800047c6:	00003597          	auipc	a1,0x3
    800047ca:	ea258593          	addi	a1,a1,-350 # 80007668 <etext+0x668>
    800047ce:	fb040513          	addi	a0,s0,-80
    800047d2:	f3afe0ef          	jal	80002f0c <namecmp>
    800047d6:	10050463          	beqz	a0,800048de <sys_unlink+0x160>
    800047da:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800047dc:	f2c40613          	addi	a2,s0,-212
    800047e0:	fb040593          	addi	a1,s0,-80
    800047e4:	8526                	mv	a0,s1
    800047e6:	f3cfe0ef          	jal	80002f22 <dirlookup>
    800047ea:	892a                	mv	s2,a0
    800047ec:	0e050863          	beqz	a0,800048dc <sys_unlink+0x15e>
  ilock(ip);
    800047f0:	982fe0ef          	jal	80002972 <ilock>
  if(ip->nlink < 1)
    800047f4:	04a91783          	lh	a5,74(s2)
    800047f8:	06f05763          	blez	a5,80004866 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800047fc:	04491703          	lh	a4,68(s2)
    80004800:	4785                	li	a5,1
    80004802:	06f70963          	beq	a4,a5,80004874 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004806:	4641                	li	a2,16
    80004808:	4581                	li	a1,0
    8000480a:	fc040513          	addi	a0,s0,-64
    8000480e:	941fb0ef          	jal	8000014e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004812:	4741                	li	a4,16
    80004814:	f2c42683          	lw	a3,-212(s0)
    80004818:	fc040613          	addi	a2,s0,-64
    8000481c:	4581                	li	a1,0
    8000481e:	8526                	mv	a0,s1
    80004820:	ddefe0ef          	jal	80002dfe <writei>
    80004824:	47c1                	li	a5,16
    80004826:	08f51b63          	bne	a0,a5,800048bc <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    8000482a:	04491703          	lh	a4,68(s2)
    8000482e:	4785                	li	a5,1
    80004830:	08f70d63          	beq	a4,a5,800048ca <sys_unlink+0x14c>
  iunlockput(dp);
    80004834:	8526                	mv	a0,s1
    80004836:	b46fe0ef          	jal	80002b7c <iunlockput>
  ip->nlink--;
    8000483a:	04a95783          	lhu	a5,74(s2)
    8000483e:	37fd                	addiw	a5,a5,-1
    80004840:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004844:	854a                	mv	a0,s2
    80004846:	878fe0ef          	jal	800028be <iupdate>
  iunlockput(ip);
    8000484a:	854a                	mv	a0,s2
    8000484c:	b30fe0ef          	jal	80002b7c <iunlockput>
  end_op();
    80004850:	b77fe0ef          	jal	800033c6 <end_op>
  return 0;
    80004854:	4501                	li	a0,0
    80004856:	64ee                	ld	s1,216(sp)
    80004858:	694e                	ld	s2,208(sp)
    8000485a:	a849                	j	800048ec <sys_unlink+0x16e>
    end_op();
    8000485c:	b6bfe0ef          	jal	800033c6 <end_op>
    return -1;
    80004860:	557d                	li	a0,-1
    80004862:	64ee                	ld	s1,216(sp)
    80004864:	a061                	j	800048ec <sys_unlink+0x16e>
    80004866:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004868:	00003517          	auipc	a0,0x3
    8000486c:	e1850513          	addi	a0,a0,-488 # 80007680 <etext+0x680>
    80004870:	2be010ef          	jal	80005b2e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004874:	04c92703          	lw	a4,76(s2)
    80004878:	02000793          	li	a5,32
    8000487c:	f8e7f5e3          	bgeu	a5,a4,80004806 <sys_unlink+0x88>
    80004880:	e5ce                	sd	s3,200(sp)
    80004882:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004886:	4741                	li	a4,16
    80004888:	86ce                	mv	a3,s3
    8000488a:	f1840613          	addi	a2,s0,-232
    8000488e:	4581                	li	a1,0
    80004890:	854a                	mv	a0,s2
    80004892:	c70fe0ef          	jal	80002d02 <readi>
    80004896:	47c1                	li	a5,16
    80004898:	00f51c63          	bne	a0,a5,800048b0 <sys_unlink+0x132>
    if(de.inum != 0)
    8000489c:	f1845783          	lhu	a5,-232(s0)
    800048a0:	efa1                	bnez	a5,800048f8 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800048a2:	29c1                	addiw	s3,s3,16
    800048a4:	04c92783          	lw	a5,76(s2)
    800048a8:	fcf9efe3          	bltu	s3,a5,80004886 <sys_unlink+0x108>
    800048ac:	69ae                	ld	s3,200(sp)
    800048ae:	bfa1                	j	80004806 <sys_unlink+0x88>
      panic("isdirempty: readi");
    800048b0:	00003517          	auipc	a0,0x3
    800048b4:	de850513          	addi	a0,a0,-536 # 80007698 <etext+0x698>
    800048b8:	276010ef          	jal	80005b2e <panic>
    800048bc:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800048be:	00003517          	auipc	a0,0x3
    800048c2:	df250513          	addi	a0,a0,-526 # 800076b0 <etext+0x6b0>
    800048c6:	268010ef          	jal	80005b2e <panic>
    dp->nlink--;
    800048ca:	04a4d783          	lhu	a5,74(s1)
    800048ce:	37fd                	addiw	a5,a5,-1
    800048d0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800048d4:	8526                	mv	a0,s1
    800048d6:	fe9fd0ef          	jal	800028be <iupdate>
    800048da:	bfa9                	j	80004834 <sys_unlink+0xb6>
    800048dc:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800048de:	8526                	mv	a0,s1
    800048e0:	a9cfe0ef          	jal	80002b7c <iunlockput>
  end_op();
    800048e4:	ae3fe0ef          	jal	800033c6 <end_op>
  return -1;
    800048e8:	557d                	li	a0,-1
    800048ea:	64ee                	ld	s1,216(sp)
}
    800048ec:	70ae                	ld	ra,232(sp)
    800048ee:	740e                	ld	s0,224(sp)
    800048f0:	616d                	addi	sp,sp,240
    800048f2:	8082                	ret
    return -1;
    800048f4:	557d                	li	a0,-1
    800048f6:	bfdd                	j	800048ec <sys_unlink+0x16e>
    iunlockput(ip);
    800048f8:	854a                	mv	a0,s2
    800048fa:	a82fe0ef          	jal	80002b7c <iunlockput>
    goto bad;
    800048fe:	694e                	ld	s2,208(sp)
    80004900:	69ae                	ld	s3,200(sp)
    80004902:	bff1                	j	800048de <sys_unlink+0x160>

0000000080004904 <sys_open>:

uint64
sys_open(void)
{
    80004904:	7131                	addi	sp,sp,-192
    80004906:	fd06                	sd	ra,184(sp)
    80004908:	f922                	sd	s0,176(sp)
    8000490a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000490c:	f4c40593          	addi	a1,s0,-180
    80004910:	4505                	li	a0,1
    80004912:	e6afd0ef          	jal	80001f7c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004916:	08000613          	li	a2,128
    8000491a:	f5040593          	addi	a1,s0,-176
    8000491e:	4501                	li	a0,0
    80004920:	e94fd0ef          	jal	80001fb4 <argstr>
    80004924:	87aa                	mv	a5,a0
    return -1;
    80004926:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004928:	0a07c263          	bltz	a5,800049cc <sys_open+0xc8>
    8000492c:	f526                	sd	s1,168(sp)

  begin_op();
    8000492e:	a2ffe0ef          	jal	8000335c <begin_op>

  if(omode & O_CREATE){
    80004932:	f4c42783          	lw	a5,-180(s0)
    80004936:	2007f793          	andi	a5,a5,512
    8000493a:	c3d5                	beqz	a5,800049de <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000493c:	4681                	li	a3,0
    8000493e:	4601                	li	a2,0
    80004940:	4589                	li	a1,2
    80004942:	f5040513          	addi	a0,s0,-176
    80004946:	829ff0ef          	jal	8000416e <create>
    8000494a:	84aa                	mv	s1,a0
    if(ip == 0){
    8000494c:	c541                	beqz	a0,800049d4 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000494e:	04449703          	lh	a4,68(s1)
    80004952:	478d                	li	a5,3
    80004954:	00f71763          	bne	a4,a5,80004962 <sys_open+0x5e>
    80004958:	0464d703          	lhu	a4,70(s1)
    8000495c:	47a5                	li	a5,9
    8000495e:	0ae7ed63          	bltu	a5,a4,80004a18 <sys_open+0x114>
    80004962:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004964:	d61fe0ef          	jal	800036c4 <filealloc>
    80004968:	892a                	mv	s2,a0
    8000496a:	c179                	beqz	a0,80004a30 <sys_open+0x12c>
    8000496c:	ed4e                	sd	s3,152(sp)
    8000496e:	fc2ff0ef          	jal	80004130 <fdalloc>
    80004972:	89aa                	mv	s3,a0
    80004974:	0a054a63          	bltz	a0,80004a28 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004978:	04449703          	lh	a4,68(s1)
    8000497c:	478d                	li	a5,3
    8000497e:	0cf70263          	beq	a4,a5,80004a42 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004982:	4789                	li	a5,2
    80004984:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004988:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000498c:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004990:	f4c42783          	lw	a5,-180(s0)
    80004994:	0017c713          	xori	a4,a5,1
    80004998:	8b05                	andi	a4,a4,1
    8000499a:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000499e:	0037f713          	andi	a4,a5,3
    800049a2:	00e03733          	snez	a4,a4
    800049a6:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800049aa:	4007f793          	andi	a5,a5,1024
    800049ae:	c791                	beqz	a5,800049ba <sys_open+0xb6>
    800049b0:	04449703          	lh	a4,68(s1)
    800049b4:	4789                	li	a5,2
    800049b6:	08f70d63          	beq	a4,a5,80004a50 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800049ba:	8526                	mv	a0,s1
    800049bc:	864fe0ef          	jal	80002a20 <iunlock>
  end_op();
    800049c0:	a07fe0ef          	jal	800033c6 <end_op>

  return fd;
    800049c4:	854e                	mv	a0,s3
    800049c6:	74aa                	ld	s1,168(sp)
    800049c8:	790a                	ld	s2,160(sp)
    800049ca:	69ea                	ld	s3,152(sp)
}
    800049cc:	70ea                	ld	ra,184(sp)
    800049ce:	744a                	ld	s0,176(sp)
    800049d0:	6129                	addi	sp,sp,192
    800049d2:	8082                	ret
      end_op();
    800049d4:	9f3fe0ef          	jal	800033c6 <end_op>
      return -1;
    800049d8:	557d                	li	a0,-1
    800049da:	74aa                	ld	s1,168(sp)
    800049dc:	bfc5                	j	800049cc <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800049de:	f5040513          	addi	a0,s0,-176
    800049e2:	fa6fe0ef          	jal	80003188 <namei>
    800049e6:	84aa                	mv	s1,a0
    800049e8:	c11d                	beqz	a0,80004a0e <sys_open+0x10a>
    ilock(ip);
    800049ea:	f89fd0ef          	jal	80002972 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800049ee:	04449703          	lh	a4,68(s1)
    800049f2:	4785                	li	a5,1
    800049f4:	f4f71de3          	bne	a4,a5,8000494e <sys_open+0x4a>
    800049f8:	f4c42783          	lw	a5,-180(s0)
    800049fc:	d3bd                	beqz	a5,80004962 <sys_open+0x5e>
      iunlockput(ip);
    800049fe:	8526                	mv	a0,s1
    80004a00:	97cfe0ef          	jal	80002b7c <iunlockput>
      end_op();
    80004a04:	9c3fe0ef          	jal	800033c6 <end_op>
      return -1;
    80004a08:	557d                	li	a0,-1
    80004a0a:	74aa                	ld	s1,168(sp)
    80004a0c:	b7c1                	j	800049cc <sys_open+0xc8>
      end_op();
    80004a0e:	9b9fe0ef          	jal	800033c6 <end_op>
      return -1;
    80004a12:	557d                	li	a0,-1
    80004a14:	74aa                	ld	s1,168(sp)
    80004a16:	bf5d                	j	800049cc <sys_open+0xc8>
    iunlockput(ip);
    80004a18:	8526                	mv	a0,s1
    80004a1a:	962fe0ef          	jal	80002b7c <iunlockput>
    end_op();
    80004a1e:	9a9fe0ef          	jal	800033c6 <end_op>
    return -1;
    80004a22:	557d                	li	a0,-1
    80004a24:	74aa                	ld	s1,168(sp)
    80004a26:	b75d                	j	800049cc <sys_open+0xc8>
      fileclose(f);
    80004a28:	854a                	mv	a0,s2
    80004a2a:	d3ffe0ef          	jal	80003768 <fileclose>
    80004a2e:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004a30:	8526                	mv	a0,s1
    80004a32:	94afe0ef          	jal	80002b7c <iunlockput>
    end_op();
    80004a36:	991fe0ef          	jal	800033c6 <end_op>
    return -1;
    80004a3a:	557d                	li	a0,-1
    80004a3c:	74aa                	ld	s1,168(sp)
    80004a3e:	790a                	ld	s2,160(sp)
    80004a40:	b771                	j	800049cc <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004a42:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004a46:	04649783          	lh	a5,70(s1)
    80004a4a:	02f91223          	sh	a5,36(s2)
    80004a4e:	bf3d                	j	8000498c <sys_open+0x88>
    itrunc(ip);
    80004a50:	8526                	mv	a0,s1
    80004a52:	80efe0ef          	jal	80002a60 <itrunc>
    80004a56:	b795                	j	800049ba <sys_open+0xb6>

0000000080004a58 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004a58:	7175                	addi	sp,sp,-144
    80004a5a:	e506                	sd	ra,136(sp)
    80004a5c:	e122                	sd	s0,128(sp)
    80004a5e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004a60:	8fdfe0ef          	jal	8000335c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004a64:	08000613          	li	a2,128
    80004a68:	f7040593          	addi	a1,s0,-144
    80004a6c:	4501                	li	a0,0
    80004a6e:	d46fd0ef          	jal	80001fb4 <argstr>
    80004a72:	02054363          	bltz	a0,80004a98 <sys_mkdir+0x40>
    80004a76:	4681                	li	a3,0
    80004a78:	4601                	li	a2,0
    80004a7a:	4585                	li	a1,1
    80004a7c:	f7040513          	addi	a0,s0,-144
    80004a80:	eeeff0ef          	jal	8000416e <create>
    80004a84:	c911                	beqz	a0,80004a98 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004a86:	8f6fe0ef          	jal	80002b7c <iunlockput>
  end_op();
    80004a8a:	93dfe0ef          	jal	800033c6 <end_op>
  return 0;
    80004a8e:	4501                	li	a0,0
}
    80004a90:	60aa                	ld	ra,136(sp)
    80004a92:	640a                	ld	s0,128(sp)
    80004a94:	6149                	addi	sp,sp,144
    80004a96:	8082                	ret
    end_op();
    80004a98:	92ffe0ef          	jal	800033c6 <end_op>
    return -1;
    80004a9c:	557d                	li	a0,-1
    80004a9e:	bfcd                	j	80004a90 <sys_mkdir+0x38>

0000000080004aa0 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004aa0:	7135                	addi	sp,sp,-160
    80004aa2:	ed06                	sd	ra,152(sp)
    80004aa4:	e922                	sd	s0,144(sp)
    80004aa6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004aa8:	8b5fe0ef          	jal	8000335c <begin_op>
  argint(1, &major);
    80004aac:	f6c40593          	addi	a1,s0,-148
    80004ab0:	4505                	li	a0,1
    80004ab2:	ccafd0ef          	jal	80001f7c <argint>
  argint(2, &minor);
    80004ab6:	f6840593          	addi	a1,s0,-152
    80004aba:	4509                	li	a0,2
    80004abc:	cc0fd0ef          	jal	80001f7c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004ac0:	08000613          	li	a2,128
    80004ac4:	f7040593          	addi	a1,s0,-144
    80004ac8:	4501                	li	a0,0
    80004aca:	ceafd0ef          	jal	80001fb4 <argstr>
    80004ace:	02054563          	bltz	a0,80004af8 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004ad2:	f6841683          	lh	a3,-152(s0)
    80004ad6:	f6c41603          	lh	a2,-148(s0)
    80004ada:	458d                	li	a1,3
    80004adc:	f7040513          	addi	a0,s0,-144
    80004ae0:	e8eff0ef          	jal	8000416e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004ae4:	c911                	beqz	a0,80004af8 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004ae6:	896fe0ef          	jal	80002b7c <iunlockput>
  end_op();
    80004aea:	8ddfe0ef          	jal	800033c6 <end_op>
  return 0;
    80004aee:	4501                	li	a0,0
}
    80004af0:	60ea                	ld	ra,152(sp)
    80004af2:	644a                	ld	s0,144(sp)
    80004af4:	610d                	addi	sp,sp,160
    80004af6:	8082                	ret
    end_op();
    80004af8:	8cffe0ef          	jal	800033c6 <end_op>
    return -1;
    80004afc:	557d                	li	a0,-1
    80004afe:	bfcd                	j	80004af0 <sys_mknod+0x50>

0000000080004b00 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004b00:	7135                	addi	sp,sp,-160
    80004b02:	ed06                	sd	ra,152(sp)
    80004b04:	e922                	sd	s0,144(sp)
    80004b06:	e14a                	sd	s2,128(sp)
    80004b08:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004b0a:	a70fc0ef          	jal	80000d7a <myproc>
    80004b0e:	892a                	mv	s2,a0
  
  begin_op();
    80004b10:	84dfe0ef          	jal	8000335c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004b14:	08000613          	li	a2,128
    80004b18:	f6040593          	addi	a1,s0,-160
    80004b1c:	4501                	li	a0,0
    80004b1e:	c96fd0ef          	jal	80001fb4 <argstr>
    80004b22:	04054363          	bltz	a0,80004b68 <sys_chdir+0x68>
    80004b26:	e526                	sd	s1,136(sp)
    80004b28:	f6040513          	addi	a0,s0,-160
    80004b2c:	e5cfe0ef          	jal	80003188 <namei>
    80004b30:	84aa                	mv	s1,a0
    80004b32:	c915                	beqz	a0,80004b66 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004b34:	e3ffd0ef          	jal	80002972 <ilock>
  if(ip->type != T_DIR){
    80004b38:	04449703          	lh	a4,68(s1)
    80004b3c:	4785                	li	a5,1
    80004b3e:	02f71963          	bne	a4,a5,80004b70 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004b42:	8526                	mv	a0,s1
    80004b44:	eddfd0ef          	jal	80002a20 <iunlock>
  iput(p->cwd);
    80004b48:	15093503          	ld	a0,336(s2)
    80004b4c:	fa9fd0ef          	jal	80002af4 <iput>
  end_op();
    80004b50:	877fe0ef          	jal	800033c6 <end_op>
  p->cwd = ip;
    80004b54:	14993823          	sd	s1,336(s2)
  return 0;
    80004b58:	4501                	li	a0,0
    80004b5a:	64aa                	ld	s1,136(sp)
}
    80004b5c:	60ea                	ld	ra,152(sp)
    80004b5e:	644a                	ld	s0,144(sp)
    80004b60:	690a                	ld	s2,128(sp)
    80004b62:	610d                	addi	sp,sp,160
    80004b64:	8082                	ret
    80004b66:	64aa                	ld	s1,136(sp)
    end_op();
    80004b68:	85ffe0ef          	jal	800033c6 <end_op>
    return -1;
    80004b6c:	557d                	li	a0,-1
    80004b6e:	b7fd                	j	80004b5c <sys_chdir+0x5c>
    iunlockput(ip);
    80004b70:	8526                	mv	a0,s1
    80004b72:	80afe0ef          	jal	80002b7c <iunlockput>
    end_op();
    80004b76:	851fe0ef          	jal	800033c6 <end_op>
    return -1;
    80004b7a:	557d                	li	a0,-1
    80004b7c:	64aa                	ld	s1,136(sp)
    80004b7e:	bff9                	j	80004b5c <sys_chdir+0x5c>

0000000080004b80 <sys_exec>:

uint64
sys_exec(void)
{
    80004b80:	7121                	addi	sp,sp,-448
    80004b82:	ff06                	sd	ra,440(sp)
    80004b84:	fb22                	sd	s0,432(sp)
    80004b86:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004b88:	e4840593          	addi	a1,s0,-440
    80004b8c:	4505                	li	a0,1
    80004b8e:	c0afd0ef          	jal	80001f98 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004b92:	08000613          	li	a2,128
    80004b96:	f5040593          	addi	a1,s0,-176
    80004b9a:	4501                	li	a0,0
    80004b9c:	c18fd0ef          	jal	80001fb4 <argstr>
    80004ba0:	87aa                	mv	a5,a0
    return -1;
    80004ba2:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004ba4:	0c07c463          	bltz	a5,80004c6c <sys_exec+0xec>
    80004ba8:	f726                	sd	s1,424(sp)
    80004baa:	f34a                	sd	s2,416(sp)
    80004bac:	ef4e                	sd	s3,408(sp)
    80004bae:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80004bb0:	10000613          	li	a2,256
    80004bb4:	4581                	li	a1,0
    80004bb6:	e5040513          	addi	a0,s0,-432
    80004bba:	d94fb0ef          	jal	8000014e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004bbe:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80004bc2:	89a6                	mv	s3,s1
    80004bc4:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004bc6:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004bca:	00391513          	slli	a0,s2,0x3
    80004bce:	e4040593          	addi	a1,s0,-448
    80004bd2:	e4843783          	ld	a5,-440(s0)
    80004bd6:	953e                	add	a0,a0,a5
    80004bd8:	b1afd0ef          	jal	80001ef2 <fetchaddr>
    80004bdc:	02054663          	bltz	a0,80004c08 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80004be0:	e4043783          	ld	a5,-448(s0)
    80004be4:	c3a9                	beqz	a5,80004c26 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004be6:	d18fb0ef          	jal	800000fe <kalloc>
    80004bea:	85aa                	mv	a1,a0
    80004bec:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004bf0:	cd01                	beqz	a0,80004c08 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004bf2:	6605                	lui	a2,0x1
    80004bf4:	e4043503          	ld	a0,-448(s0)
    80004bf8:	b44fd0ef          	jal	80001f3c <fetchstr>
    80004bfc:	00054663          	bltz	a0,80004c08 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80004c00:	0905                	addi	s2,s2,1
    80004c02:	09a1                	addi	s3,s3,8
    80004c04:	fd4913e3          	bne	s2,s4,80004bca <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004c08:	f5040913          	addi	s2,s0,-176
    80004c0c:	6088                	ld	a0,0(s1)
    80004c0e:	c931                	beqz	a0,80004c62 <sys_exec+0xe2>
    kfree(argv[i]);
    80004c10:	c0cfb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004c14:	04a1                	addi	s1,s1,8
    80004c16:	ff249be3          	bne	s1,s2,80004c0c <sys_exec+0x8c>
  return -1;
    80004c1a:	557d                	li	a0,-1
    80004c1c:	74ba                	ld	s1,424(sp)
    80004c1e:	791a                	ld	s2,416(sp)
    80004c20:	69fa                	ld	s3,408(sp)
    80004c22:	6a5a                	ld	s4,400(sp)
    80004c24:	a0a1                	j	80004c6c <sys_exec+0xec>
      argv[i] = 0;
    80004c26:	0009079b          	sext.w	a5,s2
    80004c2a:	078e                	slli	a5,a5,0x3
    80004c2c:	fd078793          	addi	a5,a5,-48
    80004c30:	97a2                	add	a5,a5,s0
    80004c32:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80004c36:	e5040593          	addi	a1,s0,-432
    80004c3a:	f5040513          	addi	a0,s0,-176
    80004c3e:	928ff0ef          	jal	80003d66 <kexec>
    80004c42:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004c44:	f5040993          	addi	s3,s0,-176
    80004c48:	6088                	ld	a0,0(s1)
    80004c4a:	c511                	beqz	a0,80004c56 <sys_exec+0xd6>
    kfree(argv[i]);
    80004c4c:	bd0fb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004c50:	04a1                	addi	s1,s1,8
    80004c52:	ff349be3          	bne	s1,s3,80004c48 <sys_exec+0xc8>
  return ret;
    80004c56:	854a                	mv	a0,s2
    80004c58:	74ba                	ld	s1,424(sp)
    80004c5a:	791a                	ld	s2,416(sp)
    80004c5c:	69fa                	ld	s3,408(sp)
    80004c5e:	6a5a                	ld	s4,400(sp)
    80004c60:	a031                	j	80004c6c <sys_exec+0xec>
  return -1;
    80004c62:	557d                	li	a0,-1
    80004c64:	74ba                	ld	s1,424(sp)
    80004c66:	791a                	ld	s2,416(sp)
    80004c68:	69fa                	ld	s3,408(sp)
    80004c6a:	6a5a                	ld	s4,400(sp)
}
    80004c6c:	70fa                	ld	ra,440(sp)
    80004c6e:	745a                	ld	s0,432(sp)
    80004c70:	6139                	addi	sp,sp,448
    80004c72:	8082                	ret

0000000080004c74 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004c74:	7139                	addi	sp,sp,-64
    80004c76:	fc06                	sd	ra,56(sp)
    80004c78:	f822                	sd	s0,48(sp)
    80004c7a:	f426                	sd	s1,40(sp)
    80004c7c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004c7e:	8fcfc0ef          	jal	80000d7a <myproc>
    80004c82:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004c84:	fd840593          	addi	a1,s0,-40
    80004c88:	4501                	li	a0,0
    80004c8a:	b0efd0ef          	jal	80001f98 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004c8e:	fc840593          	addi	a1,s0,-56
    80004c92:	fd040513          	addi	a0,s0,-48
    80004c96:	dddfe0ef          	jal	80003a72 <pipealloc>
    return -1;
    80004c9a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004c9c:	0a054463          	bltz	a0,80004d44 <sys_pipe+0xd0>
  fd0 = -1;
    80004ca0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004ca4:	fd043503          	ld	a0,-48(s0)
    80004ca8:	c88ff0ef          	jal	80004130 <fdalloc>
    80004cac:	fca42223          	sw	a0,-60(s0)
    80004cb0:	08054163          	bltz	a0,80004d32 <sys_pipe+0xbe>
    80004cb4:	fc843503          	ld	a0,-56(s0)
    80004cb8:	c78ff0ef          	jal	80004130 <fdalloc>
    80004cbc:	fca42023          	sw	a0,-64(s0)
    80004cc0:	06054063          	bltz	a0,80004d20 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004cc4:	4691                	li	a3,4
    80004cc6:	fc440613          	addi	a2,s0,-60
    80004cca:	fd843583          	ld	a1,-40(s0)
    80004cce:	68a8                	ld	a0,80(s1)
    80004cd0:	dbffb0ef          	jal	80000a8e <copyout>
    80004cd4:	00054e63          	bltz	a0,80004cf0 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004cd8:	4691                	li	a3,4
    80004cda:	fc040613          	addi	a2,s0,-64
    80004cde:	fd843583          	ld	a1,-40(s0)
    80004ce2:	0591                	addi	a1,a1,4
    80004ce4:	68a8                	ld	a0,80(s1)
    80004ce6:	da9fb0ef          	jal	80000a8e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004cea:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004cec:	04055c63          	bgez	a0,80004d44 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80004cf0:	fc442783          	lw	a5,-60(s0)
    80004cf4:	07e9                	addi	a5,a5,26
    80004cf6:	078e                	slli	a5,a5,0x3
    80004cf8:	97a6                	add	a5,a5,s1
    80004cfa:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004cfe:	fc042783          	lw	a5,-64(s0)
    80004d02:	07e9                	addi	a5,a5,26
    80004d04:	078e                	slli	a5,a5,0x3
    80004d06:	94be                	add	s1,s1,a5
    80004d08:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80004d0c:	fd043503          	ld	a0,-48(s0)
    80004d10:	a59fe0ef          	jal	80003768 <fileclose>
    fileclose(wf);
    80004d14:	fc843503          	ld	a0,-56(s0)
    80004d18:	a51fe0ef          	jal	80003768 <fileclose>
    return -1;
    80004d1c:	57fd                	li	a5,-1
    80004d1e:	a01d                	j	80004d44 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80004d20:	fc442783          	lw	a5,-60(s0)
    80004d24:	0007c763          	bltz	a5,80004d32 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80004d28:	07e9                	addi	a5,a5,26
    80004d2a:	078e                	slli	a5,a5,0x3
    80004d2c:	97a6                	add	a5,a5,s1
    80004d2e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80004d32:	fd043503          	ld	a0,-48(s0)
    80004d36:	a33fe0ef          	jal	80003768 <fileclose>
    fileclose(wf);
    80004d3a:	fc843503          	ld	a0,-56(s0)
    80004d3e:	a2bfe0ef          	jal	80003768 <fileclose>
    return -1;
    80004d42:	57fd                	li	a5,-1
}
    80004d44:	853e                	mv	a0,a5
    80004d46:	70e2                	ld	ra,56(sp)
    80004d48:	7442                	ld	s0,48(sp)
    80004d4a:	74a2                	ld	s1,40(sp)
    80004d4c:	6121                	addi	sp,sp,64
    80004d4e:	8082                	ret

0000000080004d50 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80004d50:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80004d52:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80004d54:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80004d56:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80004d58:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80004d5a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80004d5c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80004d5e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80004d60:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80004d62:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80004d64:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80004d66:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80004d68:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80004d6a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80004d6c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80004d6e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80004d70:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80004d72:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80004d74:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80004d76:	88cfd0ef          	jal	80001e02 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80004d7a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80004d7c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80004d7e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80004d80:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80004d82:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80004d84:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80004d86:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80004d88:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80004d8a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80004d8c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80004d8e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80004d90:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80004d92:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80004d94:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80004d96:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80004d98:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80004d9a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80004d9c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80004d9e:	10200073          	sret
	...

0000000080004dae <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80004dae:	1141                	addi	sp,sp,-16
    80004db0:	e422                	sd	s0,8(sp)
    80004db2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004db4:	0c0007b7          	lui	a5,0xc000
    80004db8:	4705                	li	a4,1
    80004dba:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80004dbc:	0c0007b7          	lui	a5,0xc000
    80004dc0:	c3d8                	sw	a4,4(a5)
}
    80004dc2:	6422                	ld	s0,8(sp)
    80004dc4:	0141                	addi	sp,sp,16
    80004dc6:	8082                	ret

0000000080004dc8 <plicinithart>:

void
plicinithart(void)
{
    80004dc8:	1141                	addi	sp,sp,-16
    80004dca:	e406                	sd	ra,8(sp)
    80004dcc:	e022                	sd	s0,0(sp)
    80004dce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004dd0:	f7ffb0ef          	jal	80000d4e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004dd4:	0085171b          	slliw	a4,a0,0x8
    80004dd8:	0c0027b7          	lui	a5,0xc002
    80004ddc:	97ba                	add	a5,a5,a4
    80004dde:	40200713          	li	a4,1026
    80004de2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004de6:	00d5151b          	slliw	a0,a0,0xd
    80004dea:	0c2017b7          	lui	a5,0xc201
    80004dee:	97aa                	add	a5,a5,a0
    80004df0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80004df4:	60a2                	ld	ra,8(sp)
    80004df6:	6402                	ld	s0,0(sp)
    80004df8:	0141                	addi	sp,sp,16
    80004dfa:	8082                	ret

0000000080004dfc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80004dfc:	1141                	addi	sp,sp,-16
    80004dfe:	e406                	sd	ra,8(sp)
    80004e00:	e022                	sd	s0,0(sp)
    80004e02:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004e04:	f4bfb0ef          	jal	80000d4e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80004e08:	00d5151b          	slliw	a0,a0,0xd
    80004e0c:	0c2017b7          	lui	a5,0xc201
    80004e10:	97aa                	add	a5,a5,a0
  return irq;
}
    80004e12:	43c8                	lw	a0,4(a5)
    80004e14:	60a2                	ld	ra,8(sp)
    80004e16:	6402                	ld	s0,0(sp)
    80004e18:	0141                	addi	sp,sp,16
    80004e1a:	8082                	ret

0000000080004e1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80004e1c:	1101                	addi	sp,sp,-32
    80004e1e:	ec06                	sd	ra,24(sp)
    80004e20:	e822                	sd	s0,16(sp)
    80004e22:	e426                	sd	s1,8(sp)
    80004e24:	1000                	addi	s0,sp,32
    80004e26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80004e28:	f27fb0ef          	jal	80000d4e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80004e2c:	00d5151b          	slliw	a0,a0,0xd
    80004e30:	0c2017b7          	lui	a5,0xc201
    80004e34:	97aa                	add	a5,a5,a0
    80004e36:	c3c4                	sw	s1,4(a5)
}
    80004e38:	60e2                	ld	ra,24(sp)
    80004e3a:	6442                	ld	s0,16(sp)
    80004e3c:	64a2                	ld	s1,8(sp)
    80004e3e:	6105                	addi	sp,sp,32
    80004e40:	8082                	ret

0000000080004e42 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80004e42:	1141                	addi	sp,sp,-16
    80004e44:	e406                	sd	ra,8(sp)
    80004e46:	e022                	sd	s0,0(sp)
    80004e48:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80004e4a:	479d                	li	a5,7
    80004e4c:	04a7ca63          	blt	a5,a0,80004ea0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80004e50:	00022797          	auipc	a5,0x22
    80004e54:	68078793          	addi	a5,a5,1664 # 800274d0 <disk>
    80004e58:	97aa                	add	a5,a5,a0
    80004e5a:	0187c783          	lbu	a5,24(a5)
    80004e5e:	e7b9                	bnez	a5,80004eac <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004e60:	00451693          	slli	a3,a0,0x4
    80004e64:	00022797          	auipc	a5,0x22
    80004e68:	66c78793          	addi	a5,a5,1644 # 800274d0 <disk>
    80004e6c:	6398                	ld	a4,0(a5)
    80004e6e:	9736                	add	a4,a4,a3
    80004e70:	00073023          	sd	zero,0(a4) # fffffffffffff000 <end+0xffffffff7ffcf918>
  disk.desc[i].len = 0;
    80004e74:	6398                	ld	a4,0(a5)
    80004e76:	9736                	add	a4,a4,a3
    80004e78:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80004e7c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004e80:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004e84:	97aa                	add	a5,a5,a0
    80004e86:	4705                	li	a4,1
    80004e88:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80004e8c:	00022517          	auipc	a0,0x22
    80004e90:	65c50513          	addi	a0,a0,1628 # 800274e8 <disk+0x18>
    80004e94:	d88fc0ef          	jal	8000141c <wakeup>
}
    80004e98:	60a2                	ld	ra,8(sp)
    80004e9a:	6402                	ld	s0,0(sp)
    80004e9c:	0141                	addi	sp,sp,16
    80004e9e:	8082                	ret
    panic("free_desc 1");
    80004ea0:	00003517          	auipc	a0,0x3
    80004ea4:	82050513          	addi	a0,a0,-2016 # 800076c0 <etext+0x6c0>
    80004ea8:	487000ef          	jal	80005b2e <panic>
    panic("free_desc 2");
    80004eac:	00003517          	auipc	a0,0x3
    80004eb0:	82450513          	addi	a0,a0,-2012 # 800076d0 <etext+0x6d0>
    80004eb4:	47b000ef          	jal	80005b2e <panic>

0000000080004eb8 <virtio_disk_init>:
{
    80004eb8:	1101                	addi	sp,sp,-32
    80004eba:	ec06                	sd	ra,24(sp)
    80004ebc:	e822                	sd	s0,16(sp)
    80004ebe:	e426                	sd	s1,8(sp)
    80004ec0:	e04a                	sd	s2,0(sp)
    80004ec2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004ec4:	00003597          	auipc	a1,0x3
    80004ec8:	81c58593          	addi	a1,a1,-2020 # 800076e0 <etext+0x6e0>
    80004ecc:	00022517          	auipc	a0,0x22
    80004ed0:	72c50513          	addi	a0,a0,1836 # 800275f8 <disk+0x128>
    80004ed4:	697000ef          	jal	80005d6a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004ed8:	100017b7          	lui	a5,0x10001
    80004edc:	4398                	lw	a4,0(a5)
    80004ede:	2701                	sext.w	a4,a4
    80004ee0:	747277b7          	lui	a5,0x74727
    80004ee4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004ee8:	18f71063          	bne	a4,a5,80005068 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004eec:	100017b7          	lui	a5,0x10001
    80004ef0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80004ef2:	439c                	lw	a5,0(a5)
    80004ef4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004ef6:	4709                	li	a4,2
    80004ef8:	16e79863          	bne	a5,a4,80005068 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004efc:	100017b7          	lui	a5,0x10001
    80004f00:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80004f02:	439c                	lw	a5,0(a5)
    80004f04:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004f06:	16e79163          	bne	a5,a4,80005068 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004f0a:	100017b7          	lui	a5,0x10001
    80004f0e:	47d8                	lw	a4,12(a5)
    80004f10:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004f12:	554d47b7          	lui	a5,0x554d4
    80004f16:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004f1a:	14f71763          	bne	a4,a5,80005068 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004f1e:	100017b7          	lui	a5,0x10001
    80004f22:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004f26:	4705                	li	a4,1
    80004f28:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004f2a:	470d                	li	a4,3
    80004f2c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004f2e:	10001737          	lui	a4,0x10001
    80004f32:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80004f34:	c7ffe737          	lui	a4,0xc7ffe
    80004f38:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fcf077>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004f3c:	8ef9                	and	a3,a3,a4
    80004f3e:	10001737          	lui	a4,0x10001
    80004f42:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004f44:	472d                	li	a4,11
    80004f46:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004f48:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80004f4c:	439c                	lw	a5,0(a5)
    80004f4e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004f52:	8ba1                	andi	a5,a5,8
    80004f54:	12078063          	beqz	a5,80005074 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004f58:	100017b7          	lui	a5,0x10001
    80004f5c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004f60:	100017b7          	lui	a5,0x10001
    80004f64:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80004f68:	439c                	lw	a5,0(a5)
    80004f6a:	2781                	sext.w	a5,a5
    80004f6c:	10079a63          	bnez	a5,80005080 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004f70:	100017b7          	lui	a5,0x10001
    80004f74:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80004f78:	439c                	lw	a5,0(a5)
    80004f7a:	2781                	sext.w	a5,a5
  if(max == 0)
    80004f7c:	10078863          	beqz	a5,8000508c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004f80:	471d                	li	a4,7
    80004f82:	10f77b63          	bgeu	a4,a5,80005098 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004f86:	978fb0ef          	jal	800000fe <kalloc>
    80004f8a:	00022497          	auipc	s1,0x22
    80004f8e:	54648493          	addi	s1,s1,1350 # 800274d0 <disk>
    80004f92:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004f94:	96afb0ef          	jal	800000fe <kalloc>
    80004f98:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004f9a:	964fb0ef          	jal	800000fe <kalloc>
    80004f9e:	87aa                	mv	a5,a0
    80004fa0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004fa2:	6088                	ld	a0,0(s1)
    80004fa4:	10050063          	beqz	a0,800050a4 <virtio_disk_init+0x1ec>
    80004fa8:	00022717          	auipc	a4,0x22
    80004fac:	53073703          	ld	a4,1328(a4) # 800274d8 <disk+0x8>
    80004fb0:	0e070a63          	beqz	a4,800050a4 <virtio_disk_init+0x1ec>
    80004fb4:	0e078863          	beqz	a5,800050a4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004fb8:	6605                	lui	a2,0x1
    80004fba:	4581                	li	a1,0
    80004fbc:	992fb0ef          	jal	8000014e <memset>
  memset(disk.avail, 0, PGSIZE);
    80004fc0:	00022497          	auipc	s1,0x22
    80004fc4:	51048493          	addi	s1,s1,1296 # 800274d0 <disk>
    80004fc8:	6605                	lui	a2,0x1
    80004fca:	4581                	li	a1,0
    80004fcc:	6488                	ld	a0,8(s1)
    80004fce:	980fb0ef          	jal	8000014e <memset>
  memset(disk.used, 0, PGSIZE);
    80004fd2:	6605                	lui	a2,0x1
    80004fd4:	4581                	li	a1,0
    80004fd6:	6888                	ld	a0,16(s1)
    80004fd8:	976fb0ef          	jal	8000014e <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004fdc:	100017b7          	lui	a5,0x10001
    80004fe0:	4721                	li	a4,8
    80004fe2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004fe4:	4098                	lw	a4,0(s1)
    80004fe6:	100017b7          	lui	a5,0x10001
    80004fea:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004fee:	40d8                	lw	a4,4(s1)
    80004ff0:	100017b7          	lui	a5,0x10001
    80004ff4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004ff8:	649c                	ld	a5,8(s1)
    80004ffa:	0007869b          	sext.w	a3,a5
    80004ffe:	10001737          	lui	a4,0x10001
    80005002:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005006:	9781                	srai	a5,a5,0x20
    80005008:	10001737          	lui	a4,0x10001
    8000500c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005010:	689c                	ld	a5,16(s1)
    80005012:	0007869b          	sext.w	a3,a5
    80005016:	10001737          	lui	a4,0x10001
    8000501a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000501e:	9781                	srai	a5,a5,0x20
    80005020:	10001737          	lui	a4,0x10001
    80005024:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005028:	10001737          	lui	a4,0x10001
    8000502c:	4785                	li	a5,1
    8000502e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005030:	00f48c23          	sb	a5,24(s1)
    80005034:	00f48ca3          	sb	a5,25(s1)
    80005038:	00f48d23          	sb	a5,26(s1)
    8000503c:	00f48da3          	sb	a5,27(s1)
    80005040:	00f48e23          	sb	a5,28(s1)
    80005044:	00f48ea3          	sb	a5,29(s1)
    80005048:	00f48f23          	sb	a5,30(s1)
    8000504c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005050:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005054:	100017b7          	lui	a5,0x10001
    80005058:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000505c:	60e2                	ld	ra,24(sp)
    8000505e:	6442                	ld	s0,16(sp)
    80005060:	64a2                	ld	s1,8(sp)
    80005062:	6902                	ld	s2,0(sp)
    80005064:	6105                	addi	sp,sp,32
    80005066:	8082                	ret
    panic("could not find virtio disk");
    80005068:	00002517          	auipc	a0,0x2
    8000506c:	68850513          	addi	a0,a0,1672 # 800076f0 <etext+0x6f0>
    80005070:	2bf000ef          	jal	80005b2e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005074:	00002517          	auipc	a0,0x2
    80005078:	69c50513          	addi	a0,a0,1692 # 80007710 <etext+0x710>
    8000507c:	2b3000ef          	jal	80005b2e <panic>
    panic("virtio disk should not be ready");
    80005080:	00002517          	auipc	a0,0x2
    80005084:	6b050513          	addi	a0,a0,1712 # 80007730 <etext+0x730>
    80005088:	2a7000ef          	jal	80005b2e <panic>
    panic("virtio disk has no queue 0");
    8000508c:	00002517          	auipc	a0,0x2
    80005090:	6c450513          	addi	a0,a0,1732 # 80007750 <etext+0x750>
    80005094:	29b000ef          	jal	80005b2e <panic>
    panic("virtio disk max queue too short");
    80005098:	00002517          	auipc	a0,0x2
    8000509c:	6d850513          	addi	a0,a0,1752 # 80007770 <etext+0x770>
    800050a0:	28f000ef          	jal	80005b2e <panic>
    panic("virtio disk kalloc");
    800050a4:	00002517          	auipc	a0,0x2
    800050a8:	6ec50513          	addi	a0,a0,1772 # 80007790 <etext+0x790>
    800050ac:	283000ef          	jal	80005b2e <panic>

00000000800050b0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800050b0:	7159                	addi	sp,sp,-112
    800050b2:	f486                	sd	ra,104(sp)
    800050b4:	f0a2                	sd	s0,96(sp)
    800050b6:	eca6                	sd	s1,88(sp)
    800050b8:	e8ca                	sd	s2,80(sp)
    800050ba:	e4ce                	sd	s3,72(sp)
    800050bc:	e0d2                	sd	s4,64(sp)
    800050be:	fc56                	sd	s5,56(sp)
    800050c0:	f85a                	sd	s6,48(sp)
    800050c2:	f45e                	sd	s7,40(sp)
    800050c4:	f062                	sd	s8,32(sp)
    800050c6:	ec66                	sd	s9,24(sp)
    800050c8:	1880                	addi	s0,sp,112
    800050ca:	8a2a                	mv	s4,a0
    800050cc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800050ce:	00c52c83          	lw	s9,12(a0)
    800050d2:	001c9c9b          	slliw	s9,s9,0x1
    800050d6:	1c82                	slli	s9,s9,0x20
    800050d8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800050dc:	00022517          	auipc	a0,0x22
    800050e0:	51c50513          	addi	a0,a0,1308 # 800275f8 <disk+0x128>
    800050e4:	507000ef          	jal	80005dea <acquire>
  for(int i = 0; i < 3; i++){
    800050e8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800050ea:	44a1                	li	s1,8
      disk.free[i] = 0;
    800050ec:	00022b17          	auipc	s6,0x22
    800050f0:	3e4b0b13          	addi	s6,s6,996 # 800274d0 <disk>
  for(int i = 0; i < 3; i++){
    800050f4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800050f6:	00022c17          	auipc	s8,0x22
    800050fa:	502c0c13          	addi	s8,s8,1282 # 800275f8 <disk+0x128>
    800050fe:	a8b9                	j	8000515c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005100:	00fb0733          	add	a4,s6,a5
    80005104:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005108:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000510a:	0207c563          	bltz	a5,80005134 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000510e:	2905                	addiw	s2,s2,1
    80005110:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005112:	05590963          	beq	s2,s5,80005164 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005116:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005118:	00022717          	auipc	a4,0x22
    8000511c:	3b870713          	addi	a4,a4,952 # 800274d0 <disk>
    80005120:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005122:	01874683          	lbu	a3,24(a4)
    80005126:	fee9                	bnez	a3,80005100 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005128:	2785                	addiw	a5,a5,1
    8000512a:	0705                	addi	a4,a4,1
    8000512c:	fe979be3          	bne	a5,s1,80005122 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005130:	57fd                	li	a5,-1
    80005132:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005134:	01205d63          	blez	s2,8000514e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005138:	f9042503          	lw	a0,-112(s0)
    8000513c:	d07ff0ef          	jal	80004e42 <free_desc>
      for(int j = 0; j < i; j++)
    80005140:	4785                	li	a5,1
    80005142:	0127d663          	bge	a5,s2,8000514e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005146:	f9442503          	lw	a0,-108(s0)
    8000514a:	cf9ff0ef          	jal	80004e42 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000514e:	85e2                	mv	a1,s8
    80005150:	00022517          	auipc	a0,0x22
    80005154:	39850513          	addi	a0,a0,920 # 800274e8 <disk+0x18>
    80005158:	a78fc0ef          	jal	800013d0 <sleep>
  for(int i = 0; i < 3; i++){
    8000515c:	f9040613          	addi	a2,s0,-112
    80005160:	894e                	mv	s2,s3
    80005162:	bf55                	j	80005116 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005164:	f9042503          	lw	a0,-112(s0)
    80005168:	00451693          	slli	a3,a0,0x4

  if(write)
    8000516c:	00022797          	auipc	a5,0x22
    80005170:	36478793          	addi	a5,a5,868 # 800274d0 <disk>
    80005174:	00a50713          	addi	a4,a0,10
    80005178:	0712                	slli	a4,a4,0x4
    8000517a:	973e                	add	a4,a4,a5
    8000517c:	01703633          	snez	a2,s7
    80005180:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005182:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005186:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000518a:	6398                	ld	a4,0(a5)
    8000518c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000518e:	0a868613          	addi	a2,a3,168
    80005192:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005194:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005196:	6390                	ld	a2,0(a5)
    80005198:	00d605b3          	add	a1,a2,a3
    8000519c:	4741                	li	a4,16
    8000519e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800051a0:	4805                	li	a6,1
    800051a2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800051a6:	f9442703          	lw	a4,-108(s0)
    800051aa:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800051ae:	0712                	slli	a4,a4,0x4
    800051b0:	963a                	add	a2,a2,a4
    800051b2:	058a0593          	addi	a1,s4,88
    800051b6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800051b8:	0007b883          	ld	a7,0(a5)
    800051bc:	9746                	add	a4,a4,a7
    800051be:	40000613          	li	a2,1024
    800051c2:	c710                	sw	a2,8(a4)
  if(write)
    800051c4:	001bb613          	seqz	a2,s7
    800051c8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800051cc:	00166613          	ori	a2,a2,1
    800051d0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800051d4:	f9842583          	lw	a1,-104(s0)
    800051d8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800051dc:	00250613          	addi	a2,a0,2
    800051e0:	0612                	slli	a2,a2,0x4
    800051e2:	963e                	add	a2,a2,a5
    800051e4:	577d                	li	a4,-1
    800051e6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800051ea:	0592                	slli	a1,a1,0x4
    800051ec:	98ae                	add	a7,a7,a1
    800051ee:	03068713          	addi	a4,a3,48
    800051f2:	973e                	add	a4,a4,a5
    800051f4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800051f8:	6398                	ld	a4,0(a5)
    800051fa:	972e                	add	a4,a4,a1
    800051fc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005200:	4689                	li	a3,2
    80005202:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005206:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000520a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000520e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005212:	6794                	ld	a3,8(a5)
    80005214:	0026d703          	lhu	a4,2(a3)
    80005218:	8b1d                	andi	a4,a4,7
    8000521a:	0706                	slli	a4,a4,0x1
    8000521c:	96ba                	add	a3,a3,a4
    8000521e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005222:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005226:	6798                	ld	a4,8(a5)
    80005228:	00275783          	lhu	a5,2(a4)
    8000522c:	2785                	addiw	a5,a5,1
    8000522e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005232:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005236:	100017b7          	lui	a5,0x10001
    8000523a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000523e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005242:	00022917          	auipc	s2,0x22
    80005246:	3b690913          	addi	s2,s2,950 # 800275f8 <disk+0x128>
  while(b->disk == 1) {
    8000524a:	4485                	li	s1,1
    8000524c:	01079a63          	bne	a5,a6,80005260 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005250:	85ca                	mv	a1,s2
    80005252:	8552                	mv	a0,s4
    80005254:	97cfc0ef          	jal	800013d0 <sleep>
  while(b->disk == 1) {
    80005258:	004a2783          	lw	a5,4(s4)
    8000525c:	fe978ae3          	beq	a5,s1,80005250 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005260:	f9042903          	lw	s2,-112(s0)
    80005264:	00290713          	addi	a4,s2,2
    80005268:	0712                	slli	a4,a4,0x4
    8000526a:	00022797          	auipc	a5,0x22
    8000526e:	26678793          	addi	a5,a5,614 # 800274d0 <disk>
    80005272:	97ba                	add	a5,a5,a4
    80005274:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005278:	00022997          	auipc	s3,0x22
    8000527c:	25898993          	addi	s3,s3,600 # 800274d0 <disk>
    80005280:	00491713          	slli	a4,s2,0x4
    80005284:	0009b783          	ld	a5,0(s3)
    80005288:	97ba                	add	a5,a5,a4
    8000528a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000528e:	854a                	mv	a0,s2
    80005290:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005294:	bafff0ef          	jal	80004e42 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005298:	8885                	andi	s1,s1,1
    8000529a:	f0fd                	bnez	s1,80005280 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000529c:	00022517          	auipc	a0,0x22
    800052a0:	35c50513          	addi	a0,a0,860 # 800275f8 <disk+0x128>
    800052a4:	3df000ef          	jal	80005e82 <release>
}
    800052a8:	70a6                	ld	ra,104(sp)
    800052aa:	7406                	ld	s0,96(sp)
    800052ac:	64e6                	ld	s1,88(sp)
    800052ae:	6946                	ld	s2,80(sp)
    800052b0:	69a6                	ld	s3,72(sp)
    800052b2:	6a06                	ld	s4,64(sp)
    800052b4:	7ae2                	ld	s5,56(sp)
    800052b6:	7b42                	ld	s6,48(sp)
    800052b8:	7ba2                	ld	s7,40(sp)
    800052ba:	7c02                	ld	s8,32(sp)
    800052bc:	6ce2                	ld	s9,24(sp)
    800052be:	6165                	addi	sp,sp,112
    800052c0:	8082                	ret

00000000800052c2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800052c2:	1101                	addi	sp,sp,-32
    800052c4:	ec06                	sd	ra,24(sp)
    800052c6:	e822                	sd	s0,16(sp)
    800052c8:	e426                	sd	s1,8(sp)
    800052ca:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800052cc:	00022497          	auipc	s1,0x22
    800052d0:	20448493          	addi	s1,s1,516 # 800274d0 <disk>
    800052d4:	00022517          	auipc	a0,0x22
    800052d8:	32450513          	addi	a0,a0,804 # 800275f8 <disk+0x128>
    800052dc:	30f000ef          	jal	80005dea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800052e0:	100017b7          	lui	a5,0x10001
    800052e4:	53b8                	lw	a4,96(a5)
    800052e6:	8b0d                	andi	a4,a4,3
    800052e8:	100017b7          	lui	a5,0x10001
    800052ec:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800052ee:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800052f2:	689c                	ld	a5,16(s1)
    800052f4:	0204d703          	lhu	a4,32(s1)
    800052f8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800052fc:	04f70663          	beq	a4,a5,80005348 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005300:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005304:	6898                	ld	a4,16(s1)
    80005306:	0204d783          	lhu	a5,32(s1)
    8000530a:	8b9d                	andi	a5,a5,7
    8000530c:	078e                	slli	a5,a5,0x3
    8000530e:	97ba                	add	a5,a5,a4
    80005310:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005312:	00278713          	addi	a4,a5,2
    80005316:	0712                	slli	a4,a4,0x4
    80005318:	9726                	add	a4,a4,s1
    8000531a:	01074703          	lbu	a4,16(a4)
    8000531e:	e321                	bnez	a4,8000535e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005320:	0789                	addi	a5,a5,2
    80005322:	0792                	slli	a5,a5,0x4
    80005324:	97a6                	add	a5,a5,s1
    80005326:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005328:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000532c:	8f0fc0ef          	jal	8000141c <wakeup>

    disk.used_idx += 1;
    80005330:	0204d783          	lhu	a5,32(s1)
    80005334:	2785                	addiw	a5,a5,1
    80005336:	17c2                	slli	a5,a5,0x30
    80005338:	93c1                	srli	a5,a5,0x30
    8000533a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000533e:	6898                	ld	a4,16(s1)
    80005340:	00275703          	lhu	a4,2(a4)
    80005344:	faf71ee3          	bne	a4,a5,80005300 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005348:	00022517          	auipc	a0,0x22
    8000534c:	2b050513          	addi	a0,a0,688 # 800275f8 <disk+0x128>
    80005350:	333000ef          	jal	80005e82 <release>
}
    80005354:	60e2                	ld	ra,24(sp)
    80005356:	6442                	ld	s0,16(sp)
    80005358:	64a2                	ld	s1,8(sp)
    8000535a:	6105                	addi	sp,sp,32
    8000535c:	8082                	ret
      panic("virtio_disk_intr status");
    8000535e:	00002517          	auipc	a0,0x2
    80005362:	44a50513          	addi	a0,a0,1098 # 800077a8 <etext+0x7a8>
    80005366:	7c8000ef          	jal	80005b2e <panic>

000000008000536a <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000536a:	1141                	addi	sp,sp,-16
    8000536c:	e422                	sd	s0,8(sp)
    8000536e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80005370:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80005374:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80005378:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000537c:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80005380:	577d                	li	a4,-1
    80005382:	177e                	slli	a4,a4,0x3f
    80005384:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80005386:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000538a:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    8000538e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80005392:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80005396:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000539a:	000f4737          	lui	a4,0xf4
    8000539e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800053a2:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800053a4:	14d79073          	csrw	stimecmp,a5
}
    800053a8:	6422                	ld	s0,8(sp)
    800053aa:	0141                	addi	sp,sp,16
    800053ac:	8082                	ret

00000000800053ae <start>:
{
    800053ae:	1141                	addi	sp,sp,-16
    800053b0:	e406                	sd	ra,8(sp)
    800053b2:	e022                	sd	s0,0(sp)
    800053b4:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800053b6:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    800053ba:	7779                	lui	a4,0xffffe
    800053bc:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffcf117>
    800053c0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800053c2:	6705                	lui	a4,0x1
    800053c4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800053c8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800053ca:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800053ce:	ffffb797          	auipc	a5,0xffffb
    800053d2:	f1a78793          	addi	a5,a5,-230 # 800002e8 <main>
    800053d6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800053da:	4781                	li	a5,0
    800053dc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800053e0:	67c1                	lui	a5,0x10
    800053e2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800053e4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800053e8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800053ec:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800053f0:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800053f4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800053f8:	57fd                	li	a5,-1
    800053fa:	83a9                	srli	a5,a5,0xa
    800053fc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80005400:	47bd                	li	a5,15
    80005402:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80005406:	f65ff0ef          	jal	8000536a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    8000540a:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    8000540e:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80005410:	823e                	mv	tp,a5
  asm volatile("mret");
    80005412:	30200073          	mret
}
    80005416:	60a2                	ld	ra,8(sp)
    80005418:	6402                	ld	s0,0(sp)
    8000541a:	0141                	addi	sp,sp,16
    8000541c:	8082                	ret

000000008000541e <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    8000541e:	7119                	addi	sp,sp,-128
    80005420:	fc86                	sd	ra,120(sp)
    80005422:	f8a2                	sd	s0,112(sp)
    80005424:	f4a6                	sd	s1,104(sp)
    80005426:	0100                	addi	s0,sp,128
  char buf[32];
  int i = 0;

  while(i < n){
    80005428:	06c05a63          	blez	a2,8000549c <consolewrite+0x7e>
    8000542c:	f0ca                	sd	s2,96(sp)
    8000542e:	ecce                	sd	s3,88(sp)
    80005430:	e8d2                	sd	s4,80(sp)
    80005432:	e4d6                	sd	s5,72(sp)
    80005434:	e0da                	sd	s6,64(sp)
    80005436:	fc5e                	sd	s7,56(sp)
    80005438:	f862                	sd	s8,48(sp)
    8000543a:	f466                	sd	s9,40(sp)
    8000543c:	8aaa                	mv	s5,a0
    8000543e:	8b2e                	mv	s6,a1
    80005440:	8a32                	mv	s4,a2
  int i = 0;
    80005442:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    80005444:	02000c13          	li	s8,32
    80005448:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    8000544c:	5bfd                	li	s7,-1
    8000544e:	a035                	j	8000547a <consolewrite+0x5c>
    if(nn > n - i)
    80005450:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80005454:	86ce                	mv	a3,s3
    80005456:	01648633          	add	a2,s1,s6
    8000545a:	85d6                	mv	a1,s5
    8000545c:	f8040513          	addi	a0,s0,-128
    80005460:	b92fc0ef          	jal	800017f2 <either_copyin>
    80005464:	03750e63          	beq	a0,s7,800054a0 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    80005468:	85ce                	mv	a1,s3
    8000546a:	f8040513          	addi	a0,s0,-128
    8000546e:	778000ef          	jal	80005be6 <uartwrite>
    i += nn;
    80005472:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80005476:	0144da63          	bge	s1,s4,8000548a <consolewrite+0x6c>
    if(nn > n - i)
    8000547a:	409a093b          	subw	s2,s4,s1
    8000547e:	0009079b          	sext.w	a5,s2
    80005482:	fcfc57e3          	bge	s8,a5,80005450 <consolewrite+0x32>
    80005486:	8966                	mv	s2,s9
    80005488:	b7e1                	j	80005450 <consolewrite+0x32>
    8000548a:	7906                	ld	s2,96(sp)
    8000548c:	69e6                	ld	s3,88(sp)
    8000548e:	6a46                	ld	s4,80(sp)
    80005490:	6aa6                	ld	s5,72(sp)
    80005492:	6b06                	ld	s6,64(sp)
    80005494:	7be2                	ld	s7,56(sp)
    80005496:	7c42                	ld	s8,48(sp)
    80005498:	7ca2                	ld	s9,40(sp)
    8000549a:	a819                	j	800054b0 <consolewrite+0x92>
  int i = 0;
    8000549c:	4481                	li	s1,0
    8000549e:	a809                	j	800054b0 <consolewrite+0x92>
    800054a0:	7906                	ld	s2,96(sp)
    800054a2:	69e6                	ld	s3,88(sp)
    800054a4:	6a46                	ld	s4,80(sp)
    800054a6:	6aa6                	ld	s5,72(sp)
    800054a8:	6b06                	ld	s6,64(sp)
    800054aa:	7be2                	ld	s7,56(sp)
    800054ac:	7c42                	ld	s8,48(sp)
    800054ae:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    800054b0:	8526                	mv	a0,s1
    800054b2:	70e6                	ld	ra,120(sp)
    800054b4:	7446                	ld	s0,112(sp)
    800054b6:	74a6                	ld	s1,104(sp)
    800054b8:	6109                	addi	sp,sp,128
    800054ba:	8082                	ret

00000000800054bc <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    800054bc:	711d                	addi	sp,sp,-96
    800054be:	ec86                	sd	ra,88(sp)
    800054c0:	e8a2                	sd	s0,80(sp)
    800054c2:	e4a6                	sd	s1,72(sp)
    800054c4:	e0ca                	sd	s2,64(sp)
    800054c6:	fc4e                	sd	s3,56(sp)
    800054c8:	f852                	sd	s4,48(sp)
    800054ca:	f456                	sd	s5,40(sp)
    800054cc:	f05a                	sd	s6,32(sp)
    800054ce:	1080                	addi	s0,sp,96
    800054d0:	8aaa                	mv	s5,a0
    800054d2:	8a2e                	mv	s4,a1
    800054d4:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    800054d6:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    800054da:	0002a517          	auipc	a0,0x2a
    800054de:	13650513          	addi	a0,a0,310 # 8002f610 <cons>
    800054e2:	109000ef          	jal	80005dea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800054e6:	0002a497          	auipc	s1,0x2a
    800054ea:	12a48493          	addi	s1,s1,298 # 8002f610 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800054ee:	0002a917          	auipc	s2,0x2a
    800054f2:	1ba90913          	addi	s2,s2,442 # 8002f6a8 <cons+0x98>
  while(n > 0){
    800054f6:	0b305d63          	blez	s3,800055b0 <consoleread+0xf4>
    while(cons.r == cons.w){
    800054fa:	0984a783          	lw	a5,152(s1)
    800054fe:	09c4a703          	lw	a4,156(s1)
    80005502:	0af71263          	bne	a4,a5,800055a6 <consoleread+0xea>
      if(killed(myproc())){
    80005506:	875fb0ef          	jal	80000d7a <myproc>
    8000550a:	97afc0ef          	jal	80001684 <killed>
    8000550e:	e12d                	bnez	a0,80005570 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    80005510:	85a6                	mv	a1,s1
    80005512:	854a                	mv	a0,s2
    80005514:	ebdfb0ef          	jal	800013d0 <sleep>
    while(cons.r == cons.w){
    80005518:	0984a783          	lw	a5,152(s1)
    8000551c:	09c4a703          	lw	a4,156(s1)
    80005520:	fef703e3          	beq	a4,a5,80005506 <consoleread+0x4a>
    80005524:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80005526:	0002a717          	auipc	a4,0x2a
    8000552a:	0ea70713          	addi	a4,a4,234 # 8002f610 <cons>
    8000552e:	0017869b          	addiw	a3,a5,1
    80005532:	08d72c23          	sw	a3,152(a4)
    80005536:	07f7f693          	andi	a3,a5,127
    8000553a:	9736                	add	a4,a4,a3
    8000553c:	01874703          	lbu	a4,24(a4)
    80005540:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80005544:	4691                	li	a3,4
    80005546:	04db8663          	beq	s7,a3,80005592 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000554a:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000554e:	4685                	li	a3,1
    80005550:	faf40613          	addi	a2,s0,-81
    80005554:	85d2                	mv	a1,s4
    80005556:	8556                	mv	a0,s5
    80005558:	a50fc0ef          	jal	800017a8 <either_copyout>
    8000555c:	57fd                	li	a5,-1
    8000555e:	04f50863          	beq	a0,a5,800055ae <consoleread+0xf2>
      break;

    dst++;
    80005562:	0a05                	addi	s4,s4,1
    --n;
    80005564:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80005566:	47a9                	li	a5,10
    80005568:	04fb8d63          	beq	s7,a5,800055c2 <consoleread+0x106>
    8000556c:	6be2                	ld	s7,24(sp)
    8000556e:	b761                	j	800054f6 <consoleread+0x3a>
        release(&cons.lock);
    80005570:	0002a517          	auipc	a0,0x2a
    80005574:	0a050513          	addi	a0,a0,160 # 8002f610 <cons>
    80005578:	10b000ef          	jal	80005e82 <release>
        return -1;
    8000557c:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    8000557e:	60e6                	ld	ra,88(sp)
    80005580:	6446                	ld	s0,80(sp)
    80005582:	64a6                	ld	s1,72(sp)
    80005584:	6906                	ld	s2,64(sp)
    80005586:	79e2                	ld	s3,56(sp)
    80005588:	7a42                	ld	s4,48(sp)
    8000558a:	7aa2                	ld	s5,40(sp)
    8000558c:	7b02                	ld	s6,32(sp)
    8000558e:	6125                	addi	sp,sp,96
    80005590:	8082                	ret
      if(n < target){
    80005592:	0009871b          	sext.w	a4,s3
    80005596:	01677a63          	bgeu	a4,s6,800055aa <consoleread+0xee>
        cons.r--;
    8000559a:	0002a717          	auipc	a4,0x2a
    8000559e:	10f72723          	sw	a5,270(a4) # 8002f6a8 <cons+0x98>
    800055a2:	6be2                	ld	s7,24(sp)
    800055a4:	a031                	j	800055b0 <consoleread+0xf4>
    800055a6:	ec5e                	sd	s7,24(sp)
    800055a8:	bfbd                	j	80005526 <consoleread+0x6a>
    800055aa:	6be2                	ld	s7,24(sp)
    800055ac:	a011                	j	800055b0 <consoleread+0xf4>
    800055ae:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    800055b0:	0002a517          	auipc	a0,0x2a
    800055b4:	06050513          	addi	a0,a0,96 # 8002f610 <cons>
    800055b8:	0cb000ef          	jal	80005e82 <release>
  return target - n;
    800055bc:	413b053b          	subw	a0,s6,s3
    800055c0:	bf7d                	j	8000557e <consoleread+0xc2>
    800055c2:	6be2                	ld	s7,24(sp)
    800055c4:	b7f5                	j	800055b0 <consoleread+0xf4>

00000000800055c6 <consputc>:
{
    800055c6:	1141                	addi	sp,sp,-16
    800055c8:	e406                	sd	ra,8(sp)
    800055ca:	e022                	sd	s0,0(sp)
    800055cc:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800055ce:	10000793          	li	a5,256
    800055d2:	00f50863          	beq	a0,a5,800055e2 <consputc+0x1c>
    uartputc_sync(c);
    800055d6:	6a4000ef          	jal	80005c7a <uartputc_sync>
}
    800055da:	60a2                	ld	ra,8(sp)
    800055dc:	6402                	ld	s0,0(sp)
    800055de:	0141                	addi	sp,sp,16
    800055e0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800055e2:	4521                	li	a0,8
    800055e4:	696000ef          	jal	80005c7a <uartputc_sync>
    800055e8:	02000513          	li	a0,32
    800055ec:	68e000ef          	jal	80005c7a <uartputc_sync>
    800055f0:	4521                	li	a0,8
    800055f2:	688000ef          	jal	80005c7a <uartputc_sync>
    800055f6:	b7d5                	j	800055da <consputc+0x14>

00000000800055f8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800055f8:	1101                	addi	sp,sp,-32
    800055fa:	ec06                	sd	ra,24(sp)
    800055fc:	e822                	sd	s0,16(sp)
    800055fe:	e426                	sd	s1,8(sp)
    80005600:	1000                	addi	s0,sp,32
    80005602:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005604:	0002a517          	auipc	a0,0x2a
    80005608:	00c50513          	addi	a0,a0,12 # 8002f610 <cons>
    8000560c:	7de000ef          	jal	80005dea <acquire>

  switch(c){
    80005610:	47d5                	li	a5,21
    80005612:	08f48f63          	beq	s1,a5,800056b0 <consoleintr+0xb8>
    80005616:	0297c563          	blt	a5,s1,80005640 <consoleintr+0x48>
    8000561a:	47a1                	li	a5,8
    8000561c:	0ef48463          	beq	s1,a5,80005704 <consoleintr+0x10c>
    80005620:	47c1                	li	a5,16
    80005622:	10f49563          	bne	s1,a5,8000572c <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    80005626:	a16fc0ef          	jal	8000183c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000562a:	0002a517          	auipc	a0,0x2a
    8000562e:	fe650513          	addi	a0,a0,-26 # 8002f610 <cons>
    80005632:	051000ef          	jal	80005e82 <release>
}
    80005636:	60e2                	ld	ra,24(sp)
    80005638:	6442                	ld	s0,16(sp)
    8000563a:	64a2                	ld	s1,8(sp)
    8000563c:	6105                	addi	sp,sp,32
    8000563e:	8082                	ret
  switch(c){
    80005640:	07f00793          	li	a5,127
    80005644:	0cf48063          	beq	s1,a5,80005704 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005648:	0002a717          	auipc	a4,0x2a
    8000564c:	fc870713          	addi	a4,a4,-56 # 8002f610 <cons>
    80005650:	0a072783          	lw	a5,160(a4)
    80005654:	09872703          	lw	a4,152(a4)
    80005658:	9f99                	subw	a5,a5,a4
    8000565a:	07f00713          	li	a4,127
    8000565e:	fcf766e3          	bltu	a4,a5,8000562a <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80005662:	47b5                	li	a5,13
    80005664:	0cf48763          	beq	s1,a5,80005732 <consoleintr+0x13a>
      consputc(c);
    80005668:	8526                	mv	a0,s1
    8000566a:	f5dff0ef          	jal	800055c6 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000566e:	0002a797          	auipc	a5,0x2a
    80005672:	fa278793          	addi	a5,a5,-94 # 8002f610 <cons>
    80005676:	0a07a683          	lw	a3,160(a5)
    8000567a:	0016871b          	addiw	a4,a3,1
    8000567e:	0007061b          	sext.w	a2,a4
    80005682:	0ae7a023          	sw	a4,160(a5)
    80005686:	07f6f693          	andi	a3,a3,127
    8000568a:	97b6                	add	a5,a5,a3
    8000568c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005690:	47a9                	li	a5,10
    80005692:	0cf48563          	beq	s1,a5,8000575c <consoleintr+0x164>
    80005696:	4791                	li	a5,4
    80005698:	0cf48263          	beq	s1,a5,8000575c <consoleintr+0x164>
    8000569c:	0002a797          	auipc	a5,0x2a
    800056a0:	00c7a783          	lw	a5,12(a5) # 8002f6a8 <cons+0x98>
    800056a4:	9f1d                	subw	a4,a4,a5
    800056a6:	08000793          	li	a5,128
    800056aa:	f8f710e3          	bne	a4,a5,8000562a <consoleintr+0x32>
    800056ae:	a07d                	j	8000575c <consoleintr+0x164>
    800056b0:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800056b2:	0002a717          	auipc	a4,0x2a
    800056b6:	f5e70713          	addi	a4,a4,-162 # 8002f610 <cons>
    800056ba:	0a072783          	lw	a5,160(a4)
    800056be:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800056c2:	0002a497          	auipc	s1,0x2a
    800056c6:	f4e48493          	addi	s1,s1,-178 # 8002f610 <cons>
    while(cons.e != cons.w &&
    800056ca:	4929                	li	s2,10
    800056cc:	02f70863          	beq	a4,a5,800056fc <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800056d0:	37fd                	addiw	a5,a5,-1
    800056d2:	07f7f713          	andi	a4,a5,127
    800056d6:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800056d8:	01874703          	lbu	a4,24(a4)
    800056dc:	03270263          	beq	a4,s2,80005700 <consoleintr+0x108>
      cons.e--;
    800056e0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800056e4:	10000513          	li	a0,256
    800056e8:	edfff0ef          	jal	800055c6 <consputc>
    while(cons.e != cons.w &&
    800056ec:	0a04a783          	lw	a5,160(s1)
    800056f0:	09c4a703          	lw	a4,156(s1)
    800056f4:	fcf71ee3          	bne	a4,a5,800056d0 <consoleintr+0xd8>
    800056f8:	6902                	ld	s2,0(sp)
    800056fa:	bf05                	j	8000562a <consoleintr+0x32>
    800056fc:	6902                	ld	s2,0(sp)
    800056fe:	b735                	j	8000562a <consoleintr+0x32>
    80005700:	6902                	ld	s2,0(sp)
    80005702:	b725                	j	8000562a <consoleintr+0x32>
    if(cons.e != cons.w){
    80005704:	0002a717          	auipc	a4,0x2a
    80005708:	f0c70713          	addi	a4,a4,-244 # 8002f610 <cons>
    8000570c:	0a072783          	lw	a5,160(a4)
    80005710:	09c72703          	lw	a4,156(a4)
    80005714:	f0f70be3          	beq	a4,a5,8000562a <consoleintr+0x32>
      cons.e--;
    80005718:	37fd                	addiw	a5,a5,-1
    8000571a:	0002a717          	auipc	a4,0x2a
    8000571e:	f8f72b23          	sw	a5,-106(a4) # 8002f6b0 <cons+0xa0>
      consputc(BACKSPACE);
    80005722:	10000513          	li	a0,256
    80005726:	ea1ff0ef          	jal	800055c6 <consputc>
    8000572a:	b701                	j	8000562a <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000572c:	ee048fe3          	beqz	s1,8000562a <consoleintr+0x32>
    80005730:	bf21                	j	80005648 <consoleintr+0x50>
      consputc(c);
    80005732:	4529                	li	a0,10
    80005734:	e93ff0ef          	jal	800055c6 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005738:	0002a797          	auipc	a5,0x2a
    8000573c:	ed878793          	addi	a5,a5,-296 # 8002f610 <cons>
    80005740:	0a07a703          	lw	a4,160(a5)
    80005744:	0017069b          	addiw	a3,a4,1
    80005748:	0006861b          	sext.w	a2,a3
    8000574c:	0ad7a023          	sw	a3,160(a5)
    80005750:	07f77713          	andi	a4,a4,127
    80005754:	97ba                	add	a5,a5,a4
    80005756:	4729                	li	a4,10
    80005758:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000575c:	0002a797          	auipc	a5,0x2a
    80005760:	f4c7a823          	sw	a2,-176(a5) # 8002f6ac <cons+0x9c>
        wakeup(&cons.r);
    80005764:	0002a517          	auipc	a0,0x2a
    80005768:	f4450513          	addi	a0,a0,-188 # 8002f6a8 <cons+0x98>
    8000576c:	cb1fb0ef          	jal	8000141c <wakeup>
    80005770:	bd6d                	j	8000562a <consoleintr+0x32>

0000000080005772 <consoleinit>:

void
consoleinit(void)
{
    80005772:	1141                	addi	sp,sp,-16
    80005774:	e406                	sd	ra,8(sp)
    80005776:	e022                	sd	s0,0(sp)
    80005778:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000577a:	00002597          	auipc	a1,0x2
    8000577e:	04658593          	addi	a1,a1,70 # 800077c0 <etext+0x7c0>
    80005782:	0002a517          	auipc	a0,0x2a
    80005786:	e8e50513          	addi	a0,a0,-370 # 8002f610 <cons>
    8000578a:	5e0000ef          	jal	80005d6a <initlock>

  uartinit();
    8000578e:	400000ef          	jal	80005b8e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005792:	00021797          	auipc	a5,0x21
    80005796:	ce678793          	addi	a5,a5,-794 # 80026478 <devsw>
    8000579a:	00000717          	auipc	a4,0x0
    8000579e:	d2270713          	addi	a4,a4,-734 # 800054bc <consoleread>
    800057a2:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800057a4:	00000717          	auipc	a4,0x0
    800057a8:	c7a70713          	addi	a4,a4,-902 # 8000541e <consolewrite>
    800057ac:	ef98                	sd	a4,24(a5)
}
    800057ae:	60a2                	ld	ra,8(sp)
    800057b0:	6402                	ld	s0,0(sp)
    800057b2:	0141                	addi	sp,sp,16
    800057b4:	8082                	ret

00000000800057b6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    800057b6:	7139                	addi	sp,sp,-64
    800057b8:	fc06                	sd	ra,56(sp)
    800057ba:	f822                	sd	s0,48(sp)
    800057bc:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    800057be:	c219                	beqz	a2,800057c4 <printint+0xe>
    800057c0:	08054063          	bltz	a0,80005840 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    800057c4:	4881                	li	a7,0
    800057c6:	fc840693          	addi	a3,s0,-56

  i = 0;
    800057ca:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    800057cc:	00002617          	auipc	a2,0x2
    800057d0:	15c60613          	addi	a2,a2,348 # 80007928 <digits>
    800057d4:	883e                	mv	a6,a5
    800057d6:	2785                	addiw	a5,a5,1
    800057d8:	02b57733          	remu	a4,a0,a1
    800057dc:	9732                	add	a4,a4,a2
    800057de:	00074703          	lbu	a4,0(a4)
    800057e2:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    800057e6:	872a                	mv	a4,a0
    800057e8:	02b55533          	divu	a0,a0,a1
    800057ec:	0685                	addi	a3,a3,1
    800057ee:	feb773e3          	bgeu	a4,a1,800057d4 <printint+0x1e>

  if(sign)
    800057f2:	00088a63          	beqz	a7,80005806 <printint+0x50>
    buf[i++] = '-';
    800057f6:	1781                	addi	a5,a5,-32
    800057f8:	97a2                	add	a5,a5,s0
    800057fa:	02d00713          	li	a4,45
    800057fe:	fee78423          	sb	a4,-24(a5)
    80005802:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80005806:	02f05963          	blez	a5,80005838 <printint+0x82>
    8000580a:	f426                	sd	s1,40(sp)
    8000580c:	f04a                	sd	s2,32(sp)
    8000580e:	fc840713          	addi	a4,s0,-56
    80005812:	00f704b3          	add	s1,a4,a5
    80005816:	fff70913          	addi	s2,a4,-1
    8000581a:	993e                	add	s2,s2,a5
    8000581c:	37fd                	addiw	a5,a5,-1
    8000581e:	1782                	slli	a5,a5,0x20
    80005820:	9381                	srli	a5,a5,0x20
    80005822:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    80005826:	fff4c503          	lbu	a0,-1(s1)
    8000582a:	d9dff0ef          	jal	800055c6 <consputc>
  while(--i >= 0)
    8000582e:	14fd                	addi	s1,s1,-1
    80005830:	ff249be3          	bne	s1,s2,80005826 <printint+0x70>
    80005834:	74a2                	ld	s1,40(sp)
    80005836:	7902                	ld	s2,32(sp)
}
    80005838:	70e2                	ld	ra,56(sp)
    8000583a:	7442                	ld	s0,48(sp)
    8000583c:	6121                	addi	sp,sp,64
    8000583e:	8082                	ret
    x = -xx;
    80005840:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    80005844:	4885                	li	a7,1
    x = -xx;
    80005846:	b741                	j	800057c6 <printint+0x10>

0000000080005848 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    80005848:	7131                	addi	sp,sp,-192
    8000584a:	fc86                	sd	ra,120(sp)
    8000584c:	f8a2                	sd	s0,112(sp)
    8000584e:	e8d2                	sd	s4,80(sp)
    80005850:	0100                	addi	s0,sp,128
    80005852:	8a2a                	mv	s4,a0
    80005854:	e40c                	sd	a1,8(s0)
    80005856:	e810                	sd	a2,16(s0)
    80005858:	ec14                	sd	a3,24(s0)
    8000585a:	f018                	sd	a4,32(s0)
    8000585c:	f41c                	sd	a5,40(s0)
    8000585e:	03043823          	sd	a6,48(s0)
    80005862:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80005866:	00005797          	auipc	a5,0x5
    8000586a:	b6a7a783          	lw	a5,-1174(a5) # 8000a3d0 <panicking>
    8000586e:	c3a1                	beqz	a5,800058ae <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80005870:	00840793          	addi	a5,s0,8
    80005874:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005878:	000a4503          	lbu	a0,0(s4)
    8000587c:	28050763          	beqz	a0,80005b0a <printf+0x2c2>
    80005880:	f4a6                	sd	s1,104(sp)
    80005882:	f0ca                	sd	s2,96(sp)
    80005884:	ecce                	sd	s3,88(sp)
    80005886:	e4d6                	sd	s5,72(sp)
    80005888:	e0da                	sd	s6,64(sp)
    8000588a:	f862                	sd	s8,48(sp)
    8000588c:	f466                	sd	s9,40(sp)
    8000588e:	f06a                	sd	s10,32(sp)
    80005890:	ec6e                	sd	s11,24(sp)
    80005892:	4981                	li	s3,0
    if(cx != '%'){
    80005894:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005898:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000589c:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    800058a0:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    800058a4:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    800058a8:	07000d93          	li	s11,112
    800058ac:	a01d                	j	800058d2 <printf+0x8a>
    acquire(&pr.lock);
    800058ae:	0002a517          	auipc	a0,0x2a
    800058b2:	e0a50513          	addi	a0,a0,-502 # 8002f6b8 <pr>
    800058b6:	534000ef          	jal	80005dea <acquire>
    800058ba:	bf5d                	j	80005870 <printf+0x28>
      consputc(cx);
    800058bc:	d0bff0ef          	jal	800055c6 <consputc>
      continue;
    800058c0:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800058c2:	0014899b          	addiw	s3,s1,1
    800058c6:	013a07b3          	add	a5,s4,s3
    800058ca:	0007c503          	lbu	a0,0(a5)
    800058ce:	20050b63          	beqz	a0,80005ae4 <printf+0x29c>
    if(cx != '%'){
    800058d2:	ff5515e3          	bne	a0,s5,800058bc <printf+0x74>
    i++;
    800058d6:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    800058da:	009a07b3          	add	a5,s4,s1
    800058de:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    800058e2:	20090b63          	beqz	s2,80005af8 <printf+0x2b0>
    800058e6:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800058ea:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    800058ec:	c789                	beqz	a5,800058f6 <printf+0xae>
    800058ee:	009a0733          	add	a4,s4,s1
    800058f2:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800058f6:	03690963          	beq	s2,s6,80005928 <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800058fa:	05890363          	beq	s2,s8,80005940 <printf+0xf8>
    } else if(c0 == 'u'){
    800058fe:	0d990663          	beq	s2,s9,800059ca <printf+0x182>
    } else if(c0 == 'x'){
    80005902:	11a90d63          	beq	s2,s10,80005a1c <printf+0x1d4>
    } else if(c0 == 'p'){
    80005906:	15b90663          	beq	s2,s11,80005a52 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    8000590a:	06300793          	li	a5,99
    8000590e:	18f90563          	beq	s2,a5,80005a98 <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    80005912:	07300793          	li	a5,115
    80005916:	18f90b63          	beq	s2,a5,80005aac <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000591a:	03591b63          	bne	s2,s5,80005950 <printf+0x108>
      consputc('%');
    8000591e:	02500513          	li	a0,37
    80005922:	ca5ff0ef          	jal	800055c6 <consputc>
    80005926:	bf71                	j	800058c2 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    80005928:	f8843783          	ld	a5,-120(s0)
    8000592c:	00878713          	addi	a4,a5,8
    80005930:	f8e43423          	sd	a4,-120(s0)
    80005934:	4605                	li	a2,1
    80005936:	45a9                	li	a1,10
    80005938:	4388                	lw	a0,0(a5)
    8000593a:	e7dff0ef          	jal	800057b6 <printint>
    8000593e:	b751                	j	800058c2 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    80005940:	01678f63          	beq	a5,s6,8000595e <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80005944:	03878b63          	beq	a5,s8,8000597a <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    80005948:	09978e63          	beq	a5,s9,800059e4 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    8000594c:	0fa78563          	beq	a5,s10,80005a36 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80005950:	8556                	mv	a0,s5
    80005952:	c75ff0ef          	jal	800055c6 <consputc>
      consputc(c0);
    80005956:	854a                	mv	a0,s2
    80005958:	c6fff0ef          	jal	800055c6 <consputc>
    8000595c:	b79d                	j	800058c2 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    8000595e:	f8843783          	ld	a5,-120(s0)
    80005962:	00878713          	addi	a4,a5,8
    80005966:	f8e43423          	sd	a4,-120(s0)
    8000596a:	4605                	li	a2,1
    8000596c:	45a9                	li	a1,10
    8000596e:	6388                	ld	a0,0(a5)
    80005970:	e47ff0ef          	jal	800057b6 <printint>
      i += 1;
    80005974:	0029849b          	addiw	s1,s3,2
    80005978:	b7a9                	j	800058c2 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000597a:	06400793          	li	a5,100
    8000597e:	02f68863          	beq	a3,a5,800059ae <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005982:	07500793          	li	a5,117
    80005986:	06f68d63          	beq	a3,a5,80005a00 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000598a:	07800793          	li	a5,120
    8000598e:	fcf691e3          	bne	a3,a5,80005950 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80005992:	f8843783          	ld	a5,-120(s0)
    80005996:	00878713          	addi	a4,a5,8
    8000599a:	f8e43423          	sd	a4,-120(s0)
    8000599e:	4601                	li	a2,0
    800059a0:	45c1                	li	a1,16
    800059a2:	6388                	ld	a0,0(a5)
    800059a4:	e13ff0ef          	jal	800057b6 <printint>
      i += 2;
    800059a8:	0039849b          	addiw	s1,s3,3
    800059ac:	bf19                	j	800058c2 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    800059ae:	f8843783          	ld	a5,-120(s0)
    800059b2:	00878713          	addi	a4,a5,8
    800059b6:	f8e43423          	sd	a4,-120(s0)
    800059ba:	4605                	li	a2,1
    800059bc:	45a9                	li	a1,10
    800059be:	6388                	ld	a0,0(a5)
    800059c0:	df7ff0ef          	jal	800057b6 <printint>
      i += 2;
    800059c4:	0039849b          	addiw	s1,s3,3
    800059c8:	bded                	j	800058c2 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    800059ca:	f8843783          	ld	a5,-120(s0)
    800059ce:	00878713          	addi	a4,a5,8
    800059d2:	f8e43423          	sd	a4,-120(s0)
    800059d6:	4601                	li	a2,0
    800059d8:	45a9                	li	a1,10
    800059da:	0007e503          	lwu	a0,0(a5)
    800059de:	dd9ff0ef          	jal	800057b6 <printint>
    800059e2:	b5c5                	j	800058c2 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800059e4:	f8843783          	ld	a5,-120(s0)
    800059e8:	00878713          	addi	a4,a5,8
    800059ec:	f8e43423          	sd	a4,-120(s0)
    800059f0:	4601                	li	a2,0
    800059f2:	45a9                	li	a1,10
    800059f4:	6388                	ld	a0,0(a5)
    800059f6:	dc1ff0ef          	jal	800057b6 <printint>
      i += 1;
    800059fa:	0029849b          	addiw	s1,s3,2
    800059fe:	b5d1                	j	800058c2 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80005a00:	f8843783          	ld	a5,-120(s0)
    80005a04:	00878713          	addi	a4,a5,8
    80005a08:	f8e43423          	sd	a4,-120(s0)
    80005a0c:	4601                	li	a2,0
    80005a0e:	45a9                	li	a1,10
    80005a10:	6388                	ld	a0,0(a5)
    80005a12:	da5ff0ef          	jal	800057b6 <printint>
      i += 2;
    80005a16:	0039849b          	addiw	s1,s3,3
    80005a1a:	b565                	j	800058c2 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    80005a1c:	f8843783          	ld	a5,-120(s0)
    80005a20:	00878713          	addi	a4,a5,8
    80005a24:	f8e43423          	sd	a4,-120(s0)
    80005a28:	4601                	li	a2,0
    80005a2a:	45c1                	li	a1,16
    80005a2c:	0007e503          	lwu	a0,0(a5)
    80005a30:	d87ff0ef          	jal	800057b6 <printint>
    80005a34:	b579                	j	800058c2 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    80005a36:	f8843783          	ld	a5,-120(s0)
    80005a3a:	00878713          	addi	a4,a5,8
    80005a3e:	f8e43423          	sd	a4,-120(s0)
    80005a42:	4601                	li	a2,0
    80005a44:	45c1                	li	a1,16
    80005a46:	6388                	ld	a0,0(a5)
    80005a48:	d6fff0ef          	jal	800057b6 <printint>
      i += 1;
    80005a4c:	0029849b          	addiw	s1,s3,2
    80005a50:	bd8d                	j	800058c2 <printf+0x7a>
    80005a52:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80005a54:	f8843783          	ld	a5,-120(s0)
    80005a58:	00878713          	addi	a4,a5,8
    80005a5c:	f8e43423          	sd	a4,-120(s0)
    80005a60:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80005a64:	03000513          	li	a0,48
    80005a68:	b5fff0ef          	jal	800055c6 <consputc>
  consputc('x');
    80005a6c:	07800513          	li	a0,120
    80005a70:	b57ff0ef          	jal	800055c6 <consputc>
    80005a74:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005a76:	00002b97          	auipc	s7,0x2
    80005a7a:	eb2b8b93          	addi	s7,s7,-334 # 80007928 <digits>
    80005a7e:	03c9d793          	srli	a5,s3,0x3c
    80005a82:	97de                	add	a5,a5,s7
    80005a84:	0007c503          	lbu	a0,0(a5)
    80005a88:	b3fff0ef          	jal	800055c6 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005a8c:	0992                	slli	s3,s3,0x4
    80005a8e:	397d                	addiw	s2,s2,-1
    80005a90:	fe0917e3          	bnez	s2,80005a7e <printf+0x236>
    80005a94:	7be2                	ld	s7,56(sp)
    80005a96:	b535                	j	800058c2 <printf+0x7a>
      consputc(va_arg(ap, uint));
    80005a98:	f8843783          	ld	a5,-120(s0)
    80005a9c:	00878713          	addi	a4,a5,8
    80005aa0:	f8e43423          	sd	a4,-120(s0)
    80005aa4:	4388                	lw	a0,0(a5)
    80005aa6:	b21ff0ef          	jal	800055c6 <consputc>
    80005aaa:	bd21                	j	800058c2 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    80005aac:	f8843783          	ld	a5,-120(s0)
    80005ab0:	00878713          	addi	a4,a5,8
    80005ab4:	f8e43423          	sd	a4,-120(s0)
    80005ab8:	0007b903          	ld	s2,0(a5)
    80005abc:	00090d63          	beqz	s2,80005ad6 <printf+0x28e>
      for(; *s; s++)
    80005ac0:	00094503          	lbu	a0,0(s2)
    80005ac4:	de050fe3          	beqz	a0,800058c2 <printf+0x7a>
        consputc(*s);
    80005ac8:	affff0ef          	jal	800055c6 <consputc>
      for(; *s; s++)
    80005acc:	0905                	addi	s2,s2,1
    80005ace:	00094503          	lbu	a0,0(s2)
    80005ad2:	f97d                	bnez	a0,80005ac8 <printf+0x280>
    80005ad4:	b3fd                	j	800058c2 <printf+0x7a>
        s = "(null)";
    80005ad6:	00002917          	auipc	s2,0x2
    80005ada:	cf290913          	addi	s2,s2,-782 # 800077c8 <etext+0x7c8>
      for(; *s; s++)
    80005ade:	02800513          	li	a0,40
    80005ae2:	b7dd                	j	80005ac8 <printf+0x280>
    80005ae4:	74a6                	ld	s1,104(sp)
    80005ae6:	7906                	ld	s2,96(sp)
    80005ae8:	69e6                	ld	s3,88(sp)
    80005aea:	6aa6                	ld	s5,72(sp)
    80005aec:	6b06                	ld	s6,64(sp)
    80005aee:	7c42                	ld	s8,48(sp)
    80005af0:	7ca2                	ld	s9,40(sp)
    80005af2:	7d02                	ld	s10,32(sp)
    80005af4:	6de2                	ld	s11,24(sp)
    80005af6:	a811                	j	80005b0a <printf+0x2c2>
    80005af8:	74a6                	ld	s1,104(sp)
    80005afa:	7906                	ld	s2,96(sp)
    80005afc:	69e6                	ld	s3,88(sp)
    80005afe:	6aa6                	ld	s5,72(sp)
    80005b00:	6b06                	ld	s6,64(sp)
    80005b02:	7c42                	ld	s8,48(sp)
    80005b04:	7ca2                	ld	s9,40(sp)
    80005b06:	7d02                	ld	s10,32(sp)
    80005b08:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    80005b0a:	00005797          	auipc	a5,0x5
    80005b0e:	8c67a783          	lw	a5,-1850(a5) # 8000a3d0 <panicking>
    80005b12:	c799                	beqz	a5,80005b20 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    80005b14:	4501                	li	a0,0
    80005b16:	70e6                	ld	ra,120(sp)
    80005b18:	7446                	ld	s0,112(sp)
    80005b1a:	6a46                	ld	s4,80(sp)
    80005b1c:	6129                	addi	sp,sp,192
    80005b1e:	8082                	ret
    release(&pr.lock);
    80005b20:	0002a517          	auipc	a0,0x2a
    80005b24:	b9850513          	addi	a0,a0,-1128 # 8002f6b8 <pr>
    80005b28:	35a000ef          	jal	80005e82 <release>
  return 0;
    80005b2c:	b7e5                	j	80005b14 <printf+0x2cc>

0000000080005b2e <panic>:

void
panic(char *s)
{
    80005b2e:	1101                	addi	sp,sp,-32
    80005b30:	ec06                	sd	ra,24(sp)
    80005b32:	e822                	sd	s0,16(sp)
    80005b34:	e426                	sd	s1,8(sp)
    80005b36:	e04a                	sd	s2,0(sp)
    80005b38:	1000                	addi	s0,sp,32
    80005b3a:	84aa                	mv	s1,a0
  panicking = 1;
    80005b3c:	4905                	li	s2,1
    80005b3e:	00005797          	auipc	a5,0x5
    80005b42:	8927a923          	sw	s2,-1902(a5) # 8000a3d0 <panicking>
  printf("panic: ");
    80005b46:	00002517          	auipc	a0,0x2
    80005b4a:	c8a50513          	addi	a0,a0,-886 # 800077d0 <etext+0x7d0>
    80005b4e:	cfbff0ef          	jal	80005848 <printf>
  printf("%s\n", s);
    80005b52:	85a6                	mv	a1,s1
    80005b54:	00002517          	auipc	a0,0x2
    80005b58:	c8450513          	addi	a0,a0,-892 # 800077d8 <etext+0x7d8>
    80005b5c:	cedff0ef          	jal	80005848 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005b60:	00005797          	auipc	a5,0x5
    80005b64:	8727a623          	sw	s2,-1940(a5) # 8000a3cc <panicked>
  for(;;)
    80005b68:	a001                	j	80005b68 <panic+0x3a>

0000000080005b6a <printfinit>:
    ;
}

void
printfinit(void)
{
    80005b6a:	1141                	addi	sp,sp,-16
    80005b6c:	e406                	sd	ra,8(sp)
    80005b6e:	e022                	sd	s0,0(sp)
    80005b70:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80005b72:	00002597          	auipc	a1,0x2
    80005b76:	c6e58593          	addi	a1,a1,-914 # 800077e0 <etext+0x7e0>
    80005b7a:	0002a517          	auipc	a0,0x2a
    80005b7e:	b3e50513          	addi	a0,a0,-1218 # 8002f6b8 <pr>
    80005b82:	1e8000ef          	jal	80005d6a <initlock>
}
    80005b86:	60a2                	ld	ra,8(sp)
    80005b88:	6402                	ld	s0,0(sp)
    80005b8a:	0141                	addi	sp,sp,16
    80005b8c:	8082                	ret

0000000080005b8e <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80005b8e:	1141                	addi	sp,sp,-16
    80005b90:	e406                	sd	ra,8(sp)
    80005b92:	e022                	sd	s0,0(sp)
    80005b94:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005b96:	100007b7          	lui	a5,0x10000
    80005b9a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80005b9e:	10000737          	lui	a4,0x10000
    80005ba2:	f8000693          	li	a3,-128
    80005ba6:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005baa:	468d                	li	a3,3
    80005bac:	10000637          	lui	a2,0x10000
    80005bb0:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005bb4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005bb8:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005bbc:	10000737          	lui	a4,0x10000
    80005bc0:	461d                	li	a2,7
    80005bc2:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005bc6:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    80005bca:	00002597          	auipc	a1,0x2
    80005bce:	c1e58593          	addi	a1,a1,-994 # 800077e8 <etext+0x7e8>
    80005bd2:	0002a517          	auipc	a0,0x2a
    80005bd6:	afe50513          	addi	a0,a0,-1282 # 8002f6d0 <tx_lock>
    80005bda:	190000ef          	jal	80005d6a <initlock>
}
    80005bde:	60a2                	ld	ra,8(sp)
    80005be0:	6402                	ld	s0,0(sp)
    80005be2:	0141                	addi	sp,sp,16
    80005be4:	8082                	ret

0000000080005be6 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80005be6:	715d                	addi	sp,sp,-80
    80005be8:	e486                	sd	ra,72(sp)
    80005bea:	e0a2                	sd	s0,64(sp)
    80005bec:	fc26                	sd	s1,56(sp)
    80005bee:	ec56                	sd	s5,24(sp)
    80005bf0:	0880                	addi	s0,sp,80
    80005bf2:	8aaa                	mv	s5,a0
    80005bf4:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    80005bf6:	0002a517          	auipc	a0,0x2a
    80005bfa:	ada50513          	addi	a0,a0,-1318 # 8002f6d0 <tx_lock>
    80005bfe:	1ec000ef          	jal	80005dea <acquire>

  int i = 0;
  while(i < n){ 
    80005c02:	06905063          	blez	s1,80005c62 <uartwrite+0x7c>
    80005c06:	f84a                	sd	s2,48(sp)
    80005c08:	f44e                	sd	s3,40(sp)
    80005c0a:	f052                	sd	s4,32(sp)
    80005c0c:	e85a                	sd	s6,16(sp)
    80005c0e:	e45e                	sd	s7,8(sp)
    80005c10:	8a56                	mv	s4,s5
    80005c12:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80005c14:	00004497          	auipc	s1,0x4
    80005c18:	7c448493          	addi	s1,s1,1988 # 8000a3d8 <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80005c1c:	0002a997          	auipc	s3,0x2a
    80005c20:	ab498993          	addi	s3,s3,-1356 # 8002f6d0 <tx_lock>
    80005c24:	00004917          	auipc	s2,0x4
    80005c28:	7b090913          	addi	s2,s2,1968 # 8000a3d4 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80005c2c:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80005c30:	4b05                	li	s6,1
    80005c32:	a005                	j	80005c52 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80005c34:	85ce                	mv	a1,s3
    80005c36:	854a                	mv	a0,s2
    80005c38:	f98fb0ef          	jal	800013d0 <sleep>
    while(tx_busy != 0){
    80005c3c:	409c                	lw	a5,0(s1)
    80005c3e:	fbfd                	bnez	a5,80005c34 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80005c40:	000a4783          	lbu	a5,0(s4)
    80005c44:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    80005c48:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80005c4c:	0a05                	addi	s4,s4,1
    80005c4e:	015a0563          	beq	s4,s5,80005c58 <uartwrite+0x72>
    while(tx_busy != 0){
    80005c52:	409c                	lw	a5,0(s1)
    80005c54:	f3e5                	bnez	a5,80005c34 <uartwrite+0x4e>
    80005c56:	b7ed                	j	80005c40 <uartwrite+0x5a>
    80005c58:	7942                	ld	s2,48(sp)
    80005c5a:	79a2                	ld	s3,40(sp)
    80005c5c:	7a02                	ld	s4,32(sp)
    80005c5e:	6b42                	ld	s6,16(sp)
    80005c60:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80005c62:	0002a517          	auipc	a0,0x2a
    80005c66:	a6e50513          	addi	a0,a0,-1426 # 8002f6d0 <tx_lock>
    80005c6a:	218000ef          	jal	80005e82 <release>
}
    80005c6e:	60a6                	ld	ra,72(sp)
    80005c70:	6406                	ld	s0,64(sp)
    80005c72:	74e2                	ld	s1,56(sp)
    80005c74:	6ae2                	ld	s5,24(sp)
    80005c76:	6161                	addi	sp,sp,80
    80005c78:	8082                	ret

0000000080005c7a <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005c7a:	1101                	addi	sp,sp,-32
    80005c7c:	ec06                	sd	ra,24(sp)
    80005c7e:	e822                	sd	s0,16(sp)
    80005c80:	e426                	sd	s1,8(sp)
    80005c82:	1000                	addi	s0,sp,32
    80005c84:	84aa                	mv	s1,a0
  if(panicking == 0)
    80005c86:	00004797          	auipc	a5,0x4
    80005c8a:	74a7a783          	lw	a5,1866(a5) # 8000a3d0 <panicking>
    80005c8e:	cf95                	beqz	a5,80005cca <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80005c90:	00004797          	auipc	a5,0x4
    80005c94:	73c7a783          	lw	a5,1852(a5) # 8000a3cc <panicked>
    80005c98:	ef85                	bnez	a5,80005cd0 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005c9a:	10000737          	lui	a4,0x10000
    80005c9e:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80005ca0:	00074783          	lbu	a5,0(a4)
    80005ca4:	0207f793          	andi	a5,a5,32
    80005ca8:	dfe5                	beqz	a5,80005ca0 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    80005caa:	0ff4f513          	zext.b	a0,s1
    80005cae:	100007b7          	lui	a5,0x10000
    80005cb2:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80005cb6:	00004797          	auipc	a5,0x4
    80005cba:	71a7a783          	lw	a5,1818(a5) # 8000a3d0 <panicking>
    80005cbe:	cb91                	beqz	a5,80005cd2 <uartputc_sync+0x58>
    pop_off();
}
    80005cc0:	60e2                	ld	ra,24(sp)
    80005cc2:	6442                	ld	s0,16(sp)
    80005cc4:	64a2                	ld	s1,8(sp)
    80005cc6:	6105                	addi	sp,sp,32
    80005cc8:	8082                	ret
    push_off();
    80005cca:	0e0000ef          	jal	80005daa <push_off>
    80005cce:	b7c9                	j	80005c90 <uartputc_sync+0x16>
    for(;;)
    80005cd0:	a001                	j	80005cd0 <uartputc_sync+0x56>
    pop_off();
    80005cd2:	15c000ef          	jal	80005e2e <pop_off>
}
    80005cd6:	b7ed                	j	80005cc0 <uartputc_sync+0x46>

0000000080005cd8 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80005cd8:	1141                	addi	sp,sp,-16
    80005cda:	e422                	sd	s0,8(sp)
    80005cdc:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80005cde:	100007b7          	lui	a5,0x10000
    80005ce2:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80005ce4:	0007c783          	lbu	a5,0(a5)
    80005ce8:	8b85                	andi	a5,a5,1
    80005cea:	cb81                	beqz	a5,80005cfa <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    80005cec:	100007b7          	lui	a5,0x10000
    80005cf0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80005cf4:	6422                	ld	s0,8(sp)
    80005cf6:	0141                	addi	sp,sp,16
    80005cf8:	8082                	ret
    return -1;
    80005cfa:	557d                	li	a0,-1
    80005cfc:	bfe5                	j	80005cf4 <uartgetc+0x1c>

0000000080005cfe <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005cfe:	1101                	addi	sp,sp,-32
    80005d00:	ec06                	sd	ra,24(sp)
    80005d02:	e822                	sd	s0,16(sp)
    80005d04:	e426                	sd	s1,8(sp)
    80005d06:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80005d08:	100007b7          	lui	a5,0x10000
    80005d0c:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005d0e:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    80005d12:	0002a517          	auipc	a0,0x2a
    80005d16:	9be50513          	addi	a0,a0,-1602 # 8002f6d0 <tx_lock>
    80005d1a:	0d0000ef          	jal	80005dea <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80005d1e:	100007b7          	lui	a5,0x10000
    80005d22:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80005d24:	0007c783          	lbu	a5,0(a5)
    80005d28:	0207f793          	andi	a5,a5,32
    80005d2c:	eb89                	bnez	a5,80005d3e <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80005d2e:	0002a517          	auipc	a0,0x2a
    80005d32:	9a250513          	addi	a0,a0,-1630 # 8002f6d0 <tx_lock>
    80005d36:	14c000ef          	jal	80005e82 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80005d3a:	54fd                	li	s1,-1
    80005d3c:	a831                	j	80005d58 <uartintr+0x5a>
    tx_busy = 0;
    80005d3e:	00004797          	auipc	a5,0x4
    80005d42:	6807ad23          	sw	zero,1690(a5) # 8000a3d8 <tx_busy>
    wakeup(&tx_chan);
    80005d46:	00004517          	auipc	a0,0x4
    80005d4a:	68e50513          	addi	a0,a0,1678 # 8000a3d4 <tx_chan>
    80005d4e:	ecefb0ef          	jal	8000141c <wakeup>
    80005d52:	bff1                	j	80005d2e <uartintr+0x30>
      break;
    consoleintr(c);
    80005d54:	8a5ff0ef          	jal	800055f8 <consoleintr>
    int c = uartgetc();
    80005d58:	f81ff0ef          	jal	80005cd8 <uartgetc>
    if(c == -1)
    80005d5c:	fe951ce3          	bne	a0,s1,80005d54 <uartintr+0x56>
  }
}
    80005d60:	60e2                	ld	ra,24(sp)
    80005d62:	6442                	ld	s0,16(sp)
    80005d64:	64a2                	ld	s1,8(sp)
    80005d66:	6105                	addi	sp,sp,32
    80005d68:	8082                	ret

0000000080005d6a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005d6a:	1141                	addi	sp,sp,-16
    80005d6c:	e422                	sd	s0,8(sp)
    80005d6e:	0800                	addi	s0,sp,16
  lk->name = name;
    80005d70:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005d72:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80005d76:	00053823          	sd	zero,16(a0)
}
    80005d7a:	6422                	ld	s0,8(sp)
    80005d7c:	0141                	addi	sp,sp,16
    80005d7e:	8082                	ret

0000000080005d80 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005d80:	411c                	lw	a5,0(a0)
    80005d82:	e399                	bnez	a5,80005d88 <holding+0x8>
    80005d84:	4501                	li	a0,0
  return r;
}
    80005d86:	8082                	ret
{
    80005d88:	1101                	addi	sp,sp,-32
    80005d8a:	ec06                	sd	ra,24(sp)
    80005d8c:	e822                	sd	s0,16(sp)
    80005d8e:	e426                	sd	s1,8(sp)
    80005d90:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005d92:	6904                	ld	s1,16(a0)
    80005d94:	fcbfa0ef          	jal	80000d5e <mycpu>
    80005d98:	40a48533          	sub	a0,s1,a0
    80005d9c:	00153513          	seqz	a0,a0
}
    80005da0:	60e2                	ld	ra,24(sp)
    80005da2:	6442                	ld	s0,16(sp)
    80005da4:	64a2                	ld	s1,8(sp)
    80005da6:	6105                	addi	sp,sp,32
    80005da8:	8082                	ret

0000000080005daa <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80005daa:	1101                	addi	sp,sp,-32
    80005dac:	ec06                	sd	ra,24(sp)
    80005dae:	e822                	sd	s0,16(sp)
    80005db0:	e426                	sd	s1,8(sp)
    80005db2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005db4:	100024f3          	csrr	s1,sstatus
    80005db8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80005dbc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005dbe:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80005dc2:	f9dfa0ef          	jal	80000d5e <mycpu>
    80005dc6:	5d3c                	lw	a5,120(a0)
    80005dc8:	cb99                	beqz	a5,80005dde <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80005dca:	f95fa0ef          	jal	80000d5e <mycpu>
    80005dce:	5d3c                	lw	a5,120(a0)
    80005dd0:	2785                	addiw	a5,a5,1
    80005dd2:	dd3c                	sw	a5,120(a0)
}
    80005dd4:	60e2                	ld	ra,24(sp)
    80005dd6:	6442                	ld	s0,16(sp)
    80005dd8:	64a2                	ld	s1,8(sp)
    80005dda:	6105                	addi	sp,sp,32
    80005ddc:	8082                	ret
    mycpu()->intena = old;
    80005dde:	f81fa0ef          	jal	80000d5e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80005de2:	8085                	srli	s1,s1,0x1
    80005de4:	8885                	andi	s1,s1,1
    80005de6:	dd64                	sw	s1,124(a0)
    80005de8:	b7cd                	j	80005dca <push_off+0x20>

0000000080005dea <acquire>:
{
    80005dea:	1101                	addi	sp,sp,-32
    80005dec:	ec06                	sd	ra,24(sp)
    80005dee:	e822                	sd	s0,16(sp)
    80005df0:	e426                	sd	s1,8(sp)
    80005df2:	1000                	addi	s0,sp,32
    80005df4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80005df6:	fb5ff0ef          	jal	80005daa <push_off>
  if(holding(lk))
    80005dfa:	8526                	mv	a0,s1
    80005dfc:	f85ff0ef          	jal	80005d80 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005e00:	4705                	li	a4,1
  if(holding(lk))
    80005e02:	e105                	bnez	a0,80005e22 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005e04:	87ba                	mv	a5,a4
    80005e06:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80005e0a:	2781                	sext.w	a5,a5
    80005e0c:	ffe5                	bnez	a5,80005e04 <acquire+0x1a>
  __sync_synchronize();
    80005e0e:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80005e12:	f4dfa0ef          	jal	80000d5e <mycpu>
    80005e16:	e888                	sd	a0,16(s1)
}
    80005e18:	60e2                	ld	ra,24(sp)
    80005e1a:	6442                	ld	s0,16(sp)
    80005e1c:	64a2                	ld	s1,8(sp)
    80005e1e:	6105                	addi	sp,sp,32
    80005e20:	8082                	ret
    panic("acquire");
    80005e22:	00002517          	auipc	a0,0x2
    80005e26:	9ce50513          	addi	a0,a0,-1586 # 800077f0 <etext+0x7f0>
    80005e2a:	d05ff0ef          	jal	80005b2e <panic>

0000000080005e2e <pop_off>:

void
pop_off(void)
{
    80005e2e:	1141                	addi	sp,sp,-16
    80005e30:	e406                	sd	ra,8(sp)
    80005e32:	e022                	sd	s0,0(sp)
    80005e34:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80005e36:	f29fa0ef          	jal	80000d5e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005e3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005e3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005e40:	e78d                	bnez	a5,80005e6a <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80005e42:	5d3c                	lw	a5,120(a0)
    80005e44:	02f05963          	blez	a5,80005e76 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80005e48:	37fd                	addiw	a5,a5,-1
    80005e4a:	0007871b          	sext.w	a4,a5
    80005e4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005e50:	eb09                	bnez	a4,80005e62 <pop_off+0x34>
    80005e52:	5d7c                	lw	a5,124(a0)
    80005e54:	c799                	beqz	a5,80005e62 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005e56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005e5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005e5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005e62:	60a2                	ld	ra,8(sp)
    80005e64:	6402                	ld	s0,0(sp)
    80005e66:	0141                	addi	sp,sp,16
    80005e68:	8082                	ret
    panic("pop_off - interruptible");
    80005e6a:	00002517          	auipc	a0,0x2
    80005e6e:	98e50513          	addi	a0,a0,-1650 # 800077f8 <etext+0x7f8>
    80005e72:	cbdff0ef          	jal	80005b2e <panic>
    panic("pop_off");
    80005e76:	00002517          	auipc	a0,0x2
    80005e7a:	99a50513          	addi	a0,a0,-1638 # 80007810 <etext+0x810>
    80005e7e:	cb1ff0ef          	jal	80005b2e <panic>

0000000080005e82 <release>:
{
    80005e82:	1101                	addi	sp,sp,-32
    80005e84:	ec06                	sd	ra,24(sp)
    80005e86:	e822                	sd	s0,16(sp)
    80005e88:	e426                	sd	s1,8(sp)
    80005e8a:	1000                	addi	s0,sp,32
    80005e8c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005e8e:	ef3ff0ef          	jal	80005d80 <holding>
    80005e92:	c105                	beqz	a0,80005eb2 <release+0x30>
  lk->cpu = 0;
    80005e94:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005e98:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80005e9c:	0310000f          	fence	rw,w
    80005ea0:	0004a023          	sw	zero,0(s1)
  pop_off();
    80005ea4:	f8bff0ef          	jal	80005e2e <pop_off>
}
    80005ea8:	60e2                	ld	ra,24(sp)
    80005eaa:	6442                	ld	s0,16(sp)
    80005eac:	64a2                	ld	s1,8(sp)
    80005eae:	6105                	addi	sp,sp,32
    80005eb0:	8082                	ret
    panic("release");
    80005eb2:	00002517          	auipc	a0,0x2
    80005eb6:	96650513          	addi	a0,a0,-1690 # 80007818 <etext+0x818>
    80005eba:	c75ff0ef          	jal	80005b2e <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
