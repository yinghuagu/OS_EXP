
user/_mmaptest：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <err>:
  exit(0);
}

void
err(char *why)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	1000                	addi	s0,sp,32
       a:	84aa                	mv	s1,a0
  printf("mmaptest failure: %s, pid=%d\n", why, getpid());
       c:	7f1000ef          	jal	ffc <getpid>
      10:	862a                	mv	a2,a0
      12:	85a6                	mv	a1,s1
      14:	00001517          	auipc	a0,0x1
      18:	54c50513          	addi	a0,a0,1356 # 1560 <malloc+0xf8>
      1c:	398010ef          	jal	13b4 <printf>
  exit(1);
      20:	4505                	li	a0,1
      22:	75b000ef          	jal	f7c <exit>

0000000000000026 <_v1>:
//
// check the content of the two mapped pages.
//
void
_v1(char *p)
{
      26:	1141                	addi	sp,sp,-16
      28:	e406                	sd	ra,8(sp)
      2a:	e022                	sd	s0,0(sp)
      2c:	0800                	addi	s0,sp,16
  int i;
  for (i = 0; i < PGSIZE*2; i++) {
      2e:	4581                	li	a1,0
    if (i < PGSIZE + (PGSIZE/2)) {
      30:	6785                	lui	a5,0x1
      32:	7ff78793          	addi	a5,a5,2047 # 17ff <malloc+0x397>
  for (i = 0; i < PGSIZE*2; i++) {
      36:	6689                	lui	a3,0x2
      if (p[i] != 'A') {
      38:	04100713          	li	a4,65
      3c:	a025                	j	64 <_v1+0x3e>
        printf("mismatch at %d, wanted 'A', got 0x%x\n", i, p[i]);
      3e:	00001517          	auipc	a0,0x1
      42:	54a50513          	addi	a0,a0,1354 # 1588 <malloc+0x120>
      46:	36e010ef          	jal	13b4 <printf>
        err("v1 mismatch (1)");
      4a:	00001517          	auipc	a0,0x1
      4e:	56650513          	addi	a0,a0,1382 # 15b0 <malloc+0x148>
      52:	fafff0ef          	jal	0 <err>
      }
    } else {
      if (p[i] != 0) {
      56:	00054603          	lbu	a2,0(a0)
      5a:	ee11                	bnez	a2,76 <_v1+0x50>
  for (i = 0; i < PGSIZE*2; i++) {
      5c:	2585                	addiw	a1,a1,1
      5e:	0505                	addi	a0,a0,1
      60:	02d58763          	beq	a1,a3,8e <_v1+0x68>
    if (i < PGSIZE + (PGSIZE/2)) {
      64:	feb7c9e3          	blt	a5,a1,56 <_v1+0x30>
      if (p[i] != 'A') {
      68:	00054603          	lbu	a2,0(a0)
      6c:	fce619e3          	bne	a2,a4,3e <_v1+0x18>
  for (i = 0; i < PGSIZE*2; i++) {
      70:	2585                	addiw	a1,a1,1
      72:	0505                	addi	a0,a0,1
      74:	bfc5                	j	64 <_v1+0x3e>
        printf("mismatch at %d, wanted zero, got 0x%x\n", i, p[i]);
      76:	00001517          	auipc	a0,0x1
      7a:	54a50513          	addi	a0,a0,1354 # 15c0 <malloc+0x158>
      7e:	336010ef          	jal	13b4 <printf>
        err("v1 mismatch (2)");
      82:	00001517          	auipc	a0,0x1
      86:	56650513          	addi	a0,a0,1382 # 15e8 <malloc+0x180>
      8a:	f77ff0ef          	jal	0 <err>
      }
    }
  }
}
      8e:	60a2                	ld	ra,8(sp)
      90:	6402                	ld	s0,0(sp)
      92:	0141                	addi	sp,sp,16
      94:	8082                	ret

0000000000000096 <makefile>:
// create a file to be mapped, containing
// 1.5 pages of 'A' and half a page of zeros.
//
void
makefile(const char *f)
{
      96:	7179                	addi	sp,sp,-48
      98:	f406                	sd	ra,40(sp)
      9a:	f022                	sd	s0,32(sp)
      9c:	ec26                	sd	s1,24(sp)
      9e:	e84a                	sd	s2,16(sp)
      a0:	e44e                	sd	s3,8(sp)
      a2:	1800                	addi	s0,sp,48
      a4:	84aa                	mv	s1,a0
  int i;
  int n = PGSIZE/BSIZE;

  unlink(f);
      a6:	727000ef          	jal	fcc <unlink>
  int fd = open(f, O_WRONLY | O_CREATE);
      aa:	20100593          	li	a1,513
      ae:	8526                	mv	a0,s1
      b0:	70d000ef          	jal	fbc <open>
  if (fd == -1)
      b4:	57fd                	li	a5,-1
      b6:	04f50b63          	beq	a0,a5,10c <makefile+0x76>
      ba:	892a                	mv	s2,a0
    err("open");
  memset(buf, 'A', BSIZE);
      bc:	40000613          	li	a2,1024
      c0:	04100593          	li	a1,65
      c4:	00003517          	auipc	a0,0x3
      c8:	f4c50513          	addi	a0,a0,-180 # 3010 <buf>
      cc:	49f000ef          	jal	d6a <memset>
      d0:	4499                	li	s1,6
  // write 1.5 page
  for (i = 0; i < n + n/2; i++) {
    if (write(fd, buf, BSIZE) != BSIZE)
      d2:	00003997          	auipc	s3,0x3
      d6:	f3e98993          	addi	s3,s3,-194 # 3010 <buf>
      da:	40000613          	li	a2,1024
      de:	85ce                	mv	a1,s3
      e0:	854a                	mv	a0,s2
      e2:	6bb000ef          	jal	f9c <write>
      e6:	40000793          	li	a5,1024
      ea:	02f51763          	bne	a0,a5,118 <makefile+0x82>
  for (i = 0; i < n + n/2; i++) {
      ee:	34fd                	addiw	s1,s1,-1
      f0:	f4ed                	bnez	s1,da <makefile+0x44>
      err("write 0 makefile");
  }
  if (close(fd) == -1)
      f2:	854a                	mv	a0,s2
      f4:	6b1000ef          	jal	fa4 <close>
      f8:	57fd                	li	a5,-1
      fa:	02f50563          	beq	a0,a5,124 <makefile+0x8e>
    err("close");
}
      fe:	70a2                	ld	ra,40(sp)
     100:	7402                	ld	s0,32(sp)
     102:	64e2                	ld	s1,24(sp)
     104:	6942                	ld	s2,16(sp)
     106:	69a2                	ld	s3,8(sp)
     108:	6145                	addi	sp,sp,48
     10a:	8082                	ret
    err("open");
     10c:	00001517          	auipc	a0,0x1
     110:	4ec50513          	addi	a0,a0,1260 # 15f8 <malloc+0x190>
     114:	eedff0ef          	jal	0 <err>
      err("write 0 makefile");
     118:	00001517          	auipc	a0,0x1
     11c:	4e850513          	addi	a0,a0,1256 # 1600 <malloc+0x198>
     120:	ee1ff0ef          	jal	0 <err>
    err("close");
     124:	00001517          	auipc	a0,0x1
     128:	4f450513          	addi	a0,a0,1268 # 1618 <malloc+0x1b0>
     12c:	ed5ff0ef          	jal	0 <err>

0000000000000130 <mmap_test>:

void
mmap_test(void)
{
     130:	7179                	addi	sp,sp,-48
     132:	f406                	sd	ra,40(sp)
     134:	f022                	sd	s0,32(sp)
     136:	ec26                	sd	s1,24(sp)
     138:	e84a                	sd	s2,16(sp)
     13a:	e44e                	sd	s3,8(sp)
     13c:	1800                	addi	s0,sp,48
  //
  // create a file with known content, map it into memory, check that
  // the mapped memory has the same bytes as originally written to the
  // file.
  //
  makefile(f);
     13e:	00001517          	auipc	a0,0x1
     142:	4e250513          	addi	a0,a0,1250 # 1620 <malloc+0x1b8>
     146:	f51ff0ef          	jal	96 <makefile>
  if ((fd = open(f, O_RDONLY)) == -1)
     14a:	4581                	li	a1,0
     14c:	00001517          	auipc	a0,0x1
     150:	4d450513          	addi	a0,a0,1236 # 1620 <malloc+0x1b8>
     154:	669000ef          	jal	fbc <open>
     158:	57fd                	li	a5,-1
     15a:	4af50a63          	beq	a0,a5,60e <mmap_test+0x4de>
     15e:	84aa                	mv	s1,a0
    err("open (1)");

  printf("test basic mmap\n");
     160:	00001517          	auipc	a0,0x1
     164:	4e050513          	addi	a0,a0,1248 # 1640 <malloc+0x1d8>
     168:	24c010ef          	jal	13b4 <printf>
  // same file (of course in this case updates are prohibited
  // due to PROT_READ). the fifth argument is the file descriptor
  // of the file to be mapped. the last argument is the starting
  // offset in the file.
  //
  char *p = mmap(0, PGSIZE*2, PROT_READ, MAP_PRIVATE, fd, 0);
     16c:	4781                	li	a5,0
     16e:	8726                	mv	a4,s1
     170:	4689                	li	a3,2
     172:	4605                	li	a2,1
     174:	6589                	lui	a1,0x2
     176:	4501                	li	a0,0
     178:	6a5000ef          	jal	101c <mmap>
     17c:	892a                	mv	s2,a0
  if (p == MAP_FAILED)
     17e:	57fd                	li	a5,-1
     180:	48f50d63          	beq	a0,a5,61a <mmap_test+0x4ea>
    err("mmap (1)");
  _v1(p);
     184:	ea3ff0ef          	jal	26 <_v1>
  if (munmap(p, PGSIZE*2) == -1)
     188:	6589                	lui	a1,0x2
     18a:	854a                	mv	a0,s2
     18c:	699000ef          	jal	1024 <munmap>
     190:	57fd                	li	a5,-1
     192:	48f50a63          	beq	a0,a5,626 <mmap_test+0x4f6>
    err("munmap (1)");

  printf("test basic mmap: OK\n");
     196:	00001517          	auipc	a0,0x1
     19a:	4e250513          	addi	a0,a0,1250 # 1678 <malloc+0x210>
     19e:	216010ef          	jal	13b4 <printf>

  printf("test mmap private\n");
     1a2:	00001517          	auipc	a0,0x1
     1a6:	4ee50513          	addi	a0,a0,1262 # 1690 <malloc+0x228>
     1aa:	20a010ef          	jal	13b4 <printf>
  // should be able to map file opened read-only with private writable
  // mapping
  p = mmap(0, PGSIZE*2, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
     1ae:	4781                	li	a5,0
     1b0:	8726                	mv	a4,s1
     1b2:	4689                	li	a3,2
     1b4:	460d                	li	a2,3
     1b6:	6589                	lui	a1,0x2
     1b8:	4501                	li	a0,0
     1ba:	663000ef          	jal	101c <mmap>
     1be:	892a                	mv	s2,a0
  if (p == MAP_FAILED)
     1c0:	57fd                	li	a5,-1
     1c2:	46f50863          	beq	a0,a5,632 <mmap_test+0x502>
    err("mmap (2)");
  if (close(fd) == -1)
     1c6:	8526                	mv	a0,s1
     1c8:	5dd000ef          	jal	fa4 <close>
     1cc:	57fd                	li	a5,-1
     1ce:	46f50863          	beq	a0,a5,63e <mmap_test+0x50e>
    err("close (1)");
  _v1(p);
     1d2:	854a                	mv	a0,s2
     1d4:	e53ff0ef          	jal	26 <_v1>
  for (i = 0; i < PGSIZE*2; i++)
     1d8:	87ca                	mv	a5,s2
     1da:	6709                	lui	a4,0x2
     1dc:	974a                	add	a4,a4,s2
    p[i] = 'Z';
     1de:	05a00693          	li	a3,90
     1e2:	00d78023          	sb	a3,0(a5)
  for (i = 0; i < PGSIZE*2; i++)
     1e6:	0785                	addi	a5,a5,1
     1e8:	fef71de3          	bne	a4,a5,1e2 <mmap_test+0xb2>
  if (munmap(p, PGSIZE*2) == -1)
     1ec:	6589                	lui	a1,0x2
     1ee:	854a                	mv	a0,s2
     1f0:	635000ef          	jal	1024 <munmap>
     1f4:	57fd                	li	a5,-1
     1f6:	44f50a63          	beq	a0,a5,64a <mmap_test+0x51a>
    err("munmap (2)");
  close(fd);
     1fa:	8526                	mv	a0,s1
     1fc:	5a9000ef          	jal	fa4 <close>

  // file should not have been modified.
  if((fd = open(f, O_RDONLY)) < 0) err("open");
     200:	4581                	li	a1,0
     202:	00001517          	auipc	a0,0x1
     206:	41e50513          	addi	a0,a0,1054 # 1620 <malloc+0x1b8>
     20a:	5b3000ef          	jal	fbc <open>
     20e:	84aa                	mv	s1,a0
     210:	44054363          	bltz	a0,656 <mmap_test+0x526>
  if(read(fd, buf, PGSIZE) != PGSIZE) err("read");
     214:	6605                	lui	a2,0x1
     216:	00003597          	auipc	a1,0x3
     21a:	dfa58593          	addi	a1,a1,-518 # 3010 <buf>
     21e:	577000ef          	jal	f94 <read>
     222:	6785                	lui	a5,0x1
     224:	42f51f63          	bne	a0,a5,662 <mmap_test+0x532>
  if(buf[0] != 'A')
     228:	00003717          	auipc	a4,0x3
     22c:	de874703          	lbu	a4,-536(a4) # 3010 <buf>
     230:	04100793          	li	a5,65
     234:	42f71d63          	bne	a4,a5,66e <mmap_test+0x53e>
    err("write to MAP_PRIVATE was written to file");
  if(read(fd, buf, PGSIZE) != PGSIZE/2) err("read");
     238:	6605                	lui	a2,0x1
     23a:	00003597          	auipc	a1,0x3
     23e:	dd658593          	addi	a1,a1,-554 # 3010 <buf>
     242:	8526                	mv	a0,s1
     244:	551000ef          	jal	f94 <read>
     248:	8005079b          	addiw	a5,a0,-2048
     24c:	42079763          	bnez	a5,67a <mmap_test+0x54a>
  if(buf[0] != 'A')
     250:	00003717          	auipc	a4,0x3
     254:	dc074703          	lbu	a4,-576(a4) # 3010 <buf>
     258:	04100793          	li	a5,65
     25c:	42f71563          	bne	a4,a5,686 <mmap_test+0x556>
    err("write to MAP_PRIVATE was written to file");
  close(fd);
     260:	8526                	mv	a0,s1
     262:	543000ef          	jal	fa4 <close>

  printf("test mmap private: OK\n");
     266:	00001517          	auipc	a0,0x1
     26a:	4aa50513          	addi	a0,a0,1194 # 1710 <malloc+0x2a8>
     26e:	146010ef          	jal	13b4 <printf>

  printf("test mmap read-only\n");
     272:	00001517          	auipc	a0,0x1
     276:	4b650513          	addi	a0,a0,1206 # 1728 <malloc+0x2c0>
     27a:	13a010ef          	jal	13b4 <printf>

  // check that mmap doesn't allow read/write mapping of a
  // file opened read-only.
  if ((fd = open(f, O_RDONLY)) == -1)
     27e:	4581                	li	a1,0
     280:	00001517          	auipc	a0,0x1
     284:	3a050513          	addi	a0,a0,928 # 1620 <malloc+0x1b8>
     288:	535000ef          	jal	fbc <open>
     28c:	84aa                	mv	s1,a0
     28e:	57fd                	li	a5,-1
     290:	40f50163          	beq	a0,a5,692 <mmap_test+0x562>
    err("open (2)");
  p = mmap(0, PGSIZE*2, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
     294:	4781                	li	a5,0
     296:	872a                	mv	a4,a0
     298:	4685                	li	a3,1
     29a:	460d                	li	a2,3
     29c:	6589                	lui	a1,0x2
     29e:	4501                	li	a0,0
     2a0:	57d000ef          	jal	101c <mmap>
  if (p != MAP_FAILED)
     2a4:	57fd                	li	a5,-1
     2a6:	3ef51c63          	bne	a0,a5,69e <mmap_test+0x56e>
    err("mmap (3)");
  if (close(fd) == -1)
     2aa:	8526                	mv	a0,s1
     2ac:	4f9000ef          	jal	fa4 <close>
     2b0:	57fd                	li	a5,-1
     2b2:	3ef50c63          	beq	a0,a5,6aa <mmap_test+0x57a>
    err("close (2)");

  printf("test mmap read-only: OK\n");
     2b6:	00001517          	auipc	a0,0x1
     2ba:	4ba50513          	addi	a0,a0,1210 # 1770 <malloc+0x308>
     2be:	0f6010ef          	jal	13b4 <printf>

  printf("test mmap read/write\n");
     2c2:	00001517          	auipc	a0,0x1
     2c6:	4ce50513          	addi	a0,a0,1230 # 1790 <malloc+0x328>
     2ca:	0ea010ef          	jal	13b4 <printf>

  // check that mmap does allow read/write mapping of a
  // file opened read/write.
  if ((fd = open(f, O_RDWR)) == -1)
     2ce:	4589                	li	a1,2
     2d0:	00001517          	auipc	a0,0x1
     2d4:	35050513          	addi	a0,a0,848 # 1620 <malloc+0x1b8>
     2d8:	4e5000ef          	jal	fbc <open>
     2dc:	84aa                	mv	s1,a0
     2de:	57fd                	li	a5,-1
     2e0:	3cf50b63          	beq	a0,a5,6b6 <mmap_test+0x586>
    err("open (3)");
  p = mmap(0, PGSIZE*3, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
     2e4:	4781                	li	a5,0
     2e6:	872a                	mv	a4,a0
     2e8:	4685                	li	a3,1
     2ea:	460d                	li	a2,3
     2ec:	658d                	lui	a1,0x3
     2ee:	4501                	li	a0,0
     2f0:	52d000ef          	jal	101c <mmap>
     2f4:	892a                	mv	s2,a0
  if (p == MAP_FAILED)
     2f6:	57fd                	li	a5,-1
     2f8:	3cf50563          	beq	a0,a5,6c2 <mmap_test+0x592>
    err("mmap (4)");
  if (close(fd) == -1)
     2fc:	8526                	mv	a0,s1
     2fe:	4a7000ef          	jal	fa4 <close>
     302:	57fd                	li	a5,-1
     304:	3cf50563          	beq	a0,a5,6ce <mmap_test+0x59e>
    err("close (3)");

  // check that the mapping still works after close(fd).
  _v1(p);
     308:	854a                	mv	a0,s2
     30a:	d1dff0ef          	jal	26 <_v1>

  // write the mapped memory.
  for (i = 0; i < PGSIZE; i++)
     30e:	6705                	lui	a4,0x1
     310:	974a                	add	a4,a4,s2
  _v1(p);
     312:	87ca                	mv	a5,s2
    p[i] = 'B';
     314:	04200693          	li	a3,66
     318:	00d78023          	sb	a3,0(a5) # 1000 <getpid+0x4>
  for (i = 0; i < PGSIZE; i++)
     31c:	0785                	addi	a5,a5,1
     31e:	fef71de3          	bne	a4,a5,318 <mmap_test+0x1e8>
     322:	6785                	lui	a5,0x1
     324:	97ca                	add	a5,a5,s2
     326:	6709                	lui	a4,0x2
     328:	974a                	add	a4,a4,s2
  for (i = PGSIZE; i < PGSIZE*2; i++)
    p[i] = 'C';
     32a:	04300693          	li	a3,67
     32e:	00d78023          	sb	a3,0(a5) # 1000 <getpid+0x4>
  for (i = PGSIZE; i < PGSIZE*2; i++)
     332:	0785                	addi	a5,a5,1
     334:	fef71de3          	bne	a4,a5,32e <mmap_test+0x1fe>

  // unmap just the first two of three pages of mapped memory.
  if (munmap(p, PGSIZE*2) == -1)
     338:	6589                	lui	a1,0x2
     33a:	854a                	mv	a0,s2
     33c:	4e9000ef          	jal	1024 <munmap>
     340:	57fd                	li	a5,-1
     342:	38f50c63          	beq	a0,a5,6da <mmap_test+0x5aa>
    err("munmap (3)");

  printf("test mmap read/write: OK\n");
     346:	00001517          	auipc	a0,0x1
     34a:	4a250513          	addi	a0,a0,1186 # 17e8 <malloc+0x380>
     34e:	066010ef          	jal	13b4 <printf>

  printf("test mmap dirty\n");
     352:	00001517          	auipc	a0,0x1
     356:	4b650513          	addi	a0,a0,1206 # 1808 <malloc+0x3a0>
     35a:	05a010ef          	jal	13b4 <printf>

  // check that the writes to the mapped memory were
  // written to the file.
  if ((fd = open(f, O_RDONLY)) == -1)
     35e:	4581                	li	a1,0
     360:	00001517          	auipc	a0,0x1
     364:	2c050513          	addi	a0,a0,704 # 1620 <malloc+0x1b8>
     368:	455000ef          	jal	fbc <open>
     36c:	89aa                	mv	s3,a0
     36e:	57fd                	li	a5,-1
     370:	36f50b63          	beq	a0,a5,6e6 <mmap_test+0x5b6>
    err("open (4)");
  if(read(fd, buf, PGSIZE) != PGSIZE)
     374:	6605                	lui	a2,0x1
     376:	00003597          	auipc	a1,0x3
     37a:	c9a58593          	addi	a1,a1,-870 # 3010 <buf>
     37e:	417000ef          	jal	f94 <read>
     382:	6785                	lui	a5,0x1
     384:	36f51763          	bne	a0,a5,6f2 <mmap_test+0x5c2>
     388:	00003497          	auipc	s1,0x3
     38c:	c8848493          	addi	s1,s1,-888 # 3010 <buf>
     390:	00004617          	auipc	a2,0x4
     394:	c8060613          	addi	a2,a2,-896 # 4010 <base>
     398:	87a6                	mv	a5,s1
    err("dirty read #1");
  for (i = 0; i < PGSIZE; i++){
    if (buf[i] != 'B')
     39a:	04200693          	li	a3,66
     39e:	0007c703          	lbu	a4,0(a5) # 1000 <getpid+0x4>
     3a2:	34d71e63          	bne	a4,a3,6fe <mmap_test+0x5ce>
  for (i = 0; i < PGSIZE; i++){
     3a6:	0785                	addi	a5,a5,1
     3a8:	fec79be3          	bne	a5,a2,39e <mmap_test+0x26e>
      err("file page 0 does not contain modifications");
  }
  if(read(fd, buf, PGSIZE) != PGSIZE/2)
     3ac:	6605                	lui	a2,0x1
     3ae:	00003597          	auipc	a1,0x3
     3b2:	c6258593          	addi	a1,a1,-926 # 3010 <buf>
     3b6:	854e                	mv	a0,s3
     3b8:	3dd000ef          	jal	f94 <read>
     3bc:	8005079b          	addiw	a5,a0,-2048
     3c0:	6705                	lui	a4,0x1
     3c2:	80070713          	addi	a4,a4,-2048 # 800 <mmap_test+0x6d0>
     3c6:	9726                	add	a4,a4,s1
    err("dirty read #2");
  for (i = 0; i < PGSIZE/2; i++){
    if (buf[i] != 'C')
     3c8:	04300693          	li	a3,67
  if(read(fd, buf, PGSIZE) != PGSIZE/2)
     3cc:	32079f63          	bnez	a5,70a <mmap_test+0x5da>
    if (buf[i] != 'C')
     3d0:	0004c783          	lbu	a5,0(s1)
     3d4:	34d79163          	bne	a5,a3,716 <mmap_test+0x5e6>
  for (i = 0; i < PGSIZE/2; i++){
     3d8:	0485                	addi	s1,s1,1
     3da:	fee49be3          	bne	s1,a4,3d0 <mmap_test+0x2a0>
      err("file page 1 does not contain modifications");
  }
  if (close(fd) == -1)
     3de:	854e                	mv	a0,s3
     3e0:	3c5000ef          	jal	fa4 <close>
     3e4:	57fd                	li	a5,-1
     3e6:	32f50e63          	beq	a0,a5,722 <mmap_test+0x5f2>
    err("close (4)");

  printf("test mmap dirty: OK\n");
     3ea:	00001517          	auipc	a0,0x1
     3ee:	4d650513          	addi	a0,a0,1238 # 18c0 <malloc+0x458>
     3f2:	7c3000ef          	jal	13b4 <printf>

  printf("test not-mapped unmap\n");
     3f6:	00001517          	auipc	a0,0x1
     3fa:	4e250513          	addi	a0,a0,1250 # 18d8 <malloc+0x470>
     3fe:	7b7000ef          	jal	13b4 <printf>

  // unmap the rest of the mapped memory.
  if (munmap(p+PGSIZE*2, PGSIZE) == -1)
     402:	6585                	lui	a1,0x1
     404:	6509                	lui	a0,0x2
     406:	954a                	add	a0,a0,s2
     408:	41d000ef          	jal	1024 <munmap>
     40c:	57fd                	li	a5,-1
     40e:	32f50063          	beq	a0,a5,72e <mmap_test+0x5fe>
    err("munmap (4)");

  printf("test not-mapped unmap: OK\n");
     412:	00001517          	auipc	a0,0x1
     416:	4ee50513          	addi	a0,a0,1262 # 1900 <malloc+0x498>
     41a:	79b000ef          	jal	13b4 <printf>

  printf("test lazy access\n");
     41e:	00001517          	auipc	a0,0x1
     422:	50250513          	addi	a0,a0,1282 # 1920 <malloc+0x4b8>
     426:	78f000ef          	jal	13b4 <printf>

  if(unlink(f) != 0) err("unlink");
     42a:	00001517          	auipc	a0,0x1
     42e:	1f650513          	addi	a0,a0,502 # 1620 <malloc+0x1b8>
     432:	39b000ef          	jal	fcc <unlink>
     436:	30051263          	bnez	a0,73a <mmap_test+0x60a>
  makefile(f);
     43a:	00001517          	auipc	a0,0x1
     43e:	1e650513          	addi	a0,a0,486 # 1620 <malloc+0x1b8>
     442:	c55ff0ef          	jal	96 <makefile>

  if ((fd = open(f, O_RDWR)) == -1)
     446:	4589                	li	a1,2
     448:	00001517          	auipc	a0,0x1
     44c:	1d850513          	addi	a0,a0,472 # 1620 <malloc+0x1b8>
     450:	36d000ef          	jal	fbc <open>
     454:	892a                	mv	s2,a0
     456:	57fd                	li	a5,-1
     458:	2ef50763          	beq	a0,a5,746 <mmap_test+0x616>
    err("open");
  p = mmap(0, PGSIZE*2, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
     45c:	4781                	li	a5,0
     45e:	872a                	mv	a4,a0
     460:	4685                	li	a3,1
     462:	460d                	li	a2,3
     464:	6589                	lui	a1,0x2
     466:	4501                	li	a0,0
     468:	3b5000ef          	jal	101c <mmap>
     46c:	84aa                	mv	s1,a0
  if (p == MAP_FAILED)
     46e:	57fd                	li	a5,-1
     470:	2ef50163          	beq	a0,a5,752 <mmap_test+0x622>
    err("mmap");
  close(fd);
     474:	854a                	mv	a0,s2
     476:	32f000ef          	jal	fa4 <close>
  // mmap() should not have read the file at this point,
  // so that the file modification we're about to make
  // ought to be visible to a subsequent read of the
  // mapped memory.

  if((fd = open(f, O_RDWR)) == -1)
     47a:	4589                	li	a1,2
     47c:	00001517          	auipc	a0,0x1
     480:	1a450513          	addi	a0,a0,420 # 1620 <malloc+0x1b8>
     484:	339000ef          	jal	fbc <open>
     488:	892a                	mv	s2,a0
     48a:	57fd                	li	a5,-1
     48c:	2cf50963          	beq	a0,a5,75e <mmap_test+0x62e>
    err("open");
  if(write(fd, "m", 1) != 1)
     490:	4605                	li	a2,1
     492:	00001597          	auipc	a1,0x1
     496:	4b658593          	addi	a1,a1,1206 # 1948 <malloc+0x4e0>
     49a:	303000ef          	jal	f9c <write>
     49e:	4785                	li	a5,1
     4a0:	2cf51563          	bne	a0,a5,76a <mmap_test+0x63a>
    err("write");
  close(fd);
     4a4:	854a                	mv	a0,s2
     4a6:	2ff000ef          	jal	fa4 <close>

  if(*p != 'm')
     4aa:	0004c703          	lbu	a4,0(s1)
     4ae:	06d00793          	li	a5,109
     4b2:	2cf71263          	bne	a4,a5,776 <mmap_test+0x646>
    err("read was not lazy");

  if(munmap(p, PGSIZE*2) == -1)
     4b6:	6589                	lui	a1,0x2
     4b8:	8526                	mv	a0,s1
     4ba:	36b000ef          	jal	1024 <munmap>
     4be:	57fd                	li	a5,-1
     4c0:	2cf50163          	beq	a0,a5,782 <mmap_test+0x652>
    err("munmap");

  printf("test lazy access: OK\n");
     4c4:	00001517          	auipc	a0,0x1
     4c8:	4b450513          	addi	a0,a0,1204 # 1978 <malloc+0x510>
     4cc:	6e9000ef          	jal	13b4 <printf>

  printf("test mmap two files\n");
     4d0:	00001517          	auipc	a0,0x1
     4d4:	4c050513          	addi	a0,a0,1216 # 1990 <malloc+0x528>
     4d8:	6dd000ef          	jal	13b4 <printf>

  //
  // mmap two different files at the same time.
  //
  int fd1;
  if((fd1 = open("mmap1", O_RDWR|O_CREATE)) < 0)
     4dc:	20200593          	li	a1,514
     4e0:	00001517          	auipc	a0,0x1
     4e4:	4c850513          	addi	a0,a0,1224 # 19a8 <malloc+0x540>
     4e8:	2d5000ef          	jal	fbc <open>
     4ec:	84aa                	mv	s1,a0
     4ee:	2a054063          	bltz	a0,78e <mmap_test+0x65e>
    err("open (5)");
  if(write(fd1, "12345", 5) != 5)
     4f2:	4615                	li	a2,5
     4f4:	00001597          	auipc	a1,0x1
     4f8:	4cc58593          	addi	a1,a1,1228 # 19c0 <malloc+0x558>
     4fc:	2a1000ef          	jal	f9c <write>
     500:	4795                	li	a5,5
     502:	28f51c63          	bne	a0,a5,79a <mmap_test+0x66a>
    err("write (1)");
  char *p1 = mmap(0, PGSIZE, PROT_READ, MAP_PRIVATE, fd1, 0);
     506:	4781                	li	a5,0
     508:	8726                	mv	a4,s1
     50a:	4689                	li	a3,2
     50c:	4605                	li	a2,1
     50e:	6585                	lui	a1,0x1
     510:	4501                	li	a0,0
     512:	30b000ef          	jal	101c <mmap>
     516:	89aa                	mv	s3,a0
  if(p1 == MAP_FAILED)
     518:	57fd                	li	a5,-1
     51a:	28f50663          	beq	a0,a5,7a6 <mmap_test+0x676>
    err("mmap (5)");
  if (close(fd1) == -1)
     51e:	8526                	mv	a0,s1
     520:	285000ef          	jal	fa4 <close>
     524:	57fd                	li	a5,-1
     526:	28f50663          	beq	a0,a5,7b2 <mmap_test+0x682>
    err("close (5)");
  if (unlink("mmap1") == -1)
     52a:	00001517          	auipc	a0,0x1
     52e:	47e50513          	addi	a0,a0,1150 # 19a8 <malloc+0x540>
     532:	29b000ef          	jal	fcc <unlink>
     536:	57fd                	li	a5,-1
     538:	28f50363          	beq	a0,a5,7be <mmap_test+0x68e>
    err("unlink (1)");

  int fd2;
  if((fd2 = open("mmap2", O_RDWR|O_CREATE)) < 0)
     53c:	20200593          	li	a1,514
     540:	00001517          	auipc	a0,0x1
     544:	4c850513          	addi	a0,a0,1224 # 1a08 <malloc+0x5a0>
     548:	275000ef          	jal	fbc <open>
     54c:	892a                	mv	s2,a0
     54e:	26054e63          	bltz	a0,7ca <mmap_test+0x69a>
    err("open (6)");
  if(write(fd2, "67890", 5) != 5)
     552:	4615                	li	a2,5
     554:	00001597          	auipc	a1,0x1
     558:	4cc58593          	addi	a1,a1,1228 # 1a20 <malloc+0x5b8>
     55c:	241000ef          	jal	f9c <write>
     560:	4795                	li	a5,5
     562:	26f51a63          	bne	a0,a5,7d6 <mmap_test+0x6a6>
    err("write (2)");
  char *p2 = mmap(0, PGSIZE, PROT_READ, MAP_PRIVATE, fd2, 0);
     566:	4781                	li	a5,0
     568:	874a                	mv	a4,s2
     56a:	4689                	li	a3,2
     56c:	4605                	li	a2,1
     56e:	6585                	lui	a1,0x1
     570:	4501                	li	a0,0
     572:	2ab000ef          	jal	101c <mmap>
     576:	84aa                	mv	s1,a0
  if(p2 == MAP_FAILED)
     578:	57fd                	li	a5,-1
     57a:	26f50463          	beq	a0,a5,7e2 <mmap_test+0x6b2>
    err("mmap (6)");
  if (close(fd2) == -1)
     57e:	854a                	mv	a0,s2
     580:	225000ef          	jal	fa4 <close>
     584:	57fd                	li	a5,-1
     586:	26f50463          	beq	a0,a5,7ee <mmap_test+0x6be>
    err("close (6)");
  if (unlink("mmap2") == -1)
     58a:	00001517          	auipc	a0,0x1
     58e:	47e50513          	addi	a0,a0,1150 # 1a08 <malloc+0x5a0>
     592:	23b000ef          	jal	fcc <unlink>
     596:	57fd                	li	a5,-1
     598:	26f50163          	beq	a0,a5,7fa <mmap_test+0x6ca>
    err("unlink (2)");

  if(memcmp(p1, "12345", 5) != 0)
     59c:	4615                	li	a2,5
     59e:	00001597          	auipc	a1,0x1
     5a2:	42258593          	addi	a1,a1,1058 # 19c0 <malloc+0x558>
     5a6:	854e                	mv	a0,s3
     5a8:	153000ef          	jal	efa <memcmp>
     5ac:	24051d63          	bnez	a0,806 <mmap_test+0x6d6>
    err("mmap1 mismatch");
  if(memcmp(p2, "67890", 5) != 0)
     5b0:	4615                	li	a2,5
     5b2:	00001597          	auipc	a1,0x1
     5b6:	46e58593          	addi	a1,a1,1134 # 1a20 <malloc+0x5b8>
     5ba:	8526                	mv	a0,s1
     5bc:	13f000ef          	jal	efa <memcmp>
     5c0:	24051963          	bnez	a0,812 <mmap_test+0x6e2>
    err("mmap2 mismatch");

  if (munmap(p1, PGSIZE) == -1)
     5c4:	6585                	lui	a1,0x1
     5c6:	854e                	mv	a0,s3
     5c8:	25d000ef          	jal	1024 <munmap>
     5cc:	57fd                	li	a5,-1
     5ce:	24f50863          	beq	a0,a5,81e <mmap_test+0x6ee>
    err("munmap (5)");
  if(memcmp(p2, "67890", 5) != 0)
     5d2:	4615                	li	a2,5
     5d4:	00001597          	auipc	a1,0x1
     5d8:	44c58593          	addi	a1,a1,1100 # 1a20 <malloc+0x5b8>
     5dc:	8526                	mv	a0,s1
     5de:	11d000ef          	jal	efa <memcmp>
     5e2:	24051463          	bnez	a0,82a <mmap_test+0x6fa>
    err("mmap2 mismatch (2)");
  if (munmap(p2, PGSIZE) == -1)
     5e6:	6585                	lui	a1,0x1
     5e8:	8526                	mv	a0,s1
     5ea:	23b000ef          	jal	1024 <munmap>
     5ee:	57fd                	li	a5,-1
     5f0:	24f50363          	beq	a0,a5,836 <mmap_test+0x706>
    err("munmap (6)");

  printf("test mmap two files: OK\n");
     5f4:	00001517          	auipc	a0,0x1
     5f8:	4cc50513          	addi	a0,a0,1228 # 1ac0 <malloc+0x658>
     5fc:	5b9000ef          	jal	13b4 <printf>
}
     600:	70a2                	ld	ra,40(sp)
     602:	7402                	ld	s0,32(sp)
     604:	64e2                	ld	s1,24(sp)
     606:	6942                	ld	s2,16(sp)
     608:	69a2                	ld	s3,8(sp)
     60a:	6145                	addi	sp,sp,48
     60c:	8082                	ret
    err("open (1)");
     60e:	00001517          	auipc	a0,0x1
     612:	02250513          	addi	a0,a0,34 # 1630 <malloc+0x1c8>
     616:	9ebff0ef          	jal	0 <err>
    err("mmap (1)");
     61a:	00001517          	auipc	a0,0x1
     61e:	03e50513          	addi	a0,a0,62 # 1658 <malloc+0x1f0>
     622:	9dfff0ef          	jal	0 <err>
    err("munmap (1)");
     626:	00001517          	auipc	a0,0x1
     62a:	04250513          	addi	a0,a0,66 # 1668 <malloc+0x200>
     62e:	9d3ff0ef          	jal	0 <err>
    err("mmap (2)");
     632:	00001517          	auipc	a0,0x1
     636:	07650513          	addi	a0,a0,118 # 16a8 <malloc+0x240>
     63a:	9c7ff0ef          	jal	0 <err>
    err("close (1)");
     63e:	00001517          	auipc	a0,0x1
     642:	07a50513          	addi	a0,a0,122 # 16b8 <malloc+0x250>
     646:	9bbff0ef          	jal	0 <err>
    err("munmap (2)");
     64a:	00001517          	auipc	a0,0x1
     64e:	07e50513          	addi	a0,a0,126 # 16c8 <malloc+0x260>
     652:	9afff0ef          	jal	0 <err>
  if((fd = open(f, O_RDONLY)) < 0) err("open");
     656:	00001517          	auipc	a0,0x1
     65a:	fa250513          	addi	a0,a0,-94 # 15f8 <malloc+0x190>
     65e:	9a3ff0ef          	jal	0 <err>
  if(read(fd, buf, PGSIZE) != PGSIZE) err("read");
     662:	00001517          	auipc	a0,0x1
     666:	07650513          	addi	a0,a0,118 # 16d8 <malloc+0x270>
     66a:	997ff0ef          	jal	0 <err>
    err("write to MAP_PRIVATE was written to file");
     66e:	00001517          	auipc	a0,0x1
     672:	07250513          	addi	a0,a0,114 # 16e0 <malloc+0x278>
     676:	98bff0ef          	jal	0 <err>
  if(read(fd, buf, PGSIZE) != PGSIZE/2) err("read");
     67a:	00001517          	auipc	a0,0x1
     67e:	05e50513          	addi	a0,a0,94 # 16d8 <malloc+0x270>
     682:	97fff0ef          	jal	0 <err>
    err("write to MAP_PRIVATE was written to file");
     686:	00001517          	auipc	a0,0x1
     68a:	05a50513          	addi	a0,a0,90 # 16e0 <malloc+0x278>
     68e:	973ff0ef          	jal	0 <err>
    err("open (2)");
     692:	00001517          	auipc	a0,0x1
     696:	0ae50513          	addi	a0,a0,174 # 1740 <malloc+0x2d8>
     69a:	967ff0ef          	jal	0 <err>
    err("mmap (3)");
     69e:	00001517          	auipc	a0,0x1
     6a2:	0b250513          	addi	a0,a0,178 # 1750 <malloc+0x2e8>
     6a6:	95bff0ef          	jal	0 <err>
    err("close (2)");
     6aa:	00001517          	auipc	a0,0x1
     6ae:	0b650513          	addi	a0,a0,182 # 1760 <malloc+0x2f8>
     6b2:	94fff0ef          	jal	0 <err>
    err("open (3)");
     6b6:	00001517          	auipc	a0,0x1
     6ba:	0f250513          	addi	a0,a0,242 # 17a8 <malloc+0x340>
     6be:	943ff0ef          	jal	0 <err>
    err("mmap (4)");
     6c2:	00001517          	auipc	a0,0x1
     6c6:	0f650513          	addi	a0,a0,246 # 17b8 <malloc+0x350>
     6ca:	937ff0ef          	jal	0 <err>
    err("close (3)");
     6ce:	00001517          	auipc	a0,0x1
     6d2:	0fa50513          	addi	a0,a0,250 # 17c8 <malloc+0x360>
     6d6:	92bff0ef          	jal	0 <err>
    err("munmap (3)");
     6da:	00001517          	auipc	a0,0x1
     6de:	0fe50513          	addi	a0,a0,254 # 17d8 <malloc+0x370>
     6e2:	91fff0ef          	jal	0 <err>
    err("open (4)");
     6e6:	00001517          	auipc	a0,0x1
     6ea:	13a50513          	addi	a0,a0,314 # 1820 <malloc+0x3b8>
     6ee:	913ff0ef          	jal	0 <err>
    err("dirty read #1");
     6f2:	00001517          	auipc	a0,0x1
     6f6:	13e50513          	addi	a0,a0,318 # 1830 <malloc+0x3c8>
     6fa:	907ff0ef          	jal	0 <err>
      err("file page 0 does not contain modifications");
     6fe:	00001517          	auipc	a0,0x1
     702:	14250513          	addi	a0,a0,322 # 1840 <malloc+0x3d8>
     706:	8fbff0ef          	jal	0 <err>
    err("dirty read #2");
     70a:	00001517          	auipc	a0,0x1
     70e:	16650513          	addi	a0,a0,358 # 1870 <malloc+0x408>
     712:	8efff0ef          	jal	0 <err>
      err("file page 1 does not contain modifications");
     716:	00001517          	auipc	a0,0x1
     71a:	16a50513          	addi	a0,a0,362 # 1880 <malloc+0x418>
     71e:	8e3ff0ef          	jal	0 <err>
    err("close (4)");
     722:	00001517          	auipc	a0,0x1
     726:	18e50513          	addi	a0,a0,398 # 18b0 <malloc+0x448>
     72a:	8d7ff0ef          	jal	0 <err>
    err("munmap (4)");
     72e:	00001517          	auipc	a0,0x1
     732:	1c250513          	addi	a0,a0,450 # 18f0 <malloc+0x488>
     736:	8cbff0ef          	jal	0 <err>
  if(unlink(f) != 0) err("unlink");
     73a:	00001517          	auipc	a0,0x1
     73e:	1fe50513          	addi	a0,a0,510 # 1938 <malloc+0x4d0>
     742:	8bfff0ef          	jal	0 <err>
    err("open");
     746:	00001517          	auipc	a0,0x1
     74a:	eb250513          	addi	a0,a0,-334 # 15f8 <malloc+0x190>
     74e:	8b3ff0ef          	jal	0 <err>
    err("mmap");
     752:	00001517          	auipc	a0,0x1
     756:	1ee50513          	addi	a0,a0,494 # 1940 <malloc+0x4d8>
     75a:	8a7ff0ef          	jal	0 <err>
    err("open");
     75e:	00001517          	auipc	a0,0x1
     762:	e9a50513          	addi	a0,a0,-358 # 15f8 <malloc+0x190>
     766:	89bff0ef          	jal	0 <err>
    err("write");
     76a:	00001517          	auipc	a0,0x1
     76e:	1e650513          	addi	a0,a0,486 # 1950 <malloc+0x4e8>
     772:	88fff0ef          	jal	0 <err>
    err("read was not lazy");
     776:	00001517          	auipc	a0,0x1
     77a:	1e250513          	addi	a0,a0,482 # 1958 <malloc+0x4f0>
     77e:	883ff0ef          	jal	0 <err>
    err("munmap");
     782:	00001517          	auipc	a0,0x1
     786:	1ee50513          	addi	a0,a0,494 # 1970 <malloc+0x508>
     78a:	877ff0ef          	jal	0 <err>
    err("open (5)");
     78e:	00001517          	auipc	a0,0x1
     792:	22250513          	addi	a0,a0,546 # 19b0 <malloc+0x548>
     796:	86bff0ef          	jal	0 <err>
    err("write (1)");
     79a:	00001517          	auipc	a0,0x1
     79e:	22e50513          	addi	a0,a0,558 # 19c8 <malloc+0x560>
     7a2:	85fff0ef          	jal	0 <err>
    err("mmap (5)");
     7a6:	00001517          	auipc	a0,0x1
     7aa:	23250513          	addi	a0,a0,562 # 19d8 <malloc+0x570>
     7ae:	853ff0ef          	jal	0 <err>
    err("close (5)");
     7b2:	00001517          	auipc	a0,0x1
     7b6:	23650513          	addi	a0,a0,566 # 19e8 <malloc+0x580>
     7ba:	847ff0ef          	jal	0 <err>
    err("unlink (1)");
     7be:	00001517          	auipc	a0,0x1
     7c2:	23a50513          	addi	a0,a0,570 # 19f8 <malloc+0x590>
     7c6:	83bff0ef          	jal	0 <err>
    err("open (6)");
     7ca:	00001517          	auipc	a0,0x1
     7ce:	24650513          	addi	a0,a0,582 # 1a10 <malloc+0x5a8>
     7d2:	82fff0ef          	jal	0 <err>
    err("write (2)");
     7d6:	00001517          	auipc	a0,0x1
     7da:	25250513          	addi	a0,a0,594 # 1a28 <malloc+0x5c0>
     7de:	823ff0ef          	jal	0 <err>
    err("mmap (6)");
     7e2:	00001517          	auipc	a0,0x1
     7e6:	25650513          	addi	a0,a0,598 # 1a38 <malloc+0x5d0>
     7ea:	817ff0ef          	jal	0 <err>
    err("close (6)");
     7ee:	00001517          	auipc	a0,0x1
     7f2:	25a50513          	addi	a0,a0,602 # 1a48 <malloc+0x5e0>
     7f6:	80bff0ef          	jal	0 <err>
    err("unlink (2)");
     7fa:	00001517          	auipc	a0,0x1
     7fe:	25e50513          	addi	a0,a0,606 # 1a58 <malloc+0x5f0>
     802:	ffeff0ef          	jal	0 <err>
    err("mmap1 mismatch");
     806:	00001517          	auipc	a0,0x1
     80a:	26250513          	addi	a0,a0,610 # 1a68 <malloc+0x600>
     80e:	ff2ff0ef          	jal	0 <err>
    err("mmap2 mismatch");
     812:	00001517          	auipc	a0,0x1
     816:	26650513          	addi	a0,a0,614 # 1a78 <malloc+0x610>
     81a:	fe6ff0ef          	jal	0 <err>
    err("munmap (5)");
     81e:	00001517          	auipc	a0,0x1
     822:	26a50513          	addi	a0,a0,618 # 1a88 <malloc+0x620>
     826:	fdaff0ef          	jal	0 <err>
    err("mmap2 mismatch (2)");
     82a:	00001517          	auipc	a0,0x1
     82e:	26e50513          	addi	a0,a0,622 # 1a98 <malloc+0x630>
     832:	fceff0ef          	jal	0 <err>
    err("munmap (6)");
     836:	00001517          	auipc	a0,0x1
     83a:	27a50513          	addi	a0,a0,634 # 1ab0 <malloc+0x648>
     83e:	fc2ff0ef          	jal	0 <err>

0000000000000842 <fork_test>:
// mmap a file, then fork.
// check that the child sees the mapped file.
//
void
fork_test(void)
{
     842:	7179                	addi	sp,sp,-48
     844:	f406                	sd	ra,40(sp)
     846:	f022                	sd	s0,32(sp)
     848:	ec26                	sd	s1,24(sp)
     84a:	e84a                	sd	s2,16(sp)
     84c:	1800                	addi	s0,sp,48
  int fd;
  int pid;
  const char * const f = "mmap.dur";

  printf("test fork\n");
     84e:	00001517          	auipc	a0,0x1
     852:	29250513          	addi	a0,a0,658 # 1ae0 <malloc+0x678>
     856:	35f000ef          	jal	13b4 <printf>

  // mmap the file twice.
  makefile(f);
     85a:	00001517          	auipc	a0,0x1
     85e:	dc650513          	addi	a0,a0,-570 # 1620 <malloc+0x1b8>
     862:	835ff0ef          	jal	96 <makefile>
  if ((fd = open(f, O_RDONLY)) == -1)
     866:	4581                	li	a1,0
     868:	00001517          	auipc	a0,0x1
     86c:	db850513          	addi	a0,a0,-584 # 1620 <malloc+0x1b8>
     870:	74c000ef          	jal	fbc <open>
     874:	57fd                	li	a5,-1
     876:	06f50e63          	beq	a0,a5,8f2 <fork_test+0xb0>
     87a:	892a                	mv	s2,a0
    err("open (7)");
  if (unlink(f) == -1)
     87c:	00001517          	auipc	a0,0x1
     880:	da450513          	addi	a0,a0,-604 # 1620 <malloc+0x1b8>
     884:	748000ef          	jal	fcc <unlink>
     888:	57fd                	li	a5,-1
     88a:	06f50a63          	beq	a0,a5,8fe <fork_test+0xbc>
    err("unlink (3)");
  char *p1 = mmap(0, PGSIZE*2, PROT_READ, MAP_SHARED, fd, 0);
     88e:	4781                	li	a5,0
     890:	874a                	mv	a4,s2
     892:	4685                	li	a3,1
     894:	4605                	li	a2,1
     896:	6589                	lui	a1,0x2
     898:	4501                	li	a0,0
     89a:	782000ef          	jal	101c <mmap>
     89e:	84aa                	mv	s1,a0
  if (p1 == MAP_FAILED)
     8a0:	57fd                	li	a5,-1
     8a2:	06f50463          	beq	a0,a5,90a <fork_test+0xc8>
    err("mmap (7)");
  char *p2 = mmap(0, PGSIZE*2, PROT_READ, MAP_SHARED, fd, 0);
     8a6:	4781                	li	a5,0
     8a8:	874a                	mv	a4,s2
     8aa:	4685                	li	a3,1
     8ac:	4605                	li	a2,1
     8ae:	6589                	lui	a1,0x2
     8b0:	4501                	li	a0,0
     8b2:	76a000ef          	jal	101c <mmap>
     8b6:	892a                	mv	s2,a0
  if (p2 == MAP_FAILED)
     8b8:	57fd                	li	a5,-1
     8ba:	04f50e63          	beq	a0,a5,916 <fork_test+0xd4>
    err("mmap (8)");

  // read just 2nd page.
  if(*(p1+PGSIZE) != 'A')
     8be:	6785                	lui	a5,0x1
     8c0:	97a6                	add	a5,a5,s1
     8c2:	0007c703          	lbu	a4,0(a5) # 1000 <getpid+0x4>
     8c6:	04100793          	li	a5,65
     8ca:	04f71c63          	bne	a4,a5,922 <fork_test+0xe0>
    err("fork mismatch (1)");

  if((pid = fork()) < 0)
     8ce:	6a6000ef          	jal	f74 <fork>
     8d2:	04054e63          	bltz	a0,92e <fork_test+0xec>
    err("fork");
  if (pid == 0) {
     8d6:	e925                	bnez	a0,946 <fork_test+0x104>
    _v1(p1);
     8d8:	8526                	mv	a0,s1
     8da:	f4cff0ef          	jal	26 <_v1>
    if (munmap(p1, PGSIZE) == -1) // just the first page
     8de:	6585                	lui	a1,0x1
     8e0:	8526                	mv	a0,s1
     8e2:	742000ef          	jal	1024 <munmap>
     8e6:	57fd                	li	a5,-1
     8e8:	04f50963          	beq	a0,a5,93a <fork_test+0xf8>
      err("munmap (7)");
    exit(0); // tell the parent that the mapping looks OK.
     8ec:	4501                	li	a0,0
     8ee:	68e000ef          	jal	f7c <exit>
    err("open (7)");
     8f2:	00001517          	auipc	a0,0x1
     8f6:	1fe50513          	addi	a0,a0,510 # 1af0 <malloc+0x688>
     8fa:	f06ff0ef          	jal	0 <err>
    err("unlink (3)");
     8fe:	00001517          	auipc	a0,0x1
     902:	20250513          	addi	a0,a0,514 # 1b00 <malloc+0x698>
     906:	efaff0ef          	jal	0 <err>
    err("mmap (7)");
     90a:	00001517          	auipc	a0,0x1
     90e:	20650513          	addi	a0,a0,518 # 1b10 <malloc+0x6a8>
     912:	eeeff0ef          	jal	0 <err>
    err("mmap (8)");
     916:	00001517          	auipc	a0,0x1
     91a:	20a50513          	addi	a0,a0,522 # 1b20 <malloc+0x6b8>
     91e:	ee2ff0ef          	jal	0 <err>
    err("fork mismatch (1)");
     922:	00001517          	auipc	a0,0x1
     926:	20e50513          	addi	a0,a0,526 # 1b30 <malloc+0x6c8>
     92a:	ed6ff0ef          	jal	0 <err>
    err("fork");
     92e:	00001517          	auipc	a0,0x1
     932:	21a50513          	addi	a0,a0,538 # 1b48 <malloc+0x6e0>
     936:	ecaff0ef          	jal	0 <err>
      err("munmap (7)");
     93a:	00001517          	auipc	a0,0x1
     93e:	21650513          	addi	a0,a0,534 # 1b50 <malloc+0x6e8>
     942:	ebeff0ef          	jal	0 <err>
  }

  int status = -1;
     946:	57fd                	li	a5,-1
     948:	fcf42e23          	sw	a5,-36(s0)
  wait(&status);
     94c:	fdc40513          	addi	a0,s0,-36
     950:	634000ef          	jal	f84 <wait>

  if(status != 0){
     954:	fdc42783          	lw	a5,-36(s0)
     958:	e39d                	bnez	a5,97e <fork_test+0x13c>
    printf("fork_test failed\n");
    exit(1);
  }

  // check that the parent's mappings are still there.
  _v1(p1);
     95a:	8526                	mv	a0,s1
     95c:	ecaff0ef          	jal	26 <_v1>
  _v1(p2);
     960:	854a                	mv	a0,s2
     962:	ec4ff0ef          	jal	26 <_v1>

  printf("test fork: OK\n");
     966:	00001517          	auipc	a0,0x1
     96a:	21250513          	addi	a0,a0,530 # 1b78 <malloc+0x710>
     96e:	247000ef          	jal	13b4 <printf>
}
     972:	70a2                	ld	ra,40(sp)
     974:	7402                	ld	s0,32(sp)
     976:	64e2                	ld	s1,24(sp)
     978:	6942                	ld	s2,16(sp)
     97a:	6145                	addi	sp,sp,48
     97c:	8082                	ret
    printf("fork_test failed\n");
     97e:	00001517          	auipc	a0,0x1
     982:	1e250513          	addi	a0,a0,482 # 1b60 <malloc+0x6f8>
     986:	22f000ef          	jal	13b4 <printf>
    exit(1);
     98a:	4505                	li	a0,1
     98c:	5f0000ef          	jal	f7c <exit>

0000000000000990 <more_test>:

void
more_test()
{
     990:	7179                	addi	sp,sp,-48
     992:	f406                	sd	ra,40(sp)
     994:	f022                	sd	s0,32(sp)
     996:	ec26                	sd	s1,24(sp)
     998:	e84a                	sd	s2,16(sp)
     99a:	1800                	addi	s0,sp,48
  int fd, pid;
  char *p;
  const char * const f = "mmap.dur";
  
  printf("test munmap prevents access\n");
     99c:	00001517          	auipc	a0,0x1
     9a0:	1ec50513          	addi	a0,a0,492 # 1b88 <malloc+0x720>
     9a4:	211000ef          	jal	13b4 <printf>
  
  makefile(f);
     9a8:	00001517          	auipc	a0,0x1
     9ac:	c7850513          	addi	a0,a0,-904 # 1620 <malloc+0x1b8>
     9b0:	ee6ff0ef          	jal	96 <makefile>
  if ((fd = open(f, O_RDWR)) == -1)
     9b4:	4589                	li	a1,2
     9b6:	00001517          	auipc	a0,0x1
     9ba:	c6a50513          	addi	a0,a0,-918 # 1620 <malloc+0x1b8>
     9be:	5fe000ef          	jal	fbc <open>
     9c2:	57fd                	li	a5,-1
     9c4:	06f50e63          	beq	a0,a5,a40 <more_test+0xb0>
     9c8:	892a                	mv	s2,a0
    err("open");
  p = mmap(0, PGSIZE*2, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
     9ca:	4781                	li	a5,0
     9cc:	872a                	mv	a4,a0
     9ce:	4685                	li	a3,1
     9d0:	460d                	li	a2,3
     9d2:	6589                	lui	a1,0x2
     9d4:	4501                	li	a0,0
     9d6:	646000ef          	jal	101c <mmap>
     9da:	84aa                	mv	s1,a0
  if (p == MAP_FAILED)
     9dc:	57fd                	li	a5,-1
     9de:	06f50763          	beq	a0,a5,a4c <more_test+0xbc>
    err("mmap");
  close(fd);
     9e2:	854a                	mv	a0,s2
     9e4:	5c0000ef          	jal	fa4 <close>

  *p = 'X';
     9e8:	05800793          	li	a5,88
     9ec:	00f48023          	sb	a5,0(s1)
  *(p+PGSIZE) = 'Y';
     9f0:	6785                	lui	a5,0x1
     9f2:	97a6                	add	a5,a5,s1
     9f4:	05900713          	li	a4,89
     9f8:	00e78023          	sb	a4,0(a5) # 1000 <getpid+0x4>

  pid = fork();
     9fc:	578000ef          	jal	f74 <fork>
  if(pid < 0) err("fork");
     a00:	04054c63          	bltz	a0,a58 <more_test+0xc8>
  if(pid == 0){
     a04:	e535                	bnez	a0,a70 <more_test+0xe0>
    *p = 'a';
     a06:	06100793          	li	a5,97
     a0a:	00f48023          	sb	a5,0(s1)
    *(p+PGSIZE) = 'b';
     a0e:	6505                	lui	a0,0x1
     a10:	9526                	add	a0,a0,s1
     a12:	06200793          	li	a5,98
     a16:	00f50023          	sb	a5,0(a0) # 1000 <getpid+0x4>
    if(munmap(p+PGSIZE, PGSIZE) == -1)
     a1a:	6585                	lui	a1,0x1
     a1c:	608000ef          	jal	1024 <munmap>
     a20:	57fd                	li	a5,-1
     a22:	04f50163          	beq	a0,a5,a64 <more_test+0xd4>
      err("munmap");
    // this should cause a fatal fault
    printf("*(p+PGSIZE) = %x\n", *(p+PGSIZE));
     a26:	6785                	lui	a5,0x1
     a28:	97a6                	add	a5,a5,s1
     a2a:	0007c583          	lbu	a1,0(a5) # 1000 <getpid+0x4>
     a2e:	00001517          	auipc	a0,0x1
     a32:	17a50513          	addi	a0,a0,378 # 1ba8 <malloc+0x740>
     a36:	17f000ef          	jal	13b4 <printf>
    exit(0);
     a3a:	4501                	li	a0,0
     a3c:	540000ef          	jal	f7c <exit>
    err("open");
     a40:	00001517          	auipc	a0,0x1
     a44:	bb850513          	addi	a0,a0,-1096 # 15f8 <malloc+0x190>
     a48:	db8ff0ef          	jal	0 <err>
    err("mmap");
     a4c:	00001517          	auipc	a0,0x1
     a50:	ef450513          	addi	a0,a0,-268 # 1940 <malloc+0x4d8>
     a54:	dacff0ef          	jal	0 <err>
  if(pid < 0) err("fork");
     a58:	00001517          	auipc	a0,0x1
     a5c:	0f050513          	addi	a0,a0,240 # 1b48 <malloc+0x6e0>
     a60:	da0ff0ef          	jal	0 <err>
      err("munmap");
     a64:	00001517          	auipc	a0,0x1
     a68:	f0c50513          	addi	a0,a0,-244 # 1970 <malloc+0x508>
     a6c:	d94ff0ef          	jal	0 <err>
  }
  int st = 0;
     a70:	fc042e23          	sw	zero,-36(s0)
  wait(&st);
     a74:	fdc40513          	addi	a0,s0,-36
     a78:	50c000ef          	jal	f84 <wait>
  if(st != -1)
     a7c:	fdc42703          	lw	a4,-36(s0)
     a80:	57fd                	li	a5,-1
     a82:	04f71363          	bne	a4,a5,ac8 <more_test+0x138>
    err("child #1 read unmapped memory");

  pid = fork();
     a86:	4ee000ef          	jal	f74 <fork>
  if(pid < 0) err("fork");
     a8a:	04054563          	bltz	a0,ad4 <more_test+0x144>
  if(pid == 0){
     a8e:	ed39                	bnez	a0,aec <more_test+0x15c>
    *p = 'c';
     a90:	06300793          	li	a5,99
     a94:	00f48023          	sb	a5,0(s1)
    *(p+PGSIZE) = 'd';
     a98:	6785                	lui	a5,0x1
     a9a:	97a6                	add	a5,a5,s1
     a9c:	06400713          	li	a4,100
     aa0:	00e78023          	sb	a4,0(a5) # 1000 <getpid+0x4>
    if(munmap(p, PGSIZE) == -1)
     aa4:	6585                	lui	a1,0x1
     aa6:	8526                	mv	a0,s1
     aa8:	57c000ef          	jal	1024 <munmap>
     aac:	57fd                	li	a5,-1
     aae:	02f50963          	beq	a0,a5,ae0 <more_test+0x150>
      err("munmap");
    // this should cause a fatal fault
    printf("*p = %x\n", *p);
     ab2:	0004c583          	lbu	a1,0(s1)
     ab6:	00001517          	auipc	a0,0x1
     aba:	12a50513          	addi	a0,a0,298 # 1be0 <malloc+0x778>
     abe:	0f7000ef          	jal	13b4 <printf>
    exit(0);
     ac2:	4501                	li	a0,0
     ac4:	4b8000ef          	jal	f7c <exit>
    err("child #1 read unmapped memory");
     ac8:	00001517          	auipc	a0,0x1
     acc:	0f850513          	addi	a0,a0,248 # 1bc0 <malloc+0x758>
     ad0:	d30ff0ef          	jal	0 <err>
  if(pid < 0) err("fork");
     ad4:	00001517          	auipc	a0,0x1
     ad8:	07450513          	addi	a0,a0,116 # 1b48 <malloc+0x6e0>
     adc:	d24ff0ef          	jal	0 <err>
      err("munmap");
     ae0:	00001517          	auipc	a0,0x1
     ae4:	e9050513          	addi	a0,a0,-368 # 1970 <malloc+0x508>
     ae8:	d18ff0ef          	jal	0 <err>
  }
  st = 0;
     aec:	fc042e23          	sw	zero,-36(s0)
  wait(&st);
     af0:	fdc40513          	addi	a0,s0,-36
     af4:	490000ef          	jal	f84 <wait>
  if(st != -1)
     af8:	fdc42703          	lw	a4,-36(s0)
     afc:	57fd                	li	a5,-1
     afe:	10f71363          	bne	a4,a5,c04 <more_test+0x274>
    err("child #2 read unmapped memory");

  // parent should still be able to access the memory.
  *p = 'P';
     b02:	05000793          	li	a5,80
     b06:	00f48023          	sb	a5,0(s1)
  *(p+PGSIZE) = 'Q';
     b0a:	6785                	lui	a5,0x1
     b0c:	97a6                	add	a5,a5,s1
     b0e:	05100713          	li	a4,81
     b12:	00e78023          	sb	a4,0(a5) # 1000 <getpid+0x4>

  if(munmap(p, PGSIZE) == -1)
     b16:	6585                	lui	a1,0x1
     b18:	8526                	mv	a0,s1
     b1a:	50a000ef          	jal	1024 <munmap>
     b1e:	57fd                	li	a5,-1
     b20:	0ef50863          	beq	a0,a5,c10 <more_test+0x280>
    err("munmap");

  *(p+PGSIZE) = 'R';
     b24:	6785                	lui	a5,0x1
     b26:	00f48533          	add	a0,s1,a5
     b2a:	05200793          	li	a5,82
     b2e:	00f50023          	sb	a5,0(a0)
  if(munmap(p+PGSIZE, PGSIZE) == -1)
     b32:	6585                	lui	a1,0x1
     b34:	4f0000ef          	jal	1024 <munmap>
     b38:	57fd                	li	a5,-1
     b3a:	0ef50163          	beq	a0,a5,c1c <more_test+0x28c>
    err("munmap");

  // read the file, check that the first page starts
  // with P and the second page with R.
  fd = open(f, O_RDONLY);
     b3e:	4581                	li	a1,0
     b40:	00001517          	auipc	a0,0x1
     b44:	ae050513          	addi	a0,a0,-1312 # 1620 <malloc+0x1b8>
     b48:	474000ef          	jal	fbc <open>
     b4c:	84aa                	mv	s1,a0
  if(fd < 0) err("open");
     b4e:	0c054d63          	bltz	a0,c28 <more_test+0x298>
  if(read(fd, buf, PGSIZE) != PGSIZE) err("read");
     b52:	6605                	lui	a2,0x1
     b54:	00002597          	auipc	a1,0x2
     b58:	4bc58593          	addi	a1,a1,1212 # 3010 <buf>
     b5c:	438000ef          	jal	f94 <read>
     b60:	6785                	lui	a5,0x1
     b62:	0cf51963          	bne	a0,a5,c34 <more_test+0x2a4>
  if(buf[0] != 'P') err("first byte of file is wrong");
     b66:	00002717          	auipc	a4,0x2
     b6a:	4aa74703          	lbu	a4,1194(a4) # 3010 <buf>
     b6e:	05000793          	li	a5,80
     b72:	0cf71763          	bne	a4,a5,c40 <more_test+0x2b0>
  if(read(fd, buf, PGSIZE) != PGSIZE/2) err("read");
     b76:	6605                	lui	a2,0x1
     b78:	00002597          	auipc	a1,0x2
     b7c:	49858593          	addi	a1,a1,1176 # 3010 <buf>
     b80:	8526                	mv	a0,s1
     b82:	412000ef          	jal	f94 <read>
     b86:	8005051b          	addiw	a0,a0,-2048
     b8a:	e169                	bnez	a0,c4c <more_test+0x2bc>
  if(buf[0] != 'R') err("first byte of 2nd page of file is wrong");
     b8c:	00002717          	auipc	a4,0x2
     b90:	48474703          	lbu	a4,1156(a4) # 3010 <buf>
     b94:	05200793          	li	a5,82
     b98:	0cf71063          	bne	a4,a5,c58 <more_test+0x2c8>
  close(fd);
     b9c:	8526                	mv	a0,s1
     b9e:	406000ef          	jal	fa4 <close>

  printf("test munmap prevents access: OK\n");
     ba2:	00001517          	auipc	a0,0x1
     ba6:	0b650513          	addi	a0,a0,182 # 1c58 <malloc+0x7f0>
     baa:	00b000ef          	jal	13b4 <printf>

  printf("test writes to read-only mapped memory\n");
     bae:	00001517          	auipc	a0,0x1
     bb2:	0d250513          	addi	a0,a0,210 # 1c80 <malloc+0x818>
     bb6:	7fe000ef          	jal	13b4 <printf>

  makefile(f);
     bba:	00001517          	auipc	a0,0x1
     bbe:	a6650513          	addi	a0,a0,-1434 # 1620 <malloc+0x1b8>
     bc2:	cd4ff0ef          	jal	96 <makefile>

  pid = fork();
     bc6:	3ae000ef          	jal	f74 <fork>
  if(pid < 0) err("fork");
     bca:	08054d63          	bltz	a0,c64 <more_test+0x2d4>
  if(pid == 0){
     bce:	ed4d                	bnez	a0,c88 <more_test+0x2f8>
    if ((fd = open(f, O_RDWR)) == -1)
     bd0:	4589                	li	a1,2
     bd2:	00001517          	auipc	a0,0x1
     bd6:	a4e50513          	addi	a0,a0,-1458 # 1620 <malloc+0x1b8>
     bda:	3e2000ef          	jal	fbc <open>
     bde:	872a                	mv	a4,a0
     be0:	57fd                	li	a5,-1
     be2:	08f50763          	beq	a0,a5,c70 <more_test+0x2e0>
      err("open");
    p = mmap(0, PGSIZE*2, PROT_READ, MAP_SHARED, fd, 0);
     be6:	4781                	li	a5,0
     be8:	4685                	li	a3,1
     bea:	4605                	li	a2,1
     bec:	6589                	lui	a1,0x2
     bee:	4501                	li	a0,0
     bf0:	42c000ef          	jal	101c <mmap>
    if (p == MAP_FAILED)
     bf4:	57fd                	li	a5,-1
     bf6:	08f50363          	beq	a0,a5,c7c <more_test+0x2ec>
      err("mmap");
    // this should cause a fatal fault
    *p = 0;
     bfa:	00050023          	sb	zero,0(a0)
    exit(*p);
     bfe:	4501                	li	a0,0
     c00:	37c000ef          	jal	f7c <exit>
    err("child #2 read unmapped memory");
     c04:	00001517          	auipc	a0,0x1
     c08:	fec50513          	addi	a0,a0,-20 # 1bf0 <malloc+0x788>
     c0c:	bf4ff0ef          	jal	0 <err>
    err("munmap");
     c10:	00001517          	auipc	a0,0x1
     c14:	d6050513          	addi	a0,a0,-672 # 1970 <malloc+0x508>
     c18:	be8ff0ef          	jal	0 <err>
    err("munmap");
     c1c:	00001517          	auipc	a0,0x1
     c20:	d5450513          	addi	a0,a0,-684 # 1970 <malloc+0x508>
     c24:	bdcff0ef          	jal	0 <err>
  if(fd < 0) err("open");
     c28:	00001517          	auipc	a0,0x1
     c2c:	9d050513          	addi	a0,a0,-1584 # 15f8 <malloc+0x190>
     c30:	bd0ff0ef          	jal	0 <err>
  if(read(fd, buf, PGSIZE) != PGSIZE) err("read");
     c34:	00001517          	auipc	a0,0x1
     c38:	aa450513          	addi	a0,a0,-1372 # 16d8 <malloc+0x270>
     c3c:	bc4ff0ef          	jal	0 <err>
  if(buf[0] != 'P') err("first byte of file is wrong");
     c40:	00001517          	auipc	a0,0x1
     c44:	fd050513          	addi	a0,a0,-48 # 1c10 <malloc+0x7a8>
     c48:	bb8ff0ef          	jal	0 <err>
  if(read(fd, buf, PGSIZE) != PGSIZE/2) err("read");
     c4c:	00001517          	auipc	a0,0x1
     c50:	a8c50513          	addi	a0,a0,-1396 # 16d8 <malloc+0x270>
     c54:	bacff0ef          	jal	0 <err>
  if(buf[0] != 'R') err("first byte of 2nd page of file is wrong");
     c58:	00001517          	auipc	a0,0x1
     c5c:	fd850513          	addi	a0,a0,-40 # 1c30 <malloc+0x7c8>
     c60:	ba0ff0ef          	jal	0 <err>
  if(pid < 0) err("fork");
     c64:	00001517          	auipc	a0,0x1
     c68:	ee450513          	addi	a0,a0,-284 # 1b48 <malloc+0x6e0>
     c6c:	b94ff0ef          	jal	0 <err>
      err("open");
     c70:	00001517          	auipc	a0,0x1
     c74:	98850513          	addi	a0,a0,-1656 # 15f8 <malloc+0x190>
     c78:	b88ff0ef          	jal	0 <err>
      err("mmap");
     c7c:	00001517          	auipc	a0,0x1
     c80:	cc450513          	addi	a0,a0,-828 # 1940 <malloc+0x4d8>
     c84:	b7cff0ef          	jal	0 <err>
  }

  st = 0;
     c88:	fc042e23          	sw	zero,-36(s0)
  wait(&st);
     c8c:	fdc40513          	addi	a0,s0,-36
     c90:	2f4000ef          	jal	f84 <wait>
  if(st != -1)
     c94:	fdc42703          	lw	a4,-36(s0)
     c98:	57fd                	li	a5,-1
     c9a:	00f71e63          	bne	a4,a5,cb6 <more_test+0x326>
    err("child wrote read-only mapping");

  printf("test writes to read-only mapped memory: OK\n");
     c9e:	00001517          	auipc	a0,0x1
     ca2:	02a50513          	addi	a0,a0,42 # 1cc8 <malloc+0x860>
     ca6:	70e000ef          	jal	13b4 <printf>
}
     caa:	70a2                	ld	ra,40(sp)
     cac:	7402                	ld	s0,32(sp)
     cae:	64e2                	ld	s1,24(sp)
     cb0:	6942                	ld	s2,16(sp)
     cb2:	6145                	addi	sp,sp,48
     cb4:	8082                	ret
    err("child wrote read-only mapping");
     cb6:	00001517          	auipc	a0,0x1
     cba:	ff250513          	addi	a0,a0,-14 # 1ca8 <malloc+0x840>
     cbe:	b42ff0ef          	jal	0 <err>

0000000000000cc2 <main>:
{
     cc2:	1141                	addi	sp,sp,-16
     cc4:	e406                	sd	ra,8(sp)
     cc6:	e022                	sd	s0,0(sp)
     cc8:	0800                	addi	s0,sp,16
  mmap_test();
     cca:	c66ff0ef          	jal	130 <mmap_test>
  fork_test();
     cce:	b75ff0ef          	jal	842 <fork_test>
  more_test();
     cd2:	cbfff0ef          	jal	990 <more_test>
  printf("mmaptest: all tests succeeded\n");
     cd6:	00001517          	auipc	a0,0x1
     cda:	02250513          	addi	a0,a0,34 # 1cf8 <malloc+0x890>
     cde:	6d6000ef          	jal	13b4 <printf>
  exit(0);
     ce2:	4501                	li	a0,0
     ce4:	298000ef          	jal	f7c <exit>

0000000000000ce8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     ce8:	1141                	addi	sp,sp,-16
     cea:	e406                	sd	ra,8(sp)
     cec:	e022                	sd	s0,0(sp)
     cee:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     cf0:	fd3ff0ef          	jal	cc2 <main>
  exit(r);
     cf4:	288000ef          	jal	f7c <exit>

0000000000000cf8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     cf8:	1141                	addi	sp,sp,-16
     cfa:	e422                	sd	s0,8(sp)
     cfc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     cfe:	87aa                	mv	a5,a0
     d00:	0585                	addi	a1,a1,1 # 2001 <digits+0x2e1>
     d02:	0785                	addi	a5,a5,1 # 1001 <getpid+0x5>
     d04:	fff5c703          	lbu	a4,-1(a1)
     d08:	fee78fa3          	sb	a4,-1(a5)
     d0c:	fb75                	bnez	a4,d00 <strcpy+0x8>
    ;
  return os;
}
     d0e:	6422                	ld	s0,8(sp)
     d10:	0141                	addi	sp,sp,16
     d12:	8082                	ret

0000000000000d14 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     d14:	1141                	addi	sp,sp,-16
     d16:	e422                	sd	s0,8(sp)
     d18:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     d1a:	00054783          	lbu	a5,0(a0)
     d1e:	cb91                	beqz	a5,d32 <strcmp+0x1e>
     d20:	0005c703          	lbu	a4,0(a1)
     d24:	00f71763          	bne	a4,a5,d32 <strcmp+0x1e>
    p++, q++;
     d28:	0505                	addi	a0,a0,1
     d2a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     d2c:	00054783          	lbu	a5,0(a0)
     d30:	fbe5                	bnez	a5,d20 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     d32:	0005c503          	lbu	a0,0(a1)
}
     d36:	40a7853b          	subw	a0,a5,a0
     d3a:	6422                	ld	s0,8(sp)
     d3c:	0141                	addi	sp,sp,16
     d3e:	8082                	ret

0000000000000d40 <strlen>:

uint
strlen(const char *s)
{
     d40:	1141                	addi	sp,sp,-16
     d42:	e422                	sd	s0,8(sp)
     d44:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     d46:	00054783          	lbu	a5,0(a0)
     d4a:	cf91                	beqz	a5,d66 <strlen+0x26>
     d4c:	0505                	addi	a0,a0,1
     d4e:	87aa                	mv	a5,a0
     d50:	86be                	mv	a3,a5
     d52:	0785                	addi	a5,a5,1
     d54:	fff7c703          	lbu	a4,-1(a5)
     d58:	ff65                	bnez	a4,d50 <strlen+0x10>
     d5a:	40a6853b          	subw	a0,a3,a0
     d5e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     d60:	6422                	ld	s0,8(sp)
     d62:	0141                	addi	sp,sp,16
     d64:	8082                	ret
  for(n = 0; s[n]; n++)
     d66:	4501                	li	a0,0
     d68:	bfe5                	j	d60 <strlen+0x20>

0000000000000d6a <memset>:

void*
memset(void *dst, int c, uint n)
{
     d6a:	1141                	addi	sp,sp,-16
     d6c:	e422                	sd	s0,8(sp)
     d6e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     d70:	ca19                	beqz	a2,d86 <memset+0x1c>
     d72:	87aa                	mv	a5,a0
     d74:	1602                	slli	a2,a2,0x20
     d76:	9201                	srli	a2,a2,0x20
     d78:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     d7c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     d80:	0785                	addi	a5,a5,1
     d82:	fee79de3          	bne	a5,a4,d7c <memset+0x12>
  }
  return dst;
}
     d86:	6422                	ld	s0,8(sp)
     d88:	0141                	addi	sp,sp,16
     d8a:	8082                	ret

0000000000000d8c <strchr>:

char*
strchr(const char *s, char c)
{
     d8c:	1141                	addi	sp,sp,-16
     d8e:	e422                	sd	s0,8(sp)
     d90:	0800                	addi	s0,sp,16
  for(; *s; s++)
     d92:	00054783          	lbu	a5,0(a0)
     d96:	cb99                	beqz	a5,dac <strchr+0x20>
    if(*s == c)
     d98:	00f58763          	beq	a1,a5,da6 <strchr+0x1a>
  for(; *s; s++)
     d9c:	0505                	addi	a0,a0,1
     d9e:	00054783          	lbu	a5,0(a0)
     da2:	fbfd                	bnez	a5,d98 <strchr+0xc>
      return (char*)s;
  return 0;
     da4:	4501                	li	a0,0
}
     da6:	6422                	ld	s0,8(sp)
     da8:	0141                	addi	sp,sp,16
     daa:	8082                	ret
  return 0;
     dac:	4501                	li	a0,0
     dae:	bfe5                	j	da6 <strchr+0x1a>

0000000000000db0 <gets>:

char*
gets(char *buf, int max)
{
     db0:	711d                	addi	sp,sp,-96
     db2:	ec86                	sd	ra,88(sp)
     db4:	e8a2                	sd	s0,80(sp)
     db6:	e4a6                	sd	s1,72(sp)
     db8:	e0ca                	sd	s2,64(sp)
     dba:	fc4e                	sd	s3,56(sp)
     dbc:	f852                	sd	s4,48(sp)
     dbe:	f456                	sd	s5,40(sp)
     dc0:	f05a                	sd	s6,32(sp)
     dc2:	ec5e                	sd	s7,24(sp)
     dc4:	1080                	addi	s0,sp,96
     dc6:	8baa                	mv	s7,a0
     dc8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     dca:	892a                	mv	s2,a0
     dcc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     dce:	4aa9                	li	s5,10
     dd0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     dd2:	89a6                	mv	s3,s1
     dd4:	2485                	addiw	s1,s1,1
     dd6:	0344d663          	bge	s1,s4,e02 <gets+0x52>
    cc = read(0, &c, 1);
     dda:	4605                	li	a2,1
     ddc:	faf40593          	addi	a1,s0,-81
     de0:	4501                	li	a0,0
     de2:	1b2000ef          	jal	f94 <read>
    if(cc < 1)
     de6:	00a05e63          	blez	a0,e02 <gets+0x52>
    buf[i++] = c;
     dea:	faf44783          	lbu	a5,-81(s0)
     dee:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     df2:	01578763          	beq	a5,s5,e00 <gets+0x50>
     df6:	0905                	addi	s2,s2,1
     df8:	fd679de3          	bne	a5,s6,dd2 <gets+0x22>
    buf[i++] = c;
     dfc:	89a6                	mv	s3,s1
     dfe:	a011                	j	e02 <gets+0x52>
     e00:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     e02:	99de                	add	s3,s3,s7
     e04:	00098023          	sb	zero,0(s3)
  return buf;
}
     e08:	855e                	mv	a0,s7
     e0a:	60e6                	ld	ra,88(sp)
     e0c:	6446                	ld	s0,80(sp)
     e0e:	64a6                	ld	s1,72(sp)
     e10:	6906                	ld	s2,64(sp)
     e12:	79e2                	ld	s3,56(sp)
     e14:	7a42                	ld	s4,48(sp)
     e16:	7aa2                	ld	s5,40(sp)
     e18:	7b02                	ld	s6,32(sp)
     e1a:	6be2                	ld	s7,24(sp)
     e1c:	6125                	addi	sp,sp,96
     e1e:	8082                	ret

0000000000000e20 <stat>:

int
stat(const char *n, struct stat *st)
{
     e20:	1101                	addi	sp,sp,-32
     e22:	ec06                	sd	ra,24(sp)
     e24:	e822                	sd	s0,16(sp)
     e26:	e04a                	sd	s2,0(sp)
     e28:	1000                	addi	s0,sp,32
     e2a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     e2c:	4581                	li	a1,0
     e2e:	18e000ef          	jal	fbc <open>
  if(fd < 0)
     e32:	02054263          	bltz	a0,e56 <stat+0x36>
     e36:	e426                	sd	s1,8(sp)
     e38:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     e3a:	85ca                	mv	a1,s2
     e3c:	198000ef          	jal	fd4 <fstat>
     e40:	892a                	mv	s2,a0
  close(fd);
     e42:	8526                	mv	a0,s1
     e44:	160000ef          	jal	fa4 <close>
  return r;
     e48:	64a2                	ld	s1,8(sp)
}
     e4a:	854a                	mv	a0,s2
     e4c:	60e2                	ld	ra,24(sp)
     e4e:	6442                	ld	s0,16(sp)
     e50:	6902                	ld	s2,0(sp)
     e52:	6105                	addi	sp,sp,32
     e54:	8082                	ret
    return -1;
     e56:	597d                	li	s2,-1
     e58:	bfcd                	j	e4a <stat+0x2a>

0000000000000e5a <atoi>:

int
atoi(const char *s)
{
     e5a:	1141                	addi	sp,sp,-16
     e5c:	e422                	sd	s0,8(sp)
     e5e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     e60:	00054683          	lbu	a3,0(a0)
     e64:	fd06879b          	addiw	a5,a3,-48 # 1fd0 <digits+0x2b0>
     e68:	0ff7f793          	zext.b	a5,a5
     e6c:	4625                	li	a2,9
     e6e:	02f66863          	bltu	a2,a5,e9e <atoi+0x44>
     e72:	872a                	mv	a4,a0
  n = 0;
     e74:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     e76:	0705                	addi	a4,a4,1
     e78:	0025179b          	slliw	a5,a0,0x2
     e7c:	9fa9                	addw	a5,a5,a0
     e7e:	0017979b          	slliw	a5,a5,0x1
     e82:	9fb5                	addw	a5,a5,a3
     e84:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     e88:	00074683          	lbu	a3,0(a4)
     e8c:	fd06879b          	addiw	a5,a3,-48
     e90:	0ff7f793          	zext.b	a5,a5
     e94:	fef671e3          	bgeu	a2,a5,e76 <atoi+0x1c>
  return n;
}
     e98:	6422                	ld	s0,8(sp)
     e9a:	0141                	addi	sp,sp,16
     e9c:	8082                	ret
  n = 0;
     e9e:	4501                	li	a0,0
     ea0:	bfe5                	j	e98 <atoi+0x3e>

0000000000000ea2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     ea2:	1141                	addi	sp,sp,-16
     ea4:	e422                	sd	s0,8(sp)
     ea6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     ea8:	02b57463          	bgeu	a0,a1,ed0 <memmove+0x2e>
    while(n-- > 0)
     eac:	00c05f63          	blez	a2,eca <memmove+0x28>
     eb0:	1602                	slli	a2,a2,0x20
     eb2:	9201                	srli	a2,a2,0x20
     eb4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     eb8:	872a                	mv	a4,a0
      *dst++ = *src++;
     eba:	0585                	addi	a1,a1,1
     ebc:	0705                	addi	a4,a4,1
     ebe:	fff5c683          	lbu	a3,-1(a1)
     ec2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     ec6:	fef71ae3          	bne	a4,a5,eba <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     eca:	6422                	ld	s0,8(sp)
     ecc:	0141                	addi	sp,sp,16
     ece:	8082                	ret
    dst += n;
     ed0:	00c50733          	add	a4,a0,a2
    src += n;
     ed4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     ed6:	fec05ae3          	blez	a2,eca <memmove+0x28>
     eda:	fff6079b          	addiw	a5,a2,-1 # fff <getpid+0x3>
     ede:	1782                	slli	a5,a5,0x20
     ee0:	9381                	srli	a5,a5,0x20
     ee2:	fff7c793          	not	a5,a5
     ee6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     ee8:	15fd                	addi	a1,a1,-1
     eea:	177d                	addi	a4,a4,-1
     eec:	0005c683          	lbu	a3,0(a1)
     ef0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     ef4:	fee79ae3          	bne	a5,a4,ee8 <memmove+0x46>
     ef8:	bfc9                	j	eca <memmove+0x28>

0000000000000efa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     efa:	1141                	addi	sp,sp,-16
     efc:	e422                	sd	s0,8(sp)
     efe:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     f00:	ca05                	beqz	a2,f30 <memcmp+0x36>
     f02:	fff6069b          	addiw	a3,a2,-1
     f06:	1682                	slli	a3,a3,0x20
     f08:	9281                	srli	a3,a3,0x20
     f0a:	0685                	addi	a3,a3,1
     f0c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     f0e:	00054783          	lbu	a5,0(a0)
     f12:	0005c703          	lbu	a4,0(a1)
     f16:	00e79863          	bne	a5,a4,f26 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     f1a:	0505                	addi	a0,a0,1
    p2++;
     f1c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     f1e:	fed518e3          	bne	a0,a3,f0e <memcmp+0x14>
  }
  return 0;
     f22:	4501                	li	a0,0
     f24:	a019                	j	f2a <memcmp+0x30>
      return *p1 - *p2;
     f26:	40e7853b          	subw	a0,a5,a4
}
     f2a:	6422                	ld	s0,8(sp)
     f2c:	0141                	addi	sp,sp,16
     f2e:	8082                	ret
  return 0;
     f30:	4501                	li	a0,0
     f32:	bfe5                	j	f2a <memcmp+0x30>

0000000000000f34 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     f34:	1141                	addi	sp,sp,-16
     f36:	e406                	sd	ra,8(sp)
     f38:	e022                	sd	s0,0(sp)
     f3a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     f3c:	f67ff0ef          	jal	ea2 <memmove>
}
     f40:	60a2                	ld	ra,8(sp)
     f42:	6402                	ld	s0,0(sp)
     f44:	0141                	addi	sp,sp,16
     f46:	8082                	ret

0000000000000f48 <sbrk>:

char *
sbrk(int n) {
     f48:	1141                	addi	sp,sp,-16
     f4a:	e406                	sd	ra,8(sp)
     f4c:	e022                	sd	s0,0(sp)
     f4e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     f50:	4585                	li	a1,1
     f52:	0b2000ef          	jal	1004 <sys_sbrk>
}
     f56:	60a2                	ld	ra,8(sp)
     f58:	6402                	ld	s0,0(sp)
     f5a:	0141                	addi	sp,sp,16
     f5c:	8082                	ret

0000000000000f5e <sbrklazy>:

char *
sbrklazy(int n) {
     f5e:	1141                	addi	sp,sp,-16
     f60:	e406                	sd	ra,8(sp)
     f62:	e022                	sd	s0,0(sp)
     f64:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     f66:	4589                	li	a1,2
     f68:	09c000ef          	jal	1004 <sys_sbrk>
}
     f6c:	60a2                	ld	ra,8(sp)
     f6e:	6402                	ld	s0,0(sp)
     f70:	0141                	addi	sp,sp,16
     f72:	8082                	ret

0000000000000f74 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     f74:	4885                	li	a7,1
 ecall
     f76:	00000073          	ecall
 ret
     f7a:	8082                	ret

0000000000000f7c <exit>:
.global exit
exit:
 li a7, SYS_exit
     f7c:	4889                	li	a7,2
 ecall
     f7e:	00000073          	ecall
 ret
     f82:	8082                	ret

0000000000000f84 <wait>:
.global wait
wait:
 li a7, SYS_wait
     f84:	488d                	li	a7,3
 ecall
     f86:	00000073          	ecall
 ret
     f8a:	8082                	ret

0000000000000f8c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     f8c:	4891                	li	a7,4
 ecall
     f8e:	00000073          	ecall
 ret
     f92:	8082                	ret

0000000000000f94 <read>:
.global read
read:
 li a7, SYS_read
     f94:	4895                	li	a7,5
 ecall
     f96:	00000073          	ecall
 ret
     f9a:	8082                	ret

0000000000000f9c <write>:
.global write
write:
 li a7, SYS_write
     f9c:	48c1                	li	a7,16
 ecall
     f9e:	00000073          	ecall
 ret
     fa2:	8082                	ret

0000000000000fa4 <close>:
.global close
close:
 li a7, SYS_close
     fa4:	48d5                	li	a7,21
 ecall
     fa6:	00000073          	ecall
 ret
     faa:	8082                	ret

0000000000000fac <kill>:
.global kill
kill:
 li a7, SYS_kill
     fac:	4899                	li	a7,6
 ecall
     fae:	00000073          	ecall
 ret
     fb2:	8082                	ret

0000000000000fb4 <exec>:
.global exec
exec:
 li a7, SYS_exec
     fb4:	489d                	li	a7,7
 ecall
     fb6:	00000073          	ecall
 ret
     fba:	8082                	ret

0000000000000fbc <open>:
.global open
open:
 li a7, SYS_open
     fbc:	48bd                	li	a7,15
 ecall
     fbe:	00000073          	ecall
 ret
     fc2:	8082                	ret

0000000000000fc4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     fc4:	48c5                	li	a7,17
 ecall
     fc6:	00000073          	ecall
 ret
     fca:	8082                	ret

0000000000000fcc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     fcc:	48c9                	li	a7,18
 ecall
     fce:	00000073          	ecall
 ret
     fd2:	8082                	ret

0000000000000fd4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     fd4:	48a1                	li	a7,8
 ecall
     fd6:	00000073          	ecall
 ret
     fda:	8082                	ret

0000000000000fdc <link>:
.global link
link:
 li a7, SYS_link
     fdc:	48cd                	li	a7,19
 ecall
     fde:	00000073          	ecall
 ret
     fe2:	8082                	ret

0000000000000fe4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     fe4:	48d1                	li	a7,20
 ecall
     fe6:	00000073          	ecall
 ret
     fea:	8082                	ret

0000000000000fec <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     fec:	48a5                	li	a7,9
 ecall
     fee:	00000073          	ecall
 ret
     ff2:	8082                	ret

0000000000000ff4 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ff4:	48a9                	li	a7,10
 ecall
     ff6:	00000073          	ecall
 ret
     ffa:	8082                	ret

0000000000000ffc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ffc:	48ad                	li	a7,11
 ecall
     ffe:	00000073          	ecall
 ret
    1002:	8082                	ret

0000000000001004 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
    1004:	48b1                	li	a7,12
 ecall
    1006:	00000073          	ecall
 ret
    100a:	8082                	ret

000000000000100c <pause>:
.global pause
pause:
 li a7, SYS_pause
    100c:	48b5                	li	a7,13
 ecall
    100e:	00000073          	ecall
 ret
    1012:	8082                	ret

0000000000001014 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    1014:	48b9                	li	a7,14
 ecall
    1016:	00000073          	ecall
 ret
    101a:	8082                	ret

000000000000101c <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
    101c:	48d9                	li	a7,22
 ecall
    101e:	00000073          	ecall
 ret
    1022:	8082                	ret

0000000000001024 <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
    1024:	48dd                	li	a7,23
 ecall
    1026:	00000073          	ecall
 ret
    102a:	8082                	ret

000000000000102c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    102c:	1101                	addi	sp,sp,-32
    102e:	ec06                	sd	ra,24(sp)
    1030:	e822                	sd	s0,16(sp)
    1032:	1000                	addi	s0,sp,32
    1034:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    1038:	4605                	li	a2,1
    103a:	fef40593          	addi	a1,s0,-17
    103e:	f5fff0ef          	jal	f9c <write>
}
    1042:	60e2                	ld	ra,24(sp)
    1044:	6442                	ld	s0,16(sp)
    1046:	6105                	addi	sp,sp,32
    1048:	8082                	ret

000000000000104a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
    104a:	715d                	addi	sp,sp,-80
    104c:	e486                	sd	ra,72(sp)
    104e:	e0a2                	sd	s0,64(sp)
    1050:	f84a                	sd	s2,48(sp)
    1052:	0880                	addi	s0,sp,80
    1054:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
    1056:	c299                	beqz	a3,105c <printint+0x12>
    1058:	0805c363          	bltz	a1,10de <printint+0x94>
  neg = 0;
    105c:	4881                	li	a7,0
    105e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    1062:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
    1064:	00001517          	auipc	a0,0x1
    1068:	cbc50513          	addi	a0,a0,-836 # 1d20 <digits>
    106c:	883e                	mv	a6,a5
    106e:	2785                	addiw	a5,a5,1
    1070:	02c5f733          	remu	a4,a1,a2
    1074:	972a                	add	a4,a4,a0
    1076:	00074703          	lbu	a4,0(a4)
    107a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
    107e:	872e                	mv	a4,a1
    1080:	02c5d5b3          	divu	a1,a1,a2
    1084:	0685                	addi	a3,a3,1
    1086:	fec773e3          	bgeu	a4,a2,106c <printint+0x22>
  if(neg)
    108a:	00088b63          	beqz	a7,10a0 <printint+0x56>
    buf[i++] = '-';
    108e:	fd078793          	addi	a5,a5,-48
    1092:	97a2                	add	a5,a5,s0
    1094:	02d00713          	li	a4,45
    1098:	fee78423          	sb	a4,-24(a5)
    109c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    10a0:	02f05a63          	blez	a5,10d4 <printint+0x8a>
    10a4:	fc26                	sd	s1,56(sp)
    10a6:	f44e                	sd	s3,40(sp)
    10a8:	fb840713          	addi	a4,s0,-72
    10ac:	00f704b3          	add	s1,a4,a5
    10b0:	fff70993          	addi	s3,a4,-1
    10b4:	99be                	add	s3,s3,a5
    10b6:	37fd                	addiw	a5,a5,-1
    10b8:	1782                	slli	a5,a5,0x20
    10ba:	9381                	srli	a5,a5,0x20
    10bc:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
    10c0:	fff4c583          	lbu	a1,-1(s1)
    10c4:	854a                	mv	a0,s2
    10c6:	f67ff0ef          	jal	102c <putc>
  while(--i >= 0)
    10ca:	14fd                	addi	s1,s1,-1
    10cc:	ff349ae3          	bne	s1,s3,10c0 <printint+0x76>
    10d0:	74e2                	ld	s1,56(sp)
    10d2:	79a2                	ld	s3,40(sp)
}
    10d4:	60a6                	ld	ra,72(sp)
    10d6:	6406                	ld	s0,64(sp)
    10d8:	7942                	ld	s2,48(sp)
    10da:	6161                	addi	sp,sp,80
    10dc:	8082                	ret
    x = -xx;
    10de:	40b005b3          	neg	a1,a1
    neg = 1;
    10e2:	4885                	li	a7,1
    x = -xx;
    10e4:	bfad                	j	105e <printint+0x14>

00000000000010e6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    10e6:	711d                	addi	sp,sp,-96
    10e8:	ec86                	sd	ra,88(sp)
    10ea:	e8a2                	sd	s0,80(sp)
    10ec:	e0ca                	sd	s2,64(sp)
    10ee:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    10f0:	0005c903          	lbu	s2,0(a1)
    10f4:	28090663          	beqz	s2,1380 <vprintf+0x29a>
    10f8:	e4a6                	sd	s1,72(sp)
    10fa:	fc4e                	sd	s3,56(sp)
    10fc:	f852                	sd	s4,48(sp)
    10fe:	f456                	sd	s5,40(sp)
    1100:	f05a                	sd	s6,32(sp)
    1102:	ec5e                	sd	s7,24(sp)
    1104:	e862                	sd	s8,16(sp)
    1106:	e466                	sd	s9,8(sp)
    1108:	8b2a                	mv	s6,a0
    110a:	8a2e                	mv	s4,a1
    110c:	8bb2                	mv	s7,a2
  state = 0;
    110e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    1110:	4481                	li	s1,0
    1112:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    1114:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    1118:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    111c:	06c00c93          	li	s9,108
    1120:	a005                	j	1140 <vprintf+0x5a>
        putc(fd, c0);
    1122:	85ca                	mv	a1,s2
    1124:	855a                	mv	a0,s6
    1126:	f07ff0ef          	jal	102c <putc>
    112a:	a019                	j	1130 <vprintf+0x4a>
    } else if(state == '%'){
    112c:	03598263          	beq	s3,s5,1150 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
    1130:	2485                	addiw	s1,s1,1
    1132:	8726                	mv	a4,s1
    1134:	009a07b3          	add	a5,s4,s1
    1138:	0007c903          	lbu	s2,0(a5)
    113c:	22090a63          	beqz	s2,1370 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
    1140:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1144:	fe0994e3          	bnez	s3,112c <vprintf+0x46>
      if(c0 == '%'){
    1148:	fd579de3          	bne	a5,s5,1122 <vprintf+0x3c>
        state = '%';
    114c:	89be                	mv	s3,a5
    114e:	b7cd                	j	1130 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
    1150:	00ea06b3          	add	a3,s4,a4
    1154:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    1158:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
    115a:	c681                	beqz	a3,1162 <vprintf+0x7c>
    115c:	9752                	add	a4,a4,s4
    115e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
    1162:	05878363          	beq	a5,s8,11a8 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
    1166:	05978d63          	beq	a5,s9,11c0 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
    116a:	07500713          	li	a4,117
    116e:	0ee78763          	beq	a5,a4,125c <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
    1172:	07800713          	li	a4,120
    1176:	12e78963          	beq	a5,a4,12a8 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
    117a:	07000713          	li	a4,112
    117e:	14e78e63          	beq	a5,a4,12da <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
    1182:	06300713          	li	a4,99
    1186:	18e78e63          	beq	a5,a4,1322 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
    118a:	07300713          	li	a4,115
    118e:	1ae78463          	beq	a5,a4,1336 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
    1192:	02500713          	li	a4,37
    1196:	04e79563          	bne	a5,a4,11e0 <vprintf+0xfa>
        putc(fd, '%');
    119a:	02500593          	li	a1,37
    119e:	855a                	mv	a0,s6
    11a0:	e8dff0ef          	jal	102c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    11a4:	4981                	li	s3,0
    11a6:	b769                	j	1130 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
    11a8:	008b8913          	addi	s2,s7,8
    11ac:	4685                	li	a3,1
    11ae:	4629                	li	a2,10
    11b0:	000ba583          	lw	a1,0(s7)
    11b4:	855a                	mv	a0,s6
    11b6:	e95ff0ef          	jal	104a <printint>
    11ba:	8bca                	mv	s7,s2
      state = 0;
    11bc:	4981                	li	s3,0
    11be:	bf8d                	j	1130 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
    11c0:	06400793          	li	a5,100
    11c4:	02f68963          	beq	a3,a5,11f6 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    11c8:	06c00793          	li	a5,108
    11cc:	04f68263          	beq	a3,a5,1210 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
    11d0:	07500793          	li	a5,117
    11d4:	0af68063          	beq	a3,a5,1274 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
    11d8:	07800793          	li	a5,120
    11dc:	0ef68263          	beq	a3,a5,12c0 <vprintf+0x1da>
        putc(fd, '%');
    11e0:	02500593          	li	a1,37
    11e4:	855a                	mv	a0,s6
    11e6:	e47ff0ef          	jal	102c <putc>
        putc(fd, c0);
    11ea:	85ca                	mv	a1,s2
    11ec:	855a                	mv	a0,s6
    11ee:	e3fff0ef          	jal	102c <putc>
      state = 0;
    11f2:	4981                	li	s3,0
    11f4:	bf35                	j	1130 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    11f6:	008b8913          	addi	s2,s7,8
    11fa:	4685                	li	a3,1
    11fc:	4629                	li	a2,10
    11fe:	000bb583          	ld	a1,0(s7)
    1202:	855a                	mv	a0,s6
    1204:	e47ff0ef          	jal	104a <printint>
        i += 1;
    1208:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    120a:	8bca                	mv	s7,s2
      state = 0;
    120c:	4981                	li	s3,0
        i += 1;
    120e:	b70d                	j	1130 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    1210:	06400793          	li	a5,100
    1214:	02f60763          	beq	a2,a5,1242 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    1218:	07500793          	li	a5,117
    121c:	06f60963          	beq	a2,a5,128e <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    1220:	07800793          	li	a5,120
    1224:	faf61ee3          	bne	a2,a5,11e0 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
    1228:	008b8913          	addi	s2,s7,8
    122c:	4681                	li	a3,0
    122e:	4641                	li	a2,16
    1230:	000bb583          	ld	a1,0(s7)
    1234:	855a                	mv	a0,s6
    1236:	e15ff0ef          	jal	104a <printint>
        i += 2;
    123a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    123c:	8bca                	mv	s7,s2
      state = 0;
    123e:	4981                	li	s3,0
        i += 2;
    1240:	bdc5                	j	1130 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    1242:	008b8913          	addi	s2,s7,8
    1246:	4685                	li	a3,1
    1248:	4629                	li	a2,10
    124a:	000bb583          	ld	a1,0(s7)
    124e:	855a                	mv	a0,s6
    1250:	dfbff0ef          	jal	104a <printint>
        i += 2;
    1254:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    1256:	8bca                	mv	s7,s2
      state = 0;
    1258:	4981                	li	s3,0
        i += 2;
    125a:	bdd9                	j	1130 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
    125c:	008b8913          	addi	s2,s7,8
    1260:	4681                	li	a3,0
    1262:	4629                	li	a2,10
    1264:	000be583          	lwu	a1,0(s7)
    1268:	855a                	mv	a0,s6
    126a:	de1ff0ef          	jal	104a <printint>
    126e:	8bca                	mv	s7,s2
      state = 0;
    1270:	4981                	li	s3,0
    1272:	bd7d                	j	1130 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1274:	008b8913          	addi	s2,s7,8
    1278:	4681                	li	a3,0
    127a:	4629                	li	a2,10
    127c:	000bb583          	ld	a1,0(s7)
    1280:	855a                	mv	a0,s6
    1282:	dc9ff0ef          	jal	104a <printint>
        i += 1;
    1286:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    1288:	8bca                	mv	s7,s2
      state = 0;
    128a:	4981                	li	s3,0
        i += 1;
    128c:	b555                	j	1130 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    128e:	008b8913          	addi	s2,s7,8
    1292:	4681                	li	a3,0
    1294:	4629                	li	a2,10
    1296:	000bb583          	ld	a1,0(s7)
    129a:	855a                	mv	a0,s6
    129c:	dafff0ef          	jal	104a <printint>
        i += 2;
    12a0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    12a2:	8bca                	mv	s7,s2
      state = 0;
    12a4:	4981                	li	s3,0
        i += 2;
    12a6:	b569                	j	1130 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
    12a8:	008b8913          	addi	s2,s7,8
    12ac:	4681                	li	a3,0
    12ae:	4641                	li	a2,16
    12b0:	000be583          	lwu	a1,0(s7)
    12b4:	855a                	mv	a0,s6
    12b6:	d95ff0ef          	jal	104a <printint>
    12ba:	8bca                	mv	s7,s2
      state = 0;
    12bc:	4981                	li	s3,0
    12be:	bd8d                	j	1130 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    12c0:	008b8913          	addi	s2,s7,8
    12c4:	4681                	li	a3,0
    12c6:	4641                	li	a2,16
    12c8:	000bb583          	ld	a1,0(s7)
    12cc:	855a                	mv	a0,s6
    12ce:	d7dff0ef          	jal	104a <printint>
        i += 1;
    12d2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    12d4:	8bca                	mv	s7,s2
      state = 0;
    12d6:	4981                	li	s3,0
        i += 1;
    12d8:	bda1                	j	1130 <vprintf+0x4a>
    12da:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    12dc:	008b8d13          	addi	s10,s7,8
    12e0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    12e4:	03000593          	li	a1,48
    12e8:	855a                	mv	a0,s6
    12ea:	d43ff0ef          	jal	102c <putc>
  putc(fd, 'x');
    12ee:	07800593          	li	a1,120
    12f2:	855a                	mv	a0,s6
    12f4:	d39ff0ef          	jal	102c <putc>
    12f8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    12fa:	00001b97          	auipc	s7,0x1
    12fe:	a26b8b93          	addi	s7,s7,-1498 # 1d20 <digits>
    1302:	03c9d793          	srli	a5,s3,0x3c
    1306:	97de                	add	a5,a5,s7
    1308:	0007c583          	lbu	a1,0(a5)
    130c:	855a                	mv	a0,s6
    130e:	d1fff0ef          	jal	102c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1312:	0992                	slli	s3,s3,0x4
    1314:	397d                	addiw	s2,s2,-1
    1316:	fe0916e3          	bnez	s2,1302 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
    131a:	8bea                	mv	s7,s10
      state = 0;
    131c:	4981                	li	s3,0
    131e:	6d02                	ld	s10,0(sp)
    1320:	bd01                	j	1130 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
    1322:	008b8913          	addi	s2,s7,8
    1326:	000bc583          	lbu	a1,0(s7)
    132a:	855a                	mv	a0,s6
    132c:	d01ff0ef          	jal	102c <putc>
    1330:	8bca                	mv	s7,s2
      state = 0;
    1332:	4981                	li	s3,0
    1334:	bbf5                	j	1130 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
    1336:	008b8993          	addi	s3,s7,8
    133a:	000bb903          	ld	s2,0(s7)
    133e:	00090f63          	beqz	s2,135c <vprintf+0x276>
        for(; *s; s++)
    1342:	00094583          	lbu	a1,0(s2)
    1346:	c195                	beqz	a1,136a <vprintf+0x284>
          putc(fd, *s);
    1348:	855a                	mv	a0,s6
    134a:	ce3ff0ef          	jal	102c <putc>
        for(; *s; s++)
    134e:	0905                	addi	s2,s2,1
    1350:	00094583          	lbu	a1,0(s2)
    1354:	f9f5                	bnez	a1,1348 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    1356:	8bce                	mv	s7,s3
      state = 0;
    1358:	4981                	li	s3,0
    135a:	bbd9                	j	1130 <vprintf+0x4a>
          s = "(null)";
    135c:	00001917          	auipc	s2,0x1
    1360:	9bc90913          	addi	s2,s2,-1604 # 1d18 <malloc+0x8b0>
        for(; *s; s++)
    1364:	02800593          	li	a1,40
    1368:	b7c5                	j	1348 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    136a:	8bce                	mv	s7,s3
      state = 0;
    136c:	4981                	li	s3,0
    136e:	b3c9                	j	1130 <vprintf+0x4a>
    1370:	64a6                	ld	s1,72(sp)
    1372:	79e2                	ld	s3,56(sp)
    1374:	7a42                	ld	s4,48(sp)
    1376:	7aa2                	ld	s5,40(sp)
    1378:	7b02                	ld	s6,32(sp)
    137a:	6be2                	ld	s7,24(sp)
    137c:	6c42                	ld	s8,16(sp)
    137e:	6ca2                	ld	s9,8(sp)
    }
  }
}
    1380:	60e6                	ld	ra,88(sp)
    1382:	6446                	ld	s0,80(sp)
    1384:	6906                	ld	s2,64(sp)
    1386:	6125                	addi	sp,sp,96
    1388:	8082                	ret

000000000000138a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    138a:	715d                	addi	sp,sp,-80
    138c:	ec06                	sd	ra,24(sp)
    138e:	e822                	sd	s0,16(sp)
    1390:	1000                	addi	s0,sp,32
    1392:	e010                	sd	a2,0(s0)
    1394:	e414                	sd	a3,8(s0)
    1396:	e818                	sd	a4,16(s0)
    1398:	ec1c                	sd	a5,24(s0)
    139a:	03043023          	sd	a6,32(s0)
    139e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    13a2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    13a6:	8622                	mv	a2,s0
    13a8:	d3fff0ef          	jal	10e6 <vprintf>
}
    13ac:	60e2                	ld	ra,24(sp)
    13ae:	6442                	ld	s0,16(sp)
    13b0:	6161                	addi	sp,sp,80
    13b2:	8082                	ret

00000000000013b4 <printf>:

void
printf(const char *fmt, ...)
{
    13b4:	711d                	addi	sp,sp,-96
    13b6:	ec06                	sd	ra,24(sp)
    13b8:	e822                	sd	s0,16(sp)
    13ba:	1000                	addi	s0,sp,32
    13bc:	e40c                	sd	a1,8(s0)
    13be:	e810                	sd	a2,16(s0)
    13c0:	ec14                	sd	a3,24(s0)
    13c2:	f018                	sd	a4,32(s0)
    13c4:	f41c                	sd	a5,40(s0)
    13c6:	03043823          	sd	a6,48(s0)
    13ca:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    13ce:	00840613          	addi	a2,s0,8
    13d2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    13d6:	85aa                	mv	a1,a0
    13d8:	4505                	li	a0,1
    13da:	d0dff0ef          	jal	10e6 <vprintf>
}
    13de:	60e2                	ld	ra,24(sp)
    13e0:	6442                	ld	s0,16(sp)
    13e2:	6125                	addi	sp,sp,96
    13e4:	8082                	ret

00000000000013e6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    13e6:	1141                	addi	sp,sp,-16
    13e8:	e422                	sd	s0,8(sp)
    13ea:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    13ec:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    13f0:	00002797          	auipc	a5,0x2
    13f4:	c107b783          	ld	a5,-1008(a5) # 3000 <freep>
    13f8:	a02d                	j	1422 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    13fa:	4618                	lw	a4,8(a2)
    13fc:	9f2d                	addw	a4,a4,a1
    13fe:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1402:	6398                	ld	a4,0(a5)
    1404:	6310                	ld	a2,0(a4)
    1406:	a83d                	j	1444 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1408:	ff852703          	lw	a4,-8(a0)
    140c:	9f31                	addw	a4,a4,a2
    140e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1410:	ff053683          	ld	a3,-16(a0)
    1414:	a091                	j	1458 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1416:	6398                	ld	a4,0(a5)
    1418:	00e7e463          	bltu	a5,a4,1420 <free+0x3a>
    141c:	00e6ea63          	bltu	a3,a4,1430 <free+0x4a>
{
    1420:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1422:	fed7fae3          	bgeu	a5,a3,1416 <free+0x30>
    1426:	6398                	ld	a4,0(a5)
    1428:	00e6e463          	bltu	a3,a4,1430 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    142c:	fee7eae3          	bltu	a5,a4,1420 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1430:	ff852583          	lw	a1,-8(a0)
    1434:	6390                	ld	a2,0(a5)
    1436:	02059813          	slli	a6,a1,0x20
    143a:	01c85713          	srli	a4,a6,0x1c
    143e:	9736                	add	a4,a4,a3
    1440:	fae60de3          	beq	a2,a4,13fa <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1444:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1448:	4790                	lw	a2,8(a5)
    144a:	02061593          	slli	a1,a2,0x20
    144e:	01c5d713          	srli	a4,a1,0x1c
    1452:	973e                	add	a4,a4,a5
    1454:	fae68ae3          	beq	a3,a4,1408 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1458:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    145a:	00002717          	auipc	a4,0x2
    145e:	baf73323          	sd	a5,-1114(a4) # 3000 <freep>
}
    1462:	6422                	ld	s0,8(sp)
    1464:	0141                	addi	sp,sp,16
    1466:	8082                	ret

0000000000001468 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1468:	7139                	addi	sp,sp,-64
    146a:	fc06                	sd	ra,56(sp)
    146c:	f822                	sd	s0,48(sp)
    146e:	f426                	sd	s1,40(sp)
    1470:	ec4e                	sd	s3,24(sp)
    1472:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1474:	02051493          	slli	s1,a0,0x20
    1478:	9081                	srli	s1,s1,0x20
    147a:	04bd                	addi	s1,s1,15
    147c:	8091                	srli	s1,s1,0x4
    147e:	0014899b          	addiw	s3,s1,1
    1482:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1484:	00002517          	auipc	a0,0x2
    1488:	b7c53503          	ld	a0,-1156(a0) # 3000 <freep>
    148c:	c915                	beqz	a0,14c0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    148e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1490:	4798                	lw	a4,8(a5)
    1492:	08977a63          	bgeu	a4,s1,1526 <malloc+0xbe>
    1496:	f04a                	sd	s2,32(sp)
    1498:	e852                	sd	s4,16(sp)
    149a:	e456                	sd	s5,8(sp)
    149c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    149e:	8a4e                	mv	s4,s3
    14a0:	0009871b          	sext.w	a4,s3
    14a4:	6685                	lui	a3,0x1
    14a6:	00d77363          	bgeu	a4,a3,14ac <malloc+0x44>
    14aa:	6a05                	lui	s4,0x1
    14ac:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    14b0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    14b4:	00002917          	auipc	s2,0x2
    14b8:	b4c90913          	addi	s2,s2,-1204 # 3000 <freep>
  if(p == SBRK_ERROR)
    14bc:	5afd                	li	s5,-1
    14be:	a081                	j	14fe <malloc+0x96>
    14c0:	f04a                	sd	s2,32(sp)
    14c2:	e852                	sd	s4,16(sp)
    14c4:	e456                	sd	s5,8(sp)
    14c6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    14c8:	00003797          	auipc	a5,0x3
    14cc:	b4878793          	addi	a5,a5,-1208 # 4010 <base>
    14d0:	00002717          	auipc	a4,0x2
    14d4:	b2f73823          	sd	a5,-1232(a4) # 3000 <freep>
    14d8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    14da:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    14de:	b7c1                	j	149e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    14e0:	6398                	ld	a4,0(a5)
    14e2:	e118                	sd	a4,0(a0)
    14e4:	a8a9                	j	153e <malloc+0xd6>
  hp->s.size = nu;
    14e6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    14ea:	0541                	addi	a0,a0,16
    14ec:	efbff0ef          	jal	13e6 <free>
  return freep;
    14f0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    14f4:	c12d                	beqz	a0,1556 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    14f6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    14f8:	4798                	lw	a4,8(a5)
    14fa:	02977263          	bgeu	a4,s1,151e <malloc+0xb6>
    if(p == freep)
    14fe:	00093703          	ld	a4,0(s2)
    1502:	853e                	mv	a0,a5
    1504:	fef719e3          	bne	a4,a5,14f6 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    1508:	8552                	mv	a0,s4
    150a:	a3fff0ef          	jal	f48 <sbrk>
  if(p == SBRK_ERROR)
    150e:	fd551ce3          	bne	a0,s5,14e6 <malloc+0x7e>
        return 0;
    1512:	4501                	li	a0,0
    1514:	7902                	ld	s2,32(sp)
    1516:	6a42                	ld	s4,16(sp)
    1518:	6aa2                	ld	s5,8(sp)
    151a:	6b02                	ld	s6,0(sp)
    151c:	a03d                	j	154a <malloc+0xe2>
    151e:	7902                	ld	s2,32(sp)
    1520:	6a42                	ld	s4,16(sp)
    1522:	6aa2                	ld	s5,8(sp)
    1524:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    1526:	fae48de3          	beq	s1,a4,14e0 <malloc+0x78>
        p->s.size -= nunits;
    152a:	4137073b          	subw	a4,a4,s3
    152e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1530:	02071693          	slli	a3,a4,0x20
    1534:	01c6d713          	srli	a4,a3,0x1c
    1538:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    153a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    153e:	00002717          	auipc	a4,0x2
    1542:	aca73123          	sd	a0,-1342(a4) # 3000 <freep>
      return (void*)(p + 1);
    1546:	01078513          	addi	a0,a5,16
  }
}
    154a:	70e2                	ld	ra,56(sp)
    154c:	7442                	ld	s0,48(sp)
    154e:	74a2                	ld	s1,40(sp)
    1550:	69e2                	ld	s3,24(sp)
    1552:	6121                	addi	sp,sp,64
    1554:	8082                	ret
    1556:	7902                	ld	s2,32(sp)
    1558:	6a42                	ld	s4,16(sp)
    155a:	6aa2                	ld	s5,8(sp)
    155c:	6b02                	ld	s6,0(sp)
    155e:	b7f5                	j	154a <malloc+0xe2>
