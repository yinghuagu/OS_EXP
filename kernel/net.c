#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "fs.h"
#include "sleeplock.h"
#include "file.h"
#include "net.h"

// xv6's ethernet and IP addresses
static uint8 local_mac[ETHADDR_LEN] = { 0x52, 0x54, 0x00, 0x12, 0x34, 0x56 };
static uint32 local_ip = MAKE_IP_ADDR(10, 0, 2, 15);

// qemu host's ethernet address.
static uint8 host_mac[ETHADDR_LEN] = { 0x52, 0x55, 0x0a, 0x00, 0x02, 0x02 };

static struct spinlock netlock;

// 新增的数据结构，每一个 struct sock 代表一个“正在监听的端口”

#define NSOCK 16         // 最大支持绑定的端口数
#define RX_RING_SIZE 16  // 每个端口最多缓存 16 个包

struct sock {
  struct spinlock lock;     // 保护该 socket 的锁
  int port;                 // 绑定的本地端口号
  int valid;                // 是否正在使用：1=已绑定，0=空闲
  char *rxq[RX_RING_SIZE];  // 接收队列：存放等待 recv 的数据包指针
  int r;                    // 读索引 (Read Index)
  int w;                    // 写索引 (Write Index)
};

// 全局 sockets 数组
struct sock sockets[NSOCK];

void
netinit(void)
{
  initlock(&netlock, "netlock");
  // 初始化每个 socket 的锁
  for(int i = 0; i < NSOCK; i++) {
    initlock(&sockets[i].lock, "sock");
  }
}

//
// bind(int port)
// prepare to receive UDP packets address to the port,
// i.e. allocate any queues &c needed.
//
uint64
sys_bind(void)
{
  int port;
  argint(0, &port);

  acquire(&netlock);
  
  // 1. 检查该端口是否已经被绑定
  for(int i = 0; i < NSOCK; i++) {
    if(sockets[i].valid && sockets[i].port == port) {
      release(&netlock);
      return -1; // 端口已被占用
    }
  }

  // 2. 找一个空闲的 socket 结构
  for(int i = 0; i < NSOCK; i++) {
    if(!sockets[i].valid) {
      sockets[i].valid = 1;
      sockets[i].port = port;
      sockets[i].r = 0;
      sockets[i].w = 0;
      release(&netlock);
      return 0; // 绑定成功
    }
  }
  
  release(&netlock);
  return -1; // 没有空闲 socket
}

//
// unbind(int port)
// release any resources previously created by bind(port);
// from now on UDP packets addressed to port should be dropped.
//
uint64
sys_unbind(void)
{
  int port;
  argint(0, &port);
    
  acquire(&netlock);
  for(int i = 0; i < NSOCK; i++) {
    if(sockets[i].valid && sockets[i].port == port) {
      acquire(&sockets[i].lock);
      while(sockets[i].r != sockets[i].w) {
        kfree(sockets[i].rxq[sockets[i].r]);
        sockets[i].r = (sockets[i].r + 1) % RX_RING_SIZE;
      }
      release(&sockets[i].lock);
      
      // 标记为未使用
      sockets[i].valid = 0;
      release(&netlock);
      return 0;
    }
  }
  release(&netlock);
  return 0;
}

//
// recv(int dport, int *src, short *sport, char *buf, int maxlen)
// if there's a received UDP packet already queued that was
// addressed to dport, then return it.
// otherwise wait for such a packet.
//
// sets *src to the IP source address.
// sets *sport to the UDP source port.
// copies up to maxlen bytes of UDP payload to buf.
// returns the number of bytes copied,
// and -1 if there was an error.
//
// dport, *src, and *sport are host byte order.
// bind(dport) must previously have been called.
//
uint64
sys_recv(void)
{
  int dport;
  uint64 src_addr, sport_addr, buf_addr;
  int maxlen;

  argint(0, &dport);
  argaddr(1, &src_addr);
  argaddr(2, &sport_addr);
  argaddr(3, &buf_addr);// 用户空间提供的地址
  argint(4, &maxlen);// 用户空间提供的最大长度

  struct sock *s = 0;

  // 查找对应 dport 的 socket
  acquire(&netlock);
  for(int i = 0; i < NSOCK; i++) {
    if(sockets[i].valid && sockets[i].port == dport) {
      s = &sockets[i];
      break;
    }
  }
  release(&netlock);

  if(s == 0) return -1; // 端口未绑定

  acquire(&s->lock);
  
  // 如果队列为空，则睡眠等待 (Sleep)
  while(s->r == s->w) {
    if(myproc()->killed) {
      release(&s->lock);
      return -1;
    }
    sleep(s, &s->lock);
  }

  char *buf = s->rxq[s->r];
  s->r = (s->r + 1) % RX_RING_SIZE;
  
  release(&s->lock);

  // 解析头部 (Ethernet -> IP -> UDP)
  struct eth *eth = (struct eth *)buf;
  struct ip *ip = (struct ip *)(eth + 1);
  struct udp *udp = (struct udp *)(ip + 1);
  char *payload = (char *)(udp + 1); // 实际数据在 UDP 头之后
  
  // 计算 payload 长度 = UDP包总长 - UDP头长度(2*4=8字节)
  int payload_len = ntohs(udp->ulen) - sizeof(struct udp);

  // 准备返回给用户的数据，需要注意字节序转换: Network -> Host
  uint32 src_ip = ntohl(ip->ip_src);
  uint16 src_port = ntohs(udp->sport);
  int copy_len = payload_len < maxlen ? payload_len : maxlen; // 防止缓冲区溢出

  // 复制数据到用户空间 (copyout)
  if(copyout(myproc()->pagetable, src_addr, (char*)&src_ip, sizeof(src_ip)) < 0 ||
     copyout(myproc()->pagetable, sport_addr, (char*)&src_port, sizeof(src_port)) < 0 ||
     copyout(myproc()->pagetable, buf_addr, payload, copy_len) < 0) {
    kfree(buf); // 即使失败也要释放内存
    return -1;
  }

  // 6. 释放数据包内存
  kfree(buf);
  return copy_len;
}

// This code is lifted from FreeBSD's ping.c, and is copyright by the Regents
// of the University of California.
static unsigned short
in_cksum(const unsigned char *addr, int len)
{
  int nleft = len;
  const unsigned short *w = (const unsigned short *)addr;
  unsigned int sum = 0;
  unsigned short answer = 0;

  /*
   * Our algorithm is simple, using a 32 bit accumulator (sum), we add
   * sequential 16 bit words to it, and at the end, fold back all the
   * carry bits from the top 16 bits into the lower 16 bits.
   */
  while (nleft > 1)  {
    sum += *w++;
    nleft -= 2;
  }

  /* mop up an odd byte, if necessary */
  if (nleft == 1) {
    *(unsigned char *)(&answer) = *(const unsigned char *)w;
    sum += answer;
  }

  /* add back carry outs from top 16 bits to low 16 bits */
  sum = (sum & 0xffff) + (sum >> 16);
  sum += (sum >> 16);
  /* guaranteed now that the lower 16 bits of sum are correct */

  answer = ~sum; /* truncate to 16 bits */
  return answer;
}

//
// send(int sport, int dst, int dport, char *buf, int len)
//
uint64
sys_send(void)
{
  struct proc *p = myproc();
  int sport;
  int dst;
  int dport;
  uint64 bufaddr;
  int len;

  argint(0, &sport);
  argint(1, &dst);
  argint(2, &dport);
  argaddr(3, &bufaddr);
  argint(4, &len);

  int total = len + sizeof(struct eth) + sizeof(struct ip) + sizeof(struct udp);
  if(total > PGSIZE)
    return -1;

  char *buf = kalloc();
  if(buf == 0){
    printf("sys_send: kalloc failed\n");
    return -1;
  }
  memset(buf, 0, PGSIZE);

  struct eth *eth = (struct eth *) buf;
  memmove(eth->dhost, host_mac, ETHADDR_LEN);
  memmove(eth->shost, local_mac, ETHADDR_LEN);
  eth->type = htons(ETHTYPE_IP);

  struct ip *ip = (struct ip *)(eth + 1);
  ip->ip_vhl = 0x45; // version 4, header length 4*5
  ip->ip_tos = 0;
  ip->ip_len = htons(sizeof(struct ip) + sizeof(struct udp) + len);
  ip->ip_id = 0;
  ip->ip_off = 0;
  ip->ip_ttl = 100;
  ip->ip_p = IPPROTO_UDP;
  ip->ip_src = htonl(local_ip);
  ip->ip_dst = htonl(dst);
  ip->ip_sum = in_cksum((unsigned char *)ip, sizeof(*ip));

  struct udp *udp = (struct udp *)(ip + 1);
  udp->sport = htons(sport);
  udp->dport = htons(dport);
  udp->ulen = htons(len + sizeof(struct udp));

  char *payload = (char *)(udp + 1);
  if(copyin(p->pagetable, payload, bufaddr, len) < 0){
    kfree(buf);
    printf("send: copyin failed\n");
    return -1;
  }

  e1000_transmit(buf, total);

  return 0;
}

void
ip_rx(char *buf, int len)
{
  // don't delete this printf; make grade depends on it.
  static int seen_ip = 0;
  if(seen_ip == 0)
    printf("ip_rx: received an IP packet\n");
  seen_ip = 1;

  //
  // Your code here.
  //
  
  // 解析协议头
  struct eth *eth = (struct eth *)buf;
  struct ip *ip = (struct ip *)(eth + 1);
  
  // 检查是否为 UDP 协议
  if(ip->ip_p != IPPROTO_UDP) {
    // 不是 UDP，我们不处理，释放内存
    kfree(buf);
    return;
  }

  // 获取目的端口 (Destination Port)
  struct udp *udp = (struct udp *)(ip + 1);
  uint16 dport = ntohs(udp->dport);

  // 查找是否有进程 bind 了这个端口
  struct sock *s = 0;
  acquire(&netlock);
  for(int i = 0; i < NSOCK; i++) {
    if(sockets[i].valid && sockets[i].port == dport) {
      s = &sockets[i];
      break;
    }
  }
  release(&netlock);

  // 处理数据包
  if(s) {
    acquire(&s->lock);
    // 判断缓冲区是否满了，环形队列判满条件: (write + 1) % SIZE == read
    if((s->w + 1) % RX_RING_SIZE == s->r) {
      // 队列满了，丢弃包
      release(&s->lock);
      kfree(buf);
    } else {
      // 入队
      s->rxq[s->w] = buf;
      s->w = (s->w + 1) % RX_RING_SIZE;
      wakeup(s); // 唤醒正在 sys_recv 中睡眠的进程
      release(&s->lock);
    }
  } else {
    // 没人监听这个端口，丢弃
    kfree(buf);
  }
}

//
// send an ARP reply packet to tell qemu to map
// xv6's ip address to its ethernet address.
// this is the bare minimum needed to persuade
// qemu to send IP packets to xv6; the real ARP
// protocol is more complex.
//
void
arp_rx(char *inbuf)
{
  static int seen_arp = 0;

  if(seen_arp){
    kfree(inbuf);
    return;
  }
  printf("arp_rx: received an ARP packet\n");
  seen_arp = 1;

  struct eth *ineth = (struct eth *) inbuf;
  struct arp *inarp = (struct arp *) (ineth + 1);

  char *buf = kalloc();
  if(buf == 0)
    panic("send_arp_reply");
  
  struct eth *eth = (struct eth *) buf;
  memmove(eth->dhost, ineth->shost, ETHADDR_LEN); // ethernet destination = query source
  memmove(eth->shost, local_mac, ETHADDR_LEN); // ethernet source = xv6's ethernet address
  eth->type = htons(ETHTYPE_ARP);

  struct arp *arp = (struct arp *)(eth + 1);
  arp->hrd = htons(ARP_HRD_ETHER);
  arp->pro = htons(ETHTYPE_IP);
  arp->hln = ETHADDR_LEN;
  arp->pln = sizeof(uint32);
  arp->op = htons(ARP_OP_REPLY);

  memmove(arp->sha, local_mac, ETHADDR_LEN);
  arp->sip = htonl(local_ip);
  memmove(arp->tha, ineth->shost, ETHADDR_LEN);
  arp->tip = inarp->sip;

  e1000_transmit(buf, sizeof(*eth) + sizeof(*arp));

  kfree(inbuf);
}

void
net_rx(char *buf, int len)
{
  struct eth *eth = (struct eth *) buf;

  if(len >= sizeof(struct eth) + sizeof(struct arp) &&
     ntohs(eth->type) == ETHTYPE_ARP){
    arp_rx(buf);
  } else if(len >= sizeof(struct eth) + sizeof(struct ip) &&
     ntohs(eth->type) == ETHTYPE_IP){
    ip_rx(buf, len);
  } else {
    kfree(buf);
  }
}