#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "e1000_dev.h"

#define TX_RING_SIZE 16
static struct tx_desc tx_ring[TX_RING_SIZE] __attribute__((aligned(16))); //发送环数组，每个元素是tx_desc结构体
static void *tx_bufs[TX_RING_SIZE]; // 记录发送缓冲区指针，用于释放

#define RX_RING_SIZE 16
static struct rx_desc rx_ring[RX_RING_SIZE] __attribute__((aligned(16))); //接收环数组，每个元素是rx_desc结构体
static void *rx_bufs[RX_RING_SIZE]; // 记录接收缓冲区指针

extern void net_rx(char *buf, int len);

// remember where the e1000's registers live.
static volatile uint32 *regs;

struct spinlock e1000_lock;

// called by pci_init().
// xregs is the memory address at which the
// e1000's registers are mapped.
// this code loosely follows the initialization directions
// in Chapter 14 of Intel's Software Developer's Manual.
void
e1000_init(uint32 *xregs)
{
  int i;

  initlock(&e1000_lock, "e1000");

  regs = xregs;

  // Reset the device
  regs[E1000_IMS] = 0; // disable interrupts
  regs[E1000_CTL] |= E1000_CTL_RST;
  regs[E1000_IMS] = 0; // redisable interrupts
  __sync_synchronize();

  // [E1000 14.5] Transmit initialization
  memset(tx_ring, 0, sizeof(tx_ring));
  for (i = 0; i < TX_RING_SIZE; i++) {
    tx_ring[i].status = E1000_TXD_STAT_DD;
    tx_ring[i].addr = 0;
    tx_bufs[i] = 0; // 初始化指针数组
  }
  regs[E1000_TDBAL] = (uint64) tx_ring;
  if(sizeof(tx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_TDLEN] = sizeof(tx_ring);
  regs[E1000_TDH] = regs[E1000_TDT] = 0;//初始化接收环的大小、头尾指针归0
  
  // [E1000 14.4] Receive initialization
  memset(rx_ring, 0, sizeof(rx_ring));
  for (i = 0; i < RX_RING_SIZE; i++) {
    rx_bufs[i] = kalloc(); // 分配内存并记录指针
    if (!rx_bufs[i])
      panic("e1000");
    rx_ring[i].addr = (uint64) rx_bufs[i]; // 将物理地址填入描述符
  }
  regs[E1000_RDBAL] = (uint64) rx_ring;
  if(sizeof(rx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_RDH] = 0;
  regs[E1000_RDT] = RX_RING_SIZE - 1;// tail指向最后一个可用的描述符，因为一个环大小就为16，故这里尾指针为15
  regs[E1000_RDLEN] = sizeof(rx_ring);

  // filter by qemu's MAC address, 52:54:00:12:34:56
  regs[E1000_RA] = 0x12005452;
  regs[E1000_RA+1] = 0x5634 | (1<<31);
  // multicast table
  for (int i = 0; i < 4096/32; i++)
    regs[E1000_MTA + i] = 0;

  // transmitter control bits.
  regs[E1000_TCTL] = E1000_TCTL_EN |  // enable
    E1000_TCTL_PSP |                  // pad short packets
    (0x10 << E1000_TCTL_CT_SHIFT) |   // collision stuff
    (0x40 << E1000_TCTL_COLD_SHIFT);
  regs[E1000_TIPG] = 10 | (8<<10) | (6<<20); // inter-pkt gap

  // receiver control bits.
  regs[E1000_RCTL] = E1000_RCTL_EN | // enable receiver
    E1000_RCTL_BAM |                 // enable broadcast
    E1000_RCTL_SZ_2048 |             // 2048-byte rx buffers
    E1000_RCTL_SECRC;                // strip CRC
  
  // ask e1000 for receive interrupts.
  regs[E1000_RDTR] = 0; // interrupt after every received packet (no timer)
  regs[E1000_RADV] = 0; // interrupt after every packet (no timer)
  regs[E1000_IMS] = (1 << 7); // RXDW -- Receiver Descriptor Write Back
}

int
e1000_transmit(char *buf, int len)
{
  acquire(&e1000_lock); // 发送必须加锁，防止多个 CPU 同时操作网卡寄存器导致混乱

  uint32 idx = regs[E1000_TDT]; //获取当前应该往哪放数据,即尾指针的位置

  // 检查该位置是否可用 (DD位为1表示之前的包发完了，可以使用)
  if((tx_ring[idx].status & E1000_TXD_STAT_DD) == 0){
    release(&e1000_lock);
    return -1; // 队列满了，返回失败
  }

  // 如果这个位置之前有指针，说明那个包已经发完了，释放它
  if(tx_bufs[idx]){
    kfree(tx_bufs[idx]);
    tx_bufs[idx] = 0;
  }

  // 填入新数据的信息
  tx_ring[idx].addr = (uint64)buf; 
  tx_ring[idx].length = len;     
  tx_ring[idx].cmd = E1000_TXD_CMD_EOP | E1000_TXD_CMD_RS; // EOP:包结束, RS:发完报告状态，意思是发完了会运行这个命令，使status置为1，表示发完了
  
  tx_bufs[idx] = buf; // 记录指针，以便下次转回这里时释放

  // 更新尾指针位置，写入这个寄存器会触发网卡开始工作！
  regs[E1000_TDT] = (idx + 1) % TX_RING_SIZE;

  release(&e1000_lock);
  return 0;
}

static void
e1000_recv(void)
{
  // 计算要检查的接收环位置 (RDT的下一个位置)
  int idx = (regs[E1000_RDT] + 1) % RX_RING_SIZE;

  // 循环检查，只要DD位是1，说明网卡在这里写了数据
  while(rx_ring[idx].status & E1000_RXD_STAT_DD){
    
    // 取出接收到的数据的指针
    char *buf = rx_bufs[idx];
    int len = rx_ring[idx].length; // 网卡告诉我们实际收了多少字节
    //上传到网络层
    net_rx(buf, len);

    // 补充新的空缓冲区
    buf = kalloc(); 
    if(buf == 0) panic("e1000_recv kalloc");

    // 更新软件记录
    rx_bufs[idx] = buf; 
    rx_ring[idx].addr = (uint64)buf; 
    rx_ring[idx].status = 0; 

    // 推进 RDT 指针，即当前新的空间是队列中最后一个可用的描述符，故更新尾指针
    regs[E1000_RDT] = idx;

    // 继续检查下一个
    idx = (idx + 1) % RX_RING_SIZE;
  }
}

void
e1000_intr(void)
{
  // tell the e1000 we've seen this interrupt;
  // without this the e1000 won't raise any
  // further interrupts.
  regs[E1000_ICR] = 0xffffffff;

  e1000_recv();
}