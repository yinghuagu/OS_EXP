# MIT 6.S081 Lab: Networking

**Lab Website:** https://pdos.csail.mit.edu/6.S081/2025/labs/net.html

This repository contains my implementation of the **Networking Lab** for the MIT 6.S081 (Operating System Engineering) course. The project adds a functional network stack to the xv6 operating system, enabling it to communicate via the UDP protocol using an emulated E1000 network interface card.

## Project Overview

The goal of this lab is to write a device driver for a network interface card (NIC) and implement the receive side of the networking stack.

### Key Features Implemented

1. **E1000 Network Driver (`kernel/e1000.c`)**
   - Implemented DMA-based packet transmission (`e1000_transmit`) and reception (`e1000_recv`) using ring buffers.
   - Managed memory mapping between the kernel (virtual addresses) and the hardware (physical addresses).
   - Handled "delayed freeing" of transmission buffers to ensure memory safety during asynchronous DMA operations.
   - Configured E1000 registers (RDT, TDT) via MMIO to synchronize software and hardware pointers.
2. **UDP Network Stack (`kernel/net.c`)**
   - Designed a socket layer to manage UDP ports using a global `sockets` array and spinlocks for concurrency control.
   - Implemented system calls:
     - `sys_bind`: Registers a UDP port for the current process.
     - `sys_recv`: Handles blocking reads (using `sleep`/`wakeup`) to receive data from the network ring buffer.
     - `sys_unbind`: Cleans up resources and prevents memory leaks upon closing.
   - Implemented `ip_rx` to handle the demultiplexing of incoming IP packets to the correct UDP socket queues.
   - Added support for ARP (Address Resolution Protocol) handling.

## Code Structure

- **`kernel/e1000.c`**: The E1000 driver implementation (TX/RX logic).
- **`kernel/net.c`**: The network stack (IP/UDP processing, socket management).
- **`kernel/e1000_dev.h`**: Hardware definitions, register offsets, and descriptor formats.
- **`user/nettest.c`**: User-space test suite used to verify the implementation.

## How to Run

### Prerequisites

You need a Linux environment (or WSL) with the RISC-V toolchain and QEMU installed.

### Automated Grading

To run the full automated test suite (which interacts with a host-side Python script):

```
make grade
```

## Test Results

The implementation passes all test cases, including basic transmission, ARP resolution, multiple socket handling, and DNS simulation.

```
== Test running nettest == 
$ make qemu-gdb
(21.5s) 
== Test   nettest: txone == 
  nettest: txone: OK 
== Test   nettest: arp_rx == 
  nettest: arp_rx: OK 
== Test   nettest: ip_rx == 
  nettest: ip_rx: OK 
...
== Test   nettest: dns == 
  nettest: dns: OK 
Score: 171/171
```

## Acknowledgments

- Course materials and xv6 source code provided by **MIT PDOS**.
- Hardware documentation based on **Intel 8254x Family of Gigabit Ethernet Controllers**.