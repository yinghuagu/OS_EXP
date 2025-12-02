
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
    80000004:	35813103          	ld	sp,856(sp) # 8000a358 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000016:	2f8050ef          	jal	8000530e <start>

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
    80000034:	67878793          	addi	a5,a5,1656 # 8002f6a8 <end>
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
    80000050:	35490913          	addi	s2,s2,852 # 8000a3a0 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	4f5050ef          	jal	80005d4a <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	57d050ef          	jal	80005de2 <release>
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
    8000007e:	211050ef          	jal	80005a8e <panic>

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
    800000de:	2c650513          	addi	a0,a0,710 # 8000a3a0 <kmem>
    800000e2:	3e9050ef          	jal	80005cca <initlock>
  freerange(end, (void*)PHYSTOP);
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	0002f517          	auipc	a0,0x2f
    800000ee:	5be50513          	addi	a0,a0,1470 # 8002f6a8 <end>
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
    8000010c:	29848493          	addi	s1,s1,664 # 8000a3a0 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	439050ef          	jal	80005d4a <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if(r)
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	0000a517          	auipc	a0,0xa
    80000120:	28450513          	addi	a0,a0,644 # 8000a3a0 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000126:	4bd050ef          	jal	80005de2 <release>

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
    80000144:	26050513          	addi	a0,a0,608 # 8000a3a0 <kmem>
    80000148:	49b050ef          	jal	80005de2 <release>
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
    800001c2:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffcf959>
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
    800002f8:	07c70713          	addi	a4,a4,124 # 8000a370 <started>
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
    80000316:	492050ef          	jal	800057a8 <printf>
    kvminithart();    // turn on paging
    8000031a:	080000ef          	jal	8000039a <kvminithart>
    trapinithart();   // install kernel trap vector
    8000031e:	7bc010ef          	jal	80001ada <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000322:	207040ef          	jal	80004d28 <plicinithart>
  }

  scheduler();        
    80000326:	713000ef          	jal	80001238 <scheduler>
    consoleinit();
    8000032a:	3a8050ef          	jal	800056d2 <consoleinit>
    printfinit();
    8000032e:	79c050ef          	jal	80005aca <printfinit>
    printf("\n");
    80000332:	00007517          	auipc	a0,0x7
    80000336:	ce650513          	addi	a0,a0,-794 # 80007018 <etext+0x18>
    8000033a:	46e050ef          	jal	800057a8 <printf>
    printf("xv6 kernel is booting\n");
    8000033e:	00007517          	auipc	a0,0x7
    80000342:	ce250513          	addi	a0,a0,-798 # 80007020 <etext+0x20>
    80000346:	462050ef          	jal	800057a8 <printf>
    printf("\n");
    8000034a:	00007517          	auipc	a0,0x7
    8000034e:	cce50513          	addi	a0,a0,-818 # 80007018 <etext+0x18>
    80000352:	456050ef          	jal	800057a8 <printf>
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
    8000036e:	1a1040ef          	jal	80004d0e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000372:	1b7040ef          	jal	80004d28 <plicinithart>
    binit();         // buffer cache
    80000376:	609010ef          	jal	8000217e <binit>
    iinit();         // inode table
    8000037a:	38e020ef          	jal	80002708 <iinit>
    fileinit();      // file table
    8000037e:	280030ef          	jal	800035fe <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000382:	297040ef          	jal	80004e18 <virtio_disk_init>
    userinit();      // first user process
    80000386:	4cf000ef          	jal	80001054 <userinit>
    __sync_synchronize();
    8000038a:	0330000f          	fence	rw,rw
    started = 1;
    8000038e:	4785                	li	a5,1
    80000390:	0000a717          	auipc	a4,0xa
    80000394:	fef72023          	sw	a5,-32(a4) # 8000a370 <started>
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
    800003a8:	fd47b783          	ld	a5,-44(a5) # 8000a378 <kernel_pagetable>
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
    800003f0:	69e050ef          	jal	80005a8e <panic>
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
    80000416:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffcf94f>
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
    80000506:	588050ef          	jal	80005a8e <panic>
    panic("mappages: size not aligned");
    8000050a:	00007517          	auipc	a0,0x7
    8000050e:	b6e50513          	addi	a0,a0,-1170 # 80007078 <etext+0x78>
    80000512:	57c050ef          	jal	80005a8e <panic>
    panic("mappages: size");
    80000516:	00007517          	auipc	a0,0x7
    8000051a:	b8250513          	addi	a0,a0,-1150 # 80007098 <etext+0x98>
    8000051e:	570050ef          	jal	80005a8e <panic>
      panic("mappages: remap");
    80000522:	00007517          	auipc	a0,0x7
    80000526:	b8650513          	addi	a0,a0,-1146 # 800070a8 <etext+0xa8>
    8000052a:	564050ef          	jal	80005a8e <panic>
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
    8000056e:	520050ef          	jal	80005a8e <panic>

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
    80000634:	d4a7b423          	sd	a0,-696(a5) # 8000a378 <kernel_pagetable>
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
    800006a8:	3e6050ef          	jal	80005a8e <panic>
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
    80000820:	26e050ef          	jal	80005a8e <panic>
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
    80000930:	15e050ef          	jal	80005a8e <panic>

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
    80000c1a:	bda48493          	addi	s1,s1,-1062 # 8000a7f0 <proc>
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
    80000c46:	5aea8a93          	addi	s5,s5,1454 # 8001c1f0 <tickslock>
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
    80000c94:	5fb040ef          	jal	80005a8e <panic>

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
    80000cb8:	70c50513          	addi	a0,a0,1804 # 8000a3c0 <pid_lock>
    80000cbc:	00e050ef          	jal	80005cca <initlock>
  initlock(&wait_lock, "wait_lock");
    80000cc0:	00006597          	auipc	a1,0x6
    80000cc4:	44858593          	addi	a1,a1,1096 # 80007108 <etext+0x108>
    80000cc8:	00009517          	auipc	a0,0x9
    80000ccc:	71050513          	addi	a0,a0,1808 # 8000a3d8 <wait_lock>
    80000cd0:	7fb040ef          	jal	80005cca <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cd4:	0000a497          	auipc	s1,0xa
    80000cd8:	b1c48493          	addi	s1,s1,-1252 # 8000a7f0 <proc>
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
    80000d0c:	4e8a0a13          	addi	s4,s4,1256 # 8001c1f0 <tickslock>
      initlock(&p->lock, "proc");
    80000d10:	85da                	mv	a1,s6
    80000d12:	8526                	mv	a0,s1
    80000d14:	7b7040ef          	jal	80005cca <initlock>
      p->state = UNUSED;
    80000d18:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000d1c:	415487b3          	sub	a5,s1,s5
    80000d20:	878d                	srai	a5,a5,0x3
    80000d22:	032787b3          	mul	a5,a5,s2
    80000d26:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffcf959>
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
    80000d6e:	68650513          	addi	a0,a0,1670 # 8000a3f0 <cpus>
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
    80000d84:	787040ef          	jal	80005d0a <push_off>
    80000d88:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000d8a:	2781                	sext.w	a5,a5
    80000d8c:	079e                	slli	a5,a5,0x7
    80000d8e:	00009717          	auipc	a4,0x9
    80000d92:	63270713          	addi	a4,a4,1586 # 8000a3c0 <pid_lock>
    80000d96:	97ba                	add	a5,a5,a4
    80000d98:	7b84                	ld	s1,48(a5)
  pop_off();
    80000d9a:	7f5040ef          	jal	80005d8e <pop_off>
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
    80000dba:	028050ef          	jal	80005de2 <release>

  if (first) {
    80000dbe:	00009797          	auipc	a5,0x9
    80000dc2:	5827a783          	lw	a5,1410(a5) # 8000a340 <first.1>
    80000dc6:	cf8d                	beqz	a5,80000e00 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80000dc8:	4505                	li	a0,1
    80000dca:	5fb010ef          	jal	80002bc4 <fsinit>

    first = 0;
    80000dce:	00009797          	auipc	a5,0x9
    80000dd2:	5607a923          	sw	zero,1394(a5) # 8000a340 <first.1>
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
    80000dee:	6d7020ef          	jal	80003cc4 <kexec>
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
    80000e3e:	451040ef          	jal	80005a8e <panic>

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
    80000e52:	57290913          	addi	s2,s2,1394 # 8000a3c0 <pid_lock>
    80000e56:	854a                	mv	a0,s2
    80000e58:	6f3040ef          	jal	80005d4a <acquire>
  pid = nextpid;
    80000e5c:	00009797          	auipc	a5,0x9
    80000e60:	4e878793          	addi	a5,a5,1256 # 8000a344 <nextpid>
    80000e64:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000e66:	0014871b          	addiw	a4,s1,1
    80000e6a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000e6c:	854a                	mv	a0,s2
    80000e6e:	775040ef          	jal	80005de2 <release>
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
    80000faa:	84a48493          	addi	s1,s1,-1974 # 8000a7f0 <proc>
    80000fae:	0001b917          	auipc	s2,0x1b
    80000fb2:	24290913          	addi	s2,s2,578 # 8001c1f0 <tickslock>
    acquire(&p->lock);
    80000fb6:	8526                	mv	a0,s1
    80000fb8:	593040ef          	jal	80005d4a <acquire>
    if(p->state == UNUSED) {
    80000fbc:	4c9c                	lw	a5,24(s1)
    80000fbe:	cb91                	beqz	a5,80000fd2 <allocproc+0x38>
      release(&p->lock);
    80000fc0:	8526                	mv	a0,s1
    80000fc2:	621040ef          	jal	80005de2 <release>
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
    8000103c:	5a7040ef          	jal	80005de2 <release>
    return 0;
    80001040:	84ca                	mv	s1,s2
    80001042:	b7d5                	j	80001026 <allocproc+0x8c>
    freeproc(p);
    80001044:	8526                	mv	a0,s1
    80001046:	f05ff0ef          	jal	80000f4a <freeproc>
    release(&p->lock);
    8000104a:	8526                	mv	a0,s1
    8000104c:	597040ef          	jal	80005de2 <release>
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
    80001068:	30a7be23          	sd	a0,796(a5) # 8000a380 <initproc>
  p->cwd = namei("/");
    8000106c:	00006517          	auipc	a0,0x6
    80001070:	0c450513          	addi	a0,a0,196 # 80007130 <etext+0x130>
    80001074:	072020ef          	jal	800030e6 <namei>
    80001078:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000107c:	478d                	li	a5,3
    8000107e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001080:	8526                	mv	a0,s1
    80001082:	561040ef          	jal	80005de2 <release>
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
    8000112a:	4b9040ef          	jal	80005de2 <release>
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
    8000116a:	516020ef          	jal	80003680 <filedup>
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
    800011c8:	4b8020ef          	jal	80003680 <filedup>
    800011cc:	00a93023          	sd	a0,0(s2)
    800011d0:	b7f5                	j	800011bc <kfork+0xdc>
  np->cwd = idup(p->cwd);
    800011d2:	150a3503          	ld	a0,336(s4)
    800011d6:	6c4010ef          	jal	8000289a <idup>
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
    800011f2:	3f1040ef          	jal	80005de2 <release>
  acquire(&wait_lock);
    800011f6:	00009497          	auipc	s1,0x9
    800011fa:	1e248493          	addi	s1,s1,482 # 8000a3d8 <wait_lock>
    800011fe:	8526                	mv	a0,s1
    80001200:	34b040ef          	jal	80005d4a <acquire>
  np->parent = p;
    80001204:	0349bc23          	sd	s4,56(s3)
  release(&wait_lock);
    80001208:	8526                	mv	a0,s1
    8000120a:	3d9040ef          	jal	80005de2 <release>
  acquire(&np->lock);
    8000120e:	854e                	mv	a0,s3
    80001210:	33b040ef          	jal	80005d4a <acquire>
  np->state = RUNNABLE;
    80001214:	478d                	li	a5,3
    80001216:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000121a:	854e                	mv	a0,s3
    8000121c:	3c7040ef          	jal	80005de2 <release>
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
    8000125c:	16870713          	addi	a4,a4,360 # 8000a3c0 <pid_lock>
    80001260:	975a                	add	a4,a4,s6
    80001262:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001266:	00009717          	auipc	a4,0x9
    8000126a:	19270713          	addi	a4,a4,402 # 8000a3f8 <cpus+0x8>
    8000126e:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001270:	4c11                	li	s8,4
        c->proc = p;
    80001272:	079e                	slli	a5,a5,0x7
    80001274:	00009a17          	auipc	s4,0x9
    80001278:	14ca0a13          	addi	s4,s4,332 # 8000a3c0 <pid_lock>
    8000127c:	9a3e                	add	s4,s4,a5
        found = 1;
    8000127e:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001280:	0001b997          	auipc	s3,0x1b
    80001284:	f7098993          	addi	s3,s3,-144 # 8001c1f0 <tickslock>
    80001288:	a83d                	j	800012c6 <scheduler+0x8e>
      release(&p->lock);
    8000128a:	8526                	mv	a0,s1
    8000128c:	357040ef          	jal	80005de2 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001290:	46848493          	addi	s1,s1,1128
    80001294:	03348563          	beq	s1,s3,800012be <scheduler+0x86>
      acquire(&p->lock);
    80001298:	8526                	mv	a0,s1
    8000129a:	2b1040ef          	jal	80005d4a <acquire>
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
    800012e2:	51248493          	addi	s1,s1,1298 # 8000a7f0 <proc>
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
    800012fe:	1e3040ef          	jal	80005ce0 <holding>
    80001302:	c92d                	beqz	a0,80001374 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001304:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001306:	2781                	sext.w	a5,a5
    80001308:	079e                	slli	a5,a5,0x7
    8000130a:	00009717          	auipc	a4,0x9
    8000130e:	0b670713          	addi	a4,a4,182 # 8000a3c0 <pid_lock>
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
    80001334:	09090913          	addi	s2,s2,144 # 8000a3c0 <pid_lock>
    80001338:	2781                	sext.w	a5,a5
    8000133a:	079e                	slli	a5,a5,0x7
    8000133c:	97ca                	add	a5,a5,s2
    8000133e:	0ac7a983          	lw	s3,172(a5)
    80001342:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001344:	2781                	sext.w	a5,a5
    80001346:	079e                	slli	a5,a5,0x7
    80001348:	00009597          	auipc	a1,0x9
    8000134c:	0b058593          	addi	a1,a1,176 # 8000a3f8 <cpus+0x8>
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
    8000137c:	712040ef          	jal	80005a8e <panic>
    panic("sched locks");
    80001380:	00006517          	auipc	a0,0x6
    80001384:	dc850513          	addi	a0,a0,-568 # 80007148 <etext+0x148>
    80001388:	706040ef          	jal	80005a8e <panic>
    panic("sched RUNNING");
    8000138c:	00006517          	auipc	a0,0x6
    80001390:	dcc50513          	addi	a0,a0,-564 # 80007158 <etext+0x158>
    80001394:	6fa040ef          	jal	80005a8e <panic>
    panic("sched interruptible");
    80001398:	00006517          	auipc	a0,0x6
    8000139c:	dd050513          	addi	a0,a0,-560 # 80007168 <etext+0x168>
    800013a0:	6ee040ef          	jal	80005a8e <panic>

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
    800013b4:	197040ef          	jal	80005d4a <acquire>
  p->state = RUNNABLE;
    800013b8:	478d                	li	a5,3
    800013ba:	cc9c                	sw	a5,24(s1)
  sched();
    800013bc:	f2fff0ef          	jal	800012ea <sched>
  release(&p->lock);
    800013c0:	8526                	mv	a0,s1
    800013c2:	221040ef          	jal	80005de2 <release>
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
    800013e8:	163040ef          	jal	80005d4a <acquire>
  release(lk);
    800013ec:	854a                	mv	a0,s2
    800013ee:	1f5040ef          	jal	80005de2 <release>

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
    80001404:	1df040ef          	jal	80005de2 <release>
  acquire(lk);
    80001408:	854a                	mv	a0,s2
    8000140a:	141040ef          	jal	80005d4a <acquire>
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
    80001434:	3c048493          	addi	s1,s1,960 # 8000a7f0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001438:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000143a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000143c:	0001b917          	auipc	s2,0x1b
    80001440:	db490913          	addi	s2,s2,-588 # 8001c1f0 <tickslock>
    80001444:	a801                	j	80001454 <wakeup+0x38>
      }
      release(&p->lock);
    80001446:	8526                	mv	a0,s1
    80001448:	19b040ef          	jal	80005de2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000144c:	46848493          	addi	s1,s1,1128
    80001450:	03248263          	beq	s1,s2,80001474 <wakeup+0x58>
    if(p != myproc()){
    80001454:	927ff0ef          	jal	80000d7a <myproc>
    80001458:	fea48ae3          	beq	s1,a0,8000144c <wakeup+0x30>
      acquire(&p->lock);
    8000145c:	8526                	mv	a0,s1
    8000145e:	0ed040ef          	jal	80005d4a <acquire>
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
    8000149c:	35848493          	addi	s1,s1,856 # 8000a7f0 <proc>
      pp->parent = initproc;
    800014a0:	00009a17          	auipc	s4,0x9
    800014a4:	ee0a0a13          	addi	s4,s4,-288 # 8000a380 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800014a8:	0001b997          	auipc	s3,0x1b
    800014ac:	d4898993          	addi	s3,s3,-696 # 8001c1f0 <tickslock>
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
    800014f8:	e8c7b783          	ld	a5,-372(a5) # 8000a380 <initproc>
    800014fc:	0d050493          	addi	s1,a0,208
    80001500:	15050913          	addi	s2,a0,336
    80001504:	00a78463          	beq	a5,a0,8000150c <kexit+0x30>
    80001508:	e456                	sd	s5,8(sp)
    8000150a:	a839                	j	80001528 <kexit+0x4c>
    8000150c:	e456                	sd	s5,8(sp)
    panic("init exiting");
    8000150e:	00006517          	auipc	a0,0x6
    80001512:	c7250513          	addi	a0,a0,-910 # 80007180 <etext+0x180>
    80001516:	578040ef          	jal	80005a8e <panic>
      fileclose(f);
    8000151a:	1ac020ef          	jal	800036c6 <fileclose>
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
    8000152e:	58d010ef          	jal	800032ba <begin_op>
  for (int i = 0; i < VMA_COUNT; i ++) {
    80001532:	16898493          	addi	s1,s3,360
    80001536:	46898a93          	addi	s5,s3,1128
    8000153a:	a081                	j	8000157a <kexit+0x9e>
          if (writei(ip, 1, vma->address, file_off, wlen) < 0) {
    8000153c:	00893603          	ld	a2,8(s2)
    80001540:	4585                	li	a1,1
    80001542:	01b010ef          	jal	80002d5c <writei>
      fileclose(vma->file);
    80001546:	02093503          	ld	a0,32(s2)
    8000154a:	17c020ef          	jal	800036c6 <fileclose>
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
    800015ac:	4a6010ef          	jal	80002a52 <iput>
  end_op();
    800015b0:	575010ef          	jal	80003324 <end_op>
  p->cwd = 0;
    800015b4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800015b8:	00009497          	auipc	s1,0x9
    800015bc:	e2048493          	addi	s1,s1,-480 # 8000a3d8 <wait_lock>
    800015c0:	8526                	mv	a0,s1
    800015c2:	788040ef          	jal	80005d4a <acquire>
  reparent(p);
    800015c6:	854e                	mv	a0,s3
    800015c8:	ebfff0ef          	jal	80001486 <reparent>
  wakeup(p->parent);
    800015cc:	0389b503          	ld	a0,56(s3)
    800015d0:	e4dff0ef          	jal	8000141c <wakeup>
  acquire(&p->lock);
    800015d4:	854e                	mv	a0,s3
    800015d6:	774040ef          	jal	80005d4a <acquire>
  p->xstate = status;
    800015da:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800015de:	4795                	li	a5,5
    800015e0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800015e4:	8526                	mv	a0,s1
    800015e6:	7fc040ef          	jal	80005de2 <release>
  sched();
    800015ea:	d01ff0ef          	jal	800012ea <sched>
  panic("zombie exit");
    800015ee:	00006517          	auipc	a0,0x6
    800015f2:	ba250513          	addi	a0,a0,-1118 # 80007190 <etext+0x190>
    800015f6:	498040ef          	jal	80005a8e <panic>

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
    8000160e:	1e648493          	addi	s1,s1,486 # 8000a7f0 <proc>
    80001612:	0001b997          	auipc	s3,0x1b
    80001616:	bde98993          	addi	s3,s3,-1058 # 8001c1f0 <tickslock>
    acquire(&p->lock);
    8000161a:	8526                	mv	a0,s1
    8000161c:	72e040ef          	jal	80005d4a <acquire>
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
    80001628:	7ba040ef          	jal	80005de2 <release>
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
    80001646:	79c040ef          	jal	80005de2 <release>
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
    8000166c:	6de040ef          	jal	80005d4a <acquire>
  p->killed = 1;
    80001670:	4785                	li	a5,1
    80001672:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001674:	8526                	mv	a0,s1
    80001676:	76c040ef          	jal	80005de2 <release>
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
    80001692:	6b8040ef          	jal	80005d4a <acquire>
  k = p->killed;
    80001696:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000169a:	8526                	mv	a0,s1
    8000169c:	746040ef          	jal	80005de2 <release>
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
    800016d2:	d0a50513          	addi	a0,a0,-758 # 8000a3d8 <wait_lock>
    800016d6:	674040ef          	jal	80005d4a <acquire>
    havekids = 0;
    800016da:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800016dc:	4a15                	li	s4,5
        havekids = 1;
    800016de:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800016e0:	0001b997          	auipc	s3,0x1b
    800016e4:	b1098993          	addi	s3,s3,-1264 # 8001c1f0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800016e8:	00009c17          	auipc	s8,0x9
    800016ec:	cf0c0c13          	addi	s8,s8,-784 # 8000a3d8 <wait_lock>
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
    80001716:	6cc040ef          	jal	80005de2 <release>
          release(&wait_lock);
    8000171a:	00009517          	auipc	a0,0x9
    8000171e:	cbe50513          	addi	a0,a0,-834 # 8000a3d8 <wait_lock>
    80001722:	6c0040ef          	jal	80005de2 <release>
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
    80001742:	6a0040ef          	jal	80005de2 <release>
            release(&wait_lock);
    80001746:	00009517          	auipc	a0,0x9
    8000174a:	c9250513          	addi	a0,a0,-878 # 8000a3d8 <wait_lock>
    8000174e:	694040ef          	jal	80005de2 <release>
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
    80001766:	5e4040ef          	jal	80005d4a <acquire>
        if(pp->state == ZOMBIE){
    8000176a:	4c9c                	lw	a5,24(s1)
    8000176c:	f94783e3          	beq	a5,s4,800016f2 <kwait+0x44>
        release(&pp->lock);
    80001770:	8526                	mv	a0,s1
    80001772:	670040ef          	jal	80005de2 <release>
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
    80001792:	06248493          	addi	s1,s1,98 # 8000a7f0 <proc>
    80001796:	b7e1                	j	8000175e <kwait+0xb0>
      release(&wait_lock);
    80001798:	00009517          	auipc	a0,0x9
    8000179c:	c4050513          	addi	a0,a0,-960 # 8000a3d8 <wait_lock>
    800017a0:	642040ef          	jal	80005de2 <release>
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
    8000185a:	74f030ef          	jal	800057a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000185e:	00009497          	auipc	s1,0x9
    80001862:	0ea48493          	addi	s1,s1,234 # 8000a948 <proc+0x158>
    80001866:	0001b917          	auipc	s2,0x1b
    8000186a:	ae290913          	addi	s2,s2,-1310 # 8001c348 <bcache+0x140>
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
    80001898:	711030ef          	jal	800057a8 <printf>
    printf("\n");
    8000189c:	8552                	mv	a0,s4
    8000189e:	70b030ef          	jal	800057a8 <printf>
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
    8000195c:	64d030ef          	jal	800057a8 <printf>

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
    8000197c:	755000ef          	jal	800028d0 <ilock>
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
    8000199c:	60d030ef          	jal	800057a8 <printf>
  if (readi(vma->file->ip, 0, pa, file_off, PGSIZE) < 0) {
    800019a0:	709c                	ld	a5,32(s1)
    800019a2:	6705                	lui	a4,0x1
    800019a4:	86d6                	mv	a3,s5
    800019a6:	8652                	mv	a2,s4
    800019a8:	4581                	li	a1,0
    800019aa:	6f88                	ld	a0,24(a5)
    800019ac:	2b4010ef          	jal	80002c60 <readi>
    800019b0:	06054e63          	bltz	a0,80001a2c <mmap_alloc_page+0x14c>
    iunlock(vma->file->ip);
    kfree((void*)pa);
    return -1;
  }
  iunlock(vma->file->ip);
    800019b4:	709c                	ld	a5,32(s1)
    800019b6:	6f88                	ld	a0,24(a5)
    800019b8:	7c7000ef          	jal	8000297e <iunlock>

  printf("mmap_alloc_page: pid=%d first_byte=0x%x\n", p->pid, ((uchar*)pa)[0]);
    800019bc:	000a4603          	lbu	a2,0(s4)
    800019c0:	0309a583          	lw	a1,48(s3)
    800019c4:	00006517          	auipc	a0,0x6
    800019c8:	8c450513          	addi	a0,a0,-1852 # 80007288 <etext+0x288>
    800019cc:	5dd030ef          	jal	800057a8 <printf>
 
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
    80001a24:	585030ef          	jal	800057a8 <printf>
    return -1;
    80001a28:	557d                	li	a0,-1
    80001a2a:	bfe9                	j	80001a04 <mmap_alloc_page+0x124>
    iunlock(vma->file->ip);
    80001a2c:	709c                	ld	a5,32(s1)
    80001a2e:	6f88                	ld	a0,24(a5)
    80001a30:	74f000ef          	jal	8000297e <iunlock>
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
    80001aca:	72a50513          	addi	a0,a0,1834 # 8001c1f0 <tickslock>
    80001ace:	1fc040ef          	jal	80005cca <initlock>
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
    80001ae4:	1d078793          	addi	a5,a5,464 # 80004cb0 <kernelvec>
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
    80001b9a:	65a48493          	addi	s1,s1,1626 # 8001c1f0 <tickslock>
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	1aa040ef          	jal	80005d4a <acquire>
    ticks++;
    80001ba4:	00008517          	auipc	a0,0x8
    80001ba8:	7e450513          	addi	a0,a0,2020 # 8000a388 <ticks>
    80001bac:	411c                	lw	a5,0(a0)
    80001bae:	2785                	addiw	a5,a5,1
    80001bb0:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001bb2:	86bff0ef          	jal	8000141c <wakeup>
    release(&tickslock);
    80001bb6:	8526                	mv	a0,s1
    80001bb8:	22a040ef          	jal	80005de2 <release>
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
    80001bec:	170030ef          	jal	80004d5c <plic_claim>
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
    80001c06:	058040ef          	jal	80005c5e <uartintr>
    if(irq)
    80001c0a:	a819                	j	80001c20 <devintr+0x60>
      virtio_disk_intr();
    80001c0c:	616030ef          	jal	80005222 <virtio_disk_intr>
    if(irq)
    80001c10:	a801                	j	80001c20 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80001c12:	85a6                	mv	a1,s1
    80001c14:	00005517          	auipc	a0,0x5
    80001c18:	6dc50513          	addi	a0,a0,1756 # 800072f0 <etext+0x2f0>
    80001c1c:	38d030ef          	jal	800057a8 <printf>
      plic_complete(irq);
    80001c20:	8526                	mv	a0,s1
    80001c22:	15a030ef          	jal	80004d7c <plic_complete>
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
    80001c34:	1101                	addi	sp,sp,-32
    80001c36:	ec06                	sd	ra,24(sp)
    80001c38:	e822                	sd	s0,16(sp)
    80001c3a:	e426                	sd	s1,8(sp)
    80001c3c:	e04a                	sd	s2,0(sp)
    80001c3e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c40:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001c44:	1007f793          	andi	a5,a5,256
    80001c48:	eba5                	bnez	a5,80001cb8 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001c4a:	00003797          	auipc	a5,0x3
    80001c4e:	06678793          	addi	a5,a5,102 # 80004cb0 <kernelvec>
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
    80001c6a:	04f70d63          	beq	a4,a5,80001cc4 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80001c6e:	f53ff0ef          	jal	80001bc0 <devintr>
    80001c72:	892a                	mv	s2,a0
    80001c74:	0c051763          	bnez	a0,80001d42 <usertrap+0x10e>
    80001c78:	14202773          	csrr	a4,scause
  } else if (r_scause() == 13 || r_scause() == 15) {
    80001c7c:	47b5                	li	a5,13
    80001c7e:	00f70763          	beq	a4,a5,80001c8c <usertrap+0x58>
    80001c82:	14202773          	csrr	a4,scause
    80001c86:	47bd                	li	a5,15
    80001c88:	08f71663          	bne	a4,a5,80001d14 <usertrap+0xe0>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001c8c:	14302973          	csrr	s2,stval
    pte_t *pte = walk(p->pagetable, va0, 0);
    80001c90:	4601                	li	a2,0
    80001c92:	75fd                	lui	a1,0xfffff
    80001c94:	00b975b3          	and	a1,s2,a1
    80001c98:	68a8                	ld	a0,80(s1)
    80001c9a:	f28fe0ef          	jal	800003c2 <walk>
    if(pte && (*pte & PTE_V)){
    80001c9e:	c501                	beqz	a0,80001ca6 <usertrap+0x72>
    80001ca0:	611c                	ld	a5,0(a0)
    80001ca2:	8b85                	andi	a5,a5,1
    80001ca4:	e7a5                	bnez	a5,80001d0c <usertrap+0xd8>
      if (mmap_alloc_page(p, va) != 0)
    80001ca6:	85ca                	mv	a1,s2
    80001ca8:	8526                	mv	a0,s1
    80001caa:	c37ff0ef          	jal	800018e0 <mmap_alloc_page>
    80001cae:	c915                	beqz	a0,80001ce2 <usertrap+0xae>
        setkilled(p);
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	9afff0ef          	jal	80001660 <setkilled>
    80001cb6:	a035                	j	80001ce2 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80001cb8:	00005517          	auipc	a0,0x5
    80001cbc:	65850513          	addi	a0,a0,1624 # 80007310 <etext+0x310>
    80001cc0:	5cf030ef          	jal	80005a8e <panic>
    if(killed(p))
    80001cc4:	9c1ff0ef          	jal	80001684 <killed>
    80001cc8:	ed15                	bnez	a0,80001d04 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80001cca:	6cb8                	ld	a4,88(s1)
    80001ccc:	6f1c                	ld	a5,24(a4)
    80001cce:	0791                	addi	a5,a5,4
    80001cd0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cd2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001cd6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001cda:	10079073          	csrw	sstatus,a5
    syscall();
    80001cde:	264000ef          	jal	80001f42 <syscall>
  if(killed(p))
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	9a1ff0ef          	jal	80001684 <killed>
    80001ce8:	e135                	bnez	a0,80001d4c <usertrap+0x118>
  prepare_return();
    80001cea:	e09ff0ef          	jal	80001af2 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001cee:	68a8                	ld	a0,80(s1)
    80001cf0:	8131                	srli	a0,a0,0xc
    80001cf2:	57fd                	li	a5,-1
    80001cf4:	17fe                	slli	a5,a5,0x3f
    80001cf6:	8d5d                	or	a0,a0,a5
}
    80001cf8:	60e2                	ld	ra,24(sp)
    80001cfa:	6442                	ld	s0,16(sp)
    80001cfc:	64a2                	ld	s1,8(sp)
    80001cfe:	6902                	ld	s2,0(sp)
    80001d00:	6105                	addi	sp,sp,32
    80001d02:	8082                	ret
      kexit(-1);
    80001d04:	557d                	li	a0,-1
    80001d06:	fd6ff0ef          	jal	800014dc <kexit>
    80001d0a:	b7c1                	j	80001cca <usertrap+0x96>
      setkilled(p);
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	953ff0ef          	jal	80001660 <setkilled>
    80001d12:	bfc1                	j	80001ce2 <usertrap+0xae>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d14:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001d18:	5890                	lw	a2,48(s1)
    80001d1a:	00005517          	auipc	a0,0x5
    80001d1e:	61650513          	addi	a0,a0,1558 # 80007330 <etext+0x330>
    80001d22:	287030ef          	jal	800057a8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d26:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001d2a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001d2e:	00005517          	auipc	a0,0x5
    80001d32:	63250513          	addi	a0,a0,1586 # 80007360 <etext+0x360>
    80001d36:	273030ef          	jal	800057a8 <printf>
    setkilled(p);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	925ff0ef          	jal	80001660 <setkilled>
    80001d40:	b74d                	j	80001ce2 <usertrap+0xae>
  if(killed(p))
    80001d42:	8526                	mv	a0,s1
    80001d44:	941ff0ef          	jal	80001684 <killed>
    80001d48:	c511                	beqz	a0,80001d54 <usertrap+0x120>
    80001d4a:	a011                	j	80001d4e <usertrap+0x11a>
    80001d4c:	4901                	li	s2,0
    kexit(-1);
    80001d4e:	557d                	li	a0,-1
    80001d50:	f8cff0ef          	jal	800014dc <kexit>
  if(which_dev == 2)
    80001d54:	4789                	li	a5,2
    80001d56:	f8f91ae3          	bne	s2,a5,80001cea <usertrap+0xb6>
    yield();
    80001d5a:	e4aff0ef          	jal	800013a4 <yield>
    80001d5e:	b771                	j	80001cea <usertrap+0xb6>

0000000080001d60 <kerneltrap>:
{
    80001d60:	7179                	addi	sp,sp,-48
    80001d62:	f406                	sd	ra,40(sp)
    80001d64:	f022                	sd	s0,32(sp)
    80001d66:	ec26                	sd	s1,24(sp)
    80001d68:	e84a                	sd	s2,16(sp)
    80001d6a:	e44e                	sd	s3,8(sp)
    80001d6c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d6e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d72:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d76:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001d7a:	1004f793          	andi	a5,s1,256
    80001d7e:	c795                	beqz	a5,80001daa <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d80:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001d84:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001d86:	eb85                	bnez	a5,80001db6 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001d88:	e39ff0ef          	jal	80001bc0 <devintr>
    80001d8c:	c91d                	beqz	a0,80001dc2 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001d8e:	4789                	li	a5,2
    80001d90:	04f50a63          	beq	a0,a5,80001de4 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001d94:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d98:	10049073          	csrw	sstatus,s1
}
    80001d9c:	70a2                	ld	ra,40(sp)
    80001d9e:	7402                	ld	s0,32(sp)
    80001da0:	64e2                	ld	s1,24(sp)
    80001da2:	6942                	ld	s2,16(sp)
    80001da4:	69a2                	ld	s3,8(sp)
    80001da6:	6145                	addi	sp,sp,48
    80001da8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001daa:	00005517          	auipc	a0,0x5
    80001dae:	5de50513          	addi	a0,a0,1502 # 80007388 <etext+0x388>
    80001db2:	4dd030ef          	jal	80005a8e <panic>
    panic("kerneltrap: interrupts enabled");
    80001db6:	00005517          	auipc	a0,0x5
    80001dba:	5fa50513          	addi	a0,a0,1530 # 800073b0 <etext+0x3b0>
    80001dbe:	4d1030ef          	jal	80005a8e <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001dc2:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001dc6:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001dca:	85ce                	mv	a1,s3
    80001dcc:	00005517          	auipc	a0,0x5
    80001dd0:	60450513          	addi	a0,a0,1540 # 800073d0 <etext+0x3d0>
    80001dd4:	1d5030ef          	jal	800057a8 <printf>
    panic("kerneltrap");
    80001dd8:	00005517          	auipc	a0,0x5
    80001ddc:	62050513          	addi	a0,a0,1568 # 800073f8 <etext+0x3f8>
    80001de0:	4af030ef          	jal	80005a8e <panic>
  if(which_dev == 2 && myproc() != 0)
    80001de4:	f97fe0ef          	jal	80000d7a <myproc>
    80001de8:	d555                	beqz	a0,80001d94 <kerneltrap+0x34>
    yield();
    80001dea:	dbaff0ef          	jal	800013a4 <yield>
    80001dee:	b75d                	j	80001d94 <kerneltrap+0x34>

0000000080001df0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001df0:	1101                	addi	sp,sp,-32
    80001df2:	ec06                	sd	ra,24(sp)
    80001df4:	e822                	sd	s0,16(sp)
    80001df6:	e426                	sd	s1,8(sp)
    80001df8:	1000                	addi	s0,sp,32
    80001dfa:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dfc:	f7ffe0ef          	jal	80000d7a <myproc>
  switch (n) {
    80001e00:	4795                	li	a5,5
    80001e02:	0497e163          	bltu	a5,s1,80001e44 <argraw+0x54>
    80001e06:	048a                	slli	s1,s1,0x2
    80001e08:	00006717          	auipc	a4,0x6
    80001e0c:	a4870713          	addi	a4,a4,-1464 # 80007850 <states.0+0x30>
    80001e10:	94ba                	add	s1,s1,a4
    80001e12:	409c                	lw	a5,0(s1)
    80001e14:	97ba                	add	a5,a5,a4
    80001e16:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001e18:	6d3c                	ld	a5,88(a0)
    80001e1a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001e1c:	60e2                	ld	ra,24(sp)
    80001e1e:	6442                	ld	s0,16(sp)
    80001e20:	64a2                	ld	s1,8(sp)
    80001e22:	6105                	addi	sp,sp,32
    80001e24:	8082                	ret
    return p->trapframe->a1;
    80001e26:	6d3c                	ld	a5,88(a0)
    80001e28:	7fa8                	ld	a0,120(a5)
    80001e2a:	bfcd                	j	80001e1c <argraw+0x2c>
    return p->trapframe->a2;
    80001e2c:	6d3c                	ld	a5,88(a0)
    80001e2e:	63c8                	ld	a0,128(a5)
    80001e30:	b7f5                	j	80001e1c <argraw+0x2c>
    return p->trapframe->a3;
    80001e32:	6d3c                	ld	a5,88(a0)
    80001e34:	67c8                	ld	a0,136(a5)
    80001e36:	b7dd                	j	80001e1c <argraw+0x2c>
    return p->trapframe->a4;
    80001e38:	6d3c                	ld	a5,88(a0)
    80001e3a:	6bc8                	ld	a0,144(a5)
    80001e3c:	b7c5                	j	80001e1c <argraw+0x2c>
    return p->trapframe->a5;
    80001e3e:	6d3c                	ld	a5,88(a0)
    80001e40:	6fc8                	ld	a0,152(a5)
    80001e42:	bfe9                	j	80001e1c <argraw+0x2c>
  panic("argraw");
    80001e44:	00005517          	auipc	a0,0x5
    80001e48:	5c450513          	addi	a0,a0,1476 # 80007408 <etext+0x408>
    80001e4c:	443030ef          	jal	80005a8e <panic>

0000000080001e50 <fetchaddr>:
{
    80001e50:	1101                	addi	sp,sp,-32
    80001e52:	ec06                	sd	ra,24(sp)
    80001e54:	e822                	sd	s0,16(sp)
    80001e56:	e426                	sd	s1,8(sp)
    80001e58:	e04a                	sd	s2,0(sp)
    80001e5a:	1000                	addi	s0,sp,32
    80001e5c:	84aa                	mv	s1,a0
    80001e5e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001e60:	f1bfe0ef          	jal	80000d7a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001e64:	653c                	ld	a5,72(a0)
    80001e66:	02f4f663          	bgeu	s1,a5,80001e92 <fetchaddr+0x42>
    80001e6a:	00848713          	addi	a4,s1,8
    80001e6e:	02e7e463          	bltu	a5,a4,80001e96 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001e72:	46a1                	li	a3,8
    80001e74:	8626                	mv	a2,s1
    80001e76:	85ca                	mv	a1,s2
    80001e78:	6928                	ld	a0,80(a0)
    80001e7a:	cf9fe0ef          	jal	80000b72 <copyin>
    80001e7e:	00a03533          	snez	a0,a0
    80001e82:	40a00533          	neg	a0,a0
}
    80001e86:	60e2                	ld	ra,24(sp)
    80001e88:	6442                	ld	s0,16(sp)
    80001e8a:	64a2                	ld	s1,8(sp)
    80001e8c:	6902                	ld	s2,0(sp)
    80001e8e:	6105                	addi	sp,sp,32
    80001e90:	8082                	ret
    return -1;
    80001e92:	557d                	li	a0,-1
    80001e94:	bfcd                	j	80001e86 <fetchaddr+0x36>
    80001e96:	557d                	li	a0,-1
    80001e98:	b7fd                	j	80001e86 <fetchaddr+0x36>

0000000080001e9a <fetchstr>:
{
    80001e9a:	7179                	addi	sp,sp,-48
    80001e9c:	f406                	sd	ra,40(sp)
    80001e9e:	f022                	sd	s0,32(sp)
    80001ea0:	ec26                	sd	s1,24(sp)
    80001ea2:	e84a                	sd	s2,16(sp)
    80001ea4:	e44e                	sd	s3,8(sp)
    80001ea6:	1800                	addi	s0,sp,48
    80001ea8:	892a                	mv	s2,a0
    80001eaa:	84ae                	mv	s1,a1
    80001eac:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001eae:	ecdfe0ef          	jal	80000d7a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001eb2:	86ce                	mv	a3,s3
    80001eb4:	864a                	mv	a2,s2
    80001eb6:	85a6                	mv	a1,s1
    80001eb8:	6928                	ld	a0,80(a0)
    80001eba:	a7bfe0ef          	jal	80000934 <copyinstr>
    80001ebe:	00054c63          	bltz	a0,80001ed6 <fetchstr+0x3c>
  return strlen(buf);
    80001ec2:	8526                	mv	a0,s1
    80001ec4:	bfafe0ef          	jal	800002be <strlen>
}
    80001ec8:	70a2                	ld	ra,40(sp)
    80001eca:	7402                	ld	s0,32(sp)
    80001ecc:	64e2                	ld	s1,24(sp)
    80001ece:	6942                	ld	s2,16(sp)
    80001ed0:	69a2                	ld	s3,8(sp)
    80001ed2:	6145                	addi	sp,sp,48
    80001ed4:	8082                	ret
    return -1;
    80001ed6:	557d                	li	a0,-1
    80001ed8:	bfc5                	j	80001ec8 <fetchstr+0x2e>

0000000080001eda <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001eda:	1101                	addi	sp,sp,-32
    80001edc:	ec06                	sd	ra,24(sp)
    80001ede:	e822                	sd	s0,16(sp)
    80001ee0:	e426                	sd	s1,8(sp)
    80001ee2:	1000                	addi	s0,sp,32
    80001ee4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001ee6:	f0bff0ef          	jal	80001df0 <argraw>
    80001eea:	c088                	sw	a0,0(s1)
}
    80001eec:	60e2                	ld	ra,24(sp)
    80001eee:	6442                	ld	s0,16(sp)
    80001ef0:	64a2                	ld	s1,8(sp)
    80001ef2:	6105                	addi	sp,sp,32
    80001ef4:	8082                	ret

0000000080001ef6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001ef6:	1101                	addi	sp,sp,-32
    80001ef8:	ec06                	sd	ra,24(sp)
    80001efa:	e822                	sd	s0,16(sp)
    80001efc:	e426                	sd	s1,8(sp)
    80001efe:	1000                	addi	s0,sp,32
    80001f00:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001f02:	eefff0ef          	jal	80001df0 <argraw>
    80001f06:	e088                	sd	a0,0(s1)
}
    80001f08:	60e2                	ld	ra,24(sp)
    80001f0a:	6442                	ld	s0,16(sp)
    80001f0c:	64a2                	ld	s1,8(sp)
    80001f0e:	6105                	addi	sp,sp,32
    80001f10:	8082                	ret

0000000080001f12 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001f12:	7179                	addi	sp,sp,-48
    80001f14:	f406                	sd	ra,40(sp)
    80001f16:	f022                	sd	s0,32(sp)
    80001f18:	ec26                	sd	s1,24(sp)
    80001f1a:	e84a                	sd	s2,16(sp)
    80001f1c:	1800                	addi	s0,sp,48
    80001f1e:	84ae                	mv	s1,a1
    80001f20:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001f22:	fd840593          	addi	a1,s0,-40
    80001f26:	fd1ff0ef          	jal	80001ef6 <argaddr>
  return fetchstr(addr, buf, max);
    80001f2a:	864a                	mv	a2,s2
    80001f2c:	85a6                	mv	a1,s1
    80001f2e:	fd843503          	ld	a0,-40(s0)
    80001f32:	f69ff0ef          	jal	80001e9a <fetchstr>
}
    80001f36:	70a2                	ld	ra,40(sp)
    80001f38:	7402                	ld	s0,32(sp)
    80001f3a:	64e2                	ld	s1,24(sp)
    80001f3c:	6942                	ld	s2,16(sp)
    80001f3e:	6145                	addi	sp,sp,48
    80001f40:	8082                	ret

0000000080001f42 <syscall>:
[SYS_munmap]  sys_munmap,
};

void
syscall(void)
{
    80001f42:	1101                	addi	sp,sp,-32
    80001f44:	ec06                	sd	ra,24(sp)
    80001f46:	e822                	sd	s0,16(sp)
    80001f48:	e426                	sd	s1,8(sp)
    80001f4a:	e04a                	sd	s2,0(sp)
    80001f4c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001f4e:	e2dfe0ef          	jal	80000d7a <myproc>
    80001f52:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001f54:	05853903          	ld	s2,88(a0)
    80001f58:	0a893783          	ld	a5,168(s2)
    80001f5c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001f60:	37fd                	addiw	a5,a5,-1
    80001f62:	4759                	li	a4,22
    80001f64:	00f76f63          	bltu	a4,a5,80001f82 <syscall+0x40>
    80001f68:	00369713          	slli	a4,a3,0x3
    80001f6c:	00006797          	auipc	a5,0x6
    80001f70:	8fc78793          	addi	a5,a5,-1796 # 80007868 <syscalls>
    80001f74:	97ba                	add	a5,a5,a4
    80001f76:	639c                	ld	a5,0(a5)
    80001f78:	c789                	beqz	a5,80001f82 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001f7a:	9782                	jalr	a5
    80001f7c:	06a93823          	sd	a0,112(s2)
    80001f80:	a829                	j	80001f9a <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001f82:	15848613          	addi	a2,s1,344
    80001f86:	588c                	lw	a1,48(s1)
    80001f88:	00005517          	auipc	a0,0x5
    80001f8c:	48850513          	addi	a0,a0,1160 # 80007410 <etext+0x410>
    80001f90:	019030ef          	jal	800057a8 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001f94:	6cbc                	ld	a5,88(s1)
    80001f96:	577d                	li	a4,-1
    80001f98:	fbb8                	sd	a4,112(a5)
  }
}
    80001f9a:	60e2                	ld	ra,24(sp)
    80001f9c:	6442                	ld	s0,16(sp)
    80001f9e:	64a2                	ld	s1,8(sp)
    80001fa0:	6902                	ld	s2,0(sp)
    80001fa2:	6105                	addi	sp,sp,32
    80001fa4:	8082                	ret

0000000080001fa6 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80001fa6:	1101                	addi	sp,sp,-32
    80001fa8:	ec06                	sd	ra,24(sp)
    80001faa:	e822                	sd	s0,16(sp)
    80001fac:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001fae:	fec40593          	addi	a1,s0,-20
    80001fb2:	4501                	li	a0,0
    80001fb4:	f27ff0ef          	jal	80001eda <argint>
  kexit(n);
    80001fb8:	fec42503          	lw	a0,-20(s0)
    80001fbc:	d20ff0ef          	jal	800014dc <kexit>
  return 0;  // not reached
}
    80001fc0:	4501                	li	a0,0
    80001fc2:	60e2                	ld	ra,24(sp)
    80001fc4:	6442                	ld	s0,16(sp)
    80001fc6:	6105                	addi	sp,sp,32
    80001fc8:	8082                	ret

0000000080001fca <sys_getpid>:

uint64
sys_getpid(void)
{
    80001fca:	1141                	addi	sp,sp,-16
    80001fcc:	e406                	sd	ra,8(sp)
    80001fce:	e022                	sd	s0,0(sp)
    80001fd0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001fd2:	da9fe0ef          	jal	80000d7a <myproc>
}
    80001fd6:	5908                	lw	a0,48(a0)
    80001fd8:	60a2                	ld	ra,8(sp)
    80001fda:	6402                	ld	s0,0(sp)
    80001fdc:	0141                	addi	sp,sp,16
    80001fde:	8082                	ret

0000000080001fe0 <sys_fork>:

uint64
sys_fork(void)
{
    80001fe0:	1141                	addi	sp,sp,-16
    80001fe2:	e406                	sd	ra,8(sp)
    80001fe4:	e022                	sd	s0,0(sp)
    80001fe6:	0800                	addi	s0,sp,16
  return kfork();
    80001fe8:	8f8ff0ef          	jal	800010e0 <kfork>
}
    80001fec:	60a2                	ld	ra,8(sp)
    80001fee:	6402                	ld	s0,0(sp)
    80001ff0:	0141                	addi	sp,sp,16
    80001ff2:	8082                	ret

0000000080001ff4 <sys_wait>:

uint64
sys_wait(void)
{
    80001ff4:	1101                	addi	sp,sp,-32
    80001ff6:	ec06                	sd	ra,24(sp)
    80001ff8:	e822                	sd	s0,16(sp)
    80001ffa:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001ffc:	fe840593          	addi	a1,s0,-24
    80002000:	4501                	li	a0,0
    80002002:	ef5ff0ef          	jal	80001ef6 <argaddr>
  return kwait(p);
    80002006:	fe843503          	ld	a0,-24(s0)
    8000200a:	ea4ff0ef          	jal	800016ae <kwait>
}
    8000200e:	60e2                	ld	ra,24(sp)
    80002010:	6442                	ld	s0,16(sp)
    80002012:	6105                	addi	sp,sp,32
    80002014:	8082                	ret

0000000080002016 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002016:	7179                	addi	sp,sp,-48
    80002018:	f406                	sd	ra,40(sp)
    8000201a:	f022                	sd	s0,32(sp)
    8000201c:	ec26                	sd	s1,24(sp)
    8000201e:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002020:	fd840593          	addi	a1,s0,-40
    80002024:	4501                	li	a0,0
    80002026:	eb5ff0ef          	jal	80001eda <argint>
  argint(1, &t);
    8000202a:	fdc40593          	addi	a1,s0,-36
    8000202e:	4505                	li	a0,1
    80002030:	eabff0ef          	jal	80001eda <argint>
  addr = myproc()->sz;
    80002034:	d47fe0ef          	jal	80000d7a <myproc>
    80002038:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    8000203a:	fdc42703          	lw	a4,-36(s0)
    8000203e:	4785                	li	a5,1
    80002040:	02f70163          	beq	a4,a5,80002062 <sys_sbrk+0x4c>
    80002044:	fd842783          	lw	a5,-40(s0)
    80002048:	0007cd63          	bltz	a5,80002062 <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    8000204c:	97a6                	add	a5,a5,s1
    8000204e:	0297e863          	bltu	a5,s1,8000207e <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    80002052:	d29fe0ef          	jal	80000d7a <myproc>
    80002056:	fd842703          	lw	a4,-40(s0)
    8000205a:	653c                	ld	a5,72(a0)
    8000205c:	97ba                	add	a5,a5,a4
    8000205e:	e53c                	sd	a5,72(a0)
    80002060:	a039                	j	8000206e <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80002062:	fd842503          	lw	a0,-40(s0)
    80002066:	82aff0ef          	jal	80001090 <growproc>
    8000206a:	00054863          	bltz	a0,8000207a <sys_sbrk+0x64>
  }
  return addr;
}
    8000206e:	8526                	mv	a0,s1
    80002070:	70a2                	ld	ra,40(sp)
    80002072:	7402                	ld	s0,32(sp)
    80002074:	64e2                	ld	s1,24(sp)
    80002076:	6145                	addi	sp,sp,48
    80002078:	8082                	ret
      return -1;
    8000207a:	54fd                	li	s1,-1
    8000207c:	bfcd                	j	8000206e <sys_sbrk+0x58>
      return -1;
    8000207e:	54fd                	li	s1,-1
    80002080:	b7fd                	j	8000206e <sys_sbrk+0x58>

0000000080002082 <sys_pause>:

uint64
sys_pause(void)
{
    80002082:	7139                	addi	sp,sp,-64
    80002084:	fc06                	sd	ra,56(sp)
    80002086:	f822                	sd	s0,48(sp)
    80002088:	f04a                	sd	s2,32(sp)
    8000208a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000208c:	fcc40593          	addi	a1,s0,-52
    80002090:	4501                	li	a0,0
    80002092:	e49ff0ef          	jal	80001eda <argint>
  if(n < 0)
    80002096:	fcc42783          	lw	a5,-52(s0)
    8000209a:	0607c763          	bltz	a5,80002108 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    8000209e:	0001a517          	auipc	a0,0x1a
    800020a2:	15250513          	addi	a0,a0,338 # 8001c1f0 <tickslock>
    800020a6:	4a5030ef          	jal	80005d4a <acquire>
  ticks0 = ticks;
    800020aa:	00008917          	auipc	s2,0x8
    800020ae:	2de92903          	lw	s2,734(s2) # 8000a388 <ticks>
  while(ticks - ticks0 < n){
    800020b2:	fcc42783          	lw	a5,-52(s0)
    800020b6:	cf8d                	beqz	a5,800020f0 <sys_pause+0x6e>
    800020b8:	f426                	sd	s1,40(sp)
    800020ba:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800020bc:	0001a997          	auipc	s3,0x1a
    800020c0:	13498993          	addi	s3,s3,308 # 8001c1f0 <tickslock>
    800020c4:	00008497          	auipc	s1,0x8
    800020c8:	2c448493          	addi	s1,s1,708 # 8000a388 <ticks>
    if(killed(myproc())){
    800020cc:	caffe0ef          	jal	80000d7a <myproc>
    800020d0:	db4ff0ef          	jal	80001684 <killed>
    800020d4:	ed0d                	bnez	a0,8000210e <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    800020d6:	85ce                	mv	a1,s3
    800020d8:	8526                	mv	a0,s1
    800020da:	af6ff0ef          	jal	800013d0 <sleep>
  while(ticks - ticks0 < n){
    800020de:	409c                	lw	a5,0(s1)
    800020e0:	412787bb          	subw	a5,a5,s2
    800020e4:	fcc42703          	lw	a4,-52(s0)
    800020e8:	fee7e2e3          	bltu	a5,a4,800020cc <sys_pause+0x4a>
    800020ec:	74a2                	ld	s1,40(sp)
    800020ee:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800020f0:	0001a517          	auipc	a0,0x1a
    800020f4:	10050513          	addi	a0,a0,256 # 8001c1f0 <tickslock>
    800020f8:	4eb030ef          	jal	80005de2 <release>
  return 0;
    800020fc:	4501                	li	a0,0
}
    800020fe:	70e2                	ld	ra,56(sp)
    80002100:	7442                	ld	s0,48(sp)
    80002102:	7902                	ld	s2,32(sp)
    80002104:	6121                	addi	sp,sp,64
    80002106:	8082                	ret
    n = 0;
    80002108:	fc042623          	sw	zero,-52(s0)
    8000210c:	bf49                	j	8000209e <sys_pause+0x1c>
      release(&tickslock);
    8000210e:	0001a517          	auipc	a0,0x1a
    80002112:	0e250513          	addi	a0,a0,226 # 8001c1f0 <tickslock>
    80002116:	4cd030ef          	jal	80005de2 <release>
      return -1;
    8000211a:	557d                	li	a0,-1
    8000211c:	74a2                	ld	s1,40(sp)
    8000211e:	69e2                	ld	s3,24(sp)
    80002120:	bff9                	j	800020fe <sys_pause+0x7c>

0000000080002122 <sys_kill>:

uint64
sys_kill(void)
{
    80002122:	1101                	addi	sp,sp,-32
    80002124:	ec06                	sd	ra,24(sp)
    80002126:	e822                	sd	s0,16(sp)
    80002128:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000212a:	fec40593          	addi	a1,s0,-20
    8000212e:	4501                	li	a0,0
    80002130:	dabff0ef          	jal	80001eda <argint>
  return kkill(pid);
    80002134:	fec42503          	lw	a0,-20(s0)
    80002138:	cc2ff0ef          	jal	800015fa <kkill>
}
    8000213c:	60e2                	ld	ra,24(sp)
    8000213e:	6442                	ld	s0,16(sp)
    80002140:	6105                	addi	sp,sp,32
    80002142:	8082                	ret

0000000080002144 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002144:	1101                	addi	sp,sp,-32
    80002146:	ec06                	sd	ra,24(sp)
    80002148:	e822                	sd	s0,16(sp)
    8000214a:	e426                	sd	s1,8(sp)
    8000214c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000214e:	0001a517          	auipc	a0,0x1a
    80002152:	0a250513          	addi	a0,a0,162 # 8001c1f0 <tickslock>
    80002156:	3f5030ef          	jal	80005d4a <acquire>
  xticks = ticks;
    8000215a:	00008497          	auipc	s1,0x8
    8000215e:	22e4a483          	lw	s1,558(s1) # 8000a388 <ticks>
  release(&tickslock);
    80002162:	0001a517          	auipc	a0,0x1a
    80002166:	08e50513          	addi	a0,a0,142 # 8001c1f0 <tickslock>
    8000216a:	479030ef          	jal	80005de2 <release>
  return xticks;
}
    8000216e:	02049513          	slli	a0,s1,0x20
    80002172:	9101                	srli	a0,a0,0x20
    80002174:	60e2                	ld	ra,24(sp)
    80002176:	6442                	ld	s0,16(sp)
    80002178:	64a2                	ld	s1,8(sp)
    8000217a:	6105                	addi	sp,sp,32
    8000217c:	8082                	ret

000000008000217e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000217e:	7179                	addi	sp,sp,-48
    80002180:	f406                	sd	ra,40(sp)
    80002182:	f022                	sd	s0,32(sp)
    80002184:	ec26                	sd	s1,24(sp)
    80002186:	e84a                	sd	s2,16(sp)
    80002188:	e44e                	sd	s3,8(sp)
    8000218a:	e052                	sd	s4,0(sp)
    8000218c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000218e:	00005597          	auipc	a1,0x5
    80002192:	2a258593          	addi	a1,a1,674 # 80007430 <etext+0x430>
    80002196:	0001a517          	auipc	a0,0x1a
    8000219a:	07250513          	addi	a0,a0,114 # 8001c208 <bcache>
    8000219e:	32d030ef          	jal	80005cca <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800021a2:	00022797          	auipc	a5,0x22
    800021a6:	06678793          	addi	a5,a5,102 # 80024208 <bcache+0x8000>
    800021aa:	00022717          	auipc	a4,0x22
    800021ae:	2c670713          	addi	a4,a4,710 # 80024470 <bcache+0x8268>
    800021b2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800021b6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800021ba:	0001a497          	auipc	s1,0x1a
    800021be:	06648493          	addi	s1,s1,102 # 8001c220 <bcache+0x18>
    b->next = bcache.head.next;
    800021c2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800021c4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800021c6:	00005a17          	auipc	s4,0x5
    800021ca:	272a0a13          	addi	s4,s4,626 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    800021ce:	2b893783          	ld	a5,696(s2)
    800021d2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800021d4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800021d8:	85d2                	mv	a1,s4
    800021da:	01048513          	addi	a0,s1,16
    800021de:	322010ef          	jal	80003500 <initsleeplock>
    bcache.head.next->prev = b;
    800021e2:	2b893783          	ld	a5,696(s2)
    800021e6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800021e8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800021ec:	45848493          	addi	s1,s1,1112
    800021f0:	fd349fe3          	bne	s1,s3,800021ce <binit+0x50>
  }
}
    800021f4:	70a2                	ld	ra,40(sp)
    800021f6:	7402                	ld	s0,32(sp)
    800021f8:	64e2                	ld	s1,24(sp)
    800021fa:	6942                	ld	s2,16(sp)
    800021fc:	69a2                	ld	s3,8(sp)
    800021fe:	6a02                	ld	s4,0(sp)
    80002200:	6145                	addi	sp,sp,48
    80002202:	8082                	ret

0000000080002204 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002204:	7179                	addi	sp,sp,-48
    80002206:	f406                	sd	ra,40(sp)
    80002208:	f022                	sd	s0,32(sp)
    8000220a:	ec26                	sd	s1,24(sp)
    8000220c:	e84a                	sd	s2,16(sp)
    8000220e:	e44e                	sd	s3,8(sp)
    80002210:	1800                	addi	s0,sp,48
    80002212:	892a                	mv	s2,a0
    80002214:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002216:	0001a517          	auipc	a0,0x1a
    8000221a:	ff250513          	addi	a0,a0,-14 # 8001c208 <bcache>
    8000221e:	32d030ef          	jal	80005d4a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002222:	00022497          	auipc	s1,0x22
    80002226:	29e4b483          	ld	s1,670(s1) # 800244c0 <bcache+0x82b8>
    8000222a:	00022797          	auipc	a5,0x22
    8000222e:	24678793          	addi	a5,a5,582 # 80024470 <bcache+0x8268>
    80002232:	02f48b63          	beq	s1,a5,80002268 <bread+0x64>
    80002236:	873e                	mv	a4,a5
    80002238:	a021                	j	80002240 <bread+0x3c>
    8000223a:	68a4                	ld	s1,80(s1)
    8000223c:	02e48663          	beq	s1,a4,80002268 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002240:	449c                	lw	a5,8(s1)
    80002242:	ff279ce3          	bne	a5,s2,8000223a <bread+0x36>
    80002246:	44dc                	lw	a5,12(s1)
    80002248:	ff3799e3          	bne	a5,s3,8000223a <bread+0x36>
      b->refcnt++;
    8000224c:	40bc                	lw	a5,64(s1)
    8000224e:	2785                	addiw	a5,a5,1
    80002250:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002252:	0001a517          	auipc	a0,0x1a
    80002256:	fb650513          	addi	a0,a0,-74 # 8001c208 <bcache>
    8000225a:	389030ef          	jal	80005de2 <release>
      acquiresleep(&b->lock);
    8000225e:	01048513          	addi	a0,s1,16
    80002262:	2d4010ef          	jal	80003536 <acquiresleep>
      return b;
    80002266:	a889                	j	800022b8 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002268:	00022497          	auipc	s1,0x22
    8000226c:	2504b483          	ld	s1,592(s1) # 800244b8 <bcache+0x82b0>
    80002270:	00022797          	auipc	a5,0x22
    80002274:	20078793          	addi	a5,a5,512 # 80024470 <bcache+0x8268>
    80002278:	00f48863          	beq	s1,a5,80002288 <bread+0x84>
    8000227c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000227e:	40bc                	lw	a5,64(s1)
    80002280:	cb91                	beqz	a5,80002294 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002282:	64a4                	ld	s1,72(s1)
    80002284:	fee49de3          	bne	s1,a4,8000227e <bread+0x7a>
  panic("bget: no buffers");
    80002288:	00005517          	auipc	a0,0x5
    8000228c:	1b850513          	addi	a0,a0,440 # 80007440 <etext+0x440>
    80002290:	7fe030ef          	jal	80005a8e <panic>
      b->dev = dev;
    80002294:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002298:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000229c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800022a0:	4785                	li	a5,1
    800022a2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800022a4:	0001a517          	auipc	a0,0x1a
    800022a8:	f6450513          	addi	a0,a0,-156 # 8001c208 <bcache>
    800022ac:	337030ef          	jal	80005de2 <release>
      acquiresleep(&b->lock);
    800022b0:	01048513          	addi	a0,s1,16
    800022b4:	282010ef          	jal	80003536 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800022b8:	409c                	lw	a5,0(s1)
    800022ba:	cb89                	beqz	a5,800022cc <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800022bc:	8526                	mv	a0,s1
    800022be:	70a2                	ld	ra,40(sp)
    800022c0:	7402                	ld	s0,32(sp)
    800022c2:	64e2                	ld	s1,24(sp)
    800022c4:	6942                	ld	s2,16(sp)
    800022c6:	69a2                	ld	s3,8(sp)
    800022c8:	6145                	addi	sp,sp,48
    800022ca:	8082                	ret
    virtio_disk_rw(b, 0);
    800022cc:	4581                	li	a1,0
    800022ce:	8526                	mv	a0,s1
    800022d0:	541020ef          	jal	80005010 <virtio_disk_rw>
    b->valid = 1;
    800022d4:	4785                	li	a5,1
    800022d6:	c09c                	sw	a5,0(s1)
  return b;
    800022d8:	b7d5                	j	800022bc <bread+0xb8>

00000000800022da <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800022da:	1101                	addi	sp,sp,-32
    800022dc:	ec06                	sd	ra,24(sp)
    800022de:	e822                	sd	s0,16(sp)
    800022e0:	e426                	sd	s1,8(sp)
    800022e2:	1000                	addi	s0,sp,32
    800022e4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800022e6:	0541                	addi	a0,a0,16
    800022e8:	2cc010ef          	jal	800035b4 <holdingsleep>
    800022ec:	c911                	beqz	a0,80002300 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800022ee:	4585                	li	a1,1
    800022f0:	8526                	mv	a0,s1
    800022f2:	51f020ef          	jal	80005010 <virtio_disk_rw>
}
    800022f6:	60e2                	ld	ra,24(sp)
    800022f8:	6442                	ld	s0,16(sp)
    800022fa:	64a2                	ld	s1,8(sp)
    800022fc:	6105                	addi	sp,sp,32
    800022fe:	8082                	ret
    panic("bwrite");
    80002300:	00005517          	auipc	a0,0x5
    80002304:	15850513          	addi	a0,a0,344 # 80007458 <etext+0x458>
    80002308:	786030ef          	jal	80005a8e <panic>

000000008000230c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000230c:	1101                	addi	sp,sp,-32
    8000230e:	ec06                	sd	ra,24(sp)
    80002310:	e822                	sd	s0,16(sp)
    80002312:	e426                	sd	s1,8(sp)
    80002314:	e04a                	sd	s2,0(sp)
    80002316:	1000                	addi	s0,sp,32
    80002318:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000231a:	01050913          	addi	s2,a0,16
    8000231e:	854a                	mv	a0,s2
    80002320:	294010ef          	jal	800035b4 <holdingsleep>
    80002324:	c135                	beqz	a0,80002388 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002326:	854a                	mv	a0,s2
    80002328:	254010ef          	jal	8000357c <releasesleep>

  acquire(&bcache.lock);
    8000232c:	0001a517          	auipc	a0,0x1a
    80002330:	edc50513          	addi	a0,a0,-292 # 8001c208 <bcache>
    80002334:	217030ef          	jal	80005d4a <acquire>
  b->refcnt--;
    80002338:	40bc                	lw	a5,64(s1)
    8000233a:	37fd                	addiw	a5,a5,-1
    8000233c:	0007871b          	sext.w	a4,a5
    80002340:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002342:	e71d                	bnez	a4,80002370 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002344:	68b8                	ld	a4,80(s1)
    80002346:	64bc                	ld	a5,72(s1)
    80002348:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000234a:	68b8                	ld	a4,80(s1)
    8000234c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000234e:	00022797          	auipc	a5,0x22
    80002352:	eba78793          	addi	a5,a5,-326 # 80024208 <bcache+0x8000>
    80002356:	2b87b703          	ld	a4,696(a5)
    8000235a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000235c:	00022717          	auipc	a4,0x22
    80002360:	11470713          	addi	a4,a4,276 # 80024470 <bcache+0x8268>
    80002364:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002366:	2b87b703          	ld	a4,696(a5)
    8000236a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000236c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002370:	0001a517          	auipc	a0,0x1a
    80002374:	e9850513          	addi	a0,a0,-360 # 8001c208 <bcache>
    80002378:	26b030ef          	jal	80005de2 <release>
}
    8000237c:	60e2                	ld	ra,24(sp)
    8000237e:	6442                	ld	s0,16(sp)
    80002380:	64a2                	ld	s1,8(sp)
    80002382:	6902                	ld	s2,0(sp)
    80002384:	6105                	addi	sp,sp,32
    80002386:	8082                	ret
    panic("brelse");
    80002388:	00005517          	auipc	a0,0x5
    8000238c:	0d850513          	addi	a0,a0,216 # 80007460 <etext+0x460>
    80002390:	6fe030ef          	jal	80005a8e <panic>

0000000080002394 <bpin>:

void
bpin(struct buf *b) {
    80002394:	1101                	addi	sp,sp,-32
    80002396:	ec06                	sd	ra,24(sp)
    80002398:	e822                	sd	s0,16(sp)
    8000239a:	e426                	sd	s1,8(sp)
    8000239c:	1000                	addi	s0,sp,32
    8000239e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800023a0:	0001a517          	auipc	a0,0x1a
    800023a4:	e6850513          	addi	a0,a0,-408 # 8001c208 <bcache>
    800023a8:	1a3030ef          	jal	80005d4a <acquire>
  b->refcnt++;
    800023ac:	40bc                	lw	a5,64(s1)
    800023ae:	2785                	addiw	a5,a5,1
    800023b0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800023b2:	0001a517          	auipc	a0,0x1a
    800023b6:	e5650513          	addi	a0,a0,-426 # 8001c208 <bcache>
    800023ba:	229030ef          	jal	80005de2 <release>
}
    800023be:	60e2                	ld	ra,24(sp)
    800023c0:	6442                	ld	s0,16(sp)
    800023c2:	64a2                	ld	s1,8(sp)
    800023c4:	6105                	addi	sp,sp,32
    800023c6:	8082                	ret

00000000800023c8 <bunpin>:

void
bunpin(struct buf *b) {
    800023c8:	1101                	addi	sp,sp,-32
    800023ca:	ec06                	sd	ra,24(sp)
    800023cc:	e822                	sd	s0,16(sp)
    800023ce:	e426                	sd	s1,8(sp)
    800023d0:	1000                	addi	s0,sp,32
    800023d2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800023d4:	0001a517          	auipc	a0,0x1a
    800023d8:	e3450513          	addi	a0,a0,-460 # 8001c208 <bcache>
    800023dc:	16f030ef          	jal	80005d4a <acquire>
  b->refcnt--;
    800023e0:	40bc                	lw	a5,64(s1)
    800023e2:	37fd                	addiw	a5,a5,-1
    800023e4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800023e6:	0001a517          	auipc	a0,0x1a
    800023ea:	e2250513          	addi	a0,a0,-478 # 8001c208 <bcache>
    800023ee:	1f5030ef          	jal	80005de2 <release>
}
    800023f2:	60e2                	ld	ra,24(sp)
    800023f4:	6442                	ld	s0,16(sp)
    800023f6:	64a2                	ld	s1,8(sp)
    800023f8:	6105                	addi	sp,sp,32
    800023fa:	8082                	ret

00000000800023fc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800023fc:	1101                	addi	sp,sp,-32
    800023fe:	ec06                	sd	ra,24(sp)
    80002400:	e822                	sd	s0,16(sp)
    80002402:	e426                	sd	s1,8(sp)
    80002404:	e04a                	sd	s2,0(sp)
    80002406:	1000                	addi	s0,sp,32
    80002408:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000240a:	00d5d59b          	srliw	a1,a1,0xd
    8000240e:	00022797          	auipc	a5,0x22
    80002412:	4d67a783          	lw	a5,1238(a5) # 800248e4 <sb+0x1c>
    80002416:	9dbd                	addw	a1,a1,a5
    80002418:	dedff0ef          	jal	80002204 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000241c:	0074f713          	andi	a4,s1,7
    80002420:	4785                	li	a5,1
    80002422:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002426:	14ce                	slli	s1,s1,0x33
    80002428:	90d9                	srli	s1,s1,0x36
    8000242a:	00950733          	add	a4,a0,s1
    8000242e:	05874703          	lbu	a4,88(a4)
    80002432:	00e7f6b3          	and	a3,a5,a4
    80002436:	c29d                	beqz	a3,8000245c <bfree+0x60>
    80002438:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000243a:	94aa                	add	s1,s1,a0
    8000243c:	fff7c793          	not	a5,a5
    80002440:	8f7d                	and	a4,a4,a5
    80002442:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002446:	7f9000ef          	jal	8000343e <log_write>
  brelse(bp);
    8000244a:	854a                	mv	a0,s2
    8000244c:	ec1ff0ef          	jal	8000230c <brelse>
}
    80002450:	60e2                	ld	ra,24(sp)
    80002452:	6442                	ld	s0,16(sp)
    80002454:	64a2                	ld	s1,8(sp)
    80002456:	6902                	ld	s2,0(sp)
    80002458:	6105                	addi	sp,sp,32
    8000245a:	8082                	ret
    panic("freeing free block");
    8000245c:	00005517          	auipc	a0,0x5
    80002460:	00c50513          	addi	a0,a0,12 # 80007468 <etext+0x468>
    80002464:	62a030ef          	jal	80005a8e <panic>

0000000080002468 <balloc>:
{
    80002468:	711d                	addi	sp,sp,-96
    8000246a:	ec86                	sd	ra,88(sp)
    8000246c:	e8a2                	sd	s0,80(sp)
    8000246e:	e4a6                	sd	s1,72(sp)
    80002470:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002472:	00022797          	auipc	a5,0x22
    80002476:	45a7a783          	lw	a5,1114(a5) # 800248cc <sb+0x4>
    8000247a:	0e078f63          	beqz	a5,80002578 <balloc+0x110>
    8000247e:	e0ca                	sd	s2,64(sp)
    80002480:	fc4e                	sd	s3,56(sp)
    80002482:	f852                	sd	s4,48(sp)
    80002484:	f456                	sd	s5,40(sp)
    80002486:	f05a                	sd	s6,32(sp)
    80002488:	ec5e                	sd	s7,24(sp)
    8000248a:	e862                	sd	s8,16(sp)
    8000248c:	e466                	sd	s9,8(sp)
    8000248e:	8baa                	mv	s7,a0
    80002490:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002492:	00022b17          	auipc	s6,0x22
    80002496:	436b0b13          	addi	s6,s6,1078 # 800248c8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000249a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000249c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000249e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800024a0:	6c89                	lui	s9,0x2
    800024a2:	a0b5                	j	8000250e <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    800024a4:	97ca                	add	a5,a5,s2
    800024a6:	8e55                	or	a2,a2,a3
    800024a8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800024ac:	854a                	mv	a0,s2
    800024ae:	791000ef          	jal	8000343e <log_write>
        brelse(bp);
    800024b2:	854a                	mv	a0,s2
    800024b4:	e59ff0ef          	jal	8000230c <brelse>
  bp = bread(dev, bno);
    800024b8:	85a6                	mv	a1,s1
    800024ba:	855e                	mv	a0,s7
    800024bc:	d49ff0ef          	jal	80002204 <bread>
    800024c0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800024c2:	40000613          	li	a2,1024
    800024c6:	4581                	li	a1,0
    800024c8:	05850513          	addi	a0,a0,88
    800024cc:	c83fd0ef          	jal	8000014e <memset>
  log_write(bp);
    800024d0:	854a                	mv	a0,s2
    800024d2:	76d000ef          	jal	8000343e <log_write>
  brelse(bp);
    800024d6:	854a                	mv	a0,s2
    800024d8:	e35ff0ef          	jal	8000230c <brelse>
}
    800024dc:	6906                	ld	s2,64(sp)
    800024de:	79e2                	ld	s3,56(sp)
    800024e0:	7a42                	ld	s4,48(sp)
    800024e2:	7aa2                	ld	s5,40(sp)
    800024e4:	7b02                	ld	s6,32(sp)
    800024e6:	6be2                	ld	s7,24(sp)
    800024e8:	6c42                	ld	s8,16(sp)
    800024ea:	6ca2                	ld	s9,8(sp)
}
    800024ec:	8526                	mv	a0,s1
    800024ee:	60e6                	ld	ra,88(sp)
    800024f0:	6446                	ld	s0,80(sp)
    800024f2:	64a6                	ld	s1,72(sp)
    800024f4:	6125                	addi	sp,sp,96
    800024f6:	8082                	ret
    brelse(bp);
    800024f8:	854a                	mv	a0,s2
    800024fa:	e13ff0ef          	jal	8000230c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800024fe:	015c87bb          	addw	a5,s9,s5
    80002502:	00078a9b          	sext.w	s5,a5
    80002506:	004b2703          	lw	a4,4(s6)
    8000250a:	04eaff63          	bgeu	s5,a4,80002568 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    8000250e:	41fad79b          	sraiw	a5,s5,0x1f
    80002512:	0137d79b          	srliw	a5,a5,0x13
    80002516:	015787bb          	addw	a5,a5,s5
    8000251a:	40d7d79b          	sraiw	a5,a5,0xd
    8000251e:	01cb2583          	lw	a1,28(s6)
    80002522:	9dbd                	addw	a1,a1,a5
    80002524:	855e                	mv	a0,s7
    80002526:	cdfff0ef          	jal	80002204 <bread>
    8000252a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000252c:	004b2503          	lw	a0,4(s6)
    80002530:	000a849b          	sext.w	s1,s5
    80002534:	8762                	mv	a4,s8
    80002536:	fca4f1e3          	bgeu	s1,a0,800024f8 <balloc+0x90>
      m = 1 << (bi % 8);
    8000253a:	00777693          	andi	a3,a4,7
    8000253e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002542:	41f7579b          	sraiw	a5,a4,0x1f
    80002546:	01d7d79b          	srliw	a5,a5,0x1d
    8000254a:	9fb9                	addw	a5,a5,a4
    8000254c:	4037d79b          	sraiw	a5,a5,0x3
    80002550:	00f90633          	add	a2,s2,a5
    80002554:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002558:	00c6f5b3          	and	a1,a3,a2
    8000255c:	d5a1                	beqz	a1,800024a4 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000255e:	2705                	addiw	a4,a4,1
    80002560:	2485                	addiw	s1,s1,1
    80002562:	fd471ae3          	bne	a4,s4,80002536 <balloc+0xce>
    80002566:	bf49                	j	800024f8 <balloc+0x90>
    80002568:	6906                	ld	s2,64(sp)
    8000256a:	79e2                	ld	s3,56(sp)
    8000256c:	7a42                	ld	s4,48(sp)
    8000256e:	7aa2                	ld	s5,40(sp)
    80002570:	7b02                	ld	s6,32(sp)
    80002572:	6be2                	ld	s7,24(sp)
    80002574:	6c42                	ld	s8,16(sp)
    80002576:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002578:	00005517          	auipc	a0,0x5
    8000257c:	f0850513          	addi	a0,a0,-248 # 80007480 <etext+0x480>
    80002580:	228030ef          	jal	800057a8 <printf>
  return 0;
    80002584:	4481                	li	s1,0
    80002586:	b79d                	j	800024ec <balloc+0x84>

0000000080002588 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002588:	7179                	addi	sp,sp,-48
    8000258a:	f406                	sd	ra,40(sp)
    8000258c:	f022                	sd	s0,32(sp)
    8000258e:	ec26                	sd	s1,24(sp)
    80002590:	e84a                	sd	s2,16(sp)
    80002592:	e44e                	sd	s3,8(sp)
    80002594:	1800                	addi	s0,sp,48
    80002596:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002598:	47ad                	li	a5,11
    8000259a:	02b7e663          	bltu	a5,a1,800025c6 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000259e:	02059793          	slli	a5,a1,0x20
    800025a2:	01e7d593          	srli	a1,a5,0x1e
    800025a6:	00b504b3          	add	s1,a0,a1
    800025aa:	0504a903          	lw	s2,80(s1)
    800025ae:	06091a63          	bnez	s2,80002622 <bmap+0x9a>
      addr = balloc(ip->dev);
    800025b2:	4108                	lw	a0,0(a0)
    800025b4:	eb5ff0ef          	jal	80002468 <balloc>
    800025b8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800025bc:	06090363          	beqz	s2,80002622 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800025c0:	0524a823          	sw	s2,80(s1)
    800025c4:	a8b9                	j	80002622 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800025c6:	ff45849b          	addiw	s1,a1,-12
    800025ca:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800025ce:	0ff00793          	li	a5,255
    800025d2:	06e7ee63          	bltu	a5,a4,8000264e <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800025d6:	08052903          	lw	s2,128(a0)
    800025da:	00091d63          	bnez	s2,800025f4 <bmap+0x6c>
      addr = balloc(ip->dev);
    800025de:	4108                	lw	a0,0(a0)
    800025e0:	e89ff0ef          	jal	80002468 <balloc>
    800025e4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800025e8:	02090d63          	beqz	s2,80002622 <bmap+0x9a>
    800025ec:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800025ee:	0929a023          	sw	s2,128(s3)
    800025f2:	a011                	j	800025f6 <bmap+0x6e>
    800025f4:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800025f6:	85ca                	mv	a1,s2
    800025f8:	0009a503          	lw	a0,0(s3)
    800025fc:	c09ff0ef          	jal	80002204 <bread>
    80002600:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002602:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002606:	02049713          	slli	a4,s1,0x20
    8000260a:	01e75593          	srli	a1,a4,0x1e
    8000260e:	00b784b3          	add	s1,a5,a1
    80002612:	0004a903          	lw	s2,0(s1)
    80002616:	00090e63          	beqz	s2,80002632 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000261a:	8552                	mv	a0,s4
    8000261c:	cf1ff0ef          	jal	8000230c <brelse>
    return addr;
    80002620:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002622:	854a                	mv	a0,s2
    80002624:	70a2                	ld	ra,40(sp)
    80002626:	7402                	ld	s0,32(sp)
    80002628:	64e2                	ld	s1,24(sp)
    8000262a:	6942                	ld	s2,16(sp)
    8000262c:	69a2                	ld	s3,8(sp)
    8000262e:	6145                	addi	sp,sp,48
    80002630:	8082                	ret
      addr = balloc(ip->dev);
    80002632:	0009a503          	lw	a0,0(s3)
    80002636:	e33ff0ef          	jal	80002468 <balloc>
    8000263a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000263e:	fc090ee3          	beqz	s2,8000261a <bmap+0x92>
        a[bn] = addr;
    80002642:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002646:	8552                	mv	a0,s4
    80002648:	5f7000ef          	jal	8000343e <log_write>
    8000264c:	b7f9                	j	8000261a <bmap+0x92>
    8000264e:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002650:	00005517          	auipc	a0,0x5
    80002654:	e4850513          	addi	a0,a0,-440 # 80007498 <etext+0x498>
    80002658:	436030ef          	jal	80005a8e <panic>

000000008000265c <iget>:
{
    8000265c:	7179                	addi	sp,sp,-48
    8000265e:	f406                	sd	ra,40(sp)
    80002660:	f022                	sd	s0,32(sp)
    80002662:	ec26                	sd	s1,24(sp)
    80002664:	e84a                	sd	s2,16(sp)
    80002666:	e44e                	sd	s3,8(sp)
    80002668:	e052                	sd	s4,0(sp)
    8000266a:	1800                	addi	s0,sp,48
    8000266c:	89aa                	mv	s3,a0
    8000266e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002670:	00022517          	auipc	a0,0x22
    80002674:	27850513          	addi	a0,a0,632 # 800248e8 <itable>
    80002678:	6d2030ef          	jal	80005d4a <acquire>
  empty = 0;
    8000267c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000267e:	00022497          	auipc	s1,0x22
    80002682:	28248493          	addi	s1,s1,642 # 80024900 <itable+0x18>
    80002686:	00024697          	auipc	a3,0x24
    8000268a:	d0a68693          	addi	a3,a3,-758 # 80026390 <log>
    8000268e:	a039                	j	8000269c <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002690:	02090963          	beqz	s2,800026c2 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002694:	08848493          	addi	s1,s1,136
    80002698:	02d48863          	beq	s1,a3,800026c8 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000269c:	449c                	lw	a5,8(s1)
    8000269e:	fef059e3          	blez	a5,80002690 <iget+0x34>
    800026a2:	4098                	lw	a4,0(s1)
    800026a4:	ff3716e3          	bne	a4,s3,80002690 <iget+0x34>
    800026a8:	40d8                	lw	a4,4(s1)
    800026aa:	ff4713e3          	bne	a4,s4,80002690 <iget+0x34>
      ip->ref++;
    800026ae:	2785                	addiw	a5,a5,1
    800026b0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800026b2:	00022517          	auipc	a0,0x22
    800026b6:	23650513          	addi	a0,a0,566 # 800248e8 <itable>
    800026ba:	728030ef          	jal	80005de2 <release>
      return ip;
    800026be:	8926                	mv	s2,s1
    800026c0:	a02d                	j	800026ea <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800026c2:	fbe9                	bnez	a5,80002694 <iget+0x38>
      empty = ip;
    800026c4:	8926                	mv	s2,s1
    800026c6:	b7f9                	j	80002694 <iget+0x38>
  if(empty == 0)
    800026c8:	02090a63          	beqz	s2,800026fc <iget+0xa0>
  ip->dev = dev;
    800026cc:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800026d0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800026d4:	4785                	li	a5,1
    800026d6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800026da:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800026de:	00022517          	auipc	a0,0x22
    800026e2:	20a50513          	addi	a0,a0,522 # 800248e8 <itable>
    800026e6:	6fc030ef          	jal	80005de2 <release>
}
    800026ea:	854a                	mv	a0,s2
    800026ec:	70a2                	ld	ra,40(sp)
    800026ee:	7402                	ld	s0,32(sp)
    800026f0:	64e2                	ld	s1,24(sp)
    800026f2:	6942                	ld	s2,16(sp)
    800026f4:	69a2                	ld	s3,8(sp)
    800026f6:	6a02                	ld	s4,0(sp)
    800026f8:	6145                	addi	sp,sp,48
    800026fa:	8082                	ret
    panic("iget: no inodes");
    800026fc:	00005517          	auipc	a0,0x5
    80002700:	db450513          	addi	a0,a0,-588 # 800074b0 <etext+0x4b0>
    80002704:	38a030ef          	jal	80005a8e <panic>

0000000080002708 <iinit>:
{
    80002708:	7179                	addi	sp,sp,-48
    8000270a:	f406                	sd	ra,40(sp)
    8000270c:	f022                	sd	s0,32(sp)
    8000270e:	ec26                	sd	s1,24(sp)
    80002710:	e84a                	sd	s2,16(sp)
    80002712:	e44e                	sd	s3,8(sp)
    80002714:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002716:	00005597          	auipc	a1,0x5
    8000271a:	daa58593          	addi	a1,a1,-598 # 800074c0 <etext+0x4c0>
    8000271e:	00022517          	auipc	a0,0x22
    80002722:	1ca50513          	addi	a0,a0,458 # 800248e8 <itable>
    80002726:	5a4030ef          	jal	80005cca <initlock>
  for(i = 0; i < NINODE; i++) {
    8000272a:	00022497          	auipc	s1,0x22
    8000272e:	1e648493          	addi	s1,s1,486 # 80024910 <itable+0x28>
    80002732:	00024997          	auipc	s3,0x24
    80002736:	c6e98993          	addi	s3,s3,-914 # 800263a0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000273a:	00005917          	auipc	s2,0x5
    8000273e:	d8e90913          	addi	s2,s2,-626 # 800074c8 <etext+0x4c8>
    80002742:	85ca                	mv	a1,s2
    80002744:	8526                	mv	a0,s1
    80002746:	5bb000ef          	jal	80003500 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000274a:	08848493          	addi	s1,s1,136
    8000274e:	ff349ae3          	bne	s1,s3,80002742 <iinit+0x3a>
}
    80002752:	70a2                	ld	ra,40(sp)
    80002754:	7402                	ld	s0,32(sp)
    80002756:	64e2                	ld	s1,24(sp)
    80002758:	6942                	ld	s2,16(sp)
    8000275a:	69a2                	ld	s3,8(sp)
    8000275c:	6145                	addi	sp,sp,48
    8000275e:	8082                	ret

0000000080002760 <ialloc>:
{
    80002760:	7139                	addi	sp,sp,-64
    80002762:	fc06                	sd	ra,56(sp)
    80002764:	f822                	sd	s0,48(sp)
    80002766:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80002768:	00022717          	auipc	a4,0x22
    8000276c:	16c72703          	lw	a4,364(a4) # 800248d4 <sb+0xc>
    80002770:	4785                	li	a5,1
    80002772:	06e7f063          	bgeu	a5,a4,800027d2 <ialloc+0x72>
    80002776:	f426                	sd	s1,40(sp)
    80002778:	f04a                	sd	s2,32(sp)
    8000277a:	ec4e                	sd	s3,24(sp)
    8000277c:	e852                	sd	s4,16(sp)
    8000277e:	e456                	sd	s5,8(sp)
    80002780:	e05a                	sd	s6,0(sp)
    80002782:	8aaa                	mv	s5,a0
    80002784:	8b2e                	mv	s6,a1
    80002786:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002788:	00022a17          	auipc	s4,0x22
    8000278c:	140a0a13          	addi	s4,s4,320 # 800248c8 <sb>
    80002790:	00495593          	srli	a1,s2,0x4
    80002794:	018a2783          	lw	a5,24(s4)
    80002798:	9dbd                	addw	a1,a1,a5
    8000279a:	8556                	mv	a0,s5
    8000279c:	a69ff0ef          	jal	80002204 <bread>
    800027a0:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800027a2:	05850993          	addi	s3,a0,88
    800027a6:	00f97793          	andi	a5,s2,15
    800027aa:	079a                	slli	a5,a5,0x6
    800027ac:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800027ae:	00099783          	lh	a5,0(s3)
    800027b2:	cb9d                	beqz	a5,800027e8 <ialloc+0x88>
    brelse(bp);
    800027b4:	b59ff0ef          	jal	8000230c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800027b8:	0905                	addi	s2,s2,1
    800027ba:	00ca2703          	lw	a4,12(s4)
    800027be:	0009079b          	sext.w	a5,s2
    800027c2:	fce7e7e3          	bltu	a5,a4,80002790 <ialloc+0x30>
    800027c6:	74a2                	ld	s1,40(sp)
    800027c8:	7902                	ld	s2,32(sp)
    800027ca:	69e2                	ld	s3,24(sp)
    800027cc:	6a42                	ld	s4,16(sp)
    800027ce:	6aa2                	ld	s5,8(sp)
    800027d0:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800027d2:	00005517          	auipc	a0,0x5
    800027d6:	cfe50513          	addi	a0,a0,-770 # 800074d0 <etext+0x4d0>
    800027da:	7cf020ef          	jal	800057a8 <printf>
  return 0;
    800027de:	4501                	li	a0,0
}
    800027e0:	70e2                	ld	ra,56(sp)
    800027e2:	7442                	ld	s0,48(sp)
    800027e4:	6121                	addi	sp,sp,64
    800027e6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800027e8:	04000613          	li	a2,64
    800027ec:	4581                	li	a1,0
    800027ee:	854e                	mv	a0,s3
    800027f0:	95ffd0ef          	jal	8000014e <memset>
      dip->type = type;
    800027f4:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800027f8:	8526                	mv	a0,s1
    800027fa:	445000ef          	jal	8000343e <log_write>
      brelse(bp);
    800027fe:	8526                	mv	a0,s1
    80002800:	b0dff0ef          	jal	8000230c <brelse>
      return iget(dev, inum);
    80002804:	0009059b          	sext.w	a1,s2
    80002808:	8556                	mv	a0,s5
    8000280a:	e53ff0ef          	jal	8000265c <iget>
    8000280e:	74a2                	ld	s1,40(sp)
    80002810:	7902                	ld	s2,32(sp)
    80002812:	69e2                	ld	s3,24(sp)
    80002814:	6a42                	ld	s4,16(sp)
    80002816:	6aa2                	ld	s5,8(sp)
    80002818:	6b02                	ld	s6,0(sp)
    8000281a:	b7d9                	j	800027e0 <ialloc+0x80>

000000008000281c <iupdate>:
{
    8000281c:	1101                	addi	sp,sp,-32
    8000281e:	ec06                	sd	ra,24(sp)
    80002820:	e822                	sd	s0,16(sp)
    80002822:	e426                	sd	s1,8(sp)
    80002824:	e04a                	sd	s2,0(sp)
    80002826:	1000                	addi	s0,sp,32
    80002828:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000282a:	415c                	lw	a5,4(a0)
    8000282c:	0047d79b          	srliw	a5,a5,0x4
    80002830:	00022597          	auipc	a1,0x22
    80002834:	0b05a583          	lw	a1,176(a1) # 800248e0 <sb+0x18>
    80002838:	9dbd                	addw	a1,a1,a5
    8000283a:	4108                	lw	a0,0(a0)
    8000283c:	9c9ff0ef          	jal	80002204 <bread>
    80002840:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002842:	05850793          	addi	a5,a0,88
    80002846:	40d8                	lw	a4,4(s1)
    80002848:	8b3d                	andi	a4,a4,15
    8000284a:	071a                	slli	a4,a4,0x6
    8000284c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000284e:	04449703          	lh	a4,68(s1)
    80002852:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002856:	04649703          	lh	a4,70(s1)
    8000285a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000285e:	04849703          	lh	a4,72(s1)
    80002862:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002866:	04a49703          	lh	a4,74(s1)
    8000286a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000286e:	44f8                	lw	a4,76(s1)
    80002870:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002872:	03400613          	li	a2,52
    80002876:	05048593          	addi	a1,s1,80
    8000287a:	00c78513          	addi	a0,a5,12
    8000287e:	92dfd0ef          	jal	800001aa <memmove>
  log_write(bp);
    80002882:	854a                	mv	a0,s2
    80002884:	3bb000ef          	jal	8000343e <log_write>
  brelse(bp);
    80002888:	854a                	mv	a0,s2
    8000288a:	a83ff0ef          	jal	8000230c <brelse>
}
    8000288e:	60e2                	ld	ra,24(sp)
    80002890:	6442                	ld	s0,16(sp)
    80002892:	64a2                	ld	s1,8(sp)
    80002894:	6902                	ld	s2,0(sp)
    80002896:	6105                	addi	sp,sp,32
    80002898:	8082                	ret

000000008000289a <idup>:
{
    8000289a:	1101                	addi	sp,sp,-32
    8000289c:	ec06                	sd	ra,24(sp)
    8000289e:	e822                	sd	s0,16(sp)
    800028a0:	e426                	sd	s1,8(sp)
    800028a2:	1000                	addi	s0,sp,32
    800028a4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800028a6:	00022517          	auipc	a0,0x22
    800028aa:	04250513          	addi	a0,a0,66 # 800248e8 <itable>
    800028ae:	49c030ef          	jal	80005d4a <acquire>
  ip->ref++;
    800028b2:	449c                	lw	a5,8(s1)
    800028b4:	2785                	addiw	a5,a5,1
    800028b6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800028b8:	00022517          	auipc	a0,0x22
    800028bc:	03050513          	addi	a0,a0,48 # 800248e8 <itable>
    800028c0:	522030ef          	jal	80005de2 <release>
}
    800028c4:	8526                	mv	a0,s1
    800028c6:	60e2                	ld	ra,24(sp)
    800028c8:	6442                	ld	s0,16(sp)
    800028ca:	64a2                	ld	s1,8(sp)
    800028cc:	6105                	addi	sp,sp,32
    800028ce:	8082                	ret

00000000800028d0 <ilock>:
{
    800028d0:	1101                	addi	sp,sp,-32
    800028d2:	ec06                	sd	ra,24(sp)
    800028d4:	e822                	sd	s0,16(sp)
    800028d6:	e426                	sd	s1,8(sp)
    800028d8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800028da:	cd19                	beqz	a0,800028f8 <ilock+0x28>
    800028dc:	84aa                	mv	s1,a0
    800028de:	451c                	lw	a5,8(a0)
    800028e0:	00f05c63          	blez	a5,800028f8 <ilock+0x28>
  acquiresleep(&ip->lock);
    800028e4:	0541                	addi	a0,a0,16
    800028e6:	451000ef          	jal	80003536 <acquiresleep>
  if(ip->valid == 0){
    800028ea:	40bc                	lw	a5,64(s1)
    800028ec:	cf89                	beqz	a5,80002906 <ilock+0x36>
}
    800028ee:	60e2                	ld	ra,24(sp)
    800028f0:	6442                	ld	s0,16(sp)
    800028f2:	64a2                	ld	s1,8(sp)
    800028f4:	6105                	addi	sp,sp,32
    800028f6:	8082                	ret
    800028f8:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800028fa:	00005517          	auipc	a0,0x5
    800028fe:	bee50513          	addi	a0,a0,-1042 # 800074e8 <etext+0x4e8>
    80002902:	18c030ef          	jal	80005a8e <panic>
    80002906:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002908:	40dc                	lw	a5,4(s1)
    8000290a:	0047d79b          	srliw	a5,a5,0x4
    8000290e:	00022597          	auipc	a1,0x22
    80002912:	fd25a583          	lw	a1,-46(a1) # 800248e0 <sb+0x18>
    80002916:	9dbd                	addw	a1,a1,a5
    80002918:	4088                	lw	a0,0(s1)
    8000291a:	8ebff0ef          	jal	80002204 <bread>
    8000291e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002920:	05850593          	addi	a1,a0,88
    80002924:	40dc                	lw	a5,4(s1)
    80002926:	8bbd                	andi	a5,a5,15
    80002928:	079a                	slli	a5,a5,0x6
    8000292a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000292c:	00059783          	lh	a5,0(a1)
    80002930:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002934:	00259783          	lh	a5,2(a1)
    80002938:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000293c:	00459783          	lh	a5,4(a1)
    80002940:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002944:	00659783          	lh	a5,6(a1)
    80002948:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000294c:	459c                	lw	a5,8(a1)
    8000294e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002950:	03400613          	li	a2,52
    80002954:	05b1                	addi	a1,a1,12
    80002956:	05048513          	addi	a0,s1,80
    8000295a:	851fd0ef          	jal	800001aa <memmove>
    brelse(bp);
    8000295e:	854a                	mv	a0,s2
    80002960:	9adff0ef          	jal	8000230c <brelse>
    ip->valid = 1;
    80002964:	4785                	li	a5,1
    80002966:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002968:	04449783          	lh	a5,68(s1)
    8000296c:	c399                	beqz	a5,80002972 <ilock+0xa2>
    8000296e:	6902                	ld	s2,0(sp)
    80002970:	bfbd                	j	800028ee <ilock+0x1e>
      panic("ilock: no type");
    80002972:	00005517          	auipc	a0,0x5
    80002976:	b7e50513          	addi	a0,a0,-1154 # 800074f0 <etext+0x4f0>
    8000297a:	114030ef          	jal	80005a8e <panic>

000000008000297e <iunlock>:
{
    8000297e:	1101                	addi	sp,sp,-32
    80002980:	ec06                	sd	ra,24(sp)
    80002982:	e822                	sd	s0,16(sp)
    80002984:	e426                	sd	s1,8(sp)
    80002986:	e04a                	sd	s2,0(sp)
    80002988:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000298a:	c505                	beqz	a0,800029b2 <iunlock+0x34>
    8000298c:	84aa                	mv	s1,a0
    8000298e:	01050913          	addi	s2,a0,16
    80002992:	854a                	mv	a0,s2
    80002994:	421000ef          	jal	800035b4 <holdingsleep>
    80002998:	cd09                	beqz	a0,800029b2 <iunlock+0x34>
    8000299a:	449c                	lw	a5,8(s1)
    8000299c:	00f05b63          	blez	a5,800029b2 <iunlock+0x34>
  releasesleep(&ip->lock);
    800029a0:	854a                	mv	a0,s2
    800029a2:	3db000ef          	jal	8000357c <releasesleep>
}
    800029a6:	60e2                	ld	ra,24(sp)
    800029a8:	6442                	ld	s0,16(sp)
    800029aa:	64a2                	ld	s1,8(sp)
    800029ac:	6902                	ld	s2,0(sp)
    800029ae:	6105                	addi	sp,sp,32
    800029b0:	8082                	ret
    panic("iunlock");
    800029b2:	00005517          	auipc	a0,0x5
    800029b6:	b4e50513          	addi	a0,a0,-1202 # 80007500 <etext+0x500>
    800029ba:	0d4030ef          	jal	80005a8e <panic>

00000000800029be <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800029be:	7179                	addi	sp,sp,-48
    800029c0:	f406                	sd	ra,40(sp)
    800029c2:	f022                	sd	s0,32(sp)
    800029c4:	ec26                	sd	s1,24(sp)
    800029c6:	e84a                	sd	s2,16(sp)
    800029c8:	e44e                	sd	s3,8(sp)
    800029ca:	1800                	addi	s0,sp,48
    800029cc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800029ce:	05050493          	addi	s1,a0,80
    800029d2:	08050913          	addi	s2,a0,128
    800029d6:	a021                	j	800029de <itrunc+0x20>
    800029d8:	0491                	addi	s1,s1,4
    800029da:	01248b63          	beq	s1,s2,800029f0 <itrunc+0x32>
    if(ip->addrs[i]){
    800029de:	408c                	lw	a1,0(s1)
    800029e0:	dde5                	beqz	a1,800029d8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800029e2:	0009a503          	lw	a0,0(s3)
    800029e6:	a17ff0ef          	jal	800023fc <bfree>
      ip->addrs[i] = 0;
    800029ea:	0004a023          	sw	zero,0(s1)
    800029ee:	b7ed                	j	800029d8 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800029f0:	0809a583          	lw	a1,128(s3)
    800029f4:	ed89                	bnez	a1,80002a0e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800029f6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800029fa:	854e                	mv	a0,s3
    800029fc:	e21ff0ef          	jal	8000281c <iupdate>
}
    80002a00:	70a2                	ld	ra,40(sp)
    80002a02:	7402                	ld	s0,32(sp)
    80002a04:	64e2                	ld	s1,24(sp)
    80002a06:	6942                	ld	s2,16(sp)
    80002a08:	69a2                	ld	s3,8(sp)
    80002a0a:	6145                	addi	sp,sp,48
    80002a0c:	8082                	ret
    80002a0e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002a10:	0009a503          	lw	a0,0(s3)
    80002a14:	ff0ff0ef          	jal	80002204 <bread>
    80002a18:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002a1a:	05850493          	addi	s1,a0,88
    80002a1e:	45850913          	addi	s2,a0,1112
    80002a22:	a021                	j	80002a2a <itrunc+0x6c>
    80002a24:	0491                	addi	s1,s1,4
    80002a26:	01248963          	beq	s1,s2,80002a38 <itrunc+0x7a>
      if(a[j])
    80002a2a:	408c                	lw	a1,0(s1)
    80002a2c:	dde5                	beqz	a1,80002a24 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80002a2e:	0009a503          	lw	a0,0(s3)
    80002a32:	9cbff0ef          	jal	800023fc <bfree>
    80002a36:	b7fd                	j	80002a24 <itrunc+0x66>
    brelse(bp);
    80002a38:	8552                	mv	a0,s4
    80002a3a:	8d3ff0ef          	jal	8000230c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002a3e:	0809a583          	lw	a1,128(s3)
    80002a42:	0009a503          	lw	a0,0(s3)
    80002a46:	9b7ff0ef          	jal	800023fc <bfree>
    ip->addrs[NDIRECT] = 0;
    80002a4a:	0809a023          	sw	zero,128(s3)
    80002a4e:	6a02                	ld	s4,0(sp)
    80002a50:	b75d                	j	800029f6 <itrunc+0x38>

0000000080002a52 <iput>:
{
    80002a52:	1101                	addi	sp,sp,-32
    80002a54:	ec06                	sd	ra,24(sp)
    80002a56:	e822                	sd	s0,16(sp)
    80002a58:	e426                	sd	s1,8(sp)
    80002a5a:	1000                	addi	s0,sp,32
    80002a5c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002a5e:	00022517          	auipc	a0,0x22
    80002a62:	e8a50513          	addi	a0,a0,-374 # 800248e8 <itable>
    80002a66:	2e4030ef          	jal	80005d4a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002a6a:	4498                	lw	a4,8(s1)
    80002a6c:	4785                	li	a5,1
    80002a6e:	02f70063          	beq	a4,a5,80002a8e <iput+0x3c>
  ip->ref--;
    80002a72:	449c                	lw	a5,8(s1)
    80002a74:	37fd                	addiw	a5,a5,-1
    80002a76:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002a78:	00022517          	auipc	a0,0x22
    80002a7c:	e7050513          	addi	a0,a0,-400 # 800248e8 <itable>
    80002a80:	362030ef          	jal	80005de2 <release>
}
    80002a84:	60e2                	ld	ra,24(sp)
    80002a86:	6442                	ld	s0,16(sp)
    80002a88:	64a2                	ld	s1,8(sp)
    80002a8a:	6105                	addi	sp,sp,32
    80002a8c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002a8e:	40bc                	lw	a5,64(s1)
    80002a90:	d3ed                	beqz	a5,80002a72 <iput+0x20>
    80002a92:	04a49783          	lh	a5,74(s1)
    80002a96:	fff1                	bnez	a5,80002a72 <iput+0x20>
    80002a98:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80002a9a:	01048913          	addi	s2,s1,16
    80002a9e:	854a                	mv	a0,s2
    80002aa0:	297000ef          	jal	80003536 <acquiresleep>
    release(&itable.lock);
    80002aa4:	00022517          	auipc	a0,0x22
    80002aa8:	e4450513          	addi	a0,a0,-444 # 800248e8 <itable>
    80002aac:	336030ef          	jal	80005de2 <release>
    itrunc(ip);
    80002ab0:	8526                	mv	a0,s1
    80002ab2:	f0dff0ef          	jal	800029be <itrunc>
    ip->type = 0;
    80002ab6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002aba:	8526                	mv	a0,s1
    80002abc:	d61ff0ef          	jal	8000281c <iupdate>
    ip->valid = 0;
    80002ac0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002ac4:	854a                	mv	a0,s2
    80002ac6:	2b7000ef          	jal	8000357c <releasesleep>
    acquire(&itable.lock);
    80002aca:	00022517          	auipc	a0,0x22
    80002ace:	e1e50513          	addi	a0,a0,-482 # 800248e8 <itable>
    80002ad2:	278030ef          	jal	80005d4a <acquire>
    80002ad6:	6902                	ld	s2,0(sp)
    80002ad8:	bf69                	j	80002a72 <iput+0x20>

0000000080002ada <iunlockput>:
{
    80002ada:	1101                	addi	sp,sp,-32
    80002adc:	ec06                	sd	ra,24(sp)
    80002ade:	e822                	sd	s0,16(sp)
    80002ae0:	e426                	sd	s1,8(sp)
    80002ae2:	1000                	addi	s0,sp,32
    80002ae4:	84aa                	mv	s1,a0
  iunlock(ip);
    80002ae6:	e99ff0ef          	jal	8000297e <iunlock>
  iput(ip);
    80002aea:	8526                	mv	a0,s1
    80002aec:	f67ff0ef          	jal	80002a52 <iput>
}
    80002af0:	60e2                	ld	ra,24(sp)
    80002af2:	6442                	ld	s0,16(sp)
    80002af4:	64a2                	ld	s1,8(sp)
    80002af6:	6105                	addi	sp,sp,32
    80002af8:	8082                	ret

0000000080002afa <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002afa:	00022717          	auipc	a4,0x22
    80002afe:	dda72703          	lw	a4,-550(a4) # 800248d4 <sb+0xc>
    80002b02:	4785                	li	a5,1
    80002b04:	0ae7ff63          	bgeu	a5,a4,80002bc2 <ireclaim+0xc8>
{
    80002b08:	7139                	addi	sp,sp,-64
    80002b0a:	fc06                	sd	ra,56(sp)
    80002b0c:	f822                	sd	s0,48(sp)
    80002b0e:	f426                	sd	s1,40(sp)
    80002b10:	f04a                	sd	s2,32(sp)
    80002b12:	ec4e                	sd	s3,24(sp)
    80002b14:	e852                	sd	s4,16(sp)
    80002b16:	e456                	sd	s5,8(sp)
    80002b18:	e05a                	sd	s6,0(sp)
    80002b1a:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002b1c:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80002b1e:	00050a1b          	sext.w	s4,a0
    80002b22:	00022a97          	auipc	s5,0x22
    80002b26:	da6a8a93          	addi	s5,s5,-602 # 800248c8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80002b2a:	00005b17          	auipc	s6,0x5
    80002b2e:	9deb0b13          	addi	s6,s6,-1570 # 80007508 <etext+0x508>
    80002b32:	a099                	j	80002b78 <ireclaim+0x7e>
    80002b34:	85ce                	mv	a1,s3
    80002b36:	855a                	mv	a0,s6
    80002b38:	471020ef          	jal	800057a8 <printf>
      ip = iget(dev, inum);
    80002b3c:	85ce                	mv	a1,s3
    80002b3e:	8552                	mv	a0,s4
    80002b40:	b1dff0ef          	jal	8000265c <iget>
    80002b44:	89aa                	mv	s3,a0
    brelse(bp);
    80002b46:	854a                	mv	a0,s2
    80002b48:	fc4ff0ef          	jal	8000230c <brelse>
    if (ip) {
    80002b4c:	00098f63          	beqz	s3,80002b6a <ireclaim+0x70>
      begin_op();
    80002b50:	76a000ef          	jal	800032ba <begin_op>
      ilock(ip);
    80002b54:	854e                	mv	a0,s3
    80002b56:	d7bff0ef          	jal	800028d0 <ilock>
      iunlock(ip);
    80002b5a:	854e                	mv	a0,s3
    80002b5c:	e23ff0ef          	jal	8000297e <iunlock>
      iput(ip);
    80002b60:	854e                	mv	a0,s3
    80002b62:	ef1ff0ef          	jal	80002a52 <iput>
      end_op();
    80002b66:	7be000ef          	jal	80003324 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80002b6a:	0485                	addi	s1,s1,1
    80002b6c:	00caa703          	lw	a4,12(s5)
    80002b70:	0004879b          	sext.w	a5,s1
    80002b74:	02e7fd63          	bgeu	a5,a4,80002bae <ireclaim+0xb4>
    80002b78:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80002b7c:	0044d593          	srli	a1,s1,0x4
    80002b80:	018aa783          	lw	a5,24(s5)
    80002b84:	9dbd                	addw	a1,a1,a5
    80002b86:	8552                	mv	a0,s4
    80002b88:	e7cff0ef          	jal	80002204 <bread>
    80002b8c:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80002b8e:	05850793          	addi	a5,a0,88
    80002b92:	00f9f713          	andi	a4,s3,15
    80002b96:	071a                	slli	a4,a4,0x6
    80002b98:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80002b9a:	00079703          	lh	a4,0(a5)
    80002b9e:	c701                	beqz	a4,80002ba6 <ireclaim+0xac>
    80002ba0:	00679783          	lh	a5,6(a5)
    80002ba4:	dbc1                	beqz	a5,80002b34 <ireclaim+0x3a>
    brelse(bp);
    80002ba6:	854a                	mv	a0,s2
    80002ba8:	f64ff0ef          	jal	8000230c <brelse>
    if (ip) {
    80002bac:	bf7d                	j	80002b6a <ireclaim+0x70>
}
    80002bae:	70e2                	ld	ra,56(sp)
    80002bb0:	7442                	ld	s0,48(sp)
    80002bb2:	74a2                	ld	s1,40(sp)
    80002bb4:	7902                	ld	s2,32(sp)
    80002bb6:	69e2                	ld	s3,24(sp)
    80002bb8:	6a42                	ld	s4,16(sp)
    80002bba:	6aa2                	ld	s5,8(sp)
    80002bbc:	6b02                	ld	s6,0(sp)
    80002bbe:	6121                	addi	sp,sp,64
    80002bc0:	8082                	ret
    80002bc2:	8082                	ret

0000000080002bc4 <fsinit>:
fsinit(int dev) {
    80002bc4:	7179                	addi	sp,sp,-48
    80002bc6:	f406                	sd	ra,40(sp)
    80002bc8:	f022                	sd	s0,32(sp)
    80002bca:	ec26                	sd	s1,24(sp)
    80002bcc:	e84a                	sd	s2,16(sp)
    80002bce:	e44e                	sd	s3,8(sp)
    80002bd0:	1800                	addi	s0,sp,48
    80002bd2:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80002bd4:	4585                	li	a1,1
    80002bd6:	e2eff0ef          	jal	80002204 <bread>
    80002bda:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002bdc:	00022997          	auipc	s3,0x22
    80002be0:	cec98993          	addi	s3,s3,-788 # 800248c8 <sb>
    80002be4:	02000613          	li	a2,32
    80002be8:	05850593          	addi	a1,a0,88
    80002bec:	854e                	mv	a0,s3
    80002bee:	dbcfd0ef          	jal	800001aa <memmove>
  brelse(bp);
    80002bf2:	854a                	mv	a0,s2
    80002bf4:	f18ff0ef          	jal	8000230c <brelse>
  if(sb.magic != FSMAGIC)
    80002bf8:	0009a703          	lw	a4,0(s3)
    80002bfc:	102037b7          	lui	a5,0x10203
    80002c00:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002c04:	02f71363          	bne	a4,a5,80002c2a <fsinit+0x66>
  initlog(dev, &sb);
    80002c08:	00022597          	auipc	a1,0x22
    80002c0c:	cc058593          	addi	a1,a1,-832 # 800248c8 <sb>
    80002c10:	8526                	mv	a0,s1
    80002c12:	62a000ef          	jal	8000323c <initlog>
  ireclaim(dev);
    80002c16:	8526                	mv	a0,s1
    80002c18:	ee3ff0ef          	jal	80002afa <ireclaim>
}
    80002c1c:	70a2                	ld	ra,40(sp)
    80002c1e:	7402                	ld	s0,32(sp)
    80002c20:	64e2                	ld	s1,24(sp)
    80002c22:	6942                	ld	s2,16(sp)
    80002c24:	69a2                	ld	s3,8(sp)
    80002c26:	6145                	addi	sp,sp,48
    80002c28:	8082                	ret
    panic("invalid file system");
    80002c2a:	00005517          	auipc	a0,0x5
    80002c2e:	8fe50513          	addi	a0,a0,-1794 # 80007528 <etext+0x528>
    80002c32:	65d020ef          	jal	80005a8e <panic>

0000000080002c36 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002c36:	1141                	addi	sp,sp,-16
    80002c38:	e422                	sd	s0,8(sp)
    80002c3a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002c3c:	411c                	lw	a5,0(a0)
    80002c3e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002c40:	415c                	lw	a5,4(a0)
    80002c42:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002c44:	04451783          	lh	a5,68(a0)
    80002c48:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002c4c:	04a51783          	lh	a5,74(a0)
    80002c50:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002c54:	04c56783          	lwu	a5,76(a0)
    80002c58:	e99c                	sd	a5,16(a1)
}
    80002c5a:	6422                	ld	s0,8(sp)
    80002c5c:	0141                	addi	sp,sp,16
    80002c5e:	8082                	ret

0000000080002c60 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002c60:	457c                	lw	a5,76(a0)
    80002c62:	0ed7eb63          	bltu	a5,a3,80002d58 <readi+0xf8>
{
    80002c66:	7159                	addi	sp,sp,-112
    80002c68:	f486                	sd	ra,104(sp)
    80002c6a:	f0a2                	sd	s0,96(sp)
    80002c6c:	eca6                	sd	s1,88(sp)
    80002c6e:	e0d2                	sd	s4,64(sp)
    80002c70:	fc56                	sd	s5,56(sp)
    80002c72:	f85a                	sd	s6,48(sp)
    80002c74:	f45e                	sd	s7,40(sp)
    80002c76:	1880                	addi	s0,sp,112
    80002c78:	8b2a                	mv	s6,a0
    80002c7a:	8bae                	mv	s7,a1
    80002c7c:	8a32                	mv	s4,a2
    80002c7e:	84b6                	mv	s1,a3
    80002c80:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002c82:	9f35                	addw	a4,a4,a3
    return 0;
    80002c84:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002c86:	0cd76063          	bltu	a4,a3,80002d46 <readi+0xe6>
    80002c8a:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80002c8c:	00e7f463          	bgeu	a5,a4,80002c94 <readi+0x34>
    n = ip->size - off;
    80002c90:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002c94:	080a8f63          	beqz	s5,80002d32 <readi+0xd2>
    80002c98:	e8ca                	sd	s2,80(sp)
    80002c9a:	f062                	sd	s8,32(sp)
    80002c9c:	ec66                	sd	s9,24(sp)
    80002c9e:	e86a                	sd	s10,16(sp)
    80002ca0:	e46e                	sd	s11,8(sp)
    80002ca2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002ca4:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002ca8:	5c7d                	li	s8,-1
    80002caa:	a80d                	j	80002cdc <readi+0x7c>
    80002cac:	020d1d93          	slli	s11,s10,0x20
    80002cb0:	020ddd93          	srli	s11,s11,0x20
    80002cb4:	05890613          	addi	a2,s2,88
    80002cb8:	86ee                	mv	a3,s11
    80002cba:	963a                	add	a2,a2,a4
    80002cbc:	85d2                	mv	a1,s4
    80002cbe:	855e                	mv	a0,s7
    80002cc0:	ae9fe0ef          	jal	800017a8 <either_copyout>
    80002cc4:	05850763          	beq	a0,s8,80002d12 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002cc8:	854a                	mv	a0,s2
    80002cca:	e42ff0ef          	jal	8000230c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002cce:	013d09bb          	addw	s3,s10,s3
    80002cd2:	009d04bb          	addw	s1,s10,s1
    80002cd6:	9a6e                	add	s4,s4,s11
    80002cd8:	0559f763          	bgeu	s3,s5,80002d26 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80002cdc:	00a4d59b          	srliw	a1,s1,0xa
    80002ce0:	855a                	mv	a0,s6
    80002ce2:	8a7ff0ef          	jal	80002588 <bmap>
    80002ce6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002cea:	c5b1                	beqz	a1,80002d36 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80002cec:	000b2503          	lw	a0,0(s6)
    80002cf0:	d14ff0ef          	jal	80002204 <bread>
    80002cf4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002cf6:	3ff4f713          	andi	a4,s1,1023
    80002cfa:	40ec87bb          	subw	a5,s9,a4
    80002cfe:	413a86bb          	subw	a3,s5,s3
    80002d02:	8d3e                	mv	s10,a5
    80002d04:	2781                	sext.w	a5,a5
    80002d06:	0006861b          	sext.w	a2,a3
    80002d0a:	faf671e3          	bgeu	a2,a5,80002cac <readi+0x4c>
    80002d0e:	8d36                	mv	s10,a3
    80002d10:	bf71                	j	80002cac <readi+0x4c>
      brelse(bp);
    80002d12:	854a                	mv	a0,s2
    80002d14:	df8ff0ef          	jal	8000230c <brelse>
      tot = -1;
    80002d18:	59fd                	li	s3,-1
      break;
    80002d1a:	6946                	ld	s2,80(sp)
    80002d1c:	7c02                	ld	s8,32(sp)
    80002d1e:	6ce2                	ld	s9,24(sp)
    80002d20:	6d42                	ld	s10,16(sp)
    80002d22:	6da2                	ld	s11,8(sp)
    80002d24:	a831                	j	80002d40 <readi+0xe0>
    80002d26:	6946                	ld	s2,80(sp)
    80002d28:	7c02                	ld	s8,32(sp)
    80002d2a:	6ce2                	ld	s9,24(sp)
    80002d2c:	6d42                	ld	s10,16(sp)
    80002d2e:	6da2                	ld	s11,8(sp)
    80002d30:	a801                	j	80002d40 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002d32:	89d6                	mv	s3,s5
    80002d34:	a031                	j	80002d40 <readi+0xe0>
    80002d36:	6946                	ld	s2,80(sp)
    80002d38:	7c02                	ld	s8,32(sp)
    80002d3a:	6ce2                	ld	s9,24(sp)
    80002d3c:	6d42                	ld	s10,16(sp)
    80002d3e:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002d40:	0009851b          	sext.w	a0,s3
    80002d44:	69a6                	ld	s3,72(sp)
}
    80002d46:	70a6                	ld	ra,104(sp)
    80002d48:	7406                	ld	s0,96(sp)
    80002d4a:	64e6                	ld	s1,88(sp)
    80002d4c:	6a06                	ld	s4,64(sp)
    80002d4e:	7ae2                	ld	s5,56(sp)
    80002d50:	7b42                	ld	s6,48(sp)
    80002d52:	7ba2                	ld	s7,40(sp)
    80002d54:	6165                	addi	sp,sp,112
    80002d56:	8082                	ret
    return 0;
    80002d58:	4501                	li	a0,0
}
    80002d5a:	8082                	ret

0000000080002d5c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002d5c:	457c                	lw	a5,76(a0)
    80002d5e:	10d7e063          	bltu	a5,a3,80002e5e <writei+0x102>
{
    80002d62:	7159                	addi	sp,sp,-112
    80002d64:	f486                	sd	ra,104(sp)
    80002d66:	f0a2                	sd	s0,96(sp)
    80002d68:	e8ca                	sd	s2,80(sp)
    80002d6a:	e0d2                	sd	s4,64(sp)
    80002d6c:	fc56                	sd	s5,56(sp)
    80002d6e:	f85a                	sd	s6,48(sp)
    80002d70:	f45e                	sd	s7,40(sp)
    80002d72:	1880                	addi	s0,sp,112
    80002d74:	8aaa                	mv	s5,a0
    80002d76:	8bae                	mv	s7,a1
    80002d78:	8a32                	mv	s4,a2
    80002d7a:	8936                	mv	s2,a3
    80002d7c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002d7e:	00e687bb          	addw	a5,a3,a4
    80002d82:	0ed7e063          	bltu	a5,a3,80002e62 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002d86:	00043737          	lui	a4,0x43
    80002d8a:	0cf76e63          	bltu	a4,a5,80002e66 <writei+0x10a>
    80002d8e:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002d90:	0a0b0f63          	beqz	s6,80002e4e <writei+0xf2>
    80002d94:	eca6                	sd	s1,88(sp)
    80002d96:	f062                	sd	s8,32(sp)
    80002d98:	ec66                	sd	s9,24(sp)
    80002d9a:	e86a                	sd	s10,16(sp)
    80002d9c:	e46e                	sd	s11,8(sp)
    80002d9e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002da0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002da4:	5c7d                	li	s8,-1
    80002da6:	a825                	j	80002dde <writei+0x82>
    80002da8:	020d1d93          	slli	s11,s10,0x20
    80002dac:	020ddd93          	srli	s11,s11,0x20
    80002db0:	05848513          	addi	a0,s1,88
    80002db4:	86ee                	mv	a3,s11
    80002db6:	8652                	mv	a2,s4
    80002db8:	85de                	mv	a1,s7
    80002dba:	953a                	add	a0,a0,a4
    80002dbc:	a37fe0ef          	jal	800017f2 <either_copyin>
    80002dc0:	05850a63          	beq	a0,s8,80002e14 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002dc4:	8526                	mv	a0,s1
    80002dc6:	678000ef          	jal	8000343e <log_write>
    brelse(bp);
    80002dca:	8526                	mv	a0,s1
    80002dcc:	d40ff0ef          	jal	8000230c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002dd0:	013d09bb          	addw	s3,s10,s3
    80002dd4:	012d093b          	addw	s2,s10,s2
    80002dd8:	9a6e                	add	s4,s4,s11
    80002dda:	0569f063          	bgeu	s3,s6,80002e1a <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002dde:	00a9559b          	srliw	a1,s2,0xa
    80002de2:	8556                	mv	a0,s5
    80002de4:	fa4ff0ef          	jal	80002588 <bmap>
    80002de8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002dec:	c59d                	beqz	a1,80002e1a <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002dee:	000aa503          	lw	a0,0(s5)
    80002df2:	c12ff0ef          	jal	80002204 <bread>
    80002df6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002df8:	3ff97713          	andi	a4,s2,1023
    80002dfc:	40ec87bb          	subw	a5,s9,a4
    80002e00:	413b06bb          	subw	a3,s6,s3
    80002e04:	8d3e                	mv	s10,a5
    80002e06:	2781                	sext.w	a5,a5
    80002e08:	0006861b          	sext.w	a2,a3
    80002e0c:	f8f67ee3          	bgeu	a2,a5,80002da8 <writei+0x4c>
    80002e10:	8d36                	mv	s10,a3
    80002e12:	bf59                	j	80002da8 <writei+0x4c>
      brelse(bp);
    80002e14:	8526                	mv	a0,s1
    80002e16:	cf6ff0ef          	jal	8000230c <brelse>
  }

  if(off > ip->size)
    80002e1a:	04caa783          	lw	a5,76(s5)
    80002e1e:	0327fa63          	bgeu	a5,s2,80002e52 <writei+0xf6>
    ip->size = off;
    80002e22:	052aa623          	sw	s2,76(s5)
    80002e26:	64e6                	ld	s1,88(sp)
    80002e28:	7c02                	ld	s8,32(sp)
    80002e2a:	6ce2                	ld	s9,24(sp)
    80002e2c:	6d42                	ld	s10,16(sp)
    80002e2e:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002e30:	8556                	mv	a0,s5
    80002e32:	9ebff0ef          	jal	8000281c <iupdate>

  return tot;
    80002e36:	0009851b          	sext.w	a0,s3
    80002e3a:	69a6                	ld	s3,72(sp)
}
    80002e3c:	70a6                	ld	ra,104(sp)
    80002e3e:	7406                	ld	s0,96(sp)
    80002e40:	6946                	ld	s2,80(sp)
    80002e42:	6a06                	ld	s4,64(sp)
    80002e44:	7ae2                	ld	s5,56(sp)
    80002e46:	7b42                	ld	s6,48(sp)
    80002e48:	7ba2                	ld	s7,40(sp)
    80002e4a:	6165                	addi	sp,sp,112
    80002e4c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002e4e:	89da                	mv	s3,s6
    80002e50:	b7c5                	j	80002e30 <writei+0xd4>
    80002e52:	64e6                	ld	s1,88(sp)
    80002e54:	7c02                	ld	s8,32(sp)
    80002e56:	6ce2                	ld	s9,24(sp)
    80002e58:	6d42                	ld	s10,16(sp)
    80002e5a:	6da2                	ld	s11,8(sp)
    80002e5c:	bfd1                	j	80002e30 <writei+0xd4>
    return -1;
    80002e5e:	557d                	li	a0,-1
}
    80002e60:	8082                	ret
    return -1;
    80002e62:	557d                	li	a0,-1
    80002e64:	bfe1                	j	80002e3c <writei+0xe0>
    return -1;
    80002e66:	557d                	li	a0,-1
    80002e68:	bfd1                	j	80002e3c <writei+0xe0>

0000000080002e6a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002e6a:	1141                	addi	sp,sp,-16
    80002e6c:	e406                	sd	ra,8(sp)
    80002e6e:	e022                	sd	s0,0(sp)
    80002e70:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002e72:	4639                	li	a2,14
    80002e74:	ba6fd0ef          	jal	8000021a <strncmp>
}
    80002e78:	60a2                	ld	ra,8(sp)
    80002e7a:	6402                	ld	s0,0(sp)
    80002e7c:	0141                	addi	sp,sp,16
    80002e7e:	8082                	ret

0000000080002e80 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002e80:	7139                	addi	sp,sp,-64
    80002e82:	fc06                	sd	ra,56(sp)
    80002e84:	f822                	sd	s0,48(sp)
    80002e86:	f426                	sd	s1,40(sp)
    80002e88:	f04a                	sd	s2,32(sp)
    80002e8a:	ec4e                	sd	s3,24(sp)
    80002e8c:	e852                	sd	s4,16(sp)
    80002e8e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002e90:	04451703          	lh	a4,68(a0)
    80002e94:	4785                	li	a5,1
    80002e96:	00f71a63          	bne	a4,a5,80002eaa <dirlookup+0x2a>
    80002e9a:	892a                	mv	s2,a0
    80002e9c:	89ae                	mv	s3,a1
    80002e9e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002ea0:	457c                	lw	a5,76(a0)
    80002ea2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002ea4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002ea6:	e39d                	bnez	a5,80002ecc <dirlookup+0x4c>
    80002ea8:	a095                	j	80002f0c <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002eaa:	00004517          	auipc	a0,0x4
    80002eae:	69650513          	addi	a0,a0,1686 # 80007540 <etext+0x540>
    80002eb2:	3dd020ef          	jal	80005a8e <panic>
      panic("dirlookup read");
    80002eb6:	00004517          	auipc	a0,0x4
    80002eba:	6a250513          	addi	a0,a0,1698 # 80007558 <etext+0x558>
    80002ebe:	3d1020ef          	jal	80005a8e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002ec2:	24c1                	addiw	s1,s1,16
    80002ec4:	04c92783          	lw	a5,76(s2)
    80002ec8:	04f4f163          	bgeu	s1,a5,80002f0a <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002ecc:	4741                	li	a4,16
    80002ece:	86a6                	mv	a3,s1
    80002ed0:	fc040613          	addi	a2,s0,-64
    80002ed4:	4581                	li	a1,0
    80002ed6:	854a                	mv	a0,s2
    80002ed8:	d89ff0ef          	jal	80002c60 <readi>
    80002edc:	47c1                	li	a5,16
    80002ede:	fcf51ce3          	bne	a0,a5,80002eb6 <dirlookup+0x36>
    if(de.inum == 0)
    80002ee2:	fc045783          	lhu	a5,-64(s0)
    80002ee6:	dff1                	beqz	a5,80002ec2 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002ee8:	fc240593          	addi	a1,s0,-62
    80002eec:	854e                	mv	a0,s3
    80002eee:	f7dff0ef          	jal	80002e6a <namecmp>
    80002ef2:	f961                	bnez	a0,80002ec2 <dirlookup+0x42>
      if(poff)
    80002ef4:	000a0463          	beqz	s4,80002efc <dirlookup+0x7c>
        *poff = off;
    80002ef8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002efc:	fc045583          	lhu	a1,-64(s0)
    80002f00:	00092503          	lw	a0,0(s2)
    80002f04:	f58ff0ef          	jal	8000265c <iget>
    80002f08:	a011                	j	80002f0c <dirlookup+0x8c>
  return 0;
    80002f0a:	4501                	li	a0,0
}
    80002f0c:	70e2                	ld	ra,56(sp)
    80002f0e:	7442                	ld	s0,48(sp)
    80002f10:	74a2                	ld	s1,40(sp)
    80002f12:	7902                	ld	s2,32(sp)
    80002f14:	69e2                	ld	s3,24(sp)
    80002f16:	6a42                	ld	s4,16(sp)
    80002f18:	6121                	addi	sp,sp,64
    80002f1a:	8082                	ret

0000000080002f1c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002f1c:	711d                	addi	sp,sp,-96
    80002f1e:	ec86                	sd	ra,88(sp)
    80002f20:	e8a2                	sd	s0,80(sp)
    80002f22:	e4a6                	sd	s1,72(sp)
    80002f24:	e0ca                	sd	s2,64(sp)
    80002f26:	fc4e                	sd	s3,56(sp)
    80002f28:	f852                	sd	s4,48(sp)
    80002f2a:	f456                	sd	s5,40(sp)
    80002f2c:	f05a                	sd	s6,32(sp)
    80002f2e:	ec5e                	sd	s7,24(sp)
    80002f30:	e862                	sd	s8,16(sp)
    80002f32:	e466                	sd	s9,8(sp)
    80002f34:	1080                	addi	s0,sp,96
    80002f36:	84aa                	mv	s1,a0
    80002f38:	8b2e                	mv	s6,a1
    80002f3a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002f3c:	00054703          	lbu	a4,0(a0)
    80002f40:	02f00793          	li	a5,47
    80002f44:	00f70e63          	beq	a4,a5,80002f60 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002f48:	e33fd0ef          	jal	80000d7a <myproc>
    80002f4c:	15053503          	ld	a0,336(a0)
    80002f50:	94bff0ef          	jal	8000289a <idup>
    80002f54:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002f56:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002f5a:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002f5c:	4b85                	li	s7,1
    80002f5e:	a871                	j	80002ffa <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002f60:	4585                	li	a1,1
    80002f62:	4505                	li	a0,1
    80002f64:	ef8ff0ef          	jal	8000265c <iget>
    80002f68:	8a2a                	mv	s4,a0
    80002f6a:	b7f5                	j	80002f56 <namex+0x3a>
      iunlockput(ip);
    80002f6c:	8552                	mv	a0,s4
    80002f6e:	b6dff0ef          	jal	80002ada <iunlockput>
      return 0;
    80002f72:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002f74:	8552                	mv	a0,s4
    80002f76:	60e6                	ld	ra,88(sp)
    80002f78:	6446                	ld	s0,80(sp)
    80002f7a:	64a6                	ld	s1,72(sp)
    80002f7c:	6906                	ld	s2,64(sp)
    80002f7e:	79e2                	ld	s3,56(sp)
    80002f80:	7a42                	ld	s4,48(sp)
    80002f82:	7aa2                	ld	s5,40(sp)
    80002f84:	7b02                	ld	s6,32(sp)
    80002f86:	6be2                	ld	s7,24(sp)
    80002f88:	6c42                	ld	s8,16(sp)
    80002f8a:	6ca2                	ld	s9,8(sp)
    80002f8c:	6125                	addi	sp,sp,96
    80002f8e:	8082                	ret
      iunlock(ip);
    80002f90:	8552                	mv	a0,s4
    80002f92:	9edff0ef          	jal	8000297e <iunlock>
      return ip;
    80002f96:	bff9                	j	80002f74 <namex+0x58>
      iunlockput(ip);
    80002f98:	8552                	mv	a0,s4
    80002f9a:	b41ff0ef          	jal	80002ada <iunlockput>
      return 0;
    80002f9e:	8a4e                	mv	s4,s3
    80002fa0:	bfd1                	j	80002f74 <namex+0x58>
  len = path - s;
    80002fa2:	40998633          	sub	a2,s3,s1
    80002fa6:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002faa:	099c5063          	bge	s8,s9,8000302a <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002fae:	4639                	li	a2,14
    80002fb0:	85a6                	mv	a1,s1
    80002fb2:	8556                	mv	a0,s5
    80002fb4:	9f6fd0ef          	jal	800001aa <memmove>
    80002fb8:	84ce                	mv	s1,s3
  while(*path == '/')
    80002fba:	0004c783          	lbu	a5,0(s1)
    80002fbe:	01279763          	bne	a5,s2,80002fcc <namex+0xb0>
    path++;
    80002fc2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002fc4:	0004c783          	lbu	a5,0(s1)
    80002fc8:	ff278de3          	beq	a5,s2,80002fc2 <namex+0xa6>
    ilock(ip);
    80002fcc:	8552                	mv	a0,s4
    80002fce:	903ff0ef          	jal	800028d0 <ilock>
    if(ip->type != T_DIR){
    80002fd2:	044a1783          	lh	a5,68(s4)
    80002fd6:	f9779be3          	bne	a5,s7,80002f6c <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002fda:	000b0563          	beqz	s6,80002fe4 <namex+0xc8>
    80002fde:	0004c783          	lbu	a5,0(s1)
    80002fe2:	d7dd                	beqz	a5,80002f90 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002fe4:	4601                	li	a2,0
    80002fe6:	85d6                	mv	a1,s5
    80002fe8:	8552                	mv	a0,s4
    80002fea:	e97ff0ef          	jal	80002e80 <dirlookup>
    80002fee:	89aa                	mv	s3,a0
    80002ff0:	d545                	beqz	a0,80002f98 <namex+0x7c>
    iunlockput(ip);
    80002ff2:	8552                	mv	a0,s4
    80002ff4:	ae7ff0ef          	jal	80002ada <iunlockput>
    ip = next;
    80002ff8:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002ffa:	0004c783          	lbu	a5,0(s1)
    80002ffe:	01279763          	bne	a5,s2,8000300c <namex+0xf0>
    path++;
    80003002:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003004:	0004c783          	lbu	a5,0(s1)
    80003008:	ff278de3          	beq	a5,s2,80003002 <namex+0xe6>
  if(*path == 0)
    8000300c:	cb8d                	beqz	a5,8000303e <namex+0x122>
  while(*path != '/' && *path != 0)
    8000300e:	0004c783          	lbu	a5,0(s1)
    80003012:	89a6                	mv	s3,s1
  len = path - s;
    80003014:	4c81                	li	s9,0
    80003016:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003018:	01278963          	beq	a5,s2,8000302a <namex+0x10e>
    8000301c:	d3d9                	beqz	a5,80002fa2 <namex+0x86>
    path++;
    8000301e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003020:	0009c783          	lbu	a5,0(s3)
    80003024:	ff279ce3          	bne	a5,s2,8000301c <namex+0x100>
    80003028:	bfad                	j	80002fa2 <namex+0x86>
    memmove(name, s, len);
    8000302a:	2601                	sext.w	a2,a2
    8000302c:	85a6                	mv	a1,s1
    8000302e:	8556                	mv	a0,s5
    80003030:	97afd0ef          	jal	800001aa <memmove>
    name[len] = 0;
    80003034:	9cd6                	add	s9,s9,s5
    80003036:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000303a:	84ce                	mv	s1,s3
    8000303c:	bfbd                	j	80002fba <namex+0x9e>
  if(nameiparent){
    8000303e:	f20b0be3          	beqz	s6,80002f74 <namex+0x58>
    iput(ip);
    80003042:	8552                	mv	a0,s4
    80003044:	a0fff0ef          	jal	80002a52 <iput>
    return 0;
    80003048:	4a01                	li	s4,0
    8000304a:	b72d                	j	80002f74 <namex+0x58>

000000008000304c <dirlink>:
{
    8000304c:	7139                	addi	sp,sp,-64
    8000304e:	fc06                	sd	ra,56(sp)
    80003050:	f822                	sd	s0,48(sp)
    80003052:	f04a                	sd	s2,32(sp)
    80003054:	ec4e                	sd	s3,24(sp)
    80003056:	e852                	sd	s4,16(sp)
    80003058:	0080                	addi	s0,sp,64
    8000305a:	892a                	mv	s2,a0
    8000305c:	8a2e                	mv	s4,a1
    8000305e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003060:	4601                	li	a2,0
    80003062:	e1fff0ef          	jal	80002e80 <dirlookup>
    80003066:	e535                	bnez	a0,800030d2 <dirlink+0x86>
    80003068:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000306a:	04c92483          	lw	s1,76(s2)
    8000306e:	c48d                	beqz	s1,80003098 <dirlink+0x4c>
    80003070:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003072:	4741                	li	a4,16
    80003074:	86a6                	mv	a3,s1
    80003076:	fc040613          	addi	a2,s0,-64
    8000307a:	4581                	li	a1,0
    8000307c:	854a                	mv	a0,s2
    8000307e:	be3ff0ef          	jal	80002c60 <readi>
    80003082:	47c1                	li	a5,16
    80003084:	04f51b63          	bne	a0,a5,800030da <dirlink+0x8e>
    if(de.inum == 0)
    80003088:	fc045783          	lhu	a5,-64(s0)
    8000308c:	c791                	beqz	a5,80003098 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000308e:	24c1                	addiw	s1,s1,16
    80003090:	04c92783          	lw	a5,76(s2)
    80003094:	fcf4efe3          	bltu	s1,a5,80003072 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003098:	4639                	li	a2,14
    8000309a:	85d2                	mv	a1,s4
    8000309c:	fc240513          	addi	a0,s0,-62
    800030a0:	9b0fd0ef          	jal	80000250 <strncpy>
  de.inum = inum;
    800030a4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800030a8:	4741                	li	a4,16
    800030aa:	86a6                	mv	a3,s1
    800030ac:	fc040613          	addi	a2,s0,-64
    800030b0:	4581                	li	a1,0
    800030b2:	854a                	mv	a0,s2
    800030b4:	ca9ff0ef          	jal	80002d5c <writei>
    800030b8:	1541                	addi	a0,a0,-16
    800030ba:	00a03533          	snez	a0,a0
    800030be:	40a00533          	neg	a0,a0
    800030c2:	74a2                	ld	s1,40(sp)
}
    800030c4:	70e2                	ld	ra,56(sp)
    800030c6:	7442                	ld	s0,48(sp)
    800030c8:	7902                	ld	s2,32(sp)
    800030ca:	69e2                	ld	s3,24(sp)
    800030cc:	6a42                	ld	s4,16(sp)
    800030ce:	6121                	addi	sp,sp,64
    800030d0:	8082                	ret
    iput(ip);
    800030d2:	981ff0ef          	jal	80002a52 <iput>
    return -1;
    800030d6:	557d                	li	a0,-1
    800030d8:	b7f5                	j	800030c4 <dirlink+0x78>
      panic("dirlink read");
    800030da:	00004517          	auipc	a0,0x4
    800030de:	48e50513          	addi	a0,a0,1166 # 80007568 <etext+0x568>
    800030e2:	1ad020ef          	jal	80005a8e <panic>

00000000800030e6 <namei>:

struct inode*
namei(char *path)
{
    800030e6:	1101                	addi	sp,sp,-32
    800030e8:	ec06                	sd	ra,24(sp)
    800030ea:	e822                	sd	s0,16(sp)
    800030ec:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800030ee:	fe040613          	addi	a2,s0,-32
    800030f2:	4581                	li	a1,0
    800030f4:	e29ff0ef          	jal	80002f1c <namex>
}
    800030f8:	60e2                	ld	ra,24(sp)
    800030fa:	6442                	ld	s0,16(sp)
    800030fc:	6105                	addi	sp,sp,32
    800030fe:	8082                	ret

0000000080003100 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003100:	1141                	addi	sp,sp,-16
    80003102:	e406                	sd	ra,8(sp)
    80003104:	e022                	sd	s0,0(sp)
    80003106:	0800                	addi	s0,sp,16
    80003108:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000310a:	4585                	li	a1,1
    8000310c:	e11ff0ef          	jal	80002f1c <namex>
}
    80003110:	60a2                	ld	ra,8(sp)
    80003112:	6402                	ld	s0,0(sp)
    80003114:	0141                	addi	sp,sp,16
    80003116:	8082                	ret

0000000080003118 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003118:	1101                	addi	sp,sp,-32
    8000311a:	ec06                	sd	ra,24(sp)
    8000311c:	e822                	sd	s0,16(sp)
    8000311e:	e426                	sd	s1,8(sp)
    80003120:	e04a                	sd	s2,0(sp)
    80003122:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003124:	00023917          	auipc	s2,0x23
    80003128:	26c90913          	addi	s2,s2,620 # 80026390 <log>
    8000312c:	01892583          	lw	a1,24(s2)
    80003130:	02492503          	lw	a0,36(s2)
    80003134:	8d0ff0ef          	jal	80002204 <bread>
    80003138:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000313a:	02892603          	lw	a2,40(s2)
    8000313e:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003140:	00c05f63          	blez	a2,8000315e <write_head+0x46>
    80003144:	00023717          	auipc	a4,0x23
    80003148:	27870713          	addi	a4,a4,632 # 800263bc <log+0x2c>
    8000314c:	87aa                	mv	a5,a0
    8000314e:	060a                	slli	a2,a2,0x2
    80003150:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003152:	4314                	lw	a3,0(a4)
    80003154:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003156:	0711                	addi	a4,a4,4
    80003158:	0791                	addi	a5,a5,4
    8000315a:	fec79ce3          	bne	a5,a2,80003152 <write_head+0x3a>
  }
  bwrite(buf);
    8000315e:	8526                	mv	a0,s1
    80003160:	97aff0ef          	jal	800022da <bwrite>
  brelse(buf);
    80003164:	8526                	mv	a0,s1
    80003166:	9a6ff0ef          	jal	8000230c <brelse>
}
    8000316a:	60e2                	ld	ra,24(sp)
    8000316c:	6442                	ld	s0,16(sp)
    8000316e:	64a2                	ld	s1,8(sp)
    80003170:	6902                	ld	s2,0(sp)
    80003172:	6105                	addi	sp,sp,32
    80003174:	8082                	ret

0000000080003176 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003176:	00023797          	auipc	a5,0x23
    8000317a:	2427a783          	lw	a5,578(a5) # 800263b8 <log+0x28>
    8000317e:	0af05e63          	blez	a5,8000323a <install_trans+0xc4>
{
    80003182:	715d                	addi	sp,sp,-80
    80003184:	e486                	sd	ra,72(sp)
    80003186:	e0a2                	sd	s0,64(sp)
    80003188:	fc26                	sd	s1,56(sp)
    8000318a:	f84a                	sd	s2,48(sp)
    8000318c:	f44e                	sd	s3,40(sp)
    8000318e:	f052                	sd	s4,32(sp)
    80003190:	ec56                	sd	s5,24(sp)
    80003192:	e85a                	sd	s6,16(sp)
    80003194:	e45e                	sd	s7,8(sp)
    80003196:	0880                	addi	s0,sp,80
    80003198:	8b2a                	mv	s6,a0
    8000319a:	00023a97          	auipc	s5,0x23
    8000319e:	222a8a93          	addi	s5,s5,546 # 800263bc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800031a2:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800031a4:	00004b97          	auipc	s7,0x4
    800031a8:	3d4b8b93          	addi	s7,s7,980 # 80007578 <etext+0x578>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800031ac:	00023a17          	auipc	s4,0x23
    800031b0:	1e4a0a13          	addi	s4,s4,484 # 80026390 <log>
    800031b4:	a025                	j	800031dc <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800031b6:	000aa603          	lw	a2,0(s5)
    800031ba:	85ce                	mv	a1,s3
    800031bc:	855e                	mv	a0,s7
    800031be:	5ea020ef          	jal	800057a8 <printf>
    800031c2:	a839                	j	800031e0 <install_trans+0x6a>
    brelse(lbuf);
    800031c4:	854a                	mv	a0,s2
    800031c6:	946ff0ef          	jal	8000230c <brelse>
    brelse(dbuf);
    800031ca:	8526                	mv	a0,s1
    800031cc:	940ff0ef          	jal	8000230c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800031d0:	2985                	addiw	s3,s3,1
    800031d2:	0a91                	addi	s5,s5,4
    800031d4:	028a2783          	lw	a5,40(s4)
    800031d8:	04f9d663          	bge	s3,a5,80003224 <install_trans+0xae>
    if(recovering) {
    800031dc:	fc0b1de3          	bnez	s6,800031b6 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800031e0:	018a2583          	lw	a1,24(s4)
    800031e4:	013585bb          	addw	a1,a1,s3
    800031e8:	2585                	addiw	a1,a1,1
    800031ea:	024a2503          	lw	a0,36(s4)
    800031ee:	816ff0ef          	jal	80002204 <bread>
    800031f2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800031f4:	000aa583          	lw	a1,0(s5)
    800031f8:	024a2503          	lw	a0,36(s4)
    800031fc:	808ff0ef          	jal	80002204 <bread>
    80003200:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003202:	40000613          	li	a2,1024
    80003206:	05890593          	addi	a1,s2,88
    8000320a:	05850513          	addi	a0,a0,88
    8000320e:	f9dfc0ef          	jal	800001aa <memmove>
    bwrite(dbuf);  // write dst to disk
    80003212:	8526                	mv	a0,s1
    80003214:	8c6ff0ef          	jal	800022da <bwrite>
    if(recovering == 0)
    80003218:	fa0b16e3          	bnez	s6,800031c4 <install_trans+0x4e>
      bunpin(dbuf);
    8000321c:	8526                	mv	a0,s1
    8000321e:	9aaff0ef          	jal	800023c8 <bunpin>
    80003222:	b74d                	j	800031c4 <install_trans+0x4e>
}
    80003224:	60a6                	ld	ra,72(sp)
    80003226:	6406                	ld	s0,64(sp)
    80003228:	74e2                	ld	s1,56(sp)
    8000322a:	7942                	ld	s2,48(sp)
    8000322c:	79a2                	ld	s3,40(sp)
    8000322e:	7a02                	ld	s4,32(sp)
    80003230:	6ae2                	ld	s5,24(sp)
    80003232:	6b42                	ld	s6,16(sp)
    80003234:	6ba2                	ld	s7,8(sp)
    80003236:	6161                	addi	sp,sp,80
    80003238:	8082                	ret
    8000323a:	8082                	ret

000000008000323c <initlog>:
{
    8000323c:	7179                	addi	sp,sp,-48
    8000323e:	f406                	sd	ra,40(sp)
    80003240:	f022                	sd	s0,32(sp)
    80003242:	ec26                	sd	s1,24(sp)
    80003244:	e84a                	sd	s2,16(sp)
    80003246:	e44e                	sd	s3,8(sp)
    80003248:	1800                	addi	s0,sp,48
    8000324a:	892a                	mv	s2,a0
    8000324c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000324e:	00023497          	auipc	s1,0x23
    80003252:	14248493          	addi	s1,s1,322 # 80026390 <log>
    80003256:	00004597          	auipc	a1,0x4
    8000325a:	34258593          	addi	a1,a1,834 # 80007598 <etext+0x598>
    8000325e:	8526                	mv	a0,s1
    80003260:	26b020ef          	jal	80005cca <initlock>
  log.start = sb->logstart;
    80003264:	0149a583          	lw	a1,20(s3)
    80003268:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    8000326a:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000326e:	854a                	mv	a0,s2
    80003270:	f95fe0ef          	jal	80002204 <bread>
  log.lh.n = lh->n;
    80003274:	4d30                	lw	a2,88(a0)
    80003276:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003278:	00c05f63          	blez	a2,80003296 <initlog+0x5a>
    8000327c:	87aa                	mv	a5,a0
    8000327e:	00023717          	auipc	a4,0x23
    80003282:	13e70713          	addi	a4,a4,318 # 800263bc <log+0x2c>
    80003286:	060a                	slli	a2,a2,0x2
    80003288:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000328a:	4ff4                	lw	a3,92(a5)
    8000328c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000328e:	0791                	addi	a5,a5,4
    80003290:	0711                	addi	a4,a4,4
    80003292:	fec79ce3          	bne	a5,a2,8000328a <initlog+0x4e>
  brelse(buf);
    80003296:	876ff0ef          	jal	8000230c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000329a:	4505                	li	a0,1
    8000329c:	edbff0ef          	jal	80003176 <install_trans>
  log.lh.n = 0;
    800032a0:	00023797          	auipc	a5,0x23
    800032a4:	1007ac23          	sw	zero,280(a5) # 800263b8 <log+0x28>
  write_head(); // clear the log
    800032a8:	e71ff0ef          	jal	80003118 <write_head>
}
    800032ac:	70a2                	ld	ra,40(sp)
    800032ae:	7402                	ld	s0,32(sp)
    800032b0:	64e2                	ld	s1,24(sp)
    800032b2:	6942                	ld	s2,16(sp)
    800032b4:	69a2                	ld	s3,8(sp)
    800032b6:	6145                	addi	sp,sp,48
    800032b8:	8082                	ret

00000000800032ba <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800032ba:	1101                	addi	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	e426                	sd	s1,8(sp)
    800032c2:	e04a                	sd	s2,0(sp)
    800032c4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800032c6:	00023517          	auipc	a0,0x23
    800032ca:	0ca50513          	addi	a0,a0,202 # 80026390 <log>
    800032ce:	27d020ef          	jal	80005d4a <acquire>
  while(1){
    if(log.committing){
    800032d2:	00023497          	auipc	s1,0x23
    800032d6:	0be48493          	addi	s1,s1,190 # 80026390 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800032da:	4979                	li	s2,30
    800032dc:	a029                	j	800032e6 <begin_op+0x2c>
      sleep(&log, &log.lock);
    800032de:	85a6                	mv	a1,s1
    800032e0:	8526                	mv	a0,s1
    800032e2:	8eefe0ef          	jal	800013d0 <sleep>
    if(log.committing){
    800032e6:	509c                	lw	a5,32(s1)
    800032e8:	fbfd                	bnez	a5,800032de <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800032ea:	4cd8                	lw	a4,28(s1)
    800032ec:	2705                	addiw	a4,a4,1
    800032ee:	0027179b          	slliw	a5,a4,0x2
    800032f2:	9fb9                	addw	a5,a5,a4
    800032f4:	0017979b          	slliw	a5,a5,0x1
    800032f8:	5494                	lw	a3,40(s1)
    800032fa:	9fb5                	addw	a5,a5,a3
    800032fc:	00f95763          	bge	s2,a5,8000330a <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003300:	85a6                	mv	a1,s1
    80003302:	8526                	mv	a0,s1
    80003304:	8ccfe0ef          	jal	800013d0 <sleep>
    80003308:	bff9                	j	800032e6 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    8000330a:	00023517          	auipc	a0,0x23
    8000330e:	08650513          	addi	a0,a0,134 # 80026390 <log>
    80003312:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003314:	2cf020ef          	jal	80005de2 <release>
      break;
    }
  }
}
    80003318:	60e2                	ld	ra,24(sp)
    8000331a:	6442                	ld	s0,16(sp)
    8000331c:	64a2                	ld	s1,8(sp)
    8000331e:	6902                	ld	s2,0(sp)
    80003320:	6105                	addi	sp,sp,32
    80003322:	8082                	ret

0000000080003324 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003324:	7139                	addi	sp,sp,-64
    80003326:	fc06                	sd	ra,56(sp)
    80003328:	f822                	sd	s0,48(sp)
    8000332a:	f426                	sd	s1,40(sp)
    8000332c:	f04a                	sd	s2,32(sp)
    8000332e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003330:	00023497          	auipc	s1,0x23
    80003334:	06048493          	addi	s1,s1,96 # 80026390 <log>
    80003338:	8526                	mv	a0,s1
    8000333a:	211020ef          	jal	80005d4a <acquire>
  log.outstanding -= 1;
    8000333e:	4cdc                	lw	a5,28(s1)
    80003340:	37fd                	addiw	a5,a5,-1
    80003342:	0007891b          	sext.w	s2,a5
    80003346:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003348:	509c                	lw	a5,32(s1)
    8000334a:	ef9d                	bnez	a5,80003388 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    8000334c:	04091763          	bnez	s2,8000339a <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003350:	00023497          	auipc	s1,0x23
    80003354:	04048493          	addi	s1,s1,64 # 80026390 <log>
    80003358:	4785                	li	a5,1
    8000335a:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000335c:	8526                	mv	a0,s1
    8000335e:	285020ef          	jal	80005de2 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003362:	549c                	lw	a5,40(s1)
    80003364:	04f04b63          	bgtz	a5,800033ba <end_op+0x96>
    acquire(&log.lock);
    80003368:	00023497          	auipc	s1,0x23
    8000336c:	02848493          	addi	s1,s1,40 # 80026390 <log>
    80003370:	8526                	mv	a0,s1
    80003372:	1d9020ef          	jal	80005d4a <acquire>
    log.committing = 0;
    80003376:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    8000337a:	8526                	mv	a0,s1
    8000337c:	8a0fe0ef          	jal	8000141c <wakeup>
    release(&log.lock);
    80003380:	8526                	mv	a0,s1
    80003382:	261020ef          	jal	80005de2 <release>
}
    80003386:	a025                	j	800033ae <end_op+0x8a>
    80003388:	ec4e                	sd	s3,24(sp)
    8000338a:	e852                	sd	s4,16(sp)
    8000338c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000338e:	00004517          	auipc	a0,0x4
    80003392:	21250513          	addi	a0,a0,530 # 800075a0 <etext+0x5a0>
    80003396:	6f8020ef          	jal	80005a8e <panic>
    wakeup(&log);
    8000339a:	00023497          	auipc	s1,0x23
    8000339e:	ff648493          	addi	s1,s1,-10 # 80026390 <log>
    800033a2:	8526                	mv	a0,s1
    800033a4:	878fe0ef          	jal	8000141c <wakeup>
  release(&log.lock);
    800033a8:	8526                	mv	a0,s1
    800033aa:	239020ef          	jal	80005de2 <release>
}
    800033ae:	70e2                	ld	ra,56(sp)
    800033b0:	7442                	ld	s0,48(sp)
    800033b2:	74a2                	ld	s1,40(sp)
    800033b4:	7902                	ld	s2,32(sp)
    800033b6:	6121                	addi	sp,sp,64
    800033b8:	8082                	ret
    800033ba:	ec4e                	sd	s3,24(sp)
    800033bc:	e852                	sd	s4,16(sp)
    800033be:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800033c0:	00023a97          	auipc	s5,0x23
    800033c4:	ffca8a93          	addi	s5,s5,-4 # 800263bc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800033c8:	00023a17          	auipc	s4,0x23
    800033cc:	fc8a0a13          	addi	s4,s4,-56 # 80026390 <log>
    800033d0:	018a2583          	lw	a1,24(s4)
    800033d4:	012585bb          	addw	a1,a1,s2
    800033d8:	2585                	addiw	a1,a1,1
    800033da:	024a2503          	lw	a0,36(s4)
    800033de:	e27fe0ef          	jal	80002204 <bread>
    800033e2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800033e4:	000aa583          	lw	a1,0(s5)
    800033e8:	024a2503          	lw	a0,36(s4)
    800033ec:	e19fe0ef          	jal	80002204 <bread>
    800033f0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800033f2:	40000613          	li	a2,1024
    800033f6:	05850593          	addi	a1,a0,88
    800033fa:	05848513          	addi	a0,s1,88
    800033fe:	dadfc0ef          	jal	800001aa <memmove>
    bwrite(to);  // write the log
    80003402:	8526                	mv	a0,s1
    80003404:	ed7fe0ef          	jal	800022da <bwrite>
    brelse(from);
    80003408:	854e                	mv	a0,s3
    8000340a:	f03fe0ef          	jal	8000230c <brelse>
    brelse(to);
    8000340e:	8526                	mv	a0,s1
    80003410:	efdfe0ef          	jal	8000230c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003414:	2905                	addiw	s2,s2,1
    80003416:	0a91                	addi	s5,s5,4
    80003418:	028a2783          	lw	a5,40(s4)
    8000341c:	faf94ae3          	blt	s2,a5,800033d0 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003420:	cf9ff0ef          	jal	80003118 <write_head>
    install_trans(0); // Now install writes to home locations
    80003424:	4501                	li	a0,0
    80003426:	d51ff0ef          	jal	80003176 <install_trans>
    log.lh.n = 0;
    8000342a:	00023797          	auipc	a5,0x23
    8000342e:	f807a723          	sw	zero,-114(a5) # 800263b8 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003432:	ce7ff0ef          	jal	80003118 <write_head>
    80003436:	69e2                	ld	s3,24(sp)
    80003438:	6a42                	ld	s4,16(sp)
    8000343a:	6aa2                	ld	s5,8(sp)
    8000343c:	b735                	j	80003368 <end_op+0x44>

000000008000343e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000343e:	1101                	addi	sp,sp,-32
    80003440:	ec06                	sd	ra,24(sp)
    80003442:	e822                	sd	s0,16(sp)
    80003444:	e426                	sd	s1,8(sp)
    80003446:	e04a                	sd	s2,0(sp)
    80003448:	1000                	addi	s0,sp,32
    8000344a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000344c:	00023917          	auipc	s2,0x23
    80003450:	f4490913          	addi	s2,s2,-188 # 80026390 <log>
    80003454:	854a                	mv	a0,s2
    80003456:	0f5020ef          	jal	80005d4a <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000345a:	02892603          	lw	a2,40(s2)
    8000345e:	47f5                	li	a5,29
    80003460:	04c7cc63          	blt	a5,a2,800034b8 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003464:	00023797          	auipc	a5,0x23
    80003468:	f487a783          	lw	a5,-184(a5) # 800263ac <log+0x1c>
    8000346c:	04f05c63          	blez	a5,800034c4 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003470:	4781                	li	a5,0
    80003472:	04c05f63          	blez	a2,800034d0 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003476:	44cc                	lw	a1,12(s1)
    80003478:	00023717          	auipc	a4,0x23
    8000347c:	f4470713          	addi	a4,a4,-188 # 800263bc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003480:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003482:	4314                	lw	a3,0(a4)
    80003484:	04b68663          	beq	a3,a1,800034d0 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003488:	2785                	addiw	a5,a5,1
    8000348a:	0711                	addi	a4,a4,4
    8000348c:	fef61be3          	bne	a2,a5,80003482 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003490:	0621                	addi	a2,a2,8
    80003492:	060a                	slli	a2,a2,0x2
    80003494:	00023797          	auipc	a5,0x23
    80003498:	efc78793          	addi	a5,a5,-260 # 80026390 <log>
    8000349c:	97b2                	add	a5,a5,a2
    8000349e:	44d8                	lw	a4,12(s1)
    800034a0:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800034a2:	8526                	mv	a0,s1
    800034a4:	ef1fe0ef          	jal	80002394 <bpin>
    log.lh.n++;
    800034a8:	00023717          	auipc	a4,0x23
    800034ac:	ee870713          	addi	a4,a4,-280 # 80026390 <log>
    800034b0:	571c                	lw	a5,40(a4)
    800034b2:	2785                	addiw	a5,a5,1
    800034b4:	d71c                	sw	a5,40(a4)
    800034b6:	a80d                	j	800034e8 <log_write+0xaa>
    panic("too big a transaction");
    800034b8:	00004517          	auipc	a0,0x4
    800034bc:	0f850513          	addi	a0,a0,248 # 800075b0 <etext+0x5b0>
    800034c0:	5ce020ef          	jal	80005a8e <panic>
    panic("log_write outside of trans");
    800034c4:	00004517          	auipc	a0,0x4
    800034c8:	10450513          	addi	a0,a0,260 # 800075c8 <etext+0x5c8>
    800034cc:	5c2020ef          	jal	80005a8e <panic>
  log.lh.block[i] = b->blockno;
    800034d0:	00878693          	addi	a3,a5,8
    800034d4:	068a                	slli	a3,a3,0x2
    800034d6:	00023717          	auipc	a4,0x23
    800034da:	eba70713          	addi	a4,a4,-326 # 80026390 <log>
    800034de:	9736                	add	a4,a4,a3
    800034e0:	44d4                	lw	a3,12(s1)
    800034e2:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800034e4:	faf60fe3          	beq	a2,a5,800034a2 <log_write+0x64>
  }
  release(&log.lock);
    800034e8:	00023517          	auipc	a0,0x23
    800034ec:	ea850513          	addi	a0,a0,-344 # 80026390 <log>
    800034f0:	0f3020ef          	jal	80005de2 <release>
}
    800034f4:	60e2                	ld	ra,24(sp)
    800034f6:	6442                	ld	s0,16(sp)
    800034f8:	64a2                	ld	s1,8(sp)
    800034fa:	6902                	ld	s2,0(sp)
    800034fc:	6105                	addi	sp,sp,32
    800034fe:	8082                	ret

0000000080003500 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003500:	1101                	addi	sp,sp,-32
    80003502:	ec06                	sd	ra,24(sp)
    80003504:	e822                	sd	s0,16(sp)
    80003506:	e426                	sd	s1,8(sp)
    80003508:	e04a                	sd	s2,0(sp)
    8000350a:	1000                	addi	s0,sp,32
    8000350c:	84aa                	mv	s1,a0
    8000350e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003510:	00004597          	auipc	a1,0x4
    80003514:	0d858593          	addi	a1,a1,216 # 800075e8 <etext+0x5e8>
    80003518:	0521                	addi	a0,a0,8
    8000351a:	7b0020ef          	jal	80005cca <initlock>
  lk->name = name;
    8000351e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003522:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003526:	0204a423          	sw	zero,40(s1)
}
    8000352a:	60e2                	ld	ra,24(sp)
    8000352c:	6442                	ld	s0,16(sp)
    8000352e:	64a2                	ld	s1,8(sp)
    80003530:	6902                	ld	s2,0(sp)
    80003532:	6105                	addi	sp,sp,32
    80003534:	8082                	ret

0000000080003536 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003536:	1101                	addi	sp,sp,-32
    80003538:	ec06                	sd	ra,24(sp)
    8000353a:	e822                	sd	s0,16(sp)
    8000353c:	e426                	sd	s1,8(sp)
    8000353e:	e04a                	sd	s2,0(sp)
    80003540:	1000                	addi	s0,sp,32
    80003542:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003544:	00850913          	addi	s2,a0,8
    80003548:	854a                	mv	a0,s2
    8000354a:	001020ef          	jal	80005d4a <acquire>
  while (lk->locked) {
    8000354e:	409c                	lw	a5,0(s1)
    80003550:	c799                	beqz	a5,8000355e <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003552:	85ca                	mv	a1,s2
    80003554:	8526                	mv	a0,s1
    80003556:	e7bfd0ef          	jal	800013d0 <sleep>
  while (lk->locked) {
    8000355a:	409c                	lw	a5,0(s1)
    8000355c:	fbfd                	bnez	a5,80003552 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000355e:	4785                	li	a5,1
    80003560:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003562:	819fd0ef          	jal	80000d7a <myproc>
    80003566:	591c                	lw	a5,48(a0)
    80003568:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000356a:	854a                	mv	a0,s2
    8000356c:	077020ef          	jal	80005de2 <release>
}
    80003570:	60e2                	ld	ra,24(sp)
    80003572:	6442                	ld	s0,16(sp)
    80003574:	64a2                	ld	s1,8(sp)
    80003576:	6902                	ld	s2,0(sp)
    80003578:	6105                	addi	sp,sp,32
    8000357a:	8082                	ret

000000008000357c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000357c:	1101                	addi	sp,sp,-32
    8000357e:	ec06                	sd	ra,24(sp)
    80003580:	e822                	sd	s0,16(sp)
    80003582:	e426                	sd	s1,8(sp)
    80003584:	e04a                	sd	s2,0(sp)
    80003586:	1000                	addi	s0,sp,32
    80003588:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000358a:	00850913          	addi	s2,a0,8
    8000358e:	854a                	mv	a0,s2
    80003590:	7ba020ef          	jal	80005d4a <acquire>
  lk->locked = 0;
    80003594:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003598:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000359c:	8526                	mv	a0,s1
    8000359e:	e7ffd0ef          	jal	8000141c <wakeup>
  release(&lk->lk);
    800035a2:	854a                	mv	a0,s2
    800035a4:	03f020ef          	jal	80005de2 <release>
}
    800035a8:	60e2                	ld	ra,24(sp)
    800035aa:	6442                	ld	s0,16(sp)
    800035ac:	64a2                	ld	s1,8(sp)
    800035ae:	6902                	ld	s2,0(sp)
    800035b0:	6105                	addi	sp,sp,32
    800035b2:	8082                	ret

00000000800035b4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800035b4:	7179                	addi	sp,sp,-48
    800035b6:	f406                	sd	ra,40(sp)
    800035b8:	f022                	sd	s0,32(sp)
    800035ba:	ec26                	sd	s1,24(sp)
    800035bc:	e84a                	sd	s2,16(sp)
    800035be:	1800                	addi	s0,sp,48
    800035c0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800035c2:	00850913          	addi	s2,a0,8
    800035c6:	854a                	mv	a0,s2
    800035c8:	782020ef          	jal	80005d4a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800035cc:	409c                	lw	a5,0(s1)
    800035ce:	ef81                	bnez	a5,800035e6 <holdingsleep+0x32>
    800035d0:	4481                	li	s1,0
  release(&lk->lk);
    800035d2:	854a                	mv	a0,s2
    800035d4:	00f020ef          	jal	80005de2 <release>
  return r;
}
    800035d8:	8526                	mv	a0,s1
    800035da:	70a2                	ld	ra,40(sp)
    800035dc:	7402                	ld	s0,32(sp)
    800035de:	64e2                	ld	s1,24(sp)
    800035e0:	6942                	ld	s2,16(sp)
    800035e2:	6145                	addi	sp,sp,48
    800035e4:	8082                	ret
    800035e6:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800035e8:	0284a983          	lw	s3,40(s1)
    800035ec:	f8efd0ef          	jal	80000d7a <myproc>
    800035f0:	5904                	lw	s1,48(a0)
    800035f2:	413484b3          	sub	s1,s1,s3
    800035f6:	0014b493          	seqz	s1,s1
    800035fa:	69a2                	ld	s3,8(sp)
    800035fc:	bfd9                	j	800035d2 <holdingsleep+0x1e>

00000000800035fe <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800035fe:	1141                	addi	sp,sp,-16
    80003600:	e406                	sd	ra,8(sp)
    80003602:	e022                	sd	s0,0(sp)
    80003604:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003606:	00004597          	auipc	a1,0x4
    8000360a:	ff258593          	addi	a1,a1,-14 # 800075f8 <etext+0x5f8>
    8000360e:	00023517          	auipc	a0,0x23
    80003612:	eca50513          	addi	a0,a0,-310 # 800264d8 <ftable>
    80003616:	6b4020ef          	jal	80005cca <initlock>
}
    8000361a:	60a2                	ld	ra,8(sp)
    8000361c:	6402                	ld	s0,0(sp)
    8000361e:	0141                	addi	sp,sp,16
    80003620:	8082                	ret

0000000080003622 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003622:	1101                	addi	sp,sp,-32
    80003624:	ec06                	sd	ra,24(sp)
    80003626:	e822                	sd	s0,16(sp)
    80003628:	e426                	sd	s1,8(sp)
    8000362a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000362c:	00023517          	auipc	a0,0x23
    80003630:	eac50513          	addi	a0,a0,-340 # 800264d8 <ftable>
    80003634:	716020ef          	jal	80005d4a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003638:	00023497          	auipc	s1,0x23
    8000363c:	eb848493          	addi	s1,s1,-328 # 800264f0 <ftable+0x18>
    80003640:	00024717          	auipc	a4,0x24
    80003644:	e5070713          	addi	a4,a4,-432 # 80027490 <disk>
    if(f->ref == 0){
    80003648:	40dc                	lw	a5,4(s1)
    8000364a:	cf89                	beqz	a5,80003664 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000364c:	02848493          	addi	s1,s1,40
    80003650:	fee49ce3          	bne	s1,a4,80003648 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003654:	00023517          	auipc	a0,0x23
    80003658:	e8450513          	addi	a0,a0,-380 # 800264d8 <ftable>
    8000365c:	786020ef          	jal	80005de2 <release>
  return 0;
    80003660:	4481                	li	s1,0
    80003662:	a809                	j	80003674 <filealloc+0x52>
      f->ref = 1;
    80003664:	4785                	li	a5,1
    80003666:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003668:	00023517          	auipc	a0,0x23
    8000366c:	e7050513          	addi	a0,a0,-400 # 800264d8 <ftable>
    80003670:	772020ef          	jal	80005de2 <release>
}
    80003674:	8526                	mv	a0,s1
    80003676:	60e2                	ld	ra,24(sp)
    80003678:	6442                	ld	s0,16(sp)
    8000367a:	64a2                	ld	s1,8(sp)
    8000367c:	6105                	addi	sp,sp,32
    8000367e:	8082                	ret

0000000080003680 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003680:	1101                	addi	sp,sp,-32
    80003682:	ec06                	sd	ra,24(sp)
    80003684:	e822                	sd	s0,16(sp)
    80003686:	e426                	sd	s1,8(sp)
    80003688:	1000                	addi	s0,sp,32
    8000368a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000368c:	00023517          	auipc	a0,0x23
    80003690:	e4c50513          	addi	a0,a0,-436 # 800264d8 <ftable>
    80003694:	6b6020ef          	jal	80005d4a <acquire>
  if(f->ref < 1)
    80003698:	40dc                	lw	a5,4(s1)
    8000369a:	02f05063          	blez	a5,800036ba <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000369e:	2785                	addiw	a5,a5,1
    800036a0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800036a2:	00023517          	auipc	a0,0x23
    800036a6:	e3650513          	addi	a0,a0,-458 # 800264d8 <ftable>
    800036aa:	738020ef          	jal	80005de2 <release>
  return f;
}
    800036ae:	8526                	mv	a0,s1
    800036b0:	60e2                	ld	ra,24(sp)
    800036b2:	6442                	ld	s0,16(sp)
    800036b4:	64a2                	ld	s1,8(sp)
    800036b6:	6105                	addi	sp,sp,32
    800036b8:	8082                	ret
    panic("filedup");
    800036ba:	00004517          	auipc	a0,0x4
    800036be:	f4650513          	addi	a0,a0,-186 # 80007600 <etext+0x600>
    800036c2:	3cc020ef          	jal	80005a8e <panic>

00000000800036c6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800036c6:	7139                	addi	sp,sp,-64
    800036c8:	fc06                	sd	ra,56(sp)
    800036ca:	f822                	sd	s0,48(sp)
    800036cc:	f426                	sd	s1,40(sp)
    800036ce:	0080                	addi	s0,sp,64
    800036d0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800036d2:	00023517          	auipc	a0,0x23
    800036d6:	e0650513          	addi	a0,a0,-506 # 800264d8 <ftable>
    800036da:	670020ef          	jal	80005d4a <acquire>
  if(f->ref < 1)
    800036de:	40dc                	lw	a5,4(s1)
    800036e0:	04f05a63          	blez	a5,80003734 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800036e4:	37fd                	addiw	a5,a5,-1
    800036e6:	0007871b          	sext.w	a4,a5
    800036ea:	c0dc                	sw	a5,4(s1)
    800036ec:	04e04e63          	bgtz	a4,80003748 <fileclose+0x82>
    800036f0:	f04a                	sd	s2,32(sp)
    800036f2:	ec4e                	sd	s3,24(sp)
    800036f4:	e852                	sd	s4,16(sp)
    800036f6:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800036f8:	0004a903          	lw	s2,0(s1)
    800036fc:	0094ca83          	lbu	s5,9(s1)
    80003700:	0104ba03          	ld	s4,16(s1)
    80003704:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003708:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000370c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003710:	00023517          	auipc	a0,0x23
    80003714:	dc850513          	addi	a0,a0,-568 # 800264d8 <ftable>
    80003718:	6ca020ef          	jal	80005de2 <release>

  if(ff.type == FD_PIPE){
    8000371c:	4785                	li	a5,1
    8000371e:	04f90063          	beq	s2,a5,8000375e <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003722:	3979                	addiw	s2,s2,-2
    80003724:	4785                	li	a5,1
    80003726:	0527f563          	bgeu	a5,s2,80003770 <fileclose+0xaa>
    8000372a:	7902                	ld	s2,32(sp)
    8000372c:	69e2                	ld	s3,24(sp)
    8000372e:	6a42                	ld	s4,16(sp)
    80003730:	6aa2                	ld	s5,8(sp)
    80003732:	a00d                	j	80003754 <fileclose+0x8e>
    80003734:	f04a                	sd	s2,32(sp)
    80003736:	ec4e                	sd	s3,24(sp)
    80003738:	e852                	sd	s4,16(sp)
    8000373a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000373c:	00004517          	auipc	a0,0x4
    80003740:	ecc50513          	addi	a0,a0,-308 # 80007608 <etext+0x608>
    80003744:	34a020ef          	jal	80005a8e <panic>
    release(&ftable.lock);
    80003748:	00023517          	auipc	a0,0x23
    8000374c:	d9050513          	addi	a0,a0,-624 # 800264d8 <ftable>
    80003750:	692020ef          	jal	80005de2 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003754:	70e2                	ld	ra,56(sp)
    80003756:	7442                	ld	s0,48(sp)
    80003758:	74a2                	ld	s1,40(sp)
    8000375a:	6121                	addi	sp,sp,64
    8000375c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000375e:	85d6                	mv	a1,s5
    80003760:	8552                	mv	a0,s4
    80003762:	336000ef          	jal	80003a98 <pipeclose>
    80003766:	7902                	ld	s2,32(sp)
    80003768:	69e2                	ld	s3,24(sp)
    8000376a:	6a42                	ld	s4,16(sp)
    8000376c:	6aa2                	ld	s5,8(sp)
    8000376e:	b7dd                	j	80003754 <fileclose+0x8e>
    begin_op();
    80003770:	b4bff0ef          	jal	800032ba <begin_op>
    iput(ff.ip);
    80003774:	854e                	mv	a0,s3
    80003776:	adcff0ef          	jal	80002a52 <iput>
    end_op();
    8000377a:	babff0ef          	jal	80003324 <end_op>
    8000377e:	7902                	ld	s2,32(sp)
    80003780:	69e2                	ld	s3,24(sp)
    80003782:	6a42                	ld	s4,16(sp)
    80003784:	6aa2                	ld	s5,8(sp)
    80003786:	b7f9                	j	80003754 <fileclose+0x8e>

0000000080003788 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003788:	715d                	addi	sp,sp,-80
    8000378a:	e486                	sd	ra,72(sp)
    8000378c:	e0a2                	sd	s0,64(sp)
    8000378e:	fc26                	sd	s1,56(sp)
    80003790:	f44e                	sd	s3,40(sp)
    80003792:	0880                	addi	s0,sp,80
    80003794:	84aa                	mv	s1,a0
    80003796:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003798:	de2fd0ef          	jal	80000d7a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000379c:	409c                	lw	a5,0(s1)
    8000379e:	37f9                	addiw	a5,a5,-2
    800037a0:	4705                	li	a4,1
    800037a2:	04f76063          	bltu	a4,a5,800037e2 <filestat+0x5a>
    800037a6:	f84a                	sd	s2,48(sp)
    800037a8:	892a                	mv	s2,a0
    ilock(f->ip);
    800037aa:	6c88                	ld	a0,24(s1)
    800037ac:	924ff0ef          	jal	800028d0 <ilock>
    stati(f->ip, &st);
    800037b0:	fb840593          	addi	a1,s0,-72
    800037b4:	6c88                	ld	a0,24(s1)
    800037b6:	c80ff0ef          	jal	80002c36 <stati>
    iunlock(f->ip);
    800037ba:	6c88                	ld	a0,24(s1)
    800037bc:	9c2ff0ef          	jal	8000297e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800037c0:	46e1                	li	a3,24
    800037c2:	fb840613          	addi	a2,s0,-72
    800037c6:	85ce                	mv	a1,s3
    800037c8:	05093503          	ld	a0,80(s2)
    800037cc:	ac2fd0ef          	jal	80000a8e <copyout>
    800037d0:	41f5551b          	sraiw	a0,a0,0x1f
    800037d4:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800037d6:	60a6                	ld	ra,72(sp)
    800037d8:	6406                	ld	s0,64(sp)
    800037da:	74e2                	ld	s1,56(sp)
    800037dc:	79a2                	ld	s3,40(sp)
    800037de:	6161                	addi	sp,sp,80
    800037e0:	8082                	ret
  return -1;
    800037e2:	557d                	li	a0,-1
    800037e4:	bfcd                	j	800037d6 <filestat+0x4e>

00000000800037e6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800037e6:	7179                	addi	sp,sp,-48
    800037e8:	f406                	sd	ra,40(sp)
    800037ea:	f022                	sd	s0,32(sp)
    800037ec:	e84a                	sd	s2,16(sp)
    800037ee:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800037f0:	00854783          	lbu	a5,8(a0)
    800037f4:	cfd1                	beqz	a5,80003890 <fileread+0xaa>
    800037f6:	ec26                	sd	s1,24(sp)
    800037f8:	e44e                	sd	s3,8(sp)
    800037fa:	84aa                	mv	s1,a0
    800037fc:	89ae                	mv	s3,a1
    800037fe:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003800:	411c                	lw	a5,0(a0)
    80003802:	4705                	li	a4,1
    80003804:	04e78363          	beq	a5,a4,8000384a <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003808:	470d                	li	a4,3
    8000380a:	04e78763          	beq	a5,a4,80003858 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000380e:	4709                	li	a4,2
    80003810:	06e79a63          	bne	a5,a4,80003884 <fileread+0x9e>
    ilock(f->ip);
    80003814:	6d08                	ld	a0,24(a0)
    80003816:	8baff0ef          	jal	800028d0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000381a:	874a                	mv	a4,s2
    8000381c:	5094                	lw	a3,32(s1)
    8000381e:	864e                	mv	a2,s3
    80003820:	4585                	li	a1,1
    80003822:	6c88                	ld	a0,24(s1)
    80003824:	c3cff0ef          	jal	80002c60 <readi>
    80003828:	892a                	mv	s2,a0
    8000382a:	00a05563          	blez	a0,80003834 <fileread+0x4e>
      f->off += r;
    8000382e:	509c                	lw	a5,32(s1)
    80003830:	9fa9                	addw	a5,a5,a0
    80003832:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003834:	6c88                	ld	a0,24(s1)
    80003836:	948ff0ef          	jal	8000297e <iunlock>
    8000383a:	64e2                	ld	s1,24(sp)
    8000383c:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000383e:	854a                	mv	a0,s2
    80003840:	70a2                	ld	ra,40(sp)
    80003842:	7402                	ld	s0,32(sp)
    80003844:	6942                	ld	s2,16(sp)
    80003846:	6145                	addi	sp,sp,48
    80003848:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000384a:	6908                	ld	a0,16(a0)
    8000384c:	388000ef          	jal	80003bd4 <piperead>
    80003850:	892a                	mv	s2,a0
    80003852:	64e2                	ld	s1,24(sp)
    80003854:	69a2                	ld	s3,8(sp)
    80003856:	b7e5                	j	8000383e <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003858:	02451783          	lh	a5,36(a0)
    8000385c:	03079693          	slli	a3,a5,0x30
    80003860:	92c1                	srli	a3,a3,0x30
    80003862:	4725                	li	a4,9
    80003864:	02d76863          	bltu	a4,a3,80003894 <fileread+0xae>
    80003868:	0792                	slli	a5,a5,0x4
    8000386a:	00023717          	auipc	a4,0x23
    8000386e:	bce70713          	addi	a4,a4,-1074 # 80026438 <devsw>
    80003872:	97ba                	add	a5,a5,a4
    80003874:	639c                	ld	a5,0(a5)
    80003876:	c39d                	beqz	a5,8000389c <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80003878:	4505                	li	a0,1
    8000387a:	9782                	jalr	a5
    8000387c:	892a                	mv	s2,a0
    8000387e:	64e2                	ld	s1,24(sp)
    80003880:	69a2                	ld	s3,8(sp)
    80003882:	bf75                	j	8000383e <fileread+0x58>
    panic("fileread");
    80003884:	00004517          	auipc	a0,0x4
    80003888:	d9450513          	addi	a0,a0,-620 # 80007618 <etext+0x618>
    8000388c:	202020ef          	jal	80005a8e <panic>
    return -1;
    80003890:	597d                	li	s2,-1
    80003892:	b775                	j	8000383e <fileread+0x58>
      return -1;
    80003894:	597d                	li	s2,-1
    80003896:	64e2                	ld	s1,24(sp)
    80003898:	69a2                	ld	s3,8(sp)
    8000389a:	b755                	j	8000383e <fileread+0x58>
    8000389c:	597d                	li	s2,-1
    8000389e:	64e2                	ld	s1,24(sp)
    800038a0:	69a2                	ld	s3,8(sp)
    800038a2:	bf71                	j	8000383e <fileread+0x58>

00000000800038a4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800038a4:	00954783          	lbu	a5,9(a0)
    800038a8:	10078b63          	beqz	a5,800039be <filewrite+0x11a>
{
    800038ac:	715d                	addi	sp,sp,-80
    800038ae:	e486                	sd	ra,72(sp)
    800038b0:	e0a2                	sd	s0,64(sp)
    800038b2:	f84a                	sd	s2,48(sp)
    800038b4:	f052                	sd	s4,32(sp)
    800038b6:	e85a                	sd	s6,16(sp)
    800038b8:	0880                	addi	s0,sp,80
    800038ba:	892a                	mv	s2,a0
    800038bc:	8b2e                	mv	s6,a1
    800038be:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800038c0:	411c                	lw	a5,0(a0)
    800038c2:	4705                	li	a4,1
    800038c4:	02e78763          	beq	a5,a4,800038f2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800038c8:	470d                	li	a4,3
    800038ca:	02e78863          	beq	a5,a4,800038fa <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800038ce:	4709                	li	a4,2
    800038d0:	0ce79c63          	bne	a5,a4,800039a8 <filewrite+0x104>
    800038d4:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800038d6:	0ac05863          	blez	a2,80003986 <filewrite+0xe2>
    800038da:	fc26                	sd	s1,56(sp)
    800038dc:	ec56                	sd	s5,24(sp)
    800038de:	e45e                	sd	s7,8(sp)
    800038e0:	e062                	sd	s8,0(sp)
    int i = 0;
    800038e2:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800038e4:	6b85                	lui	s7,0x1
    800038e6:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800038ea:	6c05                	lui	s8,0x1
    800038ec:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800038f0:	a8b5                	j	8000396c <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800038f2:	6908                	ld	a0,16(a0)
    800038f4:	1fc000ef          	jal	80003af0 <pipewrite>
    800038f8:	a04d                	j	8000399a <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800038fa:	02451783          	lh	a5,36(a0)
    800038fe:	03079693          	slli	a3,a5,0x30
    80003902:	92c1                	srli	a3,a3,0x30
    80003904:	4725                	li	a4,9
    80003906:	0ad76e63          	bltu	a4,a3,800039c2 <filewrite+0x11e>
    8000390a:	0792                	slli	a5,a5,0x4
    8000390c:	00023717          	auipc	a4,0x23
    80003910:	b2c70713          	addi	a4,a4,-1236 # 80026438 <devsw>
    80003914:	97ba                	add	a5,a5,a4
    80003916:	679c                	ld	a5,8(a5)
    80003918:	c7dd                	beqz	a5,800039c6 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000391a:	4505                	li	a0,1
    8000391c:	9782                	jalr	a5
    8000391e:	a8b5                	j	8000399a <filewrite+0xf6>
      if(n1 > max)
    80003920:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80003924:	997ff0ef          	jal	800032ba <begin_op>
      ilock(f->ip);
    80003928:	01893503          	ld	a0,24(s2)
    8000392c:	fa5fe0ef          	jal	800028d0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003930:	8756                	mv	a4,s5
    80003932:	02092683          	lw	a3,32(s2)
    80003936:	01698633          	add	a2,s3,s6
    8000393a:	4585                	li	a1,1
    8000393c:	01893503          	ld	a0,24(s2)
    80003940:	c1cff0ef          	jal	80002d5c <writei>
    80003944:	84aa                	mv	s1,a0
    80003946:	00a05763          	blez	a0,80003954 <filewrite+0xb0>
        f->off += r;
    8000394a:	02092783          	lw	a5,32(s2)
    8000394e:	9fa9                	addw	a5,a5,a0
    80003950:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003954:	01893503          	ld	a0,24(s2)
    80003958:	826ff0ef          	jal	8000297e <iunlock>
      end_op();
    8000395c:	9c9ff0ef          	jal	80003324 <end_op>

      if(r != n1){
    80003960:	029a9563          	bne	s5,s1,8000398a <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80003964:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003968:	0149da63          	bge	s3,s4,8000397c <filewrite+0xd8>
      int n1 = n - i;
    8000396c:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80003970:	0004879b          	sext.w	a5,s1
    80003974:	fafbd6e3          	bge	s7,a5,80003920 <filewrite+0x7c>
    80003978:	84e2                	mv	s1,s8
    8000397a:	b75d                	j	80003920 <filewrite+0x7c>
    8000397c:	74e2                	ld	s1,56(sp)
    8000397e:	6ae2                	ld	s5,24(sp)
    80003980:	6ba2                	ld	s7,8(sp)
    80003982:	6c02                	ld	s8,0(sp)
    80003984:	a039                	j	80003992 <filewrite+0xee>
    int i = 0;
    80003986:	4981                	li	s3,0
    80003988:	a029                	j	80003992 <filewrite+0xee>
    8000398a:	74e2                	ld	s1,56(sp)
    8000398c:	6ae2                	ld	s5,24(sp)
    8000398e:	6ba2                	ld	s7,8(sp)
    80003990:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80003992:	033a1c63          	bne	s4,s3,800039ca <filewrite+0x126>
    80003996:	8552                	mv	a0,s4
    80003998:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000399a:	60a6                	ld	ra,72(sp)
    8000399c:	6406                	ld	s0,64(sp)
    8000399e:	7942                	ld	s2,48(sp)
    800039a0:	7a02                	ld	s4,32(sp)
    800039a2:	6b42                	ld	s6,16(sp)
    800039a4:	6161                	addi	sp,sp,80
    800039a6:	8082                	ret
    800039a8:	fc26                	sd	s1,56(sp)
    800039aa:	f44e                	sd	s3,40(sp)
    800039ac:	ec56                	sd	s5,24(sp)
    800039ae:	e45e                	sd	s7,8(sp)
    800039b0:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800039b2:	00004517          	auipc	a0,0x4
    800039b6:	c7650513          	addi	a0,a0,-906 # 80007628 <etext+0x628>
    800039ba:	0d4020ef          	jal	80005a8e <panic>
    return -1;
    800039be:	557d                	li	a0,-1
}
    800039c0:	8082                	ret
      return -1;
    800039c2:	557d                	li	a0,-1
    800039c4:	bfd9                	j	8000399a <filewrite+0xf6>
    800039c6:	557d                	li	a0,-1
    800039c8:	bfc9                	j	8000399a <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800039ca:	557d                	li	a0,-1
    800039cc:	79a2                	ld	s3,40(sp)
    800039ce:	b7f1                	j	8000399a <filewrite+0xf6>

00000000800039d0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800039d0:	7179                	addi	sp,sp,-48
    800039d2:	f406                	sd	ra,40(sp)
    800039d4:	f022                	sd	s0,32(sp)
    800039d6:	ec26                	sd	s1,24(sp)
    800039d8:	e052                	sd	s4,0(sp)
    800039da:	1800                	addi	s0,sp,48
    800039dc:	84aa                	mv	s1,a0
    800039de:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800039e0:	0005b023          	sd	zero,0(a1)
    800039e4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800039e8:	c3bff0ef          	jal	80003622 <filealloc>
    800039ec:	e088                	sd	a0,0(s1)
    800039ee:	c549                	beqz	a0,80003a78 <pipealloc+0xa8>
    800039f0:	c33ff0ef          	jal	80003622 <filealloc>
    800039f4:	00aa3023          	sd	a0,0(s4)
    800039f8:	cd25                	beqz	a0,80003a70 <pipealloc+0xa0>
    800039fa:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800039fc:	f02fc0ef          	jal	800000fe <kalloc>
    80003a00:	892a                	mv	s2,a0
    80003a02:	c12d                	beqz	a0,80003a64 <pipealloc+0x94>
    80003a04:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80003a06:	4985                	li	s3,1
    80003a08:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003a0c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003a10:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003a14:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003a18:	00004597          	auipc	a1,0x4
    80003a1c:	c2058593          	addi	a1,a1,-992 # 80007638 <etext+0x638>
    80003a20:	2aa020ef          	jal	80005cca <initlock>
  (*f0)->type = FD_PIPE;
    80003a24:	609c                	ld	a5,0(s1)
    80003a26:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003a2a:	609c                	ld	a5,0(s1)
    80003a2c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003a30:	609c                	ld	a5,0(s1)
    80003a32:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003a36:	609c                	ld	a5,0(s1)
    80003a38:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003a3c:	000a3783          	ld	a5,0(s4)
    80003a40:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003a44:	000a3783          	ld	a5,0(s4)
    80003a48:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003a4c:	000a3783          	ld	a5,0(s4)
    80003a50:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003a54:	000a3783          	ld	a5,0(s4)
    80003a58:	0127b823          	sd	s2,16(a5)
  return 0;
    80003a5c:	4501                	li	a0,0
    80003a5e:	6942                	ld	s2,16(sp)
    80003a60:	69a2                	ld	s3,8(sp)
    80003a62:	a01d                	j	80003a88 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003a64:	6088                	ld	a0,0(s1)
    80003a66:	c119                	beqz	a0,80003a6c <pipealloc+0x9c>
    80003a68:	6942                	ld	s2,16(sp)
    80003a6a:	a029                	j	80003a74 <pipealloc+0xa4>
    80003a6c:	6942                	ld	s2,16(sp)
    80003a6e:	a029                	j	80003a78 <pipealloc+0xa8>
    80003a70:	6088                	ld	a0,0(s1)
    80003a72:	c10d                	beqz	a0,80003a94 <pipealloc+0xc4>
    fileclose(*f0);
    80003a74:	c53ff0ef          	jal	800036c6 <fileclose>
  if(*f1)
    80003a78:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003a7c:	557d                	li	a0,-1
  if(*f1)
    80003a7e:	c789                	beqz	a5,80003a88 <pipealloc+0xb8>
    fileclose(*f1);
    80003a80:	853e                	mv	a0,a5
    80003a82:	c45ff0ef          	jal	800036c6 <fileclose>
  return -1;
    80003a86:	557d                	li	a0,-1
}
    80003a88:	70a2                	ld	ra,40(sp)
    80003a8a:	7402                	ld	s0,32(sp)
    80003a8c:	64e2                	ld	s1,24(sp)
    80003a8e:	6a02                	ld	s4,0(sp)
    80003a90:	6145                	addi	sp,sp,48
    80003a92:	8082                	ret
  return -1;
    80003a94:	557d                	li	a0,-1
    80003a96:	bfcd                	j	80003a88 <pipealloc+0xb8>

0000000080003a98 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003a98:	1101                	addi	sp,sp,-32
    80003a9a:	ec06                	sd	ra,24(sp)
    80003a9c:	e822                	sd	s0,16(sp)
    80003a9e:	e426                	sd	s1,8(sp)
    80003aa0:	e04a                	sd	s2,0(sp)
    80003aa2:	1000                	addi	s0,sp,32
    80003aa4:	84aa                	mv	s1,a0
    80003aa6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003aa8:	2a2020ef          	jal	80005d4a <acquire>
  if(writable){
    80003aac:	02090763          	beqz	s2,80003ada <pipeclose+0x42>
    pi->writeopen = 0;
    80003ab0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003ab4:	21848513          	addi	a0,s1,536
    80003ab8:	965fd0ef          	jal	8000141c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003abc:	2204b783          	ld	a5,544(s1)
    80003ac0:	e785                	bnez	a5,80003ae8 <pipeclose+0x50>
    release(&pi->lock);
    80003ac2:	8526                	mv	a0,s1
    80003ac4:	31e020ef          	jal	80005de2 <release>
    kfree((char*)pi);
    80003ac8:	8526                	mv	a0,s1
    80003aca:	d52fc0ef          	jal	8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003ace:	60e2                	ld	ra,24(sp)
    80003ad0:	6442                	ld	s0,16(sp)
    80003ad2:	64a2                	ld	s1,8(sp)
    80003ad4:	6902                	ld	s2,0(sp)
    80003ad6:	6105                	addi	sp,sp,32
    80003ad8:	8082                	ret
    pi->readopen = 0;
    80003ada:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003ade:	21c48513          	addi	a0,s1,540
    80003ae2:	93bfd0ef          	jal	8000141c <wakeup>
    80003ae6:	bfd9                	j	80003abc <pipeclose+0x24>
    release(&pi->lock);
    80003ae8:	8526                	mv	a0,s1
    80003aea:	2f8020ef          	jal	80005de2 <release>
}
    80003aee:	b7c5                	j	80003ace <pipeclose+0x36>

0000000080003af0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003af0:	711d                	addi	sp,sp,-96
    80003af2:	ec86                	sd	ra,88(sp)
    80003af4:	e8a2                	sd	s0,80(sp)
    80003af6:	e4a6                	sd	s1,72(sp)
    80003af8:	e0ca                	sd	s2,64(sp)
    80003afa:	fc4e                	sd	s3,56(sp)
    80003afc:	f852                	sd	s4,48(sp)
    80003afe:	f456                	sd	s5,40(sp)
    80003b00:	1080                	addi	s0,sp,96
    80003b02:	84aa                	mv	s1,a0
    80003b04:	8aae                	mv	s5,a1
    80003b06:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003b08:	a72fd0ef          	jal	80000d7a <myproc>
    80003b0c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003b0e:	8526                	mv	a0,s1
    80003b10:	23a020ef          	jal	80005d4a <acquire>
  while(i < n){
    80003b14:	0b405a63          	blez	s4,80003bc8 <pipewrite+0xd8>
    80003b18:	f05a                	sd	s6,32(sp)
    80003b1a:	ec5e                	sd	s7,24(sp)
    80003b1c:	e862                	sd	s8,16(sp)
  int i = 0;
    80003b1e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003b20:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003b22:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003b26:	21c48b93          	addi	s7,s1,540
    80003b2a:	a81d                	j	80003b60 <pipewrite+0x70>
      release(&pi->lock);
    80003b2c:	8526                	mv	a0,s1
    80003b2e:	2b4020ef          	jal	80005de2 <release>
      return -1;
    80003b32:	597d                	li	s2,-1
    80003b34:	7b02                	ld	s6,32(sp)
    80003b36:	6be2                	ld	s7,24(sp)
    80003b38:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003b3a:	854a                	mv	a0,s2
    80003b3c:	60e6                	ld	ra,88(sp)
    80003b3e:	6446                	ld	s0,80(sp)
    80003b40:	64a6                	ld	s1,72(sp)
    80003b42:	6906                	ld	s2,64(sp)
    80003b44:	79e2                	ld	s3,56(sp)
    80003b46:	7a42                	ld	s4,48(sp)
    80003b48:	7aa2                	ld	s5,40(sp)
    80003b4a:	6125                	addi	sp,sp,96
    80003b4c:	8082                	ret
      wakeup(&pi->nread);
    80003b4e:	8562                	mv	a0,s8
    80003b50:	8cdfd0ef          	jal	8000141c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003b54:	85a6                	mv	a1,s1
    80003b56:	855e                	mv	a0,s7
    80003b58:	879fd0ef          	jal	800013d0 <sleep>
  while(i < n){
    80003b5c:	05495b63          	bge	s2,s4,80003bb2 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80003b60:	2204a783          	lw	a5,544(s1)
    80003b64:	d7e1                	beqz	a5,80003b2c <pipewrite+0x3c>
    80003b66:	854e                	mv	a0,s3
    80003b68:	b1dfd0ef          	jal	80001684 <killed>
    80003b6c:	f161                	bnez	a0,80003b2c <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003b6e:	2184a783          	lw	a5,536(s1)
    80003b72:	21c4a703          	lw	a4,540(s1)
    80003b76:	2007879b          	addiw	a5,a5,512
    80003b7a:	fcf70ae3          	beq	a4,a5,80003b4e <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003b7e:	4685                	li	a3,1
    80003b80:	01590633          	add	a2,s2,s5
    80003b84:	faf40593          	addi	a1,s0,-81
    80003b88:	0509b503          	ld	a0,80(s3)
    80003b8c:	fe7fc0ef          	jal	80000b72 <copyin>
    80003b90:	03650e63          	beq	a0,s6,80003bcc <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003b94:	21c4a783          	lw	a5,540(s1)
    80003b98:	0017871b          	addiw	a4,a5,1
    80003b9c:	20e4ae23          	sw	a4,540(s1)
    80003ba0:	1ff7f793          	andi	a5,a5,511
    80003ba4:	97a6                	add	a5,a5,s1
    80003ba6:	faf44703          	lbu	a4,-81(s0)
    80003baa:	00e78c23          	sb	a4,24(a5)
      i++;
    80003bae:	2905                	addiw	s2,s2,1
    80003bb0:	b775                	j	80003b5c <pipewrite+0x6c>
    80003bb2:	7b02                	ld	s6,32(sp)
    80003bb4:	6be2                	ld	s7,24(sp)
    80003bb6:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80003bb8:	21848513          	addi	a0,s1,536
    80003bbc:	861fd0ef          	jal	8000141c <wakeup>
  release(&pi->lock);
    80003bc0:	8526                	mv	a0,s1
    80003bc2:	220020ef          	jal	80005de2 <release>
  return i;
    80003bc6:	bf95                	j	80003b3a <pipewrite+0x4a>
  int i = 0;
    80003bc8:	4901                	li	s2,0
    80003bca:	b7fd                	j	80003bb8 <pipewrite+0xc8>
    80003bcc:	7b02                	ld	s6,32(sp)
    80003bce:	6be2                	ld	s7,24(sp)
    80003bd0:	6c42                	ld	s8,16(sp)
    80003bd2:	b7dd                	j	80003bb8 <pipewrite+0xc8>

0000000080003bd4 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003bd4:	715d                	addi	sp,sp,-80
    80003bd6:	e486                	sd	ra,72(sp)
    80003bd8:	e0a2                	sd	s0,64(sp)
    80003bda:	fc26                	sd	s1,56(sp)
    80003bdc:	f84a                	sd	s2,48(sp)
    80003bde:	f44e                	sd	s3,40(sp)
    80003be0:	f052                	sd	s4,32(sp)
    80003be2:	ec56                	sd	s5,24(sp)
    80003be4:	0880                	addi	s0,sp,80
    80003be6:	84aa                	mv	s1,a0
    80003be8:	892e                	mv	s2,a1
    80003bea:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003bec:	98efd0ef          	jal	80000d7a <myproc>
    80003bf0:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003bf2:	8526                	mv	a0,s1
    80003bf4:	156020ef          	jal	80005d4a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003bf8:	2184a703          	lw	a4,536(s1)
    80003bfc:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003c00:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003c04:	02f71563          	bne	a4,a5,80003c2e <piperead+0x5a>
    80003c08:	2244a783          	lw	a5,548(s1)
    80003c0c:	cb85                	beqz	a5,80003c3c <piperead+0x68>
    if(killed(pr)){
    80003c0e:	8552                	mv	a0,s4
    80003c10:	a75fd0ef          	jal	80001684 <killed>
    80003c14:	ed19                	bnez	a0,80003c32 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003c16:	85a6                	mv	a1,s1
    80003c18:	854e                	mv	a0,s3
    80003c1a:	fb6fd0ef          	jal	800013d0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003c1e:	2184a703          	lw	a4,536(s1)
    80003c22:	21c4a783          	lw	a5,540(s1)
    80003c26:	fef701e3          	beq	a4,a5,80003c08 <piperead+0x34>
    80003c2a:	e85a                	sd	s6,16(sp)
    80003c2c:	a809                	j	80003c3e <piperead+0x6a>
    80003c2e:	e85a                	sd	s6,16(sp)
    80003c30:	a039                	j	80003c3e <piperead+0x6a>
      release(&pi->lock);
    80003c32:	8526                	mv	a0,s1
    80003c34:	1ae020ef          	jal	80005de2 <release>
      return -1;
    80003c38:	59fd                	li	s3,-1
    80003c3a:	a8b1                	j	80003c96 <piperead+0xc2>
    80003c3c:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003c3e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003c40:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003c42:	05505263          	blez	s5,80003c86 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80003c46:	2184a783          	lw	a5,536(s1)
    80003c4a:	21c4a703          	lw	a4,540(s1)
    80003c4e:	02f70c63          	beq	a4,a5,80003c86 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003c52:	0017871b          	addiw	a4,a5,1
    80003c56:	20e4ac23          	sw	a4,536(s1)
    80003c5a:	1ff7f793          	andi	a5,a5,511
    80003c5e:	97a6                	add	a5,a5,s1
    80003c60:	0187c783          	lbu	a5,24(a5)
    80003c64:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003c68:	4685                	li	a3,1
    80003c6a:	fbf40613          	addi	a2,s0,-65
    80003c6e:	85ca                	mv	a1,s2
    80003c70:	050a3503          	ld	a0,80(s4)
    80003c74:	e1bfc0ef          	jal	80000a8e <copyout>
    80003c78:	01650763          	beq	a0,s6,80003c86 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003c7c:	2985                	addiw	s3,s3,1
    80003c7e:	0905                	addi	s2,s2,1
    80003c80:	fd3a93e3          	bne	s5,s3,80003c46 <piperead+0x72>
    80003c84:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003c86:	21c48513          	addi	a0,s1,540
    80003c8a:	f92fd0ef          	jal	8000141c <wakeup>
  release(&pi->lock);
    80003c8e:	8526                	mv	a0,s1
    80003c90:	152020ef          	jal	80005de2 <release>
    80003c94:	6b42                	ld	s6,16(sp)
  return i;
}
    80003c96:	854e                	mv	a0,s3
    80003c98:	60a6                	ld	ra,72(sp)
    80003c9a:	6406                	ld	s0,64(sp)
    80003c9c:	74e2                	ld	s1,56(sp)
    80003c9e:	7942                	ld	s2,48(sp)
    80003ca0:	79a2                	ld	s3,40(sp)
    80003ca2:	7a02                	ld	s4,32(sp)
    80003ca4:	6ae2                	ld	s5,24(sp)
    80003ca6:	6161                	addi	sp,sp,80
    80003ca8:	8082                	ret

0000000080003caa <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80003caa:	1141                	addi	sp,sp,-16
    80003cac:	e422                	sd	s0,8(sp)
    80003cae:	0800                	addi	s0,sp,16
    80003cb0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003cb2:	8905                	andi	a0,a0,1
    80003cb4:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003cb6:	8b89                	andi	a5,a5,2
    80003cb8:	c399                	beqz	a5,80003cbe <flags2perm+0x14>
      perm |= PTE_W;
    80003cba:	00456513          	ori	a0,a0,4
    return perm;
}
    80003cbe:	6422                	ld	s0,8(sp)
    80003cc0:	0141                	addi	sp,sp,16
    80003cc2:	8082                	ret

0000000080003cc4 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80003cc4:	df010113          	addi	sp,sp,-528
    80003cc8:	20113423          	sd	ra,520(sp)
    80003ccc:	20813023          	sd	s0,512(sp)
    80003cd0:	ffa6                	sd	s1,504(sp)
    80003cd2:	fbca                	sd	s2,496(sp)
    80003cd4:	0c00                	addi	s0,sp,528
    80003cd6:	892a                	mv	s2,a0
    80003cd8:	dea43c23          	sd	a0,-520(s0)
    80003cdc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003ce0:	89afd0ef          	jal	80000d7a <myproc>
    80003ce4:	84aa                	mv	s1,a0

  begin_op();
    80003ce6:	dd4ff0ef          	jal	800032ba <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80003cea:	854a                	mv	a0,s2
    80003cec:	bfaff0ef          	jal	800030e6 <namei>
    80003cf0:	c931                	beqz	a0,80003d44 <kexec+0x80>
    80003cf2:	f3d2                	sd	s4,480(sp)
    80003cf4:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003cf6:	bdbfe0ef          	jal	800028d0 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003cfa:	04000713          	li	a4,64
    80003cfe:	4681                	li	a3,0
    80003d00:	e5040613          	addi	a2,s0,-432
    80003d04:	4581                	li	a1,0
    80003d06:	8552                	mv	a0,s4
    80003d08:	f59fe0ef          	jal	80002c60 <readi>
    80003d0c:	04000793          	li	a5,64
    80003d10:	00f51a63          	bne	a0,a5,80003d24 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80003d14:	e5042703          	lw	a4,-432(s0)
    80003d18:	464c47b7          	lui	a5,0x464c4
    80003d1c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003d20:	02f70663          	beq	a4,a5,80003d4c <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003d24:	8552                	mv	a0,s4
    80003d26:	db5fe0ef          	jal	80002ada <iunlockput>
    end_op();
    80003d2a:	dfaff0ef          	jal	80003324 <end_op>
  }
  return -1;
    80003d2e:	557d                	li	a0,-1
    80003d30:	7a1e                	ld	s4,480(sp)
}
    80003d32:	20813083          	ld	ra,520(sp)
    80003d36:	20013403          	ld	s0,512(sp)
    80003d3a:	74fe                	ld	s1,504(sp)
    80003d3c:	795e                	ld	s2,496(sp)
    80003d3e:	21010113          	addi	sp,sp,528
    80003d42:	8082                	ret
    end_op();
    80003d44:	de0ff0ef          	jal	80003324 <end_op>
    return -1;
    80003d48:	557d                	li	a0,-1
    80003d4a:	b7e5                	j	80003d32 <kexec+0x6e>
    80003d4c:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80003d4e:	8526                	mv	a0,s1
    80003d50:	930fd0ef          	jal	80000e80 <proc_pagetable>
    80003d54:	8b2a                	mv	s6,a0
    80003d56:	2c050b63          	beqz	a0,8000402c <kexec+0x368>
    80003d5a:	f7ce                	sd	s3,488(sp)
    80003d5c:	efd6                	sd	s5,472(sp)
    80003d5e:	e7de                	sd	s7,456(sp)
    80003d60:	e3e2                	sd	s8,448(sp)
    80003d62:	ff66                	sd	s9,440(sp)
    80003d64:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003d66:	e7042d03          	lw	s10,-400(s0)
    80003d6a:	e8845783          	lhu	a5,-376(s0)
    80003d6e:	12078963          	beqz	a5,80003ea0 <kexec+0x1dc>
    80003d72:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003d74:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003d76:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003d78:	6c85                	lui	s9,0x1
    80003d7a:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003d7e:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003d82:	6a85                	lui	s5,0x1
    80003d84:	a085                	j	80003de4 <kexec+0x120>
      panic("loadseg: address should exist");
    80003d86:	00004517          	auipc	a0,0x4
    80003d8a:	8ba50513          	addi	a0,a0,-1862 # 80007640 <etext+0x640>
    80003d8e:	501010ef          	jal	80005a8e <panic>
    if(sz - i < PGSIZE)
    80003d92:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003d94:	8726                	mv	a4,s1
    80003d96:	012c06bb          	addw	a3,s8,s2
    80003d9a:	4581                	li	a1,0
    80003d9c:	8552                	mv	a0,s4
    80003d9e:	ec3fe0ef          	jal	80002c60 <readi>
    80003da2:	2501                	sext.w	a0,a0
    80003da4:	24a49a63          	bne	s1,a0,80003ff8 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003da8:	012a893b          	addw	s2,s5,s2
    80003dac:	03397363          	bgeu	s2,s3,80003dd2 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003db0:	02091593          	slli	a1,s2,0x20
    80003db4:	9181                	srli	a1,a1,0x20
    80003db6:	95de                	add	a1,a1,s7
    80003db8:	855a                	mv	a0,s6
    80003dba:	ea2fc0ef          	jal	8000045c <walkaddr>
    80003dbe:	862a                	mv	a2,a0
    if(pa == 0)
    80003dc0:	d179                	beqz	a0,80003d86 <kexec+0xc2>
    if(sz - i < PGSIZE)
    80003dc2:	412984bb          	subw	s1,s3,s2
    80003dc6:	0004879b          	sext.w	a5,s1
    80003dca:	fcfcf4e3          	bgeu	s9,a5,80003d92 <kexec+0xce>
    80003dce:	84d6                	mv	s1,s5
    80003dd0:	b7c9                	j	80003d92 <kexec+0xce>
    sz = sz1;
    80003dd2:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003dd6:	2d85                	addiw	s11,s11,1
    80003dd8:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80003ddc:	e8845783          	lhu	a5,-376(s0)
    80003de0:	08fdd063          	bge	s11,a5,80003e60 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003de4:	2d01                	sext.w	s10,s10
    80003de6:	03800713          	li	a4,56
    80003dea:	86ea                	mv	a3,s10
    80003dec:	e1840613          	addi	a2,s0,-488
    80003df0:	4581                	li	a1,0
    80003df2:	8552                	mv	a0,s4
    80003df4:	e6dfe0ef          	jal	80002c60 <readi>
    80003df8:	03800793          	li	a5,56
    80003dfc:	1cf51663          	bne	a0,a5,80003fc8 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80003e00:	e1842783          	lw	a5,-488(s0)
    80003e04:	4705                	li	a4,1
    80003e06:	fce798e3          	bne	a5,a4,80003dd6 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80003e0a:	e4043483          	ld	s1,-448(s0)
    80003e0e:	e3843783          	ld	a5,-456(s0)
    80003e12:	1af4ef63          	bltu	s1,a5,80003fd0 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003e16:	e2843783          	ld	a5,-472(s0)
    80003e1a:	94be                	add	s1,s1,a5
    80003e1c:	1af4ee63          	bltu	s1,a5,80003fd8 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003e20:	df043703          	ld	a4,-528(s0)
    80003e24:	8ff9                	and	a5,a5,a4
    80003e26:	1a079d63          	bnez	a5,80003fe0 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003e2a:	e1c42503          	lw	a0,-484(s0)
    80003e2e:	e7dff0ef          	jal	80003caa <flags2perm>
    80003e32:	86aa                	mv	a3,a0
    80003e34:	8626                	mv	a2,s1
    80003e36:	85ca                	mv	a1,s2
    80003e38:	855a                	mv	a0,s6
    80003e3a:	8fbfc0ef          	jal	80000734 <uvmalloc>
    80003e3e:	e0a43423          	sd	a0,-504(s0)
    80003e42:	1a050363          	beqz	a0,80003fe8 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003e46:	e2843b83          	ld	s7,-472(s0)
    80003e4a:	e2042c03          	lw	s8,-480(s0)
    80003e4e:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003e52:	00098463          	beqz	s3,80003e5a <kexec+0x196>
    80003e56:	4901                	li	s2,0
    80003e58:	bfa1                	j	80003db0 <kexec+0xec>
    sz = sz1;
    80003e5a:	e0843903          	ld	s2,-504(s0)
    80003e5e:	bfa5                	j	80003dd6 <kexec+0x112>
    80003e60:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80003e62:	8552                	mv	a0,s4
    80003e64:	c77fe0ef          	jal	80002ada <iunlockput>
  end_op();
    80003e68:	cbcff0ef          	jal	80003324 <end_op>
  p = myproc();
    80003e6c:	f0ffc0ef          	jal	80000d7a <myproc>
    80003e70:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003e72:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80003e76:	6985                	lui	s3,0x1
    80003e78:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003e7a:	99ca                	add	s3,s3,s2
    80003e7c:	77fd                	lui	a5,0xfffff
    80003e7e:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003e82:	4691                	li	a3,4
    80003e84:	6609                	lui	a2,0x2
    80003e86:	964e                	add	a2,a2,s3
    80003e88:	85ce                	mv	a1,s3
    80003e8a:	855a                	mv	a0,s6
    80003e8c:	8a9fc0ef          	jal	80000734 <uvmalloc>
    80003e90:	892a                	mv	s2,a0
    80003e92:	e0a43423          	sd	a0,-504(s0)
    80003e96:	e519                	bnez	a0,80003ea4 <kexec+0x1e0>
  if(pagetable)
    80003e98:	e1343423          	sd	s3,-504(s0)
    80003e9c:	4a01                	li	s4,0
    80003e9e:	aab1                	j	80003ffa <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003ea0:	4901                	li	s2,0
    80003ea2:	b7c1                	j	80003e62 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003ea4:	75f9                	lui	a1,0xffffe
    80003ea6:	95aa                	add	a1,a1,a0
    80003ea8:	855a                	mv	a0,s6
    80003eaa:	a61fc0ef          	jal	8000090a <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003eae:	7bfd                	lui	s7,0xfffff
    80003eb0:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003eb2:	e0043783          	ld	a5,-512(s0)
    80003eb6:	6388                	ld	a0,0(a5)
    80003eb8:	cd39                	beqz	a0,80003f16 <kexec+0x252>
    80003eba:	e9040993          	addi	s3,s0,-368
    80003ebe:	f9040c13          	addi	s8,s0,-112
    80003ec2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003ec4:	bfafc0ef          	jal	800002be <strlen>
    80003ec8:	0015079b          	addiw	a5,a0,1
    80003ecc:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003ed0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003ed4:	11796e63          	bltu	s2,s7,80003ff0 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003ed8:	e0043d03          	ld	s10,-512(s0)
    80003edc:	000d3a03          	ld	s4,0(s10)
    80003ee0:	8552                	mv	a0,s4
    80003ee2:	bdcfc0ef          	jal	800002be <strlen>
    80003ee6:	0015069b          	addiw	a3,a0,1
    80003eea:	8652                	mv	a2,s4
    80003eec:	85ca                	mv	a1,s2
    80003eee:	855a                	mv	a0,s6
    80003ef0:	b9ffc0ef          	jal	80000a8e <copyout>
    80003ef4:	10054063          	bltz	a0,80003ff4 <kexec+0x330>
    ustack[argc] = sp;
    80003ef8:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003efc:	0485                	addi	s1,s1,1
    80003efe:	008d0793          	addi	a5,s10,8
    80003f02:	e0f43023          	sd	a5,-512(s0)
    80003f06:	008d3503          	ld	a0,8(s10)
    80003f0a:	c909                	beqz	a0,80003f1c <kexec+0x258>
    if(argc >= MAXARG)
    80003f0c:	09a1                	addi	s3,s3,8
    80003f0e:	fb899be3          	bne	s3,s8,80003ec4 <kexec+0x200>
  ip = 0;
    80003f12:	4a01                	li	s4,0
    80003f14:	a0dd                	j	80003ffa <kexec+0x336>
  sp = sz;
    80003f16:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003f1a:	4481                	li	s1,0
  ustack[argc] = 0;
    80003f1c:	00349793          	slli	a5,s1,0x3
    80003f20:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffcf8e8>
    80003f24:	97a2                	add	a5,a5,s0
    80003f26:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003f2a:	00148693          	addi	a3,s1,1
    80003f2e:	068e                	slli	a3,a3,0x3
    80003f30:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003f34:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003f38:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003f3c:	f5796ee3          	bltu	s2,s7,80003e98 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003f40:	e9040613          	addi	a2,s0,-368
    80003f44:	85ca                	mv	a1,s2
    80003f46:	855a                	mv	a0,s6
    80003f48:	b47fc0ef          	jal	80000a8e <copyout>
    80003f4c:	0e054263          	bltz	a0,80004030 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80003f50:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003f54:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003f58:	df843783          	ld	a5,-520(s0)
    80003f5c:	0007c703          	lbu	a4,0(a5)
    80003f60:	cf11                	beqz	a4,80003f7c <kexec+0x2b8>
    80003f62:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003f64:	02f00693          	li	a3,47
    80003f68:	a039                	j	80003f76 <kexec+0x2b2>
      last = s+1;
    80003f6a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003f6e:	0785                	addi	a5,a5,1
    80003f70:	fff7c703          	lbu	a4,-1(a5)
    80003f74:	c701                	beqz	a4,80003f7c <kexec+0x2b8>
    if(*s == '/')
    80003f76:	fed71ce3          	bne	a4,a3,80003f6e <kexec+0x2aa>
    80003f7a:	bfc5                	j	80003f6a <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003f7c:	4641                	li	a2,16
    80003f7e:	df843583          	ld	a1,-520(s0)
    80003f82:	158a8513          	addi	a0,s5,344
    80003f86:	b06fc0ef          	jal	8000028c <safestrcpy>
  oldpagetable = p->pagetable;
    80003f8a:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003f8e:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003f92:	e0843783          	ld	a5,-504(s0)
    80003f96:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80003f9a:	058ab783          	ld	a5,88(s5)
    80003f9e:	e6843703          	ld	a4,-408(s0)
    80003fa2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003fa4:	058ab783          	ld	a5,88(s5)
    80003fa8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003fac:	85e6                	mv	a1,s9
    80003fae:	f57fc0ef          	jal	80000f04 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003fb2:	0004851b          	sext.w	a0,s1
    80003fb6:	79be                	ld	s3,488(sp)
    80003fb8:	7a1e                	ld	s4,480(sp)
    80003fba:	6afe                	ld	s5,472(sp)
    80003fbc:	6b5e                	ld	s6,464(sp)
    80003fbe:	6bbe                	ld	s7,456(sp)
    80003fc0:	6c1e                	ld	s8,448(sp)
    80003fc2:	7cfa                	ld	s9,440(sp)
    80003fc4:	7d5a                	ld	s10,432(sp)
    80003fc6:	b3b5                	j	80003d32 <kexec+0x6e>
    80003fc8:	e1243423          	sd	s2,-504(s0)
    80003fcc:	7dba                	ld	s11,424(sp)
    80003fce:	a035                	j	80003ffa <kexec+0x336>
    80003fd0:	e1243423          	sd	s2,-504(s0)
    80003fd4:	7dba                	ld	s11,424(sp)
    80003fd6:	a015                	j	80003ffa <kexec+0x336>
    80003fd8:	e1243423          	sd	s2,-504(s0)
    80003fdc:	7dba                	ld	s11,424(sp)
    80003fde:	a831                	j	80003ffa <kexec+0x336>
    80003fe0:	e1243423          	sd	s2,-504(s0)
    80003fe4:	7dba                	ld	s11,424(sp)
    80003fe6:	a811                	j	80003ffa <kexec+0x336>
    80003fe8:	e1243423          	sd	s2,-504(s0)
    80003fec:	7dba                	ld	s11,424(sp)
    80003fee:	a031                	j	80003ffa <kexec+0x336>
  ip = 0;
    80003ff0:	4a01                	li	s4,0
    80003ff2:	a021                	j	80003ffa <kexec+0x336>
    80003ff4:	4a01                	li	s4,0
  if(pagetable)
    80003ff6:	a011                	j	80003ffa <kexec+0x336>
    80003ff8:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003ffa:	e0843583          	ld	a1,-504(s0)
    80003ffe:	855a                	mv	a0,s6
    80004000:	f05fc0ef          	jal	80000f04 <proc_freepagetable>
  return -1;
    80004004:	557d                	li	a0,-1
  if(ip){
    80004006:	000a1b63          	bnez	s4,8000401c <kexec+0x358>
    8000400a:	79be                	ld	s3,488(sp)
    8000400c:	7a1e                	ld	s4,480(sp)
    8000400e:	6afe                	ld	s5,472(sp)
    80004010:	6b5e                	ld	s6,464(sp)
    80004012:	6bbe                	ld	s7,456(sp)
    80004014:	6c1e                	ld	s8,448(sp)
    80004016:	7cfa                	ld	s9,440(sp)
    80004018:	7d5a                	ld	s10,432(sp)
    8000401a:	bb21                	j	80003d32 <kexec+0x6e>
    8000401c:	79be                	ld	s3,488(sp)
    8000401e:	6afe                	ld	s5,472(sp)
    80004020:	6b5e                	ld	s6,464(sp)
    80004022:	6bbe                	ld	s7,456(sp)
    80004024:	6c1e                	ld	s8,448(sp)
    80004026:	7cfa                	ld	s9,440(sp)
    80004028:	7d5a                	ld	s10,432(sp)
    8000402a:	b9ed                	j	80003d24 <kexec+0x60>
    8000402c:	6b5e                	ld	s6,464(sp)
    8000402e:	b9dd                	j	80003d24 <kexec+0x60>
  sz = sz1;
    80004030:	e0843983          	ld	s3,-504(s0)
    80004034:	b595                	j	80003e98 <kexec+0x1d4>

0000000080004036 <argfd>:
}
// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004036:	7179                	addi	sp,sp,-48
    80004038:	f406                	sd	ra,40(sp)
    8000403a:	f022                	sd	s0,32(sp)
    8000403c:	ec26                	sd	s1,24(sp)
    8000403e:	e84a                	sd	s2,16(sp)
    80004040:	1800                	addi	s0,sp,48
    80004042:	892e                	mv	s2,a1
    80004044:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004046:	fdc40593          	addi	a1,s0,-36
    8000404a:	e91fd0ef          	jal	80001eda <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000404e:	fdc42703          	lw	a4,-36(s0)
    80004052:	47bd                	li	a5,15
    80004054:	02e7e963          	bltu	a5,a4,80004086 <argfd+0x50>
    80004058:	d23fc0ef          	jal	80000d7a <myproc>
    8000405c:	fdc42703          	lw	a4,-36(s0)
    80004060:	01a70793          	addi	a5,a4,26
    80004064:	078e                	slli	a5,a5,0x3
    80004066:	953e                	add	a0,a0,a5
    80004068:	611c                	ld	a5,0(a0)
    8000406a:	c385                	beqz	a5,8000408a <argfd+0x54>
    return -1;
  if(pfd)
    8000406c:	00090463          	beqz	s2,80004074 <argfd+0x3e>
    *pfd = fd;
    80004070:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004074:	4501                	li	a0,0
  if(pf)
    80004076:	c091                	beqz	s1,8000407a <argfd+0x44>
    *pf = f;
    80004078:	e09c                	sd	a5,0(s1)
}
    8000407a:	70a2                	ld	ra,40(sp)
    8000407c:	7402                	ld	s0,32(sp)
    8000407e:	64e2                	ld	s1,24(sp)
    80004080:	6942                	ld	s2,16(sp)
    80004082:	6145                	addi	sp,sp,48
    80004084:	8082                	ret
    return -1;
    80004086:	557d                	li	a0,-1
    80004088:	bfcd                	j	8000407a <argfd+0x44>
    8000408a:	557d                	li	a0,-1
    8000408c:	b7fd                	j	8000407a <argfd+0x44>

000000008000408e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000408e:	1101                	addi	sp,sp,-32
    80004090:	ec06                	sd	ra,24(sp)
    80004092:	e822                	sd	s0,16(sp)
    80004094:	e426                	sd	s1,8(sp)
    80004096:	1000                	addi	s0,sp,32
    80004098:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000409a:	ce1fc0ef          	jal	80000d7a <myproc>
    8000409e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800040a0:	0d050793          	addi	a5,a0,208
    800040a4:	4501                	li	a0,0
    800040a6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800040a8:	6398                	ld	a4,0(a5)
    800040aa:	cb19                	beqz	a4,800040c0 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800040ac:	2505                	addiw	a0,a0,1
    800040ae:	07a1                	addi	a5,a5,8
    800040b0:	fed51ce3          	bne	a0,a3,800040a8 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800040b4:	557d                	li	a0,-1
}
    800040b6:	60e2                	ld	ra,24(sp)
    800040b8:	6442                	ld	s0,16(sp)
    800040ba:	64a2                	ld	s1,8(sp)
    800040bc:	6105                	addi	sp,sp,32
    800040be:	8082                	ret
      p->ofile[fd] = f;
    800040c0:	01a50793          	addi	a5,a0,26
    800040c4:	078e                	slli	a5,a5,0x3
    800040c6:	963e                	add	a2,a2,a5
    800040c8:	e204                	sd	s1,0(a2)
      return fd;
    800040ca:	b7f5                	j	800040b6 <fdalloc+0x28>

00000000800040cc <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800040cc:	715d                	addi	sp,sp,-80
    800040ce:	e486                	sd	ra,72(sp)
    800040d0:	e0a2                	sd	s0,64(sp)
    800040d2:	fc26                	sd	s1,56(sp)
    800040d4:	f84a                	sd	s2,48(sp)
    800040d6:	f44e                	sd	s3,40(sp)
    800040d8:	ec56                	sd	s5,24(sp)
    800040da:	e85a                	sd	s6,16(sp)
    800040dc:	0880                	addi	s0,sp,80
    800040de:	8b2e                	mv	s6,a1
    800040e0:	89b2                	mv	s3,a2
    800040e2:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800040e4:	fb040593          	addi	a1,s0,-80
    800040e8:	818ff0ef          	jal	80003100 <nameiparent>
    800040ec:	84aa                	mv	s1,a0
    800040ee:	10050a63          	beqz	a0,80004202 <create+0x136>
    return 0;

  ilock(dp);
    800040f2:	fdefe0ef          	jal	800028d0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800040f6:	4601                	li	a2,0
    800040f8:	fb040593          	addi	a1,s0,-80
    800040fc:	8526                	mv	a0,s1
    800040fe:	d83fe0ef          	jal	80002e80 <dirlookup>
    80004102:	8aaa                	mv	s5,a0
    80004104:	c129                	beqz	a0,80004146 <create+0x7a>
    iunlockput(dp);
    80004106:	8526                	mv	a0,s1
    80004108:	9d3fe0ef          	jal	80002ada <iunlockput>
    ilock(ip);
    8000410c:	8556                	mv	a0,s5
    8000410e:	fc2fe0ef          	jal	800028d0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004112:	4789                	li	a5,2
    80004114:	02fb1463          	bne	s6,a5,8000413c <create+0x70>
    80004118:	044ad783          	lhu	a5,68(s5)
    8000411c:	37f9                	addiw	a5,a5,-2
    8000411e:	17c2                	slli	a5,a5,0x30
    80004120:	93c1                	srli	a5,a5,0x30
    80004122:	4705                	li	a4,1
    80004124:	00f76c63          	bltu	a4,a5,8000413c <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004128:	8556                	mv	a0,s5
    8000412a:	60a6                	ld	ra,72(sp)
    8000412c:	6406                	ld	s0,64(sp)
    8000412e:	74e2                	ld	s1,56(sp)
    80004130:	7942                	ld	s2,48(sp)
    80004132:	79a2                	ld	s3,40(sp)
    80004134:	6ae2                	ld	s5,24(sp)
    80004136:	6b42                	ld	s6,16(sp)
    80004138:	6161                	addi	sp,sp,80
    8000413a:	8082                	ret
    iunlockput(ip);
    8000413c:	8556                	mv	a0,s5
    8000413e:	99dfe0ef          	jal	80002ada <iunlockput>
    return 0;
    80004142:	4a81                	li	s5,0
    80004144:	b7d5                	j	80004128 <create+0x5c>
    80004146:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004148:	85da                	mv	a1,s6
    8000414a:	4088                	lw	a0,0(s1)
    8000414c:	e14fe0ef          	jal	80002760 <ialloc>
    80004150:	8a2a                	mv	s4,a0
    80004152:	cd15                	beqz	a0,8000418e <create+0xc2>
  ilock(ip);
    80004154:	f7cfe0ef          	jal	800028d0 <ilock>
  ip->major = major;
    80004158:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000415c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004160:	4905                	li	s2,1
    80004162:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004166:	8552                	mv	a0,s4
    80004168:	eb4fe0ef          	jal	8000281c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000416c:	032b0763          	beq	s6,s2,8000419a <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004170:	004a2603          	lw	a2,4(s4)
    80004174:	fb040593          	addi	a1,s0,-80
    80004178:	8526                	mv	a0,s1
    8000417a:	ed3fe0ef          	jal	8000304c <dirlink>
    8000417e:	06054563          	bltz	a0,800041e8 <create+0x11c>
  iunlockput(dp);
    80004182:	8526                	mv	a0,s1
    80004184:	957fe0ef          	jal	80002ada <iunlockput>
  return ip;
    80004188:	8ad2                	mv	s5,s4
    8000418a:	7a02                	ld	s4,32(sp)
    8000418c:	bf71                	j	80004128 <create+0x5c>
    iunlockput(dp);
    8000418e:	8526                	mv	a0,s1
    80004190:	94bfe0ef          	jal	80002ada <iunlockput>
    return 0;
    80004194:	8ad2                	mv	s5,s4
    80004196:	7a02                	ld	s4,32(sp)
    80004198:	bf41                	j	80004128 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000419a:	004a2603          	lw	a2,4(s4)
    8000419e:	00003597          	auipc	a1,0x3
    800041a2:	4c258593          	addi	a1,a1,1218 # 80007660 <etext+0x660>
    800041a6:	8552                	mv	a0,s4
    800041a8:	ea5fe0ef          	jal	8000304c <dirlink>
    800041ac:	02054e63          	bltz	a0,800041e8 <create+0x11c>
    800041b0:	40d0                	lw	a2,4(s1)
    800041b2:	00003597          	auipc	a1,0x3
    800041b6:	4b658593          	addi	a1,a1,1206 # 80007668 <etext+0x668>
    800041ba:	8552                	mv	a0,s4
    800041bc:	e91fe0ef          	jal	8000304c <dirlink>
    800041c0:	02054463          	bltz	a0,800041e8 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    800041c4:	004a2603          	lw	a2,4(s4)
    800041c8:	fb040593          	addi	a1,s0,-80
    800041cc:	8526                	mv	a0,s1
    800041ce:	e7ffe0ef          	jal	8000304c <dirlink>
    800041d2:	00054b63          	bltz	a0,800041e8 <create+0x11c>
    dp->nlink++;  // for ".."
    800041d6:	04a4d783          	lhu	a5,74(s1)
    800041da:	2785                	addiw	a5,a5,1
    800041dc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800041e0:	8526                	mv	a0,s1
    800041e2:	e3afe0ef          	jal	8000281c <iupdate>
    800041e6:	bf71                	j	80004182 <create+0xb6>
  ip->nlink = 0;
    800041e8:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800041ec:	8552                	mv	a0,s4
    800041ee:	e2efe0ef          	jal	8000281c <iupdate>
  iunlockput(ip);
    800041f2:	8552                	mv	a0,s4
    800041f4:	8e7fe0ef          	jal	80002ada <iunlockput>
  iunlockput(dp);
    800041f8:	8526                	mv	a0,s1
    800041fa:	8e1fe0ef          	jal	80002ada <iunlockput>
  return 0;
    800041fe:	7a02                	ld	s4,32(sp)
    80004200:	b725                	j	80004128 <create+0x5c>
    return 0;
    80004202:	8aaa                	mv	s5,a0
    80004204:	b715                	j	80004128 <create+0x5c>

0000000080004206 <sys_mmap>:
uint64 sys_mmap(void) {
    80004206:	715d                	addi	sp,sp,-80
    80004208:	e486                	sd	ra,72(sp)
    8000420a:	e0a2                	sd	s0,64(sp)
    8000420c:	0880                	addi	s0,sp,80
  argaddr(0, &addr);
    8000420e:	fd840593          	addi	a1,s0,-40
    80004212:	4501                	li	a0,0
    80004214:	ce3fd0ef          	jal	80001ef6 <argaddr>
  argint(1, &len);
    80004218:	fd440593          	addi	a1,s0,-44
    8000421c:	4505                	li	a0,1
    8000421e:	cbdfd0ef          	jal	80001eda <argint>
  argint(2, &prot);
    80004222:	fd040593          	addi	a1,s0,-48
    80004226:	4509                	li	a0,2
    80004228:	cb3fd0ef          	jal	80001eda <argint>
  argint(3, &flags);
    8000422c:	fcc40593          	addi	a1,s0,-52
    80004230:	450d                	li	a0,3
    80004232:	ca9fd0ef          	jal	80001eda <argint>
  if (argfd(4, &fd, &file) < 0)
    80004236:	fc040613          	addi	a2,s0,-64
    8000423a:	fc840593          	addi	a1,s0,-56
    8000423e:	4511                	li	a0,4
    80004240:	df7ff0ef          	jal	80004036 <argfd>
    return -1;
    80004244:	577d                	li	a4,-1
  if (argfd(4, &fd, &file) < 0)
    80004246:	0c054b63          	bltz	a0,8000431c <sys_mmap+0x116>
    8000424a:	f84a                	sd	s2,48(sp)
  argint(5, &offset);
    8000424c:	fbc40593          	addi	a1,s0,-68
    80004250:	4515                	li	a0,5
    80004252:	c89fd0ef          	jal	80001eda <argint>
  struct proc *p = myproc();
    80004256:	b25fc0ef          	jal	80000d7a <myproc>
    8000425a:	892a                	mv	s2,a0
  for (int i = 0; i < VMA_COUNT; i ++) {
    8000425c:	16850713          	addi	a4,a0,360
    80004260:	4781                	li	a5,0
    80004262:	4641                	li	a2,16
    if (!p->vmas[i].is_used) {
    80004264:	4314                	lw	a3,0(a4)
    80004266:	ca89                	beqz	a3,80004278 <sys_mmap+0x72>
  for (int i = 0; i < VMA_COUNT; i ++) {
    80004268:	2785                	addiw	a5,a5,1
    8000426a:	03070713          	addi	a4,a4,48
    8000426e:	fec79be3          	bne	a5,a2,80004264 <sys_mmap+0x5e>
    return -1;
    80004272:	577d                	li	a4,-1
    80004274:	7942                	ld	s2,48(sp)
    80004276:	a05d                	j	8000431c <sys_mmap+0x116>
    80004278:	fc26                	sd	s1,56(sp)
      vma = &p->vmas[i];
    8000427a:	00179493          	slli	s1,a5,0x1
    8000427e:	94be                	add	s1,s1,a5
    80004280:	0492                	slli	s1,s1,0x4
    80004282:	16848493          	addi	s1,s1,360
    80004286:	94ca                	add	s1,s1,s2
  if (vma == 0) {
    80004288:	ccd9                	beqz	s1,80004326 <sys_mmap+0x120>
  if (!file->readable && (prot & PROT_READ))
    8000428a:	fc043503          	ld	a0,-64(s0)
    8000428e:	00854783          	lbu	a5,8(a0)
    80004292:	e791                	bnez	a5,8000429e <sys_mmap+0x98>
    80004294:	fd042783          	lw	a5,-48(s0)
    80004298:	8b85                	andi	a5,a5,1
    return -1;
    8000429a:	577d                	li	a4,-1
  if (!file->readable && (prot & PROT_READ))
    8000429c:	ebc9                	bnez	a5,8000432e <sys_mmap+0x128>
  if (!file->writable && (prot & PROT_WRITE) && (flags & MAP_SHARED))
    8000429e:	00954783          	lbu	a5,9(a0)
    800042a2:	eb91                	bnez	a5,800042b6 <sys_mmap+0xb0>
    800042a4:	fd042783          	lw	a5,-48(s0)
    800042a8:	8b89                	andi	a5,a5,2
    800042aa:	c791                	beqz	a5,800042b6 <sys_mmap+0xb0>
    800042ac:	fcc42783          	lw	a5,-52(s0)
    800042b0:	8b85                	andi	a5,a5,1
    return -1;
    800042b2:	577d                	li	a4,-1
  if (!file->writable && (prot & PROT_WRITE) && (flags & MAP_SHARED))
    800042b4:	e3c1                	bnez	a5,80004334 <sys_mmap+0x12e>
  len = PGROUNDUP(len);
    800042b6:	fd442703          	lw	a4,-44(s0)
    800042ba:	6785                	lui	a5,0x1
    800042bc:	37fd                	addiw	a5,a5,-1 # fff <_entry-0x7ffff001>
    800042be:	9fb9                	addw	a5,a5,a4
    800042c0:	777d                	lui	a4,0xfffff
    800042c2:	8ff9                	and	a5,a5,a4
    800042c4:	2781                	sext.w	a5,a5
    800042c6:	fcf42a23          	sw	a5,-44(s0)
  if (p->sz + len >= MAXVA) 
    800042ca:	04893703          	ld	a4,72(s2)
    800042ce:	97ba                	add	a5,a5,a4
    800042d0:	56fd                	li	a3,-1
    800042d2:	82e9                	srli	a3,a3,0x1a
    return -1;
    800042d4:	577d                	li	a4,-1
  if (p->sz + len >= MAXVA) 
    800042d6:	06f6e263          	bltu	a3,a5,8000433a <sys_mmap+0x134>
  vma->is_used = 1;
    800042da:	4785                	li	a5,1
    800042dc:	c09c                	sw	a5,0(s1)
  vma->address = p->sz;
    800042de:	04893783          	ld	a5,72(s2)
    800042e2:	e49c                	sd	a5,8(s1)
  vma->length = len;
    800042e4:	fd442783          	lw	a5,-44(s0)
    800042e8:	c89c                	sw	a5,16(s1)
  vma->prot = prot;
    800042ea:	fd042783          	lw	a5,-48(s0)
    800042ee:	c8dc                	sw	a5,20(s1)
  vma->flags = flags;
    800042f0:	fcc42783          	lw	a5,-52(s0)
    800042f4:	cc9c                	sw	a5,24(s1)
  vma->fd = fd;
    800042f6:	fc842783          	lw	a5,-56(s0)
    800042fa:	ccdc                	sw	a5,28(s1)
  vma->file = file;
    800042fc:	f088                	sd	a0,32(s1)
  vma->offset = offset;
    800042fe:	fbc42783          	lw	a5,-68(s0)
    80004302:	d49c                	sw	a5,40(s1)
  filedup(file);
    80004304:	b7cff0ef          	jal	80003680 <filedup>
  p->sz += len;
    80004308:	fd442703          	lw	a4,-44(s0)
    8000430c:	04893783          	ld	a5,72(s2)
    80004310:	97ba                	add	a5,a5,a4
    80004312:	04f93423          	sd	a5,72(s2)
  return vma->address;
    80004316:	6498                	ld	a4,8(s1)
    80004318:	74e2                	ld	s1,56(sp)
    8000431a:	7942                	ld	s2,48(sp)
}
    8000431c:	853a                	mv	a0,a4
    8000431e:	60a6                	ld	ra,72(sp)
    80004320:	6406                	ld	s0,64(sp)
    80004322:	6161                	addi	sp,sp,80
    80004324:	8082                	ret
    return -1;
    80004326:	577d                	li	a4,-1
    80004328:	74e2                	ld	s1,56(sp)
    8000432a:	7942                	ld	s2,48(sp)
    8000432c:	bfc5                	j	8000431c <sys_mmap+0x116>
    8000432e:	74e2                	ld	s1,56(sp)
    80004330:	7942                	ld	s2,48(sp)
    80004332:	b7ed                	j	8000431c <sys_mmap+0x116>
    80004334:	74e2                	ld	s1,56(sp)
    80004336:	7942                	ld	s2,48(sp)
    80004338:	b7d5                	j	8000431c <sys_mmap+0x116>
    8000433a:	74e2                	ld	s1,56(sp)
    8000433c:	7942                	ld	s2,48(sp)
    8000433e:	bff9                	j	8000431c <sys_mmap+0x116>

0000000080004340 <sys_munmap>:
uint64 sys_munmap(void) {
    80004340:	7179                	addi	sp,sp,-48
    80004342:	f406                	sd	ra,40(sp)
    80004344:	f022                	sd	s0,32(sp)
    80004346:	e84a                	sd	s2,16(sp)
    80004348:	1800                	addi	s0,sp,48
  argaddr(0, &addr);
    8000434a:	fd840593          	addi	a1,s0,-40
    8000434e:	4501                	li	a0,0
    80004350:	ba7fd0ef          	jal	80001ef6 <argaddr>
  argint(1, &len);
    80004354:	fd440593          	addi	a1,s0,-44
    80004358:	4505                	li	a0,1
    8000435a:	b81fd0ef          	jal	80001eda <argint>
  struct proc *p = myproc();
    8000435e:	a1dfc0ef          	jal	80000d7a <myproc>
    80004362:	892a                	mv	s2,a0
    if (p->vmas[i].is_used && p->vmas[i].address <= addr && addr < p->vmas[i].address + p->vmas[i].length) {
    80004364:	fd843803          	ld	a6,-40(s0)
    80004368:	16850793          	addi	a5,a0,360
  for (int i = 0; i < VMA_COUNT; i ++) {
    8000436c:	4701                	li	a4,0
    8000436e:	45c1                	li	a1,16
    80004370:	a031                	j	8000437c <sys_munmap+0x3c>
    80004372:	2705                	addiw	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffcf959>
    80004374:	03078793          	addi	a5,a5,48
    80004378:	0cb70b63          	beq	a4,a1,8000444e <sys_munmap+0x10e>
    if (p->vmas[i].is_used && p->vmas[i].address <= addr && addr < p->vmas[i].address + p->vmas[i].length) {
    8000437c:	4394                	lw	a3,0(a5)
    8000437e:	daf5                	beqz	a3,80004372 <sys_munmap+0x32>
    80004380:	6794                	ld	a3,8(a5)
    80004382:	fed868e3          	bltu	a6,a3,80004372 <sys_munmap+0x32>
    80004386:	4b90                	lw	a2,16(a5)
    80004388:	96b2                	add	a3,a3,a2
    8000438a:	fed874e3          	bgeu	a6,a3,80004372 <sys_munmap+0x32>
    8000438e:	ec26                	sd	s1,24(sp)
      vma = &p->vmas[i];
    80004390:	00171493          	slli	s1,a4,0x1
    80004394:	94ba                	add	s1,s1,a4
    80004396:	0492                	slli	s1,s1,0x4
    80004398:	16848493          	addi	s1,s1,360
    8000439c:	94ca                	add	s1,s1,s2
  if (vma == 0) {
    8000439e:	c0ed                	beqz	s1,80004480 <sys_munmap+0x140>
  addr = PGROUNDDOWN(addr);
    800043a0:	77fd                	lui	a5,0xfffff
    800043a2:	00f87833          	and	a6,a6,a5
    800043a6:	fd043c23          	sd	a6,-40(s0)
  len = PGROUNDUP(len);
    800043aa:	fd442703          	lw	a4,-44(s0)
    800043ae:	6785                	lui	a5,0x1
    800043b0:	37fd                	addiw	a5,a5,-1 # fff <_entry-0x7ffff001>
    800043b2:	9fb9                	addw	a5,a5,a4
    800043b4:	777d                	lui	a4,0xfffff
    800043b6:	8ff9                	and	a5,a5,a4
    800043b8:	fcf42a23          	sw	a5,-44(s0)
  begin_op();
    800043bc:	efffe0ef          	jal	800032ba <begin_op>
  if ((vma->flags & MAP_SHARED) && (vma->prot & PROT_WRITE)) {
    800043c0:	4c9c                	lw	a5,24(s1)
    800043c2:	8b85                	andi	a5,a5,1
    800043c4:	cf85                	beqz	a5,800043fc <sys_munmap+0xbc>
    800043c6:	48dc                	lw	a5,20(s1)
    800043c8:	8b89                	andi	a5,a5,2
    800043ca:	cb8d                	beqz	a5,800043fc <sys_munmap+0xbc>
    struct inode *ip = vma->file->ip;
    800043cc:	709c                	ld	a5,32(s1)
    800043ce:	6f88                	ld	a0,24(a5)
    int file_sz = ip->size;
    800043d0:	456c                	lw	a1,76(a0)
    int file_off = vma->offset + (addr - vma->address);
    800043d2:	fd843603          	ld	a2,-40(s0)
    800043d6:	549c                	lw	a5,40(s1)
    800043d8:	9fb1                	addw	a5,a5,a2
    800043da:	6498                	ld	a4,8(s1)
    800043dc:	9f99                	subw	a5,a5,a4
    800043de:	0007869b          	sext.w	a3,a5
    if (file_off < file_sz) {
    800043e2:	00b6dd63          	bge	a3,a1,800043fc <sys_munmap+0xbc>
    int wlen = len;
    800043e6:	fd442703          	lw	a4,-44(s0)
      if (file_off + wlen > file_sz)
    800043ea:	00e7883b          	addw	a6,a5,a4
    800043ee:	0105d463          	bge	a1,a6,800043f6 <sys_munmap+0xb6>
        wlen = file_sz - file_off;
    800043f2:	40f5873b          	subw	a4,a1,a5
      if (writei(ip, 1, addr, file_off, wlen) < 0) {
    800043f6:	4585                	li	a1,1
    800043f8:	965fe0ef          	jal	80002d5c <writei>
  uvmunmap(p->pagetable, addr, len / PGSIZE, 1);
    800043fc:	fd442783          	lw	a5,-44(s0)
    80004400:	41f7d61b          	sraiw	a2,a5,0x1f
    80004404:	0146561b          	srliw	a2,a2,0x14
    80004408:	9e3d                	addw	a2,a2,a5
    8000440a:	4685                	li	a3,1
    8000440c:	40c6561b          	sraiw	a2,a2,0xc
    80004410:	fd843583          	ld	a1,-40(s0)
    80004414:	05093503          	ld	a0,80(s2)
    80004418:	a4efc0ef          	jal	80000666 <uvmunmap>
  if (addr == vma->address) {
    8000441c:	649c                	ld	a5,8(s1)
    8000441e:	fd843703          	ld	a4,-40(s0)
    80004422:	02e78863          	beq	a5,a4,80004452 <sys_munmap+0x112>
  } else if (addr + len == vma->address + vma->length) {
    80004426:	fd442603          	lw	a2,-44(s0)
    8000442a:	4894                	lw	a3,16(s1)
    8000442c:	9732                	add	a4,a4,a2
    8000442e:	97b6                	add	a5,a5,a3
    80004430:	02f71c63          	bne	a4,a5,80004468 <sys_munmap+0x128>
    vma->length -= len;
    80004434:	9e91                	subw	a3,a3,a2
    80004436:	c894                	sw	a3,16(s1)
  if (vma->length == 0) {
    80004438:	489c                	lw	a5,16(s1)
    8000443a:	cf8d                	beqz	a5,80004474 <sys_munmap+0x134>
  end_op();
    8000443c:	ee9fe0ef          	jal	80003324 <end_op>
  return 0;
    80004440:	4501                	li	a0,0
    80004442:	64e2                	ld	s1,24(sp)
}
    80004444:	70a2                	ld	ra,40(sp)
    80004446:	7402                	ld	s0,32(sp)
    80004448:	6942                	ld	s2,16(sp)
    8000444a:	6145                	addi	sp,sp,48
    8000444c:	8082                	ret
    return -1;
    8000444e:	557d                	li	a0,-1
    80004450:	bfd5                	j	80004444 <sys_munmap+0x104>
    vma->address += len;
    80004452:	fd442703          	lw	a4,-44(s0)
    80004456:	97ba                	add	a5,a5,a4
    80004458:	e49c                	sd	a5,8(s1)
    vma->length -= len;
    8000445a:	489c                	lw	a5,16(s1)
    8000445c:	9f99                	subw	a5,a5,a4
    8000445e:	c89c                	sw	a5,16(s1)
    vma->offset += len;
    80004460:	549c                	lw	a5,40(s1)
    80004462:	9fb9                	addw	a5,a5,a4
    80004464:	d49c                	sw	a5,40(s1)
    80004466:	bfc9                	j	80004438 <sys_munmap+0xf8>
    panic("munmap: wtf");
    80004468:	00003517          	auipc	a0,0x3
    8000446c:	20850513          	addi	a0,a0,520 # 80007670 <etext+0x670>
    80004470:	61e010ef          	jal	80005a8e <panic>
    fileclose(vma->file);
    80004474:	7088                	ld	a0,32(s1)
    80004476:	a50ff0ef          	jal	800036c6 <fileclose>
    vma->is_used = 0;
    8000447a:	0004a023          	sw	zero,0(s1)
    8000447e:	bf7d                	j	8000443c <sys_munmap+0xfc>
    return -1;
    80004480:	557d                	li	a0,-1
    80004482:	64e2                	ld	s1,24(sp)
    80004484:	b7c1                	j	80004444 <sys_munmap+0x104>

0000000080004486 <sys_dup>:
{
    80004486:	7179                	addi	sp,sp,-48
    80004488:	f406                	sd	ra,40(sp)
    8000448a:	f022                	sd	s0,32(sp)
    8000448c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000448e:	fd840613          	addi	a2,s0,-40
    80004492:	4581                	li	a1,0
    80004494:	4501                	li	a0,0
    80004496:	ba1ff0ef          	jal	80004036 <argfd>
    return -1;
    8000449a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000449c:	02054363          	bltz	a0,800044c2 <sys_dup+0x3c>
    800044a0:	ec26                	sd	s1,24(sp)
    800044a2:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800044a4:	fd843903          	ld	s2,-40(s0)
    800044a8:	854a                	mv	a0,s2
    800044aa:	be5ff0ef          	jal	8000408e <fdalloc>
    800044ae:	84aa                	mv	s1,a0
    return -1;
    800044b0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800044b2:	00054d63          	bltz	a0,800044cc <sys_dup+0x46>
  filedup(f);
    800044b6:	854a                	mv	a0,s2
    800044b8:	9c8ff0ef          	jal	80003680 <filedup>
  return fd;
    800044bc:	87a6                	mv	a5,s1
    800044be:	64e2                	ld	s1,24(sp)
    800044c0:	6942                	ld	s2,16(sp)
}
    800044c2:	853e                	mv	a0,a5
    800044c4:	70a2                	ld	ra,40(sp)
    800044c6:	7402                	ld	s0,32(sp)
    800044c8:	6145                	addi	sp,sp,48
    800044ca:	8082                	ret
    800044cc:	64e2                	ld	s1,24(sp)
    800044ce:	6942                	ld	s2,16(sp)
    800044d0:	bfcd                	j	800044c2 <sys_dup+0x3c>

00000000800044d2 <sys_read>:
{
    800044d2:	7179                	addi	sp,sp,-48
    800044d4:	f406                	sd	ra,40(sp)
    800044d6:	f022                	sd	s0,32(sp)
    800044d8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800044da:	fd840593          	addi	a1,s0,-40
    800044de:	4505                	li	a0,1
    800044e0:	a17fd0ef          	jal	80001ef6 <argaddr>
  argint(2, &n);
    800044e4:	fe440593          	addi	a1,s0,-28
    800044e8:	4509                	li	a0,2
    800044ea:	9f1fd0ef          	jal	80001eda <argint>
  if(argfd(0, 0, &f) < 0)
    800044ee:	fe840613          	addi	a2,s0,-24
    800044f2:	4581                	li	a1,0
    800044f4:	4501                	li	a0,0
    800044f6:	b41ff0ef          	jal	80004036 <argfd>
    800044fa:	87aa                	mv	a5,a0
    return -1;
    800044fc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800044fe:	0007ca63          	bltz	a5,80004512 <sys_read+0x40>
  return fileread(f, p, n);
    80004502:	fe442603          	lw	a2,-28(s0)
    80004506:	fd843583          	ld	a1,-40(s0)
    8000450a:	fe843503          	ld	a0,-24(s0)
    8000450e:	ad8ff0ef          	jal	800037e6 <fileread>
}
    80004512:	70a2                	ld	ra,40(sp)
    80004514:	7402                	ld	s0,32(sp)
    80004516:	6145                	addi	sp,sp,48
    80004518:	8082                	ret

000000008000451a <sys_write>:
{
    8000451a:	7179                	addi	sp,sp,-48
    8000451c:	f406                	sd	ra,40(sp)
    8000451e:	f022                	sd	s0,32(sp)
    80004520:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004522:	fd840593          	addi	a1,s0,-40
    80004526:	4505                	li	a0,1
    80004528:	9cffd0ef          	jal	80001ef6 <argaddr>
  argint(2, &n);
    8000452c:	fe440593          	addi	a1,s0,-28
    80004530:	4509                	li	a0,2
    80004532:	9a9fd0ef          	jal	80001eda <argint>
  if(argfd(0, 0, &f) < 0)
    80004536:	fe840613          	addi	a2,s0,-24
    8000453a:	4581                	li	a1,0
    8000453c:	4501                	li	a0,0
    8000453e:	af9ff0ef          	jal	80004036 <argfd>
    80004542:	87aa                	mv	a5,a0
    return -1;
    80004544:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004546:	0007ca63          	bltz	a5,8000455a <sys_write+0x40>
  return filewrite(f, p, n);
    8000454a:	fe442603          	lw	a2,-28(s0)
    8000454e:	fd843583          	ld	a1,-40(s0)
    80004552:	fe843503          	ld	a0,-24(s0)
    80004556:	b4eff0ef          	jal	800038a4 <filewrite>
}
    8000455a:	70a2                	ld	ra,40(sp)
    8000455c:	7402                	ld	s0,32(sp)
    8000455e:	6145                	addi	sp,sp,48
    80004560:	8082                	ret

0000000080004562 <sys_close>:
{
    80004562:	1101                	addi	sp,sp,-32
    80004564:	ec06                	sd	ra,24(sp)
    80004566:	e822                	sd	s0,16(sp)
    80004568:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000456a:	fe040613          	addi	a2,s0,-32
    8000456e:	fec40593          	addi	a1,s0,-20
    80004572:	4501                	li	a0,0
    80004574:	ac3ff0ef          	jal	80004036 <argfd>
    return -1;
    80004578:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000457a:	02054063          	bltz	a0,8000459a <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    8000457e:	ffcfc0ef          	jal	80000d7a <myproc>
    80004582:	fec42783          	lw	a5,-20(s0)
    80004586:	07e9                	addi	a5,a5,26
    80004588:	078e                	slli	a5,a5,0x3
    8000458a:	953e                	add	a0,a0,a5
    8000458c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004590:	fe043503          	ld	a0,-32(s0)
    80004594:	932ff0ef          	jal	800036c6 <fileclose>
  return 0;
    80004598:	4781                	li	a5,0
}
    8000459a:	853e                	mv	a0,a5
    8000459c:	60e2                	ld	ra,24(sp)
    8000459e:	6442                	ld	s0,16(sp)
    800045a0:	6105                	addi	sp,sp,32
    800045a2:	8082                	ret

00000000800045a4 <sys_fstat>:
{
    800045a4:	1101                	addi	sp,sp,-32
    800045a6:	ec06                	sd	ra,24(sp)
    800045a8:	e822                	sd	s0,16(sp)
    800045aa:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800045ac:	fe040593          	addi	a1,s0,-32
    800045b0:	4505                	li	a0,1
    800045b2:	945fd0ef          	jal	80001ef6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800045b6:	fe840613          	addi	a2,s0,-24
    800045ba:	4581                	li	a1,0
    800045bc:	4501                	li	a0,0
    800045be:	a79ff0ef          	jal	80004036 <argfd>
    800045c2:	87aa                	mv	a5,a0
    return -1;
    800045c4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800045c6:	0007c863          	bltz	a5,800045d6 <sys_fstat+0x32>
  return filestat(f, st);
    800045ca:	fe043583          	ld	a1,-32(s0)
    800045ce:	fe843503          	ld	a0,-24(s0)
    800045d2:	9b6ff0ef          	jal	80003788 <filestat>
}
    800045d6:	60e2                	ld	ra,24(sp)
    800045d8:	6442                	ld	s0,16(sp)
    800045da:	6105                	addi	sp,sp,32
    800045dc:	8082                	ret

00000000800045de <sys_link>:
{
    800045de:	7169                	addi	sp,sp,-304
    800045e0:	f606                	sd	ra,296(sp)
    800045e2:	f222                	sd	s0,288(sp)
    800045e4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800045e6:	08000613          	li	a2,128
    800045ea:	ed040593          	addi	a1,s0,-304
    800045ee:	4501                	li	a0,0
    800045f0:	923fd0ef          	jal	80001f12 <argstr>
    return -1;
    800045f4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800045f6:	0c054e63          	bltz	a0,800046d2 <sys_link+0xf4>
    800045fa:	08000613          	li	a2,128
    800045fe:	f5040593          	addi	a1,s0,-176
    80004602:	4505                	li	a0,1
    80004604:	90ffd0ef          	jal	80001f12 <argstr>
    return -1;
    80004608:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000460a:	0c054463          	bltz	a0,800046d2 <sys_link+0xf4>
    8000460e:	ee26                	sd	s1,280(sp)
  begin_op();
    80004610:	cabfe0ef          	jal	800032ba <begin_op>
  if((ip = namei(old)) == 0){
    80004614:	ed040513          	addi	a0,s0,-304
    80004618:	acffe0ef          	jal	800030e6 <namei>
    8000461c:	84aa                	mv	s1,a0
    8000461e:	c53d                	beqz	a0,8000468c <sys_link+0xae>
  ilock(ip);
    80004620:	ab0fe0ef          	jal	800028d0 <ilock>
  if(ip->type == T_DIR){
    80004624:	04449703          	lh	a4,68(s1)
    80004628:	4785                	li	a5,1
    8000462a:	06f70663          	beq	a4,a5,80004696 <sys_link+0xb8>
    8000462e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004630:	04a4d783          	lhu	a5,74(s1)
    80004634:	2785                	addiw	a5,a5,1
    80004636:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000463a:	8526                	mv	a0,s1
    8000463c:	9e0fe0ef          	jal	8000281c <iupdate>
  iunlock(ip);
    80004640:	8526                	mv	a0,s1
    80004642:	b3cfe0ef          	jal	8000297e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004646:	fd040593          	addi	a1,s0,-48
    8000464a:	f5040513          	addi	a0,s0,-176
    8000464e:	ab3fe0ef          	jal	80003100 <nameiparent>
    80004652:	892a                	mv	s2,a0
    80004654:	cd21                	beqz	a0,800046ac <sys_link+0xce>
  ilock(dp);
    80004656:	a7afe0ef          	jal	800028d0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000465a:	00092703          	lw	a4,0(s2)
    8000465e:	409c                	lw	a5,0(s1)
    80004660:	04f71363          	bne	a4,a5,800046a6 <sys_link+0xc8>
    80004664:	40d0                	lw	a2,4(s1)
    80004666:	fd040593          	addi	a1,s0,-48
    8000466a:	854a                	mv	a0,s2
    8000466c:	9e1fe0ef          	jal	8000304c <dirlink>
    80004670:	02054b63          	bltz	a0,800046a6 <sys_link+0xc8>
  iunlockput(dp);
    80004674:	854a                	mv	a0,s2
    80004676:	c64fe0ef          	jal	80002ada <iunlockput>
  iput(ip);
    8000467a:	8526                	mv	a0,s1
    8000467c:	bd6fe0ef          	jal	80002a52 <iput>
  end_op();
    80004680:	ca5fe0ef          	jal	80003324 <end_op>
  return 0;
    80004684:	4781                	li	a5,0
    80004686:	64f2                	ld	s1,280(sp)
    80004688:	6952                	ld	s2,272(sp)
    8000468a:	a0a1                	j	800046d2 <sys_link+0xf4>
    end_op();
    8000468c:	c99fe0ef          	jal	80003324 <end_op>
    return -1;
    80004690:	57fd                	li	a5,-1
    80004692:	64f2                	ld	s1,280(sp)
    80004694:	a83d                	j	800046d2 <sys_link+0xf4>
    iunlockput(ip);
    80004696:	8526                	mv	a0,s1
    80004698:	c42fe0ef          	jal	80002ada <iunlockput>
    end_op();
    8000469c:	c89fe0ef          	jal	80003324 <end_op>
    return -1;
    800046a0:	57fd                	li	a5,-1
    800046a2:	64f2                	ld	s1,280(sp)
    800046a4:	a03d                	j	800046d2 <sys_link+0xf4>
    iunlockput(dp);
    800046a6:	854a                	mv	a0,s2
    800046a8:	c32fe0ef          	jal	80002ada <iunlockput>
  ilock(ip);
    800046ac:	8526                	mv	a0,s1
    800046ae:	a22fe0ef          	jal	800028d0 <ilock>
  ip->nlink--;
    800046b2:	04a4d783          	lhu	a5,74(s1)
    800046b6:	37fd                	addiw	a5,a5,-1
    800046b8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800046bc:	8526                	mv	a0,s1
    800046be:	95efe0ef          	jal	8000281c <iupdate>
  iunlockput(ip);
    800046c2:	8526                	mv	a0,s1
    800046c4:	c16fe0ef          	jal	80002ada <iunlockput>
  end_op();
    800046c8:	c5dfe0ef          	jal	80003324 <end_op>
  return -1;
    800046cc:	57fd                	li	a5,-1
    800046ce:	64f2                	ld	s1,280(sp)
    800046d0:	6952                	ld	s2,272(sp)
}
    800046d2:	853e                	mv	a0,a5
    800046d4:	70b2                	ld	ra,296(sp)
    800046d6:	7412                	ld	s0,288(sp)
    800046d8:	6155                	addi	sp,sp,304
    800046da:	8082                	ret

00000000800046dc <sys_unlink>:
{
    800046dc:	7151                	addi	sp,sp,-240
    800046de:	f586                	sd	ra,232(sp)
    800046e0:	f1a2                	sd	s0,224(sp)
    800046e2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800046e4:	08000613          	li	a2,128
    800046e8:	f3040593          	addi	a1,s0,-208
    800046ec:	4501                	li	a0,0
    800046ee:	825fd0ef          	jal	80001f12 <argstr>
    800046f2:	16054063          	bltz	a0,80004852 <sys_unlink+0x176>
    800046f6:	eda6                	sd	s1,216(sp)
  begin_op();
    800046f8:	bc3fe0ef          	jal	800032ba <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800046fc:	fb040593          	addi	a1,s0,-80
    80004700:	f3040513          	addi	a0,s0,-208
    80004704:	9fdfe0ef          	jal	80003100 <nameiparent>
    80004708:	84aa                	mv	s1,a0
    8000470a:	c945                	beqz	a0,800047ba <sys_unlink+0xde>
  ilock(dp);
    8000470c:	9c4fe0ef          	jal	800028d0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004710:	00003597          	auipc	a1,0x3
    80004714:	f5058593          	addi	a1,a1,-176 # 80007660 <etext+0x660>
    80004718:	fb040513          	addi	a0,s0,-80
    8000471c:	f4efe0ef          	jal	80002e6a <namecmp>
    80004720:	10050e63          	beqz	a0,8000483c <sys_unlink+0x160>
    80004724:	00003597          	auipc	a1,0x3
    80004728:	f4458593          	addi	a1,a1,-188 # 80007668 <etext+0x668>
    8000472c:	fb040513          	addi	a0,s0,-80
    80004730:	f3afe0ef          	jal	80002e6a <namecmp>
    80004734:	10050463          	beqz	a0,8000483c <sys_unlink+0x160>
    80004738:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000473a:	f2c40613          	addi	a2,s0,-212
    8000473e:	fb040593          	addi	a1,s0,-80
    80004742:	8526                	mv	a0,s1
    80004744:	f3cfe0ef          	jal	80002e80 <dirlookup>
    80004748:	892a                	mv	s2,a0
    8000474a:	0e050863          	beqz	a0,8000483a <sys_unlink+0x15e>
  ilock(ip);
    8000474e:	982fe0ef          	jal	800028d0 <ilock>
  if(ip->nlink < 1)
    80004752:	04a91783          	lh	a5,74(s2)
    80004756:	06f05763          	blez	a5,800047c4 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000475a:	04491703          	lh	a4,68(s2)
    8000475e:	4785                	li	a5,1
    80004760:	06f70963          	beq	a4,a5,800047d2 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004764:	4641                	li	a2,16
    80004766:	4581                	li	a1,0
    80004768:	fc040513          	addi	a0,s0,-64
    8000476c:	9e3fb0ef          	jal	8000014e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004770:	4741                	li	a4,16
    80004772:	f2c42683          	lw	a3,-212(s0)
    80004776:	fc040613          	addi	a2,s0,-64
    8000477a:	4581                	li	a1,0
    8000477c:	8526                	mv	a0,s1
    8000477e:	ddefe0ef          	jal	80002d5c <writei>
    80004782:	47c1                	li	a5,16
    80004784:	08f51b63          	bne	a0,a5,8000481a <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004788:	04491703          	lh	a4,68(s2)
    8000478c:	4785                	li	a5,1
    8000478e:	08f70d63          	beq	a4,a5,80004828 <sys_unlink+0x14c>
  iunlockput(dp);
    80004792:	8526                	mv	a0,s1
    80004794:	b46fe0ef          	jal	80002ada <iunlockput>
  ip->nlink--;
    80004798:	04a95783          	lhu	a5,74(s2)
    8000479c:	37fd                	addiw	a5,a5,-1
    8000479e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800047a2:	854a                	mv	a0,s2
    800047a4:	878fe0ef          	jal	8000281c <iupdate>
  iunlockput(ip);
    800047a8:	854a                	mv	a0,s2
    800047aa:	b30fe0ef          	jal	80002ada <iunlockput>
  end_op();
    800047ae:	b77fe0ef          	jal	80003324 <end_op>
  return 0;
    800047b2:	4501                	li	a0,0
    800047b4:	64ee                	ld	s1,216(sp)
    800047b6:	694e                	ld	s2,208(sp)
    800047b8:	a849                	j	8000484a <sys_unlink+0x16e>
    end_op();
    800047ba:	b6bfe0ef          	jal	80003324 <end_op>
    return -1;
    800047be:	557d                	li	a0,-1
    800047c0:	64ee                	ld	s1,216(sp)
    800047c2:	a061                	j	8000484a <sys_unlink+0x16e>
    800047c4:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800047c6:	00003517          	auipc	a0,0x3
    800047ca:	eba50513          	addi	a0,a0,-326 # 80007680 <etext+0x680>
    800047ce:	2c0010ef          	jal	80005a8e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800047d2:	04c92703          	lw	a4,76(s2)
    800047d6:	02000793          	li	a5,32
    800047da:	f8e7f5e3          	bgeu	a5,a4,80004764 <sys_unlink+0x88>
    800047de:	e5ce                	sd	s3,200(sp)
    800047e0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800047e4:	4741                	li	a4,16
    800047e6:	86ce                	mv	a3,s3
    800047e8:	f1840613          	addi	a2,s0,-232
    800047ec:	4581                	li	a1,0
    800047ee:	854a                	mv	a0,s2
    800047f0:	c70fe0ef          	jal	80002c60 <readi>
    800047f4:	47c1                	li	a5,16
    800047f6:	00f51c63          	bne	a0,a5,8000480e <sys_unlink+0x132>
    if(de.inum != 0)
    800047fa:	f1845783          	lhu	a5,-232(s0)
    800047fe:	efa1                	bnez	a5,80004856 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004800:	29c1                	addiw	s3,s3,16
    80004802:	04c92783          	lw	a5,76(s2)
    80004806:	fcf9efe3          	bltu	s3,a5,800047e4 <sys_unlink+0x108>
    8000480a:	69ae                	ld	s3,200(sp)
    8000480c:	bfa1                	j	80004764 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000480e:	00003517          	auipc	a0,0x3
    80004812:	e8a50513          	addi	a0,a0,-374 # 80007698 <etext+0x698>
    80004816:	278010ef          	jal	80005a8e <panic>
    8000481a:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000481c:	00003517          	auipc	a0,0x3
    80004820:	e9450513          	addi	a0,a0,-364 # 800076b0 <etext+0x6b0>
    80004824:	26a010ef          	jal	80005a8e <panic>
    dp->nlink--;
    80004828:	04a4d783          	lhu	a5,74(s1)
    8000482c:	37fd                	addiw	a5,a5,-1
    8000482e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004832:	8526                	mv	a0,s1
    80004834:	fe9fd0ef          	jal	8000281c <iupdate>
    80004838:	bfa9                	j	80004792 <sys_unlink+0xb6>
    8000483a:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000483c:	8526                	mv	a0,s1
    8000483e:	a9cfe0ef          	jal	80002ada <iunlockput>
  end_op();
    80004842:	ae3fe0ef          	jal	80003324 <end_op>
  return -1;
    80004846:	557d                	li	a0,-1
    80004848:	64ee                	ld	s1,216(sp)
}
    8000484a:	70ae                	ld	ra,232(sp)
    8000484c:	740e                	ld	s0,224(sp)
    8000484e:	616d                	addi	sp,sp,240
    80004850:	8082                	ret
    return -1;
    80004852:	557d                	li	a0,-1
    80004854:	bfdd                	j	8000484a <sys_unlink+0x16e>
    iunlockput(ip);
    80004856:	854a                	mv	a0,s2
    80004858:	a82fe0ef          	jal	80002ada <iunlockput>
    goto bad;
    8000485c:	694e                	ld	s2,208(sp)
    8000485e:	69ae                	ld	s3,200(sp)
    80004860:	bff1                	j	8000483c <sys_unlink+0x160>

0000000080004862 <sys_open>:

uint64
sys_open(void)
{
    80004862:	7131                	addi	sp,sp,-192
    80004864:	fd06                	sd	ra,184(sp)
    80004866:	f922                	sd	s0,176(sp)
    80004868:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000486a:	f4c40593          	addi	a1,s0,-180
    8000486e:	4505                	li	a0,1
    80004870:	e6afd0ef          	jal	80001eda <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004874:	08000613          	li	a2,128
    80004878:	f5040593          	addi	a1,s0,-176
    8000487c:	4501                	li	a0,0
    8000487e:	e94fd0ef          	jal	80001f12 <argstr>
    80004882:	87aa                	mv	a5,a0
    return -1;
    80004884:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004886:	0a07c263          	bltz	a5,8000492a <sys_open+0xc8>
    8000488a:	f526                	sd	s1,168(sp)

  begin_op();
    8000488c:	a2ffe0ef          	jal	800032ba <begin_op>

  if(omode & O_CREATE){
    80004890:	f4c42783          	lw	a5,-180(s0)
    80004894:	2007f793          	andi	a5,a5,512
    80004898:	c3d5                	beqz	a5,8000493c <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000489a:	4681                	li	a3,0
    8000489c:	4601                	li	a2,0
    8000489e:	4589                	li	a1,2
    800048a0:	f5040513          	addi	a0,s0,-176
    800048a4:	829ff0ef          	jal	800040cc <create>
    800048a8:	84aa                	mv	s1,a0
    if(ip == 0){
    800048aa:	c541                	beqz	a0,80004932 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800048ac:	04449703          	lh	a4,68(s1)
    800048b0:	478d                	li	a5,3
    800048b2:	00f71763          	bne	a4,a5,800048c0 <sys_open+0x5e>
    800048b6:	0464d703          	lhu	a4,70(s1)
    800048ba:	47a5                	li	a5,9
    800048bc:	0ae7ed63          	bltu	a5,a4,80004976 <sys_open+0x114>
    800048c0:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800048c2:	d61fe0ef          	jal	80003622 <filealloc>
    800048c6:	892a                	mv	s2,a0
    800048c8:	c179                	beqz	a0,8000498e <sys_open+0x12c>
    800048ca:	ed4e                	sd	s3,152(sp)
    800048cc:	fc2ff0ef          	jal	8000408e <fdalloc>
    800048d0:	89aa                	mv	s3,a0
    800048d2:	0a054a63          	bltz	a0,80004986 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800048d6:	04449703          	lh	a4,68(s1)
    800048da:	478d                	li	a5,3
    800048dc:	0cf70263          	beq	a4,a5,800049a0 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800048e0:	4789                	li	a5,2
    800048e2:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800048e6:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800048ea:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800048ee:	f4c42783          	lw	a5,-180(s0)
    800048f2:	0017c713          	xori	a4,a5,1
    800048f6:	8b05                	andi	a4,a4,1
    800048f8:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800048fc:	0037f713          	andi	a4,a5,3
    80004900:	00e03733          	snez	a4,a4
    80004904:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004908:	4007f793          	andi	a5,a5,1024
    8000490c:	c791                	beqz	a5,80004918 <sys_open+0xb6>
    8000490e:	04449703          	lh	a4,68(s1)
    80004912:	4789                	li	a5,2
    80004914:	08f70d63          	beq	a4,a5,800049ae <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004918:	8526                	mv	a0,s1
    8000491a:	864fe0ef          	jal	8000297e <iunlock>
  end_op();
    8000491e:	a07fe0ef          	jal	80003324 <end_op>

  return fd;
    80004922:	854e                	mv	a0,s3
    80004924:	74aa                	ld	s1,168(sp)
    80004926:	790a                	ld	s2,160(sp)
    80004928:	69ea                	ld	s3,152(sp)
}
    8000492a:	70ea                	ld	ra,184(sp)
    8000492c:	744a                	ld	s0,176(sp)
    8000492e:	6129                	addi	sp,sp,192
    80004930:	8082                	ret
      end_op();
    80004932:	9f3fe0ef          	jal	80003324 <end_op>
      return -1;
    80004936:	557d                	li	a0,-1
    80004938:	74aa                	ld	s1,168(sp)
    8000493a:	bfc5                	j	8000492a <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    8000493c:	f5040513          	addi	a0,s0,-176
    80004940:	fa6fe0ef          	jal	800030e6 <namei>
    80004944:	84aa                	mv	s1,a0
    80004946:	c11d                	beqz	a0,8000496c <sys_open+0x10a>
    ilock(ip);
    80004948:	f89fd0ef          	jal	800028d0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000494c:	04449703          	lh	a4,68(s1)
    80004950:	4785                	li	a5,1
    80004952:	f4f71de3          	bne	a4,a5,800048ac <sys_open+0x4a>
    80004956:	f4c42783          	lw	a5,-180(s0)
    8000495a:	d3bd                	beqz	a5,800048c0 <sys_open+0x5e>
      iunlockput(ip);
    8000495c:	8526                	mv	a0,s1
    8000495e:	97cfe0ef          	jal	80002ada <iunlockput>
      end_op();
    80004962:	9c3fe0ef          	jal	80003324 <end_op>
      return -1;
    80004966:	557d                	li	a0,-1
    80004968:	74aa                	ld	s1,168(sp)
    8000496a:	b7c1                	j	8000492a <sys_open+0xc8>
      end_op();
    8000496c:	9b9fe0ef          	jal	80003324 <end_op>
      return -1;
    80004970:	557d                	li	a0,-1
    80004972:	74aa                	ld	s1,168(sp)
    80004974:	bf5d                	j	8000492a <sys_open+0xc8>
    iunlockput(ip);
    80004976:	8526                	mv	a0,s1
    80004978:	962fe0ef          	jal	80002ada <iunlockput>
    end_op();
    8000497c:	9a9fe0ef          	jal	80003324 <end_op>
    return -1;
    80004980:	557d                	li	a0,-1
    80004982:	74aa                	ld	s1,168(sp)
    80004984:	b75d                	j	8000492a <sys_open+0xc8>
      fileclose(f);
    80004986:	854a                	mv	a0,s2
    80004988:	d3ffe0ef          	jal	800036c6 <fileclose>
    8000498c:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000498e:	8526                	mv	a0,s1
    80004990:	94afe0ef          	jal	80002ada <iunlockput>
    end_op();
    80004994:	991fe0ef          	jal	80003324 <end_op>
    return -1;
    80004998:	557d                	li	a0,-1
    8000499a:	74aa                	ld	s1,168(sp)
    8000499c:	790a                	ld	s2,160(sp)
    8000499e:	b771                	j	8000492a <sys_open+0xc8>
    f->type = FD_DEVICE;
    800049a0:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800049a4:	04649783          	lh	a5,70(s1)
    800049a8:	02f91223          	sh	a5,36(s2)
    800049ac:	bf3d                	j	800048ea <sys_open+0x88>
    itrunc(ip);
    800049ae:	8526                	mv	a0,s1
    800049b0:	80efe0ef          	jal	800029be <itrunc>
    800049b4:	b795                	j	80004918 <sys_open+0xb6>

00000000800049b6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800049b6:	7175                	addi	sp,sp,-144
    800049b8:	e506                	sd	ra,136(sp)
    800049ba:	e122                	sd	s0,128(sp)
    800049bc:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800049be:	8fdfe0ef          	jal	800032ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800049c2:	08000613          	li	a2,128
    800049c6:	f7040593          	addi	a1,s0,-144
    800049ca:	4501                	li	a0,0
    800049cc:	d46fd0ef          	jal	80001f12 <argstr>
    800049d0:	02054363          	bltz	a0,800049f6 <sys_mkdir+0x40>
    800049d4:	4681                	li	a3,0
    800049d6:	4601                	li	a2,0
    800049d8:	4585                	li	a1,1
    800049da:	f7040513          	addi	a0,s0,-144
    800049de:	eeeff0ef          	jal	800040cc <create>
    800049e2:	c911                	beqz	a0,800049f6 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800049e4:	8f6fe0ef          	jal	80002ada <iunlockput>
  end_op();
    800049e8:	93dfe0ef          	jal	80003324 <end_op>
  return 0;
    800049ec:	4501                	li	a0,0
}
    800049ee:	60aa                	ld	ra,136(sp)
    800049f0:	640a                	ld	s0,128(sp)
    800049f2:	6149                	addi	sp,sp,144
    800049f4:	8082                	ret
    end_op();
    800049f6:	92ffe0ef          	jal	80003324 <end_op>
    return -1;
    800049fa:	557d                	li	a0,-1
    800049fc:	bfcd                	j	800049ee <sys_mkdir+0x38>

00000000800049fe <sys_mknod>:

uint64
sys_mknod(void)
{
    800049fe:	7135                	addi	sp,sp,-160
    80004a00:	ed06                	sd	ra,152(sp)
    80004a02:	e922                	sd	s0,144(sp)
    80004a04:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004a06:	8b5fe0ef          	jal	800032ba <begin_op>
  argint(1, &major);
    80004a0a:	f6c40593          	addi	a1,s0,-148
    80004a0e:	4505                	li	a0,1
    80004a10:	ccafd0ef          	jal	80001eda <argint>
  argint(2, &minor);
    80004a14:	f6840593          	addi	a1,s0,-152
    80004a18:	4509                	li	a0,2
    80004a1a:	cc0fd0ef          	jal	80001eda <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004a1e:	08000613          	li	a2,128
    80004a22:	f7040593          	addi	a1,s0,-144
    80004a26:	4501                	li	a0,0
    80004a28:	ceafd0ef          	jal	80001f12 <argstr>
    80004a2c:	02054563          	bltz	a0,80004a56 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004a30:	f6841683          	lh	a3,-152(s0)
    80004a34:	f6c41603          	lh	a2,-148(s0)
    80004a38:	458d                	li	a1,3
    80004a3a:	f7040513          	addi	a0,s0,-144
    80004a3e:	e8eff0ef          	jal	800040cc <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004a42:	c911                	beqz	a0,80004a56 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004a44:	896fe0ef          	jal	80002ada <iunlockput>
  end_op();
    80004a48:	8ddfe0ef          	jal	80003324 <end_op>
  return 0;
    80004a4c:	4501                	li	a0,0
}
    80004a4e:	60ea                	ld	ra,152(sp)
    80004a50:	644a                	ld	s0,144(sp)
    80004a52:	610d                	addi	sp,sp,160
    80004a54:	8082                	ret
    end_op();
    80004a56:	8cffe0ef          	jal	80003324 <end_op>
    return -1;
    80004a5a:	557d                	li	a0,-1
    80004a5c:	bfcd                	j	80004a4e <sys_mknod+0x50>

0000000080004a5e <sys_chdir>:

uint64
sys_chdir(void)
{
    80004a5e:	7135                	addi	sp,sp,-160
    80004a60:	ed06                	sd	ra,152(sp)
    80004a62:	e922                	sd	s0,144(sp)
    80004a64:	e14a                	sd	s2,128(sp)
    80004a66:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004a68:	b12fc0ef          	jal	80000d7a <myproc>
    80004a6c:	892a                	mv	s2,a0
  
  begin_op();
    80004a6e:	84dfe0ef          	jal	800032ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004a72:	08000613          	li	a2,128
    80004a76:	f6040593          	addi	a1,s0,-160
    80004a7a:	4501                	li	a0,0
    80004a7c:	c96fd0ef          	jal	80001f12 <argstr>
    80004a80:	04054363          	bltz	a0,80004ac6 <sys_chdir+0x68>
    80004a84:	e526                	sd	s1,136(sp)
    80004a86:	f6040513          	addi	a0,s0,-160
    80004a8a:	e5cfe0ef          	jal	800030e6 <namei>
    80004a8e:	84aa                	mv	s1,a0
    80004a90:	c915                	beqz	a0,80004ac4 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004a92:	e3ffd0ef          	jal	800028d0 <ilock>
  if(ip->type != T_DIR){
    80004a96:	04449703          	lh	a4,68(s1)
    80004a9a:	4785                	li	a5,1
    80004a9c:	02f71963          	bne	a4,a5,80004ace <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004aa0:	8526                	mv	a0,s1
    80004aa2:	eddfd0ef          	jal	8000297e <iunlock>
  iput(p->cwd);
    80004aa6:	15093503          	ld	a0,336(s2)
    80004aaa:	fa9fd0ef          	jal	80002a52 <iput>
  end_op();
    80004aae:	877fe0ef          	jal	80003324 <end_op>
  p->cwd = ip;
    80004ab2:	14993823          	sd	s1,336(s2)
  return 0;
    80004ab6:	4501                	li	a0,0
    80004ab8:	64aa                	ld	s1,136(sp)
}
    80004aba:	60ea                	ld	ra,152(sp)
    80004abc:	644a                	ld	s0,144(sp)
    80004abe:	690a                	ld	s2,128(sp)
    80004ac0:	610d                	addi	sp,sp,160
    80004ac2:	8082                	ret
    80004ac4:	64aa                	ld	s1,136(sp)
    end_op();
    80004ac6:	85ffe0ef          	jal	80003324 <end_op>
    return -1;
    80004aca:	557d                	li	a0,-1
    80004acc:	b7fd                	j	80004aba <sys_chdir+0x5c>
    iunlockput(ip);
    80004ace:	8526                	mv	a0,s1
    80004ad0:	80afe0ef          	jal	80002ada <iunlockput>
    end_op();
    80004ad4:	851fe0ef          	jal	80003324 <end_op>
    return -1;
    80004ad8:	557d                	li	a0,-1
    80004ada:	64aa                	ld	s1,136(sp)
    80004adc:	bff9                	j	80004aba <sys_chdir+0x5c>

0000000080004ade <sys_exec>:

uint64
sys_exec(void)
{
    80004ade:	7121                	addi	sp,sp,-448
    80004ae0:	ff06                	sd	ra,440(sp)
    80004ae2:	fb22                	sd	s0,432(sp)
    80004ae4:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004ae6:	e4840593          	addi	a1,s0,-440
    80004aea:	4505                	li	a0,1
    80004aec:	c0afd0ef          	jal	80001ef6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004af0:	08000613          	li	a2,128
    80004af4:	f5040593          	addi	a1,s0,-176
    80004af8:	4501                	li	a0,0
    80004afa:	c18fd0ef          	jal	80001f12 <argstr>
    80004afe:	87aa                	mv	a5,a0
    return -1;
    80004b00:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004b02:	0c07c463          	bltz	a5,80004bca <sys_exec+0xec>
    80004b06:	f726                	sd	s1,424(sp)
    80004b08:	f34a                	sd	s2,416(sp)
    80004b0a:	ef4e                	sd	s3,408(sp)
    80004b0c:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80004b0e:	10000613          	li	a2,256
    80004b12:	4581                	li	a1,0
    80004b14:	e5040513          	addi	a0,s0,-432
    80004b18:	e36fb0ef          	jal	8000014e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004b1c:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80004b20:	89a6                	mv	s3,s1
    80004b22:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004b24:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004b28:	00391513          	slli	a0,s2,0x3
    80004b2c:	e4040593          	addi	a1,s0,-448
    80004b30:	e4843783          	ld	a5,-440(s0)
    80004b34:	953e                	add	a0,a0,a5
    80004b36:	b1afd0ef          	jal	80001e50 <fetchaddr>
    80004b3a:	02054663          	bltz	a0,80004b66 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80004b3e:	e4043783          	ld	a5,-448(s0)
    80004b42:	c3a9                	beqz	a5,80004b84 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004b44:	dbafb0ef          	jal	800000fe <kalloc>
    80004b48:	85aa                	mv	a1,a0
    80004b4a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004b4e:	cd01                	beqz	a0,80004b66 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004b50:	6605                	lui	a2,0x1
    80004b52:	e4043503          	ld	a0,-448(s0)
    80004b56:	b44fd0ef          	jal	80001e9a <fetchstr>
    80004b5a:	00054663          	bltz	a0,80004b66 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80004b5e:	0905                	addi	s2,s2,1
    80004b60:	09a1                	addi	s3,s3,8
    80004b62:	fd4913e3          	bne	s2,s4,80004b28 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004b66:	f5040913          	addi	s2,s0,-176
    80004b6a:	6088                	ld	a0,0(s1)
    80004b6c:	c931                	beqz	a0,80004bc0 <sys_exec+0xe2>
    kfree(argv[i]);
    80004b6e:	caefb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004b72:	04a1                	addi	s1,s1,8
    80004b74:	ff249be3          	bne	s1,s2,80004b6a <sys_exec+0x8c>
  return -1;
    80004b78:	557d                	li	a0,-1
    80004b7a:	74ba                	ld	s1,424(sp)
    80004b7c:	791a                	ld	s2,416(sp)
    80004b7e:	69fa                	ld	s3,408(sp)
    80004b80:	6a5a                	ld	s4,400(sp)
    80004b82:	a0a1                	j	80004bca <sys_exec+0xec>
      argv[i] = 0;
    80004b84:	0009079b          	sext.w	a5,s2
    80004b88:	078e                	slli	a5,a5,0x3
    80004b8a:	fd078793          	addi	a5,a5,-48
    80004b8e:	97a2                	add	a5,a5,s0
    80004b90:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80004b94:	e5040593          	addi	a1,s0,-432
    80004b98:	f5040513          	addi	a0,s0,-176
    80004b9c:	928ff0ef          	jal	80003cc4 <kexec>
    80004ba0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004ba2:	f5040993          	addi	s3,s0,-176
    80004ba6:	6088                	ld	a0,0(s1)
    80004ba8:	c511                	beqz	a0,80004bb4 <sys_exec+0xd6>
    kfree(argv[i]);
    80004baa:	c72fb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004bae:	04a1                	addi	s1,s1,8
    80004bb0:	ff349be3          	bne	s1,s3,80004ba6 <sys_exec+0xc8>
  return ret;
    80004bb4:	854a                	mv	a0,s2
    80004bb6:	74ba                	ld	s1,424(sp)
    80004bb8:	791a                	ld	s2,416(sp)
    80004bba:	69fa                	ld	s3,408(sp)
    80004bbc:	6a5a                	ld	s4,400(sp)
    80004bbe:	a031                	j	80004bca <sys_exec+0xec>
  return -1;
    80004bc0:	557d                	li	a0,-1
    80004bc2:	74ba                	ld	s1,424(sp)
    80004bc4:	791a                	ld	s2,416(sp)
    80004bc6:	69fa                	ld	s3,408(sp)
    80004bc8:	6a5a                	ld	s4,400(sp)
}
    80004bca:	70fa                	ld	ra,440(sp)
    80004bcc:	745a                	ld	s0,432(sp)
    80004bce:	6139                	addi	sp,sp,448
    80004bd0:	8082                	ret

0000000080004bd2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004bd2:	7139                	addi	sp,sp,-64
    80004bd4:	fc06                	sd	ra,56(sp)
    80004bd6:	f822                	sd	s0,48(sp)
    80004bd8:	f426                	sd	s1,40(sp)
    80004bda:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004bdc:	99efc0ef          	jal	80000d7a <myproc>
    80004be0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004be2:	fd840593          	addi	a1,s0,-40
    80004be6:	4501                	li	a0,0
    80004be8:	b0efd0ef          	jal	80001ef6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004bec:	fc840593          	addi	a1,s0,-56
    80004bf0:	fd040513          	addi	a0,s0,-48
    80004bf4:	dddfe0ef          	jal	800039d0 <pipealloc>
    return -1;
    80004bf8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004bfa:	0a054463          	bltz	a0,80004ca2 <sys_pipe+0xd0>
  fd0 = -1;
    80004bfe:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004c02:	fd043503          	ld	a0,-48(s0)
    80004c06:	c88ff0ef          	jal	8000408e <fdalloc>
    80004c0a:	fca42223          	sw	a0,-60(s0)
    80004c0e:	08054163          	bltz	a0,80004c90 <sys_pipe+0xbe>
    80004c12:	fc843503          	ld	a0,-56(s0)
    80004c16:	c78ff0ef          	jal	8000408e <fdalloc>
    80004c1a:	fca42023          	sw	a0,-64(s0)
    80004c1e:	06054063          	bltz	a0,80004c7e <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004c22:	4691                	li	a3,4
    80004c24:	fc440613          	addi	a2,s0,-60
    80004c28:	fd843583          	ld	a1,-40(s0)
    80004c2c:	68a8                	ld	a0,80(s1)
    80004c2e:	e61fb0ef          	jal	80000a8e <copyout>
    80004c32:	00054e63          	bltz	a0,80004c4e <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004c36:	4691                	li	a3,4
    80004c38:	fc040613          	addi	a2,s0,-64
    80004c3c:	fd843583          	ld	a1,-40(s0)
    80004c40:	0591                	addi	a1,a1,4
    80004c42:	68a8                	ld	a0,80(s1)
    80004c44:	e4bfb0ef          	jal	80000a8e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004c48:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004c4a:	04055c63          	bgez	a0,80004ca2 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80004c4e:	fc442783          	lw	a5,-60(s0)
    80004c52:	07e9                	addi	a5,a5,26
    80004c54:	078e                	slli	a5,a5,0x3
    80004c56:	97a6                	add	a5,a5,s1
    80004c58:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004c5c:	fc042783          	lw	a5,-64(s0)
    80004c60:	07e9                	addi	a5,a5,26
    80004c62:	078e                	slli	a5,a5,0x3
    80004c64:	94be                	add	s1,s1,a5
    80004c66:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80004c6a:	fd043503          	ld	a0,-48(s0)
    80004c6e:	a59fe0ef          	jal	800036c6 <fileclose>
    fileclose(wf);
    80004c72:	fc843503          	ld	a0,-56(s0)
    80004c76:	a51fe0ef          	jal	800036c6 <fileclose>
    return -1;
    80004c7a:	57fd                	li	a5,-1
    80004c7c:	a01d                	j	80004ca2 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80004c7e:	fc442783          	lw	a5,-60(s0)
    80004c82:	0007c763          	bltz	a5,80004c90 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80004c86:	07e9                	addi	a5,a5,26
    80004c88:	078e                	slli	a5,a5,0x3
    80004c8a:	97a6                	add	a5,a5,s1
    80004c8c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80004c90:	fd043503          	ld	a0,-48(s0)
    80004c94:	a33fe0ef          	jal	800036c6 <fileclose>
    fileclose(wf);
    80004c98:	fc843503          	ld	a0,-56(s0)
    80004c9c:	a2bfe0ef          	jal	800036c6 <fileclose>
    return -1;
    80004ca0:	57fd                	li	a5,-1
}
    80004ca2:	853e                	mv	a0,a5
    80004ca4:	70e2                	ld	ra,56(sp)
    80004ca6:	7442                	ld	s0,48(sp)
    80004ca8:	74a2                	ld	s1,40(sp)
    80004caa:	6121                	addi	sp,sp,64
    80004cac:	8082                	ret
	...

0000000080004cb0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80004cb0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80004cb2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80004cb4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80004cb6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80004cb8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80004cba:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80004cbc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80004cbe:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80004cc0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80004cc2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80004cc4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80004cc6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80004cc8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80004cca:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80004ccc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80004cce:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80004cd0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80004cd2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80004cd4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80004cd6:	88afd0ef          	jal	80001d60 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80004cda:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80004cdc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80004cde:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80004ce0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80004ce2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80004ce4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80004ce6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80004ce8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80004cea:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80004cec:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80004cee:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80004cf0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80004cf2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80004cf4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80004cf6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80004cf8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80004cfa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80004cfc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80004cfe:	10200073          	sret
	...

0000000080004d0e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80004d0e:	1141                	addi	sp,sp,-16
    80004d10:	e422                	sd	s0,8(sp)
    80004d12:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004d14:	0c0007b7          	lui	a5,0xc000
    80004d18:	4705                	li	a4,1
    80004d1a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80004d1c:	0c0007b7          	lui	a5,0xc000
    80004d20:	c3d8                	sw	a4,4(a5)
}
    80004d22:	6422                	ld	s0,8(sp)
    80004d24:	0141                	addi	sp,sp,16
    80004d26:	8082                	ret

0000000080004d28 <plicinithart>:

void
plicinithart(void)
{
    80004d28:	1141                	addi	sp,sp,-16
    80004d2a:	e406                	sd	ra,8(sp)
    80004d2c:	e022                	sd	s0,0(sp)
    80004d2e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004d30:	81efc0ef          	jal	80000d4e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004d34:	0085171b          	slliw	a4,a0,0x8
    80004d38:	0c0027b7          	lui	a5,0xc002
    80004d3c:	97ba                	add	a5,a5,a4
    80004d3e:	40200713          	li	a4,1026
    80004d42:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004d46:	00d5151b          	slliw	a0,a0,0xd
    80004d4a:	0c2017b7          	lui	a5,0xc201
    80004d4e:	97aa                	add	a5,a5,a0
    80004d50:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80004d54:	60a2                	ld	ra,8(sp)
    80004d56:	6402                	ld	s0,0(sp)
    80004d58:	0141                	addi	sp,sp,16
    80004d5a:	8082                	ret

0000000080004d5c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80004d5c:	1141                	addi	sp,sp,-16
    80004d5e:	e406                	sd	ra,8(sp)
    80004d60:	e022                	sd	s0,0(sp)
    80004d62:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004d64:	febfb0ef          	jal	80000d4e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80004d68:	00d5151b          	slliw	a0,a0,0xd
    80004d6c:	0c2017b7          	lui	a5,0xc201
    80004d70:	97aa                	add	a5,a5,a0
  return irq;
}
    80004d72:	43c8                	lw	a0,4(a5)
    80004d74:	60a2                	ld	ra,8(sp)
    80004d76:	6402                	ld	s0,0(sp)
    80004d78:	0141                	addi	sp,sp,16
    80004d7a:	8082                	ret

0000000080004d7c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80004d7c:	1101                	addi	sp,sp,-32
    80004d7e:	ec06                	sd	ra,24(sp)
    80004d80:	e822                	sd	s0,16(sp)
    80004d82:	e426                	sd	s1,8(sp)
    80004d84:	1000                	addi	s0,sp,32
    80004d86:	84aa                	mv	s1,a0
  int hart = cpuid();
    80004d88:	fc7fb0ef          	jal	80000d4e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80004d8c:	00d5151b          	slliw	a0,a0,0xd
    80004d90:	0c2017b7          	lui	a5,0xc201
    80004d94:	97aa                	add	a5,a5,a0
    80004d96:	c3c4                	sw	s1,4(a5)
}
    80004d98:	60e2                	ld	ra,24(sp)
    80004d9a:	6442                	ld	s0,16(sp)
    80004d9c:	64a2                	ld	s1,8(sp)
    80004d9e:	6105                	addi	sp,sp,32
    80004da0:	8082                	ret

0000000080004da2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80004da2:	1141                	addi	sp,sp,-16
    80004da4:	e406                	sd	ra,8(sp)
    80004da6:	e022                	sd	s0,0(sp)
    80004da8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80004daa:	479d                	li	a5,7
    80004dac:	04a7ca63          	blt	a5,a0,80004e00 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80004db0:	00022797          	auipc	a5,0x22
    80004db4:	6e078793          	addi	a5,a5,1760 # 80027490 <disk>
    80004db8:	97aa                	add	a5,a5,a0
    80004dba:	0187c783          	lbu	a5,24(a5)
    80004dbe:	e7b9                	bnez	a5,80004e0c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004dc0:	00451693          	slli	a3,a0,0x4
    80004dc4:	00022797          	auipc	a5,0x22
    80004dc8:	6cc78793          	addi	a5,a5,1740 # 80027490 <disk>
    80004dcc:	6398                	ld	a4,0(a5)
    80004dce:	9736                	add	a4,a4,a3
    80004dd0:	00073023          	sd	zero,0(a4) # fffffffffffff000 <end+0xffffffff7ffcf958>
  disk.desc[i].len = 0;
    80004dd4:	6398                	ld	a4,0(a5)
    80004dd6:	9736                	add	a4,a4,a3
    80004dd8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80004ddc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004de0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004de4:	97aa                	add	a5,a5,a0
    80004de6:	4705                	li	a4,1
    80004de8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80004dec:	00022517          	auipc	a0,0x22
    80004df0:	6bc50513          	addi	a0,a0,1724 # 800274a8 <disk+0x18>
    80004df4:	e28fc0ef          	jal	8000141c <wakeup>
}
    80004df8:	60a2                	ld	ra,8(sp)
    80004dfa:	6402                	ld	s0,0(sp)
    80004dfc:	0141                	addi	sp,sp,16
    80004dfe:	8082                	ret
    panic("free_desc 1");
    80004e00:	00003517          	auipc	a0,0x3
    80004e04:	8c050513          	addi	a0,a0,-1856 # 800076c0 <etext+0x6c0>
    80004e08:	487000ef          	jal	80005a8e <panic>
    panic("free_desc 2");
    80004e0c:	00003517          	auipc	a0,0x3
    80004e10:	8c450513          	addi	a0,a0,-1852 # 800076d0 <etext+0x6d0>
    80004e14:	47b000ef          	jal	80005a8e <panic>

0000000080004e18 <virtio_disk_init>:
{
    80004e18:	1101                	addi	sp,sp,-32
    80004e1a:	ec06                	sd	ra,24(sp)
    80004e1c:	e822                	sd	s0,16(sp)
    80004e1e:	e426                	sd	s1,8(sp)
    80004e20:	e04a                	sd	s2,0(sp)
    80004e22:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004e24:	00003597          	auipc	a1,0x3
    80004e28:	8bc58593          	addi	a1,a1,-1860 # 800076e0 <etext+0x6e0>
    80004e2c:	00022517          	auipc	a0,0x22
    80004e30:	78c50513          	addi	a0,a0,1932 # 800275b8 <disk+0x128>
    80004e34:	697000ef          	jal	80005cca <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004e38:	100017b7          	lui	a5,0x10001
    80004e3c:	4398                	lw	a4,0(a5)
    80004e3e:	2701                	sext.w	a4,a4
    80004e40:	747277b7          	lui	a5,0x74727
    80004e44:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004e48:	18f71063          	bne	a4,a5,80004fc8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004e4c:	100017b7          	lui	a5,0x10001
    80004e50:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80004e52:	439c                	lw	a5,0(a5)
    80004e54:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004e56:	4709                	li	a4,2
    80004e58:	16e79863          	bne	a5,a4,80004fc8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004e5c:	100017b7          	lui	a5,0x10001
    80004e60:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80004e62:	439c                	lw	a5,0(a5)
    80004e64:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004e66:	16e79163          	bne	a5,a4,80004fc8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004e6a:	100017b7          	lui	a5,0x10001
    80004e6e:	47d8                	lw	a4,12(a5)
    80004e70:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004e72:	554d47b7          	lui	a5,0x554d4
    80004e76:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004e7a:	14f71763          	bne	a4,a5,80004fc8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004e7e:	100017b7          	lui	a5,0x10001
    80004e82:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004e86:	4705                	li	a4,1
    80004e88:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004e8a:	470d                	li	a4,3
    80004e8c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004e8e:	10001737          	lui	a4,0x10001
    80004e92:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80004e94:	c7ffe737          	lui	a4,0xc7ffe
    80004e98:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fcf0b7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004e9c:	8ef9                	and	a3,a3,a4
    80004e9e:	10001737          	lui	a4,0x10001
    80004ea2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ea4:	472d                	li	a4,11
    80004ea6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ea8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80004eac:	439c                	lw	a5,0(a5)
    80004eae:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004eb2:	8ba1                	andi	a5,a5,8
    80004eb4:	12078063          	beqz	a5,80004fd4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004eb8:	100017b7          	lui	a5,0x10001
    80004ebc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004ec0:	100017b7          	lui	a5,0x10001
    80004ec4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80004ec8:	439c                	lw	a5,0(a5)
    80004eca:	2781                	sext.w	a5,a5
    80004ecc:	10079a63          	bnez	a5,80004fe0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004ed0:	100017b7          	lui	a5,0x10001
    80004ed4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80004ed8:	439c                	lw	a5,0(a5)
    80004eda:	2781                	sext.w	a5,a5
  if(max == 0)
    80004edc:	10078863          	beqz	a5,80004fec <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004ee0:	471d                	li	a4,7
    80004ee2:	10f77b63          	bgeu	a4,a5,80004ff8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004ee6:	a18fb0ef          	jal	800000fe <kalloc>
    80004eea:	00022497          	auipc	s1,0x22
    80004eee:	5a648493          	addi	s1,s1,1446 # 80027490 <disk>
    80004ef2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004ef4:	a0afb0ef          	jal	800000fe <kalloc>
    80004ef8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004efa:	a04fb0ef          	jal	800000fe <kalloc>
    80004efe:	87aa                	mv	a5,a0
    80004f00:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004f02:	6088                	ld	a0,0(s1)
    80004f04:	10050063          	beqz	a0,80005004 <virtio_disk_init+0x1ec>
    80004f08:	00022717          	auipc	a4,0x22
    80004f0c:	59073703          	ld	a4,1424(a4) # 80027498 <disk+0x8>
    80004f10:	0e070a63          	beqz	a4,80005004 <virtio_disk_init+0x1ec>
    80004f14:	0e078863          	beqz	a5,80005004 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004f18:	6605                	lui	a2,0x1
    80004f1a:	4581                	li	a1,0
    80004f1c:	a32fb0ef          	jal	8000014e <memset>
  memset(disk.avail, 0, PGSIZE);
    80004f20:	00022497          	auipc	s1,0x22
    80004f24:	57048493          	addi	s1,s1,1392 # 80027490 <disk>
    80004f28:	6605                	lui	a2,0x1
    80004f2a:	4581                	li	a1,0
    80004f2c:	6488                	ld	a0,8(s1)
    80004f2e:	a20fb0ef          	jal	8000014e <memset>
  memset(disk.used, 0, PGSIZE);
    80004f32:	6605                	lui	a2,0x1
    80004f34:	4581                	li	a1,0
    80004f36:	6888                	ld	a0,16(s1)
    80004f38:	a16fb0ef          	jal	8000014e <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004f3c:	100017b7          	lui	a5,0x10001
    80004f40:	4721                	li	a4,8
    80004f42:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004f44:	4098                	lw	a4,0(s1)
    80004f46:	100017b7          	lui	a5,0x10001
    80004f4a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004f4e:	40d8                	lw	a4,4(s1)
    80004f50:	100017b7          	lui	a5,0x10001
    80004f54:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004f58:	649c                	ld	a5,8(s1)
    80004f5a:	0007869b          	sext.w	a3,a5
    80004f5e:	10001737          	lui	a4,0x10001
    80004f62:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004f66:	9781                	srai	a5,a5,0x20
    80004f68:	10001737          	lui	a4,0x10001
    80004f6c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004f70:	689c                	ld	a5,16(s1)
    80004f72:	0007869b          	sext.w	a3,a5
    80004f76:	10001737          	lui	a4,0x10001
    80004f7a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004f7e:	9781                	srai	a5,a5,0x20
    80004f80:	10001737          	lui	a4,0x10001
    80004f84:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004f88:	10001737          	lui	a4,0x10001
    80004f8c:	4785                	li	a5,1
    80004f8e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80004f90:	00f48c23          	sb	a5,24(s1)
    80004f94:	00f48ca3          	sb	a5,25(s1)
    80004f98:	00f48d23          	sb	a5,26(s1)
    80004f9c:	00f48da3          	sb	a5,27(s1)
    80004fa0:	00f48e23          	sb	a5,28(s1)
    80004fa4:	00f48ea3          	sb	a5,29(s1)
    80004fa8:	00f48f23          	sb	a5,30(s1)
    80004fac:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004fb0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004fb4:	100017b7          	lui	a5,0x10001
    80004fb8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80004fbc:	60e2                	ld	ra,24(sp)
    80004fbe:	6442                	ld	s0,16(sp)
    80004fc0:	64a2                	ld	s1,8(sp)
    80004fc2:	6902                	ld	s2,0(sp)
    80004fc4:	6105                	addi	sp,sp,32
    80004fc6:	8082                	ret
    panic("could not find virtio disk");
    80004fc8:	00002517          	auipc	a0,0x2
    80004fcc:	72850513          	addi	a0,a0,1832 # 800076f0 <etext+0x6f0>
    80004fd0:	2bf000ef          	jal	80005a8e <panic>
    panic("virtio disk FEATURES_OK unset");
    80004fd4:	00002517          	auipc	a0,0x2
    80004fd8:	73c50513          	addi	a0,a0,1852 # 80007710 <etext+0x710>
    80004fdc:	2b3000ef          	jal	80005a8e <panic>
    panic("virtio disk should not be ready");
    80004fe0:	00002517          	auipc	a0,0x2
    80004fe4:	75050513          	addi	a0,a0,1872 # 80007730 <etext+0x730>
    80004fe8:	2a7000ef          	jal	80005a8e <panic>
    panic("virtio disk has no queue 0");
    80004fec:	00002517          	auipc	a0,0x2
    80004ff0:	76450513          	addi	a0,a0,1892 # 80007750 <etext+0x750>
    80004ff4:	29b000ef          	jal	80005a8e <panic>
    panic("virtio disk max queue too short");
    80004ff8:	00002517          	auipc	a0,0x2
    80004ffc:	77850513          	addi	a0,a0,1912 # 80007770 <etext+0x770>
    80005000:	28f000ef          	jal	80005a8e <panic>
    panic("virtio disk kalloc");
    80005004:	00002517          	auipc	a0,0x2
    80005008:	78c50513          	addi	a0,a0,1932 # 80007790 <etext+0x790>
    8000500c:	283000ef          	jal	80005a8e <panic>

0000000080005010 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005010:	7159                	addi	sp,sp,-112
    80005012:	f486                	sd	ra,104(sp)
    80005014:	f0a2                	sd	s0,96(sp)
    80005016:	eca6                	sd	s1,88(sp)
    80005018:	e8ca                	sd	s2,80(sp)
    8000501a:	e4ce                	sd	s3,72(sp)
    8000501c:	e0d2                	sd	s4,64(sp)
    8000501e:	fc56                	sd	s5,56(sp)
    80005020:	f85a                	sd	s6,48(sp)
    80005022:	f45e                	sd	s7,40(sp)
    80005024:	f062                	sd	s8,32(sp)
    80005026:	ec66                	sd	s9,24(sp)
    80005028:	1880                	addi	s0,sp,112
    8000502a:	8a2a                	mv	s4,a0
    8000502c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000502e:	00c52c83          	lw	s9,12(a0)
    80005032:	001c9c9b          	slliw	s9,s9,0x1
    80005036:	1c82                	slli	s9,s9,0x20
    80005038:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000503c:	00022517          	auipc	a0,0x22
    80005040:	57c50513          	addi	a0,a0,1404 # 800275b8 <disk+0x128>
    80005044:	507000ef          	jal	80005d4a <acquire>
  for(int i = 0; i < 3; i++){
    80005048:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000504a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000504c:	00022b17          	auipc	s6,0x22
    80005050:	444b0b13          	addi	s6,s6,1092 # 80027490 <disk>
  for(int i = 0; i < 3; i++){
    80005054:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005056:	00022c17          	auipc	s8,0x22
    8000505a:	562c0c13          	addi	s8,s8,1378 # 800275b8 <disk+0x128>
    8000505e:	a8b9                	j	800050bc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005060:	00fb0733          	add	a4,s6,a5
    80005064:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005068:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000506a:	0207c563          	bltz	a5,80005094 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000506e:	2905                	addiw	s2,s2,1
    80005070:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005072:	05590963          	beq	s2,s5,800050c4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005076:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005078:	00022717          	auipc	a4,0x22
    8000507c:	41870713          	addi	a4,a4,1048 # 80027490 <disk>
    80005080:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005082:	01874683          	lbu	a3,24(a4)
    80005086:	fee9                	bnez	a3,80005060 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005088:	2785                	addiw	a5,a5,1
    8000508a:	0705                	addi	a4,a4,1
    8000508c:	fe979be3          	bne	a5,s1,80005082 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005090:	57fd                	li	a5,-1
    80005092:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005094:	01205d63          	blez	s2,800050ae <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005098:	f9042503          	lw	a0,-112(s0)
    8000509c:	d07ff0ef          	jal	80004da2 <free_desc>
      for(int j = 0; j < i; j++)
    800050a0:	4785                	li	a5,1
    800050a2:	0127d663          	bge	a5,s2,800050ae <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800050a6:	f9442503          	lw	a0,-108(s0)
    800050aa:	cf9ff0ef          	jal	80004da2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800050ae:	85e2                	mv	a1,s8
    800050b0:	00022517          	auipc	a0,0x22
    800050b4:	3f850513          	addi	a0,a0,1016 # 800274a8 <disk+0x18>
    800050b8:	b18fc0ef          	jal	800013d0 <sleep>
  for(int i = 0; i < 3; i++){
    800050bc:	f9040613          	addi	a2,s0,-112
    800050c0:	894e                	mv	s2,s3
    800050c2:	bf55                	j	80005076 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800050c4:	f9042503          	lw	a0,-112(s0)
    800050c8:	00451693          	slli	a3,a0,0x4

  if(write)
    800050cc:	00022797          	auipc	a5,0x22
    800050d0:	3c478793          	addi	a5,a5,964 # 80027490 <disk>
    800050d4:	00a50713          	addi	a4,a0,10
    800050d8:	0712                	slli	a4,a4,0x4
    800050da:	973e                	add	a4,a4,a5
    800050dc:	01703633          	snez	a2,s7
    800050e0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800050e2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800050e6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800050ea:	6398                	ld	a4,0(a5)
    800050ec:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800050ee:	0a868613          	addi	a2,a3,168
    800050f2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800050f4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800050f6:	6390                	ld	a2,0(a5)
    800050f8:	00d605b3          	add	a1,a2,a3
    800050fc:	4741                	li	a4,16
    800050fe:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005100:	4805                	li	a6,1
    80005102:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005106:	f9442703          	lw	a4,-108(s0)
    8000510a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000510e:	0712                	slli	a4,a4,0x4
    80005110:	963a                	add	a2,a2,a4
    80005112:	058a0593          	addi	a1,s4,88
    80005116:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005118:	0007b883          	ld	a7,0(a5)
    8000511c:	9746                	add	a4,a4,a7
    8000511e:	40000613          	li	a2,1024
    80005122:	c710                	sw	a2,8(a4)
  if(write)
    80005124:	001bb613          	seqz	a2,s7
    80005128:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000512c:	00166613          	ori	a2,a2,1
    80005130:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005134:	f9842583          	lw	a1,-104(s0)
    80005138:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000513c:	00250613          	addi	a2,a0,2
    80005140:	0612                	slli	a2,a2,0x4
    80005142:	963e                	add	a2,a2,a5
    80005144:	577d                	li	a4,-1
    80005146:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000514a:	0592                	slli	a1,a1,0x4
    8000514c:	98ae                	add	a7,a7,a1
    8000514e:	03068713          	addi	a4,a3,48
    80005152:	973e                	add	a4,a4,a5
    80005154:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005158:	6398                	ld	a4,0(a5)
    8000515a:	972e                	add	a4,a4,a1
    8000515c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005160:	4689                	li	a3,2
    80005162:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005166:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000516a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000516e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005172:	6794                	ld	a3,8(a5)
    80005174:	0026d703          	lhu	a4,2(a3)
    80005178:	8b1d                	andi	a4,a4,7
    8000517a:	0706                	slli	a4,a4,0x1
    8000517c:	96ba                	add	a3,a3,a4
    8000517e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005182:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005186:	6798                	ld	a4,8(a5)
    80005188:	00275783          	lhu	a5,2(a4)
    8000518c:	2785                	addiw	a5,a5,1
    8000518e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005192:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005196:	100017b7          	lui	a5,0x10001
    8000519a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000519e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800051a2:	00022917          	auipc	s2,0x22
    800051a6:	41690913          	addi	s2,s2,1046 # 800275b8 <disk+0x128>
  while(b->disk == 1) {
    800051aa:	4485                	li	s1,1
    800051ac:	01079a63          	bne	a5,a6,800051c0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800051b0:	85ca                	mv	a1,s2
    800051b2:	8552                	mv	a0,s4
    800051b4:	a1cfc0ef          	jal	800013d0 <sleep>
  while(b->disk == 1) {
    800051b8:	004a2783          	lw	a5,4(s4)
    800051bc:	fe978ae3          	beq	a5,s1,800051b0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800051c0:	f9042903          	lw	s2,-112(s0)
    800051c4:	00290713          	addi	a4,s2,2
    800051c8:	0712                	slli	a4,a4,0x4
    800051ca:	00022797          	auipc	a5,0x22
    800051ce:	2c678793          	addi	a5,a5,710 # 80027490 <disk>
    800051d2:	97ba                	add	a5,a5,a4
    800051d4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800051d8:	00022997          	auipc	s3,0x22
    800051dc:	2b898993          	addi	s3,s3,696 # 80027490 <disk>
    800051e0:	00491713          	slli	a4,s2,0x4
    800051e4:	0009b783          	ld	a5,0(s3)
    800051e8:	97ba                	add	a5,a5,a4
    800051ea:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800051ee:	854a                	mv	a0,s2
    800051f0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800051f4:	bafff0ef          	jal	80004da2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800051f8:	8885                	andi	s1,s1,1
    800051fa:	f0fd                	bnez	s1,800051e0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800051fc:	00022517          	auipc	a0,0x22
    80005200:	3bc50513          	addi	a0,a0,956 # 800275b8 <disk+0x128>
    80005204:	3df000ef          	jal	80005de2 <release>
}
    80005208:	70a6                	ld	ra,104(sp)
    8000520a:	7406                	ld	s0,96(sp)
    8000520c:	64e6                	ld	s1,88(sp)
    8000520e:	6946                	ld	s2,80(sp)
    80005210:	69a6                	ld	s3,72(sp)
    80005212:	6a06                	ld	s4,64(sp)
    80005214:	7ae2                	ld	s5,56(sp)
    80005216:	7b42                	ld	s6,48(sp)
    80005218:	7ba2                	ld	s7,40(sp)
    8000521a:	7c02                	ld	s8,32(sp)
    8000521c:	6ce2                	ld	s9,24(sp)
    8000521e:	6165                	addi	sp,sp,112
    80005220:	8082                	ret

0000000080005222 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005222:	1101                	addi	sp,sp,-32
    80005224:	ec06                	sd	ra,24(sp)
    80005226:	e822                	sd	s0,16(sp)
    80005228:	e426                	sd	s1,8(sp)
    8000522a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000522c:	00022497          	auipc	s1,0x22
    80005230:	26448493          	addi	s1,s1,612 # 80027490 <disk>
    80005234:	00022517          	auipc	a0,0x22
    80005238:	38450513          	addi	a0,a0,900 # 800275b8 <disk+0x128>
    8000523c:	30f000ef          	jal	80005d4a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005240:	100017b7          	lui	a5,0x10001
    80005244:	53b8                	lw	a4,96(a5)
    80005246:	8b0d                	andi	a4,a4,3
    80005248:	100017b7          	lui	a5,0x10001
    8000524c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000524e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005252:	689c                	ld	a5,16(s1)
    80005254:	0204d703          	lhu	a4,32(s1)
    80005258:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000525c:	04f70663          	beq	a4,a5,800052a8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005260:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005264:	6898                	ld	a4,16(s1)
    80005266:	0204d783          	lhu	a5,32(s1)
    8000526a:	8b9d                	andi	a5,a5,7
    8000526c:	078e                	slli	a5,a5,0x3
    8000526e:	97ba                	add	a5,a5,a4
    80005270:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005272:	00278713          	addi	a4,a5,2
    80005276:	0712                	slli	a4,a4,0x4
    80005278:	9726                	add	a4,a4,s1
    8000527a:	01074703          	lbu	a4,16(a4)
    8000527e:	e321                	bnez	a4,800052be <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005280:	0789                	addi	a5,a5,2
    80005282:	0792                	slli	a5,a5,0x4
    80005284:	97a6                	add	a5,a5,s1
    80005286:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005288:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000528c:	990fc0ef          	jal	8000141c <wakeup>

    disk.used_idx += 1;
    80005290:	0204d783          	lhu	a5,32(s1)
    80005294:	2785                	addiw	a5,a5,1
    80005296:	17c2                	slli	a5,a5,0x30
    80005298:	93c1                	srli	a5,a5,0x30
    8000529a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000529e:	6898                	ld	a4,16(s1)
    800052a0:	00275703          	lhu	a4,2(a4)
    800052a4:	faf71ee3          	bne	a4,a5,80005260 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800052a8:	00022517          	auipc	a0,0x22
    800052ac:	31050513          	addi	a0,a0,784 # 800275b8 <disk+0x128>
    800052b0:	333000ef          	jal	80005de2 <release>
}
    800052b4:	60e2                	ld	ra,24(sp)
    800052b6:	6442                	ld	s0,16(sp)
    800052b8:	64a2                	ld	s1,8(sp)
    800052ba:	6105                	addi	sp,sp,32
    800052bc:	8082                	ret
      panic("virtio_disk_intr status");
    800052be:	00002517          	auipc	a0,0x2
    800052c2:	4ea50513          	addi	a0,a0,1258 # 800077a8 <etext+0x7a8>
    800052c6:	7c8000ef          	jal	80005a8e <panic>

00000000800052ca <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    800052ca:	1141                	addi	sp,sp,-16
    800052cc:	e422                	sd	s0,8(sp)
    800052ce:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    800052d0:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    800052d4:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    800052d8:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    800052dc:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    800052e0:	577d                	li	a4,-1
    800052e2:	177e                	slli	a4,a4,0x3f
    800052e4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    800052e6:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    800052ea:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    800052ee:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    800052f2:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    800052f6:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    800052fa:	000f4737          	lui	a4,0xf4
    800052fe:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80005302:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80005304:	14d79073          	csrw	stimecmp,a5
}
    80005308:	6422                	ld	s0,8(sp)
    8000530a:	0141                	addi	sp,sp,16
    8000530c:	8082                	ret

000000008000530e <start>:
{
    8000530e:	1141                	addi	sp,sp,-16
    80005310:	e406                	sd	ra,8(sp)
    80005312:	e022                	sd	s0,0(sp)
    80005314:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80005316:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000531a:	7779                	lui	a4,0xffffe
    8000531c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffcf157>
    80005320:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80005322:	6705                	lui	a4,0x1
    80005324:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80005328:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000532a:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    8000532e:	ffffb797          	auipc	a5,0xffffb
    80005332:	fba78793          	addi	a5,a5,-70 # 800002e8 <main>
    80005336:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000533a:	4781                	li	a5,0
    8000533c:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80005340:	67c1                	lui	a5,0x10
    80005342:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80005344:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80005348:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000534c:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    80005350:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    80005354:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80005358:	57fd                	li	a5,-1
    8000535a:	83a9                	srli	a5,a5,0xa
    8000535c:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80005360:	47bd                	li	a5,15
    80005362:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80005366:	f65ff0ef          	jal	800052ca <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    8000536a:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    8000536e:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80005370:	823e                	mv	tp,a5
  asm volatile("mret");
    80005372:	30200073          	mret
}
    80005376:	60a2                	ld	ra,8(sp)
    80005378:	6402                	ld	s0,0(sp)
    8000537a:	0141                	addi	sp,sp,16
    8000537c:	8082                	ret

000000008000537e <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    8000537e:	7119                	addi	sp,sp,-128
    80005380:	fc86                	sd	ra,120(sp)
    80005382:	f8a2                	sd	s0,112(sp)
    80005384:	f4a6                	sd	s1,104(sp)
    80005386:	0100                	addi	s0,sp,128
  char buf[32];
  int i = 0;

  while(i < n){
    80005388:	06c05a63          	blez	a2,800053fc <consolewrite+0x7e>
    8000538c:	f0ca                	sd	s2,96(sp)
    8000538e:	ecce                	sd	s3,88(sp)
    80005390:	e8d2                	sd	s4,80(sp)
    80005392:	e4d6                	sd	s5,72(sp)
    80005394:	e0da                	sd	s6,64(sp)
    80005396:	fc5e                	sd	s7,56(sp)
    80005398:	f862                	sd	s8,48(sp)
    8000539a:	f466                	sd	s9,40(sp)
    8000539c:	8aaa                	mv	s5,a0
    8000539e:	8b2e                	mv	s6,a1
    800053a0:	8a32                	mv	s4,a2
  int i = 0;
    800053a2:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800053a4:	02000c13          	li	s8,32
    800053a8:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800053ac:	5bfd                	li	s7,-1
    800053ae:	a035                	j	800053da <consolewrite+0x5c>
    if(nn > n - i)
    800053b0:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800053b4:	86ce                	mv	a3,s3
    800053b6:	01648633          	add	a2,s1,s6
    800053ba:	85d6                	mv	a1,s5
    800053bc:	f8040513          	addi	a0,s0,-128
    800053c0:	c32fc0ef          	jal	800017f2 <either_copyin>
    800053c4:	03750e63          	beq	a0,s7,80005400 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    800053c8:	85ce                	mv	a1,s3
    800053ca:	f8040513          	addi	a0,s0,-128
    800053ce:	778000ef          	jal	80005b46 <uartwrite>
    i += nn;
    800053d2:	009904bb          	addw	s1,s2,s1
  while(i < n){
    800053d6:	0144da63          	bge	s1,s4,800053ea <consolewrite+0x6c>
    if(nn > n - i)
    800053da:	409a093b          	subw	s2,s4,s1
    800053de:	0009079b          	sext.w	a5,s2
    800053e2:	fcfc57e3          	bge	s8,a5,800053b0 <consolewrite+0x32>
    800053e6:	8966                	mv	s2,s9
    800053e8:	b7e1                	j	800053b0 <consolewrite+0x32>
    800053ea:	7906                	ld	s2,96(sp)
    800053ec:	69e6                	ld	s3,88(sp)
    800053ee:	6a46                	ld	s4,80(sp)
    800053f0:	6aa6                	ld	s5,72(sp)
    800053f2:	6b06                	ld	s6,64(sp)
    800053f4:	7be2                	ld	s7,56(sp)
    800053f6:	7c42                	ld	s8,48(sp)
    800053f8:	7ca2                	ld	s9,40(sp)
    800053fa:	a819                	j	80005410 <consolewrite+0x92>
  int i = 0;
    800053fc:	4481                	li	s1,0
    800053fe:	a809                	j	80005410 <consolewrite+0x92>
    80005400:	7906                	ld	s2,96(sp)
    80005402:	69e6                	ld	s3,88(sp)
    80005404:	6a46                	ld	s4,80(sp)
    80005406:	6aa6                	ld	s5,72(sp)
    80005408:	6b06                	ld	s6,64(sp)
    8000540a:	7be2                	ld	s7,56(sp)
    8000540c:	7c42                	ld	s8,48(sp)
    8000540e:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80005410:	8526                	mv	a0,s1
    80005412:	70e6                	ld	ra,120(sp)
    80005414:	7446                	ld	s0,112(sp)
    80005416:	74a6                	ld	s1,104(sp)
    80005418:	6109                	addi	sp,sp,128
    8000541a:	8082                	ret

000000008000541c <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000541c:	711d                	addi	sp,sp,-96
    8000541e:	ec86                	sd	ra,88(sp)
    80005420:	e8a2                	sd	s0,80(sp)
    80005422:	e4a6                	sd	s1,72(sp)
    80005424:	e0ca                	sd	s2,64(sp)
    80005426:	fc4e                	sd	s3,56(sp)
    80005428:	f852                	sd	s4,48(sp)
    8000542a:	f456                	sd	s5,40(sp)
    8000542c:	f05a                	sd	s6,32(sp)
    8000542e:	1080                	addi	s0,sp,96
    80005430:	8aaa                	mv	s5,a0
    80005432:	8a2e                	mv	s4,a1
    80005434:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005436:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000543a:	0002a517          	auipc	a0,0x2a
    8000543e:	19650513          	addi	a0,a0,406 # 8002f5d0 <cons>
    80005442:	109000ef          	jal	80005d4a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80005446:	0002a497          	auipc	s1,0x2a
    8000544a:	18a48493          	addi	s1,s1,394 # 8002f5d0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000544e:	0002a917          	auipc	s2,0x2a
    80005452:	21a90913          	addi	s2,s2,538 # 8002f668 <cons+0x98>
  while(n > 0){
    80005456:	0b305d63          	blez	s3,80005510 <consoleread+0xf4>
    while(cons.r == cons.w){
    8000545a:	0984a783          	lw	a5,152(s1)
    8000545e:	09c4a703          	lw	a4,156(s1)
    80005462:	0af71263          	bne	a4,a5,80005506 <consoleread+0xea>
      if(killed(myproc())){
    80005466:	915fb0ef          	jal	80000d7a <myproc>
    8000546a:	a1afc0ef          	jal	80001684 <killed>
    8000546e:	e12d                	bnez	a0,800054d0 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    80005470:	85a6                	mv	a1,s1
    80005472:	854a                	mv	a0,s2
    80005474:	f5dfb0ef          	jal	800013d0 <sleep>
    while(cons.r == cons.w){
    80005478:	0984a783          	lw	a5,152(s1)
    8000547c:	09c4a703          	lw	a4,156(s1)
    80005480:	fef703e3          	beq	a4,a5,80005466 <consoleread+0x4a>
    80005484:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80005486:	0002a717          	auipc	a4,0x2a
    8000548a:	14a70713          	addi	a4,a4,330 # 8002f5d0 <cons>
    8000548e:	0017869b          	addiw	a3,a5,1
    80005492:	08d72c23          	sw	a3,152(a4)
    80005496:	07f7f693          	andi	a3,a5,127
    8000549a:	9736                	add	a4,a4,a3
    8000549c:	01874703          	lbu	a4,24(a4)
    800054a0:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800054a4:	4691                	li	a3,4
    800054a6:	04db8663          	beq	s7,a3,800054f2 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800054aa:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800054ae:	4685                	li	a3,1
    800054b0:	faf40613          	addi	a2,s0,-81
    800054b4:	85d2                	mv	a1,s4
    800054b6:	8556                	mv	a0,s5
    800054b8:	af0fc0ef          	jal	800017a8 <either_copyout>
    800054bc:	57fd                	li	a5,-1
    800054be:	04f50863          	beq	a0,a5,8000550e <consoleread+0xf2>
      break;

    dst++;
    800054c2:	0a05                	addi	s4,s4,1
    --n;
    800054c4:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800054c6:	47a9                	li	a5,10
    800054c8:	04fb8d63          	beq	s7,a5,80005522 <consoleread+0x106>
    800054cc:	6be2                	ld	s7,24(sp)
    800054ce:	b761                	j	80005456 <consoleread+0x3a>
        release(&cons.lock);
    800054d0:	0002a517          	auipc	a0,0x2a
    800054d4:	10050513          	addi	a0,a0,256 # 8002f5d0 <cons>
    800054d8:	10b000ef          	jal	80005de2 <release>
        return -1;
    800054dc:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800054de:	60e6                	ld	ra,88(sp)
    800054e0:	6446                	ld	s0,80(sp)
    800054e2:	64a6                	ld	s1,72(sp)
    800054e4:	6906                	ld	s2,64(sp)
    800054e6:	79e2                	ld	s3,56(sp)
    800054e8:	7a42                	ld	s4,48(sp)
    800054ea:	7aa2                	ld	s5,40(sp)
    800054ec:	7b02                	ld	s6,32(sp)
    800054ee:	6125                	addi	sp,sp,96
    800054f0:	8082                	ret
      if(n < target){
    800054f2:	0009871b          	sext.w	a4,s3
    800054f6:	01677a63          	bgeu	a4,s6,8000550a <consoleread+0xee>
        cons.r--;
    800054fa:	0002a717          	auipc	a4,0x2a
    800054fe:	16f72723          	sw	a5,366(a4) # 8002f668 <cons+0x98>
    80005502:	6be2                	ld	s7,24(sp)
    80005504:	a031                	j	80005510 <consoleread+0xf4>
    80005506:	ec5e                	sd	s7,24(sp)
    80005508:	bfbd                	j	80005486 <consoleread+0x6a>
    8000550a:	6be2                	ld	s7,24(sp)
    8000550c:	a011                	j	80005510 <consoleread+0xf4>
    8000550e:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80005510:	0002a517          	auipc	a0,0x2a
    80005514:	0c050513          	addi	a0,a0,192 # 8002f5d0 <cons>
    80005518:	0cb000ef          	jal	80005de2 <release>
  return target - n;
    8000551c:	413b053b          	subw	a0,s6,s3
    80005520:	bf7d                	j	800054de <consoleread+0xc2>
    80005522:	6be2                	ld	s7,24(sp)
    80005524:	b7f5                	j	80005510 <consoleread+0xf4>

0000000080005526 <consputc>:
{
    80005526:	1141                	addi	sp,sp,-16
    80005528:	e406                	sd	ra,8(sp)
    8000552a:	e022                	sd	s0,0(sp)
    8000552c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000552e:	10000793          	li	a5,256
    80005532:	00f50863          	beq	a0,a5,80005542 <consputc+0x1c>
    uartputc_sync(c);
    80005536:	6a4000ef          	jal	80005bda <uartputc_sync>
}
    8000553a:	60a2                	ld	ra,8(sp)
    8000553c:	6402                	ld	s0,0(sp)
    8000553e:	0141                	addi	sp,sp,16
    80005540:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005542:	4521                	li	a0,8
    80005544:	696000ef          	jal	80005bda <uartputc_sync>
    80005548:	02000513          	li	a0,32
    8000554c:	68e000ef          	jal	80005bda <uartputc_sync>
    80005550:	4521                	li	a0,8
    80005552:	688000ef          	jal	80005bda <uartputc_sync>
    80005556:	b7d5                	j	8000553a <consputc+0x14>

0000000080005558 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005558:	1101                	addi	sp,sp,-32
    8000555a:	ec06                	sd	ra,24(sp)
    8000555c:	e822                	sd	s0,16(sp)
    8000555e:	e426                	sd	s1,8(sp)
    80005560:	1000                	addi	s0,sp,32
    80005562:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005564:	0002a517          	auipc	a0,0x2a
    80005568:	06c50513          	addi	a0,a0,108 # 8002f5d0 <cons>
    8000556c:	7de000ef          	jal	80005d4a <acquire>

  switch(c){
    80005570:	47d5                	li	a5,21
    80005572:	08f48f63          	beq	s1,a5,80005610 <consoleintr+0xb8>
    80005576:	0297c563          	blt	a5,s1,800055a0 <consoleintr+0x48>
    8000557a:	47a1                	li	a5,8
    8000557c:	0ef48463          	beq	s1,a5,80005664 <consoleintr+0x10c>
    80005580:	47c1                	li	a5,16
    80005582:	10f49563          	bne	s1,a5,8000568c <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    80005586:	ab6fc0ef          	jal	8000183c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000558a:	0002a517          	auipc	a0,0x2a
    8000558e:	04650513          	addi	a0,a0,70 # 8002f5d0 <cons>
    80005592:	051000ef          	jal	80005de2 <release>
}
    80005596:	60e2                	ld	ra,24(sp)
    80005598:	6442                	ld	s0,16(sp)
    8000559a:	64a2                	ld	s1,8(sp)
    8000559c:	6105                	addi	sp,sp,32
    8000559e:	8082                	ret
  switch(c){
    800055a0:	07f00793          	li	a5,127
    800055a4:	0cf48063          	beq	s1,a5,80005664 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800055a8:	0002a717          	auipc	a4,0x2a
    800055ac:	02870713          	addi	a4,a4,40 # 8002f5d0 <cons>
    800055b0:	0a072783          	lw	a5,160(a4)
    800055b4:	09872703          	lw	a4,152(a4)
    800055b8:	9f99                	subw	a5,a5,a4
    800055ba:	07f00713          	li	a4,127
    800055be:	fcf766e3          	bltu	a4,a5,8000558a <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800055c2:	47b5                	li	a5,13
    800055c4:	0cf48763          	beq	s1,a5,80005692 <consoleintr+0x13a>
      consputc(c);
    800055c8:	8526                	mv	a0,s1
    800055ca:	f5dff0ef          	jal	80005526 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800055ce:	0002a797          	auipc	a5,0x2a
    800055d2:	00278793          	addi	a5,a5,2 # 8002f5d0 <cons>
    800055d6:	0a07a683          	lw	a3,160(a5)
    800055da:	0016871b          	addiw	a4,a3,1
    800055de:	0007061b          	sext.w	a2,a4
    800055e2:	0ae7a023          	sw	a4,160(a5)
    800055e6:	07f6f693          	andi	a3,a3,127
    800055ea:	97b6                	add	a5,a5,a3
    800055ec:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    800055f0:	47a9                	li	a5,10
    800055f2:	0cf48563          	beq	s1,a5,800056bc <consoleintr+0x164>
    800055f6:	4791                	li	a5,4
    800055f8:	0cf48263          	beq	s1,a5,800056bc <consoleintr+0x164>
    800055fc:	0002a797          	auipc	a5,0x2a
    80005600:	06c7a783          	lw	a5,108(a5) # 8002f668 <cons+0x98>
    80005604:	9f1d                	subw	a4,a4,a5
    80005606:	08000793          	li	a5,128
    8000560a:	f8f710e3          	bne	a4,a5,8000558a <consoleintr+0x32>
    8000560e:	a07d                	j	800056bc <consoleintr+0x164>
    80005610:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80005612:	0002a717          	auipc	a4,0x2a
    80005616:	fbe70713          	addi	a4,a4,-66 # 8002f5d0 <cons>
    8000561a:	0a072783          	lw	a5,160(a4)
    8000561e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005622:	0002a497          	auipc	s1,0x2a
    80005626:	fae48493          	addi	s1,s1,-82 # 8002f5d0 <cons>
    while(cons.e != cons.w &&
    8000562a:	4929                	li	s2,10
    8000562c:	02f70863          	beq	a4,a5,8000565c <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005630:	37fd                	addiw	a5,a5,-1
    80005632:	07f7f713          	andi	a4,a5,127
    80005636:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005638:	01874703          	lbu	a4,24(a4)
    8000563c:	03270263          	beq	a4,s2,80005660 <consoleintr+0x108>
      cons.e--;
    80005640:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005644:	10000513          	li	a0,256
    80005648:	edfff0ef          	jal	80005526 <consputc>
    while(cons.e != cons.w &&
    8000564c:	0a04a783          	lw	a5,160(s1)
    80005650:	09c4a703          	lw	a4,156(s1)
    80005654:	fcf71ee3          	bne	a4,a5,80005630 <consoleintr+0xd8>
    80005658:	6902                	ld	s2,0(sp)
    8000565a:	bf05                	j	8000558a <consoleintr+0x32>
    8000565c:	6902                	ld	s2,0(sp)
    8000565e:	b735                	j	8000558a <consoleintr+0x32>
    80005660:	6902                	ld	s2,0(sp)
    80005662:	b725                	j	8000558a <consoleintr+0x32>
    if(cons.e != cons.w){
    80005664:	0002a717          	auipc	a4,0x2a
    80005668:	f6c70713          	addi	a4,a4,-148 # 8002f5d0 <cons>
    8000566c:	0a072783          	lw	a5,160(a4)
    80005670:	09c72703          	lw	a4,156(a4)
    80005674:	f0f70be3          	beq	a4,a5,8000558a <consoleintr+0x32>
      cons.e--;
    80005678:	37fd                	addiw	a5,a5,-1
    8000567a:	0002a717          	auipc	a4,0x2a
    8000567e:	fef72b23          	sw	a5,-10(a4) # 8002f670 <cons+0xa0>
      consputc(BACKSPACE);
    80005682:	10000513          	li	a0,256
    80005686:	ea1ff0ef          	jal	80005526 <consputc>
    8000568a:	b701                	j	8000558a <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000568c:	ee048fe3          	beqz	s1,8000558a <consoleintr+0x32>
    80005690:	bf21                	j	800055a8 <consoleintr+0x50>
      consputc(c);
    80005692:	4529                	li	a0,10
    80005694:	e93ff0ef          	jal	80005526 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005698:	0002a797          	auipc	a5,0x2a
    8000569c:	f3878793          	addi	a5,a5,-200 # 8002f5d0 <cons>
    800056a0:	0a07a703          	lw	a4,160(a5)
    800056a4:	0017069b          	addiw	a3,a4,1
    800056a8:	0006861b          	sext.w	a2,a3
    800056ac:	0ad7a023          	sw	a3,160(a5)
    800056b0:	07f77713          	andi	a4,a4,127
    800056b4:	97ba                	add	a5,a5,a4
    800056b6:	4729                	li	a4,10
    800056b8:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800056bc:	0002a797          	auipc	a5,0x2a
    800056c0:	fac7a823          	sw	a2,-80(a5) # 8002f66c <cons+0x9c>
        wakeup(&cons.r);
    800056c4:	0002a517          	auipc	a0,0x2a
    800056c8:	fa450513          	addi	a0,a0,-92 # 8002f668 <cons+0x98>
    800056cc:	d51fb0ef          	jal	8000141c <wakeup>
    800056d0:	bd6d                	j	8000558a <consoleintr+0x32>

00000000800056d2 <consoleinit>:

void
consoleinit(void)
{
    800056d2:	1141                	addi	sp,sp,-16
    800056d4:	e406                	sd	ra,8(sp)
    800056d6:	e022                	sd	s0,0(sp)
    800056d8:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800056da:	00002597          	auipc	a1,0x2
    800056de:	0e658593          	addi	a1,a1,230 # 800077c0 <etext+0x7c0>
    800056e2:	0002a517          	auipc	a0,0x2a
    800056e6:	eee50513          	addi	a0,a0,-274 # 8002f5d0 <cons>
    800056ea:	5e0000ef          	jal	80005cca <initlock>

  uartinit();
    800056ee:	400000ef          	jal	80005aee <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800056f2:	00021797          	auipc	a5,0x21
    800056f6:	d4678793          	addi	a5,a5,-698 # 80026438 <devsw>
    800056fa:	00000717          	auipc	a4,0x0
    800056fe:	d2270713          	addi	a4,a4,-734 # 8000541c <consoleread>
    80005702:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005704:	00000717          	auipc	a4,0x0
    80005708:	c7a70713          	addi	a4,a4,-902 # 8000537e <consolewrite>
    8000570c:	ef98                	sd	a4,24(a5)
}
    8000570e:	60a2                	ld	ra,8(sp)
    80005710:	6402                	ld	s0,0(sp)
    80005712:	0141                	addi	sp,sp,16
    80005714:	8082                	ret

0000000080005716 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80005716:	7139                	addi	sp,sp,-64
    80005718:	fc06                	sd	ra,56(sp)
    8000571a:	f822                	sd	s0,48(sp)
    8000571c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000571e:	c219                	beqz	a2,80005724 <printint+0xe>
    80005720:	08054063          	bltz	a0,800057a0 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80005724:	4881                	li	a7,0
    80005726:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000572a:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000572c:	00002617          	auipc	a2,0x2
    80005730:	1fc60613          	addi	a2,a2,508 # 80007928 <digits>
    80005734:	883e                	mv	a6,a5
    80005736:	2785                	addiw	a5,a5,1
    80005738:	02b57733          	remu	a4,a0,a1
    8000573c:	9732                	add	a4,a4,a2
    8000573e:	00074703          	lbu	a4,0(a4)
    80005742:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80005746:	872a                	mv	a4,a0
    80005748:	02b55533          	divu	a0,a0,a1
    8000574c:	0685                	addi	a3,a3,1
    8000574e:	feb773e3          	bgeu	a4,a1,80005734 <printint+0x1e>

  if(sign)
    80005752:	00088a63          	beqz	a7,80005766 <printint+0x50>
    buf[i++] = '-';
    80005756:	1781                	addi	a5,a5,-32
    80005758:	97a2                	add	a5,a5,s0
    8000575a:	02d00713          	li	a4,45
    8000575e:	fee78423          	sb	a4,-24(a5)
    80005762:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80005766:	02f05963          	blez	a5,80005798 <printint+0x82>
    8000576a:	f426                	sd	s1,40(sp)
    8000576c:	f04a                	sd	s2,32(sp)
    8000576e:	fc840713          	addi	a4,s0,-56
    80005772:	00f704b3          	add	s1,a4,a5
    80005776:	fff70913          	addi	s2,a4,-1
    8000577a:	993e                	add	s2,s2,a5
    8000577c:	37fd                	addiw	a5,a5,-1
    8000577e:	1782                	slli	a5,a5,0x20
    80005780:	9381                	srli	a5,a5,0x20
    80005782:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    80005786:	fff4c503          	lbu	a0,-1(s1)
    8000578a:	d9dff0ef          	jal	80005526 <consputc>
  while(--i >= 0)
    8000578e:	14fd                	addi	s1,s1,-1
    80005790:	ff249be3          	bne	s1,s2,80005786 <printint+0x70>
    80005794:	74a2                	ld	s1,40(sp)
    80005796:	7902                	ld	s2,32(sp)
}
    80005798:	70e2                	ld	ra,56(sp)
    8000579a:	7442                	ld	s0,48(sp)
    8000579c:	6121                	addi	sp,sp,64
    8000579e:	8082                	ret
    x = -xx;
    800057a0:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800057a4:	4885                	li	a7,1
    x = -xx;
    800057a6:	b741                	j	80005726 <printint+0x10>

00000000800057a8 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800057a8:	7131                	addi	sp,sp,-192
    800057aa:	fc86                	sd	ra,120(sp)
    800057ac:	f8a2                	sd	s0,112(sp)
    800057ae:	e8d2                	sd	s4,80(sp)
    800057b0:	0100                	addi	s0,sp,128
    800057b2:	8a2a                	mv	s4,a0
    800057b4:	e40c                	sd	a1,8(s0)
    800057b6:	e810                	sd	a2,16(s0)
    800057b8:	ec14                	sd	a3,24(s0)
    800057ba:	f018                	sd	a4,32(s0)
    800057bc:	f41c                	sd	a5,40(s0)
    800057be:	03043823          	sd	a6,48(s0)
    800057c2:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    800057c6:	00005797          	auipc	a5,0x5
    800057ca:	bca7a783          	lw	a5,-1078(a5) # 8000a390 <panicking>
    800057ce:	c3a1                	beqz	a5,8000580e <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800057d0:	00840793          	addi	a5,s0,8
    800057d4:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800057d8:	000a4503          	lbu	a0,0(s4)
    800057dc:	28050763          	beqz	a0,80005a6a <printf+0x2c2>
    800057e0:	f4a6                	sd	s1,104(sp)
    800057e2:	f0ca                	sd	s2,96(sp)
    800057e4:	ecce                	sd	s3,88(sp)
    800057e6:	e4d6                	sd	s5,72(sp)
    800057e8:	e0da                	sd	s6,64(sp)
    800057ea:	f862                	sd	s8,48(sp)
    800057ec:	f466                	sd	s9,40(sp)
    800057ee:	f06a                	sd	s10,32(sp)
    800057f0:	ec6e                	sd	s11,24(sp)
    800057f2:	4981                	li	s3,0
    if(cx != '%'){
    800057f4:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    800057f8:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    800057fc:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80005800:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005804:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005808:	07000d93          	li	s11,112
    8000580c:	a01d                	j	80005832 <printf+0x8a>
    acquire(&pr.lock);
    8000580e:	0002a517          	auipc	a0,0x2a
    80005812:	e6a50513          	addi	a0,a0,-406 # 8002f678 <pr>
    80005816:	534000ef          	jal	80005d4a <acquire>
    8000581a:	bf5d                	j	800057d0 <printf+0x28>
      consputc(cx);
    8000581c:	d0bff0ef          	jal	80005526 <consputc>
      continue;
    80005820:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005822:	0014899b          	addiw	s3,s1,1
    80005826:	013a07b3          	add	a5,s4,s3
    8000582a:	0007c503          	lbu	a0,0(a5)
    8000582e:	20050b63          	beqz	a0,80005a44 <printf+0x29c>
    if(cx != '%'){
    80005832:	ff5515e3          	bne	a0,s5,8000581c <printf+0x74>
    i++;
    80005836:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000583a:	009a07b3          	add	a5,s4,s1
    8000583e:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80005842:	20090b63          	beqz	s2,80005a58 <printf+0x2b0>
    80005846:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000584a:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000584c:	c789                	beqz	a5,80005856 <printf+0xae>
    8000584e:	009a0733          	add	a4,s4,s1
    80005852:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005856:	03690963          	beq	s2,s6,80005888 <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    8000585a:	05890363          	beq	s2,s8,800058a0 <printf+0xf8>
    } else if(c0 == 'u'){
    8000585e:	0d990663          	beq	s2,s9,8000592a <printf+0x182>
    } else if(c0 == 'x'){
    80005862:	11a90d63          	beq	s2,s10,8000597c <printf+0x1d4>
    } else if(c0 == 'p'){
    80005866:	15b90663          	beq	s2,s11,800059b2 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    8000586a:	06300793          	li	a5,99
    8000586e:	18f90563          	beq	s2,a5,800059f8 <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    80005872:	07300793          	li	a5,115
    80005876:	18f90b63          	beq	s2,a5,80005a0c <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000587a:	03591b63          	bne	s2,s5,800058b0 <printf+0x108>
      consputc('%');
    8000587e:	02500513          	li	a0,37
    80005882:	ca5ff0ef          	jal	80005526 <consputc>
    80005886:	bf71                	j	80005822 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    80005888:	f8843783          	ld	a5,-120(s0)
    8000588c:	00878713          	addi	a4,a5,8
    80005890:	f8e43423          	sd	a4,-120(s0)
    80005894:	4605                	li	a2,1
    80005896:	45a9                	li	a1,10
    80005898:	4388                	lw	a0,0(a5)
    8000589a:	e7dff0ef          	jal	80005716 <printint>
    8000589e:	b751                	j	80005822 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800058a0:	01678f63          	beq	a5,s6,800058be <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800058a4:	03878b63          	beq	a5,s8,800058da <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800058a8:	09978e63          	beq	a5,s9,80005944 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800058ac:	0fa78563          	beq	a5,s10,80005996 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800058b0:	8556                	mv	a0,s5
    800058b2:	c75ff0ef          	jal	80005526 <consputc>
      consputc(c0);
    800058b6:	854a                	mv	a0,s2
    800058b8:	c6fff0ef          	jal	80005526 <consputc>
    800058bc:	b79d                	j	80005822 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    800058be:	f8843783          	ld	a5,-120(s0)
    800058c2:	00878713          	addi	a4,a5,8
    800058c6:	f8e43423          	sd	a4,-120(s0)
    800058ca:	4605                	li	a2,1
    800058cc:	45a9                	li	a1,10
    800058ce:	6388                	ld	a0,0(a5)
    800058d0:	e47ff0ef          	jal	80005716 <printint>
      i += 1;
    800058d4:	0029849b          	addiw	s1,s3,2
    800058d8:	b7a9                	j	80005822 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800058da:	06400793          	li	a5,100
    800058de:	02f68863          	beq	a3,a5,8000590e <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800058e2:	07500793          	li	a5,117
    800058e6:	06f68d63          	beq	a3,a5,80005960 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800058ea:	07800793          	li	a5,120
    800058ee:	fcf691e3          	bne	a3,a5,800058b0 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    800058f2:	f8843783          	ld	a5,-120(s0)
    800058f6:	00878713          	addi	a4,a5,8
    800058fa:	f8e43423          	sd	a4,-120(s0)
    800058fe:	4601                	li	a2,0
    80005900:	45c1                	li	a1,16
    80005902:	6388                	ld	a0,0(a5)
    80005904:	e13ff0ef          	jal	80005716 <printint>
      i += 2;
    80005908:	0039849b          	addiw	s1,s3,3
    8000590c:	bf19                	j	80005822 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    8000590e:	f8843783          	ld	a5,-120(s0)
    80005912:	00878713          	addi	a4,a5,8
    80005916:	f8e43423          	sd	a4,-120(s0)
    8000591a:	4605                	li	a2,1
    8000591c:	45a9                	li	a1,10
    8000591e:	6388                	ld	a0,0(a5)
    80005920:	df7ff0ef          	jal	80005716 <printint>
      i += 2;
    80005924:	0039849b          	addiw	s1,s3,3
    80005928:	bded                	j	80005822 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000592a:	f8843783          	ld	a5,-120(s0)
    8000592e:	00878713          	addi	a4,a5,8
    80005932:	f8e43423          	sd	a4,-120(s0)
    80005936:	4601                	li	a2,0
    80005938:	45a9                	li	a1,10
    8000593a:	0007e503          	lwu	a0,0(a5)
    8000593e:	dd9ff0ef          	jal	80005716 <printint>
    80005942:	b5c5                	j	80005822 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80005944:	f8843783          	ld	a5,-120(s0)
    80005948:	00878713          	addi	a4,a5,8
    8000594c:	f8e43423          	sd	a4,-120(s0)
    80005950:	4601                	li	a2,0
    80005952:	45a9                	li	a1,10
    80005954:	6388                	ld	a0,0(a5)
    80005956:	dc1ff0ef          	jal	80005716 <printint>
      i += 1;
    8000595a:	0029849b          	addiw	s1,s3,2
    8000595e:	b5d1                	j	80005822 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80005960:	f8843783          	ld	a5,-120(s0)
    80005964:	00878713          	addi	a4,a5,8
    80005968:	f8e43423          	sd	a4,-120(s0)
    8000596c:	4601                	li	a2,0
    8000596e:	45a9                	li	a1,10
    80005970:	6388                	ld	a0,0(a5)
    80005972:	da5ff0ef          	jal	80005716 <printint>
      i += 2;
    80005976:	0039849b          	addiw	s1,s3,3
    8000597a:	b565                	j	80005822 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    8000597c:	f8843783          	ld	a5,-120(s0)
    80005980:	00878713          	addi	a4,a5,8
    80005984:	f8e43423          	sd	a4,-120(s0)
    80005988:	4601                	li	a2,0
    8000598a:	45c1                	li	a1,16
    8000598c:	0007e503          	lwu	a0,0(a5)
    80005990:	d87ff0ef          	jal	80005716 <printint>
    80005994:	b579                	j	80005822 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    80005996:	f8843783          	ld	a5,-120(s0)
    8000599a:	00878713          	addi	a4,a5,8
    8000599e:	f8e43423          	sd	a4,-120(s0)
    800059a2:	4601                	li	a2,0
    800059a4:	45c1                	li	a1,16
    800059a6:	6388                	ld	a0,0(a5)
    800059a8:	d6fff0ef          	jal	80005716 <printint>
      i += 1;
    800059ac:	0029849b          	addiw	s1,s3,2
    800059b0:	bd8d                	j	80005822 <printf+0x7a>
    800059b2:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    800059b4:	f8843783          	ld	a5,-120(s0)
    800059b8:	00878713          	addi	a4,a5,8
    800059bc:	f8e43423          	sd	a4,-120(s0)
    800059c0:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800059c4:	03000513          	li	a0,48
    800059c8:	b5fff0ef          	jal	80005526 <consputc>
  consputc('x');
    800059cc:	07800513          	li	a0,120
    800059d0:	b57ff0ef          	jal	80005526 <consputc>
    800059d4:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800059d6:	00002b97          	auipc	s7,0x2
    800059da:	f52b8b93          	addi	s7,s7,-174 # 80007928 <digits>
    800059de:	03c9d793          	srli	a5,s3,0x3c
    800059e2:	97de                	add	a5,a5,s7
    800059e4:	0007c503          	lbu	a0,0(a5)
    800059e8:	b3fff0ef          	jal	80005526 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800059ec:	0992                	slli	s3,s3,0x4
    800059ee:	397d                	addiw	s2,s2,-1
    800059f0:	fe0917e3          	bnez	s2,800059de <printf+0x236>
    800059f4:	7be2                	ld	s7,56(sp)
    800059f6:	b535                	j	80005822 <printf+0x7a>
      consputc(va_arg(ap, uint));
    800059f8:	f8843783          	ld	a5,-120(s0)
    800059fc:	00878713          	addi	a4,a5,8
    80005a00:	f8e43423          	sd	a4,-120(s0)
    80005a04:	4388                	lw	a0,0(a5)
    80005a06:	b21ff0ef          	jal	80005526 <consputc>
    80005a0a:	bd21                	j	80005822 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    80005a0c:	f8843783          	ld	a5,-120(s0)
    80005a10:	00878713          	addi	a4,a5,8
    80005a14:	f8e43423          	sd	a4,-120(s0)
    80005a18:	0007b903          	ld	s2,0(a5)
    80005a1c:	00090d63          	beqz	s2,80005a36 <printf+0x28e>
      for(; *s; s++)
    80005a20:	00094503          	lbu	a0,0(s2)
    80005a24:	de050fe3          	beqz	a0,80005822 <printf+0x7a>
        consputc(*s);
    80005a28:	affff0ef          	jal	80005526 <consputc>
      for(; *s; s++)
    80005a2c:	0905                	addi	s2,s2,1
    80005a2e:	00094503          	lbu	a0,0(s2)
    80005a32:	f97d                	bnez	a0,80005a28 <printf+0x280>
    80005a34:	b3fd                	j	80005822 <printf+0x7a>
        s = "(null)";
    80005a36:	00002917          	auipc	s2,0x2
    80005a3a:	d9290913          	addi	s2,s2,-622 # 800077c8 <etext+0x7c8>
      for(; *s; s++)
    80005a3e:	02800513          	li	a0,40
    80005a42:	b7dd                	j	80005a28 <printf+0x280>
    80005a44:	74a6                	ld	s1,104(sp)
    80005a46:	7906                	ld	s2,96(sp)
    80005a48:	69e6                	ld	s3,88(sp)
    80005a4a:	6aa6                	ld	s5,72(sp)
    80005a4c:	6b06                	ld	s6,64(sp)
    80005a4e:	7c42                	ld	s8,48(sp)
    80005a50:	7ca2                	ld	s9,40(sp)
    80005a52:	7d02                	ld	s10,32(sp)
    80005a54:	6de2                	ld	s11,24(sp)
    80005a56:	a811                	j	80005a6a <printf+0x2c2>
    80005a58:	74a6                	ld	s1,104(sp)
    80005a5a:	7906                	ld	s2,96(sp)
    80005a5c:	69e6                	ld	s3,88(sp)
    80005a5e:	6aa6                	ld	s5,72(sp)
    80005a60:	6b06                	ld	s6,64(sp)
    80005a62:	7c42                	ld	s8,48(sp)
    80005a64:	7ca2                	ld	s9,40(sp)
    80005a66:	7d02                	ld	s10,32(sp)
    80005a68:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    80005a6a:	00005797          	auipc	a5,0x5
    80005a6e:	9267a783          	lw	a5,-1754(a5) # 8000a390 <panicking>
    80005a72:	c799                	beqz	a5,80005a80 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    80005a74:	4501                	li	a0,0
    80005a76:	70e6                	ld	ra,120(sp)
    80005a78:	7446                	ld	s0,112(sp)
    80005a7a:	6a46                	ld	s4,80(sp)
    80005a7c:	6129                	addi	sp,sp,192
    80005a7e:	8082                	ret
    release(&pr.lock);
    80005a80:	0002a517          	auipc	a0,0x2a
    80005a84:	bf850513          	addi	a0,a0,-1032 # 8002f678 <pr>
    80005a88:	35a000ef          	jal	80005de2 <release>
  return 0;
    80005a8c:	b7e5                	j	80005a74 <printf+0x2cc>

0000000080005a8e <panic>:

void
panic(char *s)
{
    80005a8e:	1101                	addi	sp,sp,-32
    80005a90:	ec06                	sd	ra,24(sp)
    80005a92:	e822                	sd	s0,16(sp)
    80005a94:	e426                	sd	s1,8(sp)
    80005a96:	e04a                	sd	s2,0(sp)
    80005a98:	1000                	addi	s0,sp,32
    80005a9a:	84aa                	mv	s1,a0
  panicking = 1;
    80005a9c:	4905                	li	s2,1
    80005a9e:	00005797          	auipc	a5,0x5
    80005aa2:	8f27a923          	sw	s2,-1806(a5) # 8000a390 <panicking>
  printf("panic: ");
    80005aa6:	00002517          	auipc	a0,0x2
    80005aaa:	d2a50513          	addi	a0,a0,-726 # 800077d0 <etext+0x7d0>
    80005aae:	cfbff0ef          	jal	800057a8 <printf>
  printf("%s\n", s);
    80005ab2:	85a6                	mv	a1,s1
    80005ab4:	00002517          	auipc	a0,0x2
    80005ab8:	d2450513          	addi	a0,a0,-732 # 800077d8 <etext+0x7d8>
    80005abc:	cedff0ef          	jal	800057a8 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005ac0:	00005797          	auipc	a5,0x5
    80005ac4:	8d27a623          	sw	s2,-1844(a5) # 8000a38c <panicked>
  for(;;)
    80005ac8:	a001                	j	80005ac8 <panic+0x3a>

0000000080005aca <printfinit>:
    ;
}

void
printfinit(void)
{
    80005aca:	1141                	addi	sp,sp,-16
    80005acc:	e406                	sd	ra,8(sp)
    80005ace:	e022                	sd	s0,0(sp)
    80005ad0:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80005ad2:	00002597          	auipc	a1,0x2
    80005ad6:	d0e58593          	addi	a1,a1,-754 # 800077e0 <etext+0x7e0>
    80005ada:	0002a517          	auipc	a0,0x2a
    80005ade:	b9e50513          	addi	a0,a0,-1122 # 8002f678 <pr>
    80005ae2:	1e8000ef          	jal	80005cca <initlock>
}
    80005ae6:	60a2                	ld	ra,8(sp)
    80005ae8:	6402                	ld	s0,0(sp)
    80005aea:	0141                	addi	sp,sp,16
    80005aec:	8082                	ret

0000000080005aee <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80005aee:	1141                	addi	sp,sp,-16
    80005af0:	e406                	sd	ra,8(sp)
    80005af2:	e022                	sd	s0,0(sp)
    80005af4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005af6:	100007b7          	lui	a5,0x10000
    80005afa:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80005afe:	10000737          	lui	a4,0x10000
    80005b02:	f8000693          	li	a3,-128
    80005b06:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005b0a:	468d                	li	a3,3
    80005b0c:	10000637          	lui	a2,0x10000
    80005b10:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005b14:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005b18:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005b1c:	10000737          	lui	a4,0x10000
    80005b20:	461d                	li	a2,7
    80005b22:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005b26:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    80005b2a:	00002597          	auipc	a1,0x2
    80005b2e:	cbe58593          	addi	a1,a1,-834 # 800077e8 <etext+0x7e8>
    80005b32:	0002a517          	auipc	a0,0x2a
    80005b36:	b5e50513          	addi	a0,a0,-1186 # 8002f690 <tx_lock>
    80005b3a:	190000ef          	jal	80005cca <initlock>
}
    80005b3e:	60a2                	ld	ra,8(sp)
    80005b40:	6402                	ld	s0,0(sp)
    80005b42:	0141                	addi	sp,sp,16
    80005b44:	8082                	ret

0000000080005b46 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80005b46:	715d                	addi	sp,sp,-80
    80005b48:	e486                	sd	ra,72(sp)
    80005b4a:	e0a2                	sd	s0,64(sp)
    80005b4c:	fc26                	sd	s1,56(sp)
    80005b4e:	ec56                	sd	s5,24(sp)
    80005b50:	0880                	addi	s0,sp,80
    80005b52:	8aaa                	mv	s5,a0
    80005b54:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    80005b56:	0002a517          	auipc	a0,0x2a
    80005b5a:	b3a50513          	addi	a0,a0,-1222 # 8002f690 <tx_lock>
    80005b5e:	1ec000ef          	jal	80005d4a <acquire>

  int i = 0;
  while(i < n){ 
    80005b62:	06905063          	blez	s1,80005bc2 <uartwrite+0x7c>
    80005b66:	f84a                	sd	s2,48(sp)
    80005b68:	f44e                	sd	s3,40(sp)
    80005b6a:	f052                	sd	s4,32(sp)
    80005b6c:	e85a                	sd	s6,16(sp)
    80005b6e:	e45e                	sd	s7,8(sp)
    80005b70:	8a56                	mv	s4,s5
    80005b72:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80005b74:	00005497          	auipc	s1,0x5
    80005b78:	82448493          	addi	s1,s1,-2012 # 8000a398 <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80005b7c:	0002a997          	auipc	s3,0x2a
    80005b80:	b1498993          	addi	s3,s3,-1260 # 8002f690 <tx_lock>
    80005b84:	00005917          	auipc	s2,0x5
    80005b88:	81090913          	addi	s2,s2,-2032 # 8000a394 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80005b8c:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80005b90:	4b05                	li	s6,1
    80005b92:	a005                	j	80005bb2 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80005b94:	85ce                	mv	a1,s3
    80005b96:	854a                	mv	a0,s2
    80005b98:	839fb0ef          	jal	800013d0 <sleep>
    while(tx_busy != 0){
    80005b9c:	409c                	lw	a5,0(s1)
    80005b9e:	fbfd                	bnez	a5,80005b94 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80005ba0:	000a4783          	lbu	a5,0(s4)
    80005ba4:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    80005ba8:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80005bac:	0a05                	addi	s4,s4,1
    80005bae:	015a0563          	beq	s4,s5,80005bb8 <uartwrite+0x72>
    while(tx_busy != 0){
    80005bb2:	409c                	lw	a5,0(s1)
    80005bb4:	f3e5                	bnez	a5,80005b94 <uartwrite+0x4e>
    80005bb6:	b7ed                	j	80005ba0 <uartwrite+0x5a>
    80005bb8:	7942                	ld	s2,48(sp)
    80005bba:	79a2                	ld	s3,40(sp)
    80005bbc:	7a02                	ld	s4,32(sp)
    80005bbe:	6b42                	ld	s6,16(sp)
    80005bc0:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80005bc2:	0002a517          	auipc	a0,0x2a
    80005bc6:	ace50513          	addi	a0,a0,-1330 # 8002f690 <tx_lock>
    80005bca:	218000ef          	jal	80005de2 <release>
}
    80005bce:	60a6                	ld	ra,72(sp)
    80005bd0:	6406                	ld	s0,64(sp)
    80005bd2:	74e2                	ld	s1,56(sp)
    80005bd4:	6ae2                	ld	s5,24(sp)
    80005bd6:	6161                	addi	sp,sp,80
    80005bd8:	8082                	ret

0000000080005bda <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005bda:	1101                	addi	sp,sp,-32
    80005bdc:	ec06                	sd	ra,24(sp)
    80005bde:	e822                	sd	s0,16(sp)
    80005be0:	e426                	sd	s1,8(sp)
    80005be2:	1000                	addi	s0,sp,32
    80005be4:	84aa                	mv	s1,a0
  if(panicking == 0)
    80005be6:	00004797          	auipc	a5,0x4
    80005bea:	7aa7a783          	lw	a5,1962(a5) # 8000a390 <panicking>
    80005bee:	cf95                	beqz	a5,80005c2a <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80005bf0:	00004797          	auipc	a5,0x4
    80005bf4:	79c7a783          	lw	a5,1948(a5) # 8000a38c <panicked>
    80005bf8:	ef85                	bnez	a5,80005c30 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005bfa:	10000737          	lui	a4,0x10000
    80005bfe:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80005c00:	00074783          	lbu	a5,0(a4)
    80005c04:	0207f793          	andi	a5,a5,32
    80005c08:	dfe5                	beqz	a5,80005c00 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    80005c0a:	0ff4f513          	zext.b	a0,s1
    80005c0e:	100007b7          	lui	a5,0x10000
    80005c12:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80005c16:	00004797          	auipc	a5,0x4
    80005c1a:	77a7a783          	lw	a5,1914(a5) # 8000a390 <panicking>
    80005c1e:	cb91                	beqz	a5,80005c32 <uartputc_sync+0x58>
    pop_off();
}
    80005c20:	60e2                	ld	ra,24(sp)
    80005c22:	6442                	ld	s0,16(sp)
    80005c24:	64a2                	ld	s1,8(sp)
    80005c26:	6105                	addi	sp,sp,32
    80005c28:	8082                	ret
    push_off();
    80005c2a:	0e0000ef          	jal	80005d0a <push_off>
    80005c2e:	b7c9                	j	80005bf0 <uartputc_sync+0x16>
    for(;;)
    80005c30:	a001                	j	80005c30 <uartputc_sync+0x56>
    pop_off();
    80005c32:	15c000ef          	jal	80005d8e <pop_off>
}
    80005c36:	b7ed                	j	80005c20 <uartputc_sync+0x46>

0000000080005c38 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80005c38:	1141                	addi	sp,sp,-16
    80005c3a:	e422                	sd	s0,8(sp)
    80005c3c:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80005c3e:	100007b7          	lui	a5,0x10000
    80005c42:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80005c44:	0007c783          	lbu	a5,0(a5)
    80005c48:	8b85                	andi	a5,a5,1
    80005c4a:	cb81                	beqz	a5,80005c5a <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    80005c4c:	100007b7          	lui	a5,0x10000
    80005c50:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80005c54:	6422                	ld	s0,8(sp)
    80005c56:	0141                	addi	sp,sp,16
    80005c58:	8082                	ret
    return -1;
    80005c5a:	557d                	li	a0,-1
    80005c5c:	bfe5                	j	80005c54 <uartgetc+0x1c>

0000000080005c5e <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005c5e:	1101                	addi	sp,sp,-32
    80005c60:	ec06                	sd	ra,24(sp)
    80005c62:	e822                	sd	s0,16(sp)
    80005c64:	e426                	sd	s1,8(sp)
    80005c66:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80005c68:	100007b7          	lui	a5,0x10000
    80005c6c:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005c6e:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    80005c72:	0002a517          	auipc	a0,0x2a
    80005c76:	a1e50513          	addi	a0,a0,-1506 # 8002f690 <tx_lock>
    80005c7a:	0d0000ef          	jal	80005d4a <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80005c7e:	100007b7          	lui	a5,0x10000
    80005c82:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80005c84:	0007c783          	lbu	a5,0(a5)
    80005c88:	0207f793          	andi	a5,a5,32
    80005c8c:	eb89                	bnez	a5,80005c9e <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80005c8e:	0002a517          	auipc	a0,0x2a
    80005c92:	a0250513          	addi	a0,a0,-1534 # 8002f690 <tx_lock>
    80005c96:	14c000ef          	jal	80005de2 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80005c9a:	54fd                	li	s1,-1
    80005c9c:	a831                	j	80005cb8 <uartintr+0x5a>
    tx_busy = 0;
    80005c9e:	00004797          	auipc	a5,0x4
    80005ca2:	6e07ad23          	sw	zero,1786(a5) # 8000a398 <tx_busy>
    wakeup(&tx_chan);
    80005ca6:	00004517          	auipc	a0,0x4
    80005caa:	6ee50513          	addi	a0,a0,1774 # 8000a394 <tx_chan>
    80005cae:	f6efb0ef          	jal	8000141c <wakeup>
    80005cb2:	bff1                	j	80005c8e <uartintr+0x30>
      break;
    consoleintr(c);
    80005cb4:	8a5ff0ef          	jal	80005558 <consoleintr>
    int c = uartgetc();
    80005cb8:	f81ff0ef          	jal	80005c38 <uartgetc>
    if(c == -1)
    80005cbc:	fe951ce3          	bne	a0,s1,80005cb4 <uartintr+0x56>
  }
}
    80005cc0:	60e2                	ld	ra,24(sp)
    80005cc2:	6442                	ld	s0,16(sp)
    80005cc4:	64a2                	ld	s1,8(sp)
    80005cc6:	6105                	addi	sp,sp,32
    80005cc8:	8082                	ret

0000000080005cca <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005cca:	1141                	addi	sp,sp,-16
    80005ccc:	e422                	sd	s0,8(sp)
    80005cce:	0800                	addi	s0,sp,16
  lk->name = name;
    80005cd0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005cd2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80005cd6:	00053823          	sd	zero,16(a0)
}
    80005cda:	6422                	ld	s0,8(sp)
    80005cdc:	0141                	addi	sp,sp,16
    80005cde:	8082                	ret

0000000080005ce0 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005ce0:	411c                	lw	a5,0(a0)
    80005ce2:	e399                	bnez	a5,80005ce8 <holding+0x8>
    80005ce4:	4501                	li	a0,0
  return r;
}
    80005ce6:	8082                	ret
{
    80005ce8:	1101                	addi	sp,sp,-32
    80005cea:	ec06                	sd	ra,24(sp)
    80005cec:	e822                	sd	s0,16(sp)
    80005cee:	e426                	sd	s1,8(sp)
    80005cf0:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005cf2:	6904                	ld	s1,16(a0)
    80005cf4:	86afb0ef          	jal	80000d5e <mycpu>
    80005cf8:	40a48533          	sub	a0,s1,a0
    80005cfc:	00153513          	seqz	a0,a0
}
    80005d00:	60e2                	ld	ra,24(sp)
    80005d02:	6442                	ld	s0,16(sp)
    80005d04:	64a2                	ld	s1,8(sp)
    80005d06:	6105                	addi	sp,sp,32
    80005d08:	8082                	ret

0000000080005d0a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80005d0a:	1101                	addi	sp,sp,-32
    80005d0c:	ec06                	sd	ra,24(sp)
    80005d0e:	e822                	sd	s0,16(sp)
    80005d10:	e426                	sd	s1,8(sp)
    80005d12:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005d14:	100024f3          	csrr	s1,sstatus
    80005d18:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80005d1c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005d1e:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80005d22:	83cfb0ef          	jal	80000d5e <mycpu>
    80005d26:	5d3c                	lw	a5,120(a0)
    80005d28:	cb99                	beqz	a5,80005d3e <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80005d2a:	834fb0ef          	jal	80000d5e <mycpu>
    80005d2e:	5d3c                	lw	a5,120(a0)
    80005d30:	2785                	addiw	a5,a5,1
    80005d32:	dd3c                	sw	a5,120(a0)
}
    80005d34:	60e2                	ld	ra,24(sp)
    80005d36:	6442                	ld	s0,16(sp)
    80005d38:	64a2                	ld	s1,8(sp)
    80005d3a:	6105                	addi	sp,sp,32
    80005d3c:	8082                	ret
    mycpu()->intena = old;
    80005d3e:	820fb0ef          	jal	80000d5e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80005d42:	8085                	srli	s1,s1,0x1
    80005d44:	8885                	andi	s1,s1,1
    80005d46:	dd64                	sw	s1,124(a0)
    80005d48:	b7cd                	j	80005d2a <push_off+0x20>

0000000080005d4a <acquire>:
{
    80005d4a:	1101                	addi	sp,sp,-32
    80005d4c:	ec06                	sd	ra,24(sp)
    80005d4e:	e822                	sd	s0,16(sp)
    80005d50:	e426                	sd	s1,8(sp)
    80005d52:	1000                	addi	s0,sp,32
    80005d54:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80005d56:	fb5ff0ef          	jal	80005d0a <push_off>
  if(holding(lk))
    80005d5a:	8526                	mv	a0,s1
    80005d5c:	f85ff0ef          	jal	80005ce0 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005d60:	4705                	li	a4,1
  if(holding(lk))
    80005d62:	e105                	bnez	a0,80005d82 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005d64:	87ba                	mv	a5,a4
    80005d66:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80005d6a:	2781                	sext.w	a5,a5
    80005d6c:	ffe5                	bnez	a5,80005d64 <acquire+0x1a>
  __sync_synchronize();
    80005d6e:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80005d72:	fedfa0ef          	jal	80000d5e <mycpu>
    80005d76:	e888                	sd	a0,16(s1)
}
    80005d78:	60e2                	ld	ra,24(sp)
    80005d7a:	6442                	ld	s0,16(sp)
    80005d7c:	64a2                	ld	s1,8(sp)
    80005d7e:	6105                	addi	sp,sp,32
    80005d80:	8082                	ret
    panic("acquire");
    80005d82:	00002517          	auipc	a0,0x2
    80005d86:	a6e50513          	addi	a0,a0,-1426 # 800077f0 <etext+0x7f0>
    80005d8a:	d05ff0ef          	jal	80005a8e <panic>

0000000080005d8e <pop_off>:

void
pop_off(void)
{
    80005d8e:	1141                	addi	sp,sp,-16
    80005d90:	e406                	sd	ra,8(sp)
    80005d92:	e022                	sd	s0,0(sp)
    80005d94:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80005d96:	fc9fa0ef          	jal	80000d5e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005d9a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005d9e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005da0:	e78d                	bnez	a5,80005dca <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80005da2:	5d3c                	lw	a5,120(a0)
    80005da4:	02f05963          	blez	a5,80005dd6 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80005da8:	37fd                	addiw	a5,a5,-1
    80005daa:	0007871b          	sext.w	a4,a5
    80005dae:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005db0:	eb09                	bnez	a4,80005dc2 <pop_off+0x34>
    80005db2:	5d7c                	lw	a5,124(a0)
    80005db4:	c799                	beqz	a5,80005dc2 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005db6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005dba:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005dbe:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005dc2:	60a2                	ld	ra,8(sp)
    80005dc4:	6402                	ld	s0,0(sp)
    80005dc6:	0141                	addi	sp,sp,16
    80005dc8:	8082                	ret
    panic("pop_off - interruptible");
    80005dca:	00002517          	auipc	a0,0x2
    80005dce:	a2e50513          	addi	a0,a0,-1490 # 800077f8 <etext+0x7f8>
    80005dd2:	cbdff0ef          	jal	80005a8e <panic>
    panic("pop_off");
    80005dd6:	00002517          	auipc	a0,0x2
    80005dda:	a3a50513          	addi	a0,a0,-1478 # 80007810 <etext+0x810>
    80005dde:	cb1ff0ef          	jal	80005a8e <panic>

0000000080005de2 <release>:
{
    80005de2:	1101                	addi	sp,sp,-32
    80005de4:	ec06                	sd	ra,24(sp)
    80005de6:	e822                	sd	s0,16(sp)
    80005de8:	e426                	sd	s1,8(sp)
    80005dea:	1000                	addi	s0,sp,32
    80005dec:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005dee:	ef3ff0ef          	jal	80005ce0 <holding>
    80005df2:	c105                	beqz	a0,80005e12 <release+0x30>
  lk->cpu = 0;
    80005df4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005df8:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80005dfc:	0310000f          	fence	rw,w
    80005e00:	0004a023          	sw	zero,0(s1)
  pop_off();
    80005e04:	f8bff0ef          	jal	80005d8e <pop_off>
}
    80005e08:	60e2                	ld	ra,24(sp)
    80005e0a:	6442                	ld	s0,16(sp)
    80005e0c:	64a2                	ld	s1,8(sp)
    80005e0e:	6105                	addi	sp,sp,32
    80005e10:	8082                	ret
    panic("release");
    80005e12:	00002517          	auipc	a0,0x2
    80005e16:	a0650513          	addi	a0,a0,-1530 # 80007818 <etext+0x818>
    80005e1a:	c75ff0ef          	jal	80005a8e <panic>
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
