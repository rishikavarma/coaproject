
#initially starts from machine mode at 10010000
#s loop page starts at 10011000
#s trap handler page starts at 10012000
#root page table(level 2) at 10020000
#level 1 at 10021000
#level 0 at 10022000
#the link.ld file is set so that _start loads at 10010000

_start:

#enabling pmp for read write and execute protect fro s and u mode

#setting up pmpaddr0,pmpaddr1,pmpaddr2
la	t0,_start
srli	t0,t0,0x2
csrw	pmpaddr0,t0

la	t0,_mtrapentry
srli	t0,t0,0x2
csrw	pmpaddr1,t0

li	t0,0xfffffffffff
srli	t0,t0,0x2
csrw	pmpaddr2,t0

#setting up pmpcfg0 for pmp0cfg, pmp1cfg and pmp2cfg.
#pmp1cfg is r,x,w protected.  Here lock bit is disabled to allow m mode access.
#pmp0cfg ,pmp2cfg are r,x,w enabled

csrs pmpcfg0,x0

li t0, 0x0f080f
csrw pmpcfg0,t0



#setting up starting page in 3 level page table (identically mapped to 10010000)
#vpn[2]=0,vpn[1]=128,vpn[0]=16
#offset to level 2=0*8=0
#offset to level 1=128*8=0x400
#offset to level 0=16*8=0x80

li t0, 0x10020000
li t1, 0x4008401
sd t1,0(t0)

li t0, 0x10021400
li t1, 0x4008801
sd t1,0(t0)

#here dirty bit is enabled so that stack(10010900) which is in the same page can be accessed by s trap handler for writing.

li t0, 0x10022080
li t1, 0x40040cf
sd t1,0(t0)

#initially making wrong s loop page entry at level-0 to create page fault
#this only changes in level zero i.e. vpn[1] and vpn[2] are same as above.
#vpn[0]=17
#offset to level 0=17*8=0x88

li t0, 0x10022088
li t1, 0x0
sd t1,0(t0)

#setting up s trap handler page in 3 level page table (identically mapped to 10012000)
#this only changes in level zero i.e. vpn[1] and vpn[2] are same as above.
#vpn[0]=18
#offset to level 0=18*8=0x90


li t0, 0x10022090
li t1, 0x400484f
sd t1,0(t0)

#setting up translation for 10022000 so as to enable store into 0 level page table in s trap handler
#this only changes in level zero i.e. vpn[1] and vpn[2] are same as above.
#vpn[0]=34
#offset to level 0=34*8=272=0x110

#here also d bit is enabled as witing s involved. 

li t0, 0x10022110
li t1, 0x40088cf
sd t1,0(t0)


li	sp,0x10010900
la	t0,_mtrapentry
csrw	mtvec,t0

la	t0,_strapentry
csrw stvec,t0


#page mode =8

addi	t1,x0,8
slli	t1,t1,60

#giving ppn value

li t2,0x10020000
srli t2,t2,12
or t1, t2, t1
csrw satp, t1

#delegate page fault to supervisor mode
li t0,0x1000
csrw medeleg,t0

#setting mpp bits which are 7th and 8th bits of mstatus to supervisor mode

li	t0, 0x1800
csrrc	zero,mstatus,t0 

li	t0,0x0800  #setting mpp to 01
csrs	mstatus, t0


#entering s mode

la	t0,_smodule
csrw	mepc,t0
mret  



.p2align 0x2
_mtrapentry:


addi	sp,sp,-34*4

#save the context
sw x1, 1*4(sp)
sw x2, 2*4(sp)
sw x3, 3*4(sp)
sw x4, 4*4(sp)
sw x5, 5*4(sp)
sw x6, 6*4(sp)
sw x7, 7*4(sp)
sw x8, 8*4(sp)
sw x9, 9*4(sp)
sw x10, 10*4(sp)
sw x11, 11*4(sp)
sw x12, 12*4(sp)
sw x13, 13*4(sp)
sw x14, 14*4(sp)
sw x15, 15*4(sp)
sw x16, 16*4(sp)
sw x17, 17*4(sp)
sw x18, 18*4(sp)
sw x19, 19*4(sp)
sw x20, 20*4(sp)
sw x21, 21*4(sp)
sw x22, 22*4(sp)
sw x23, 23*4(sp)
sw x24, 24*4(sp)
sw x25, 25*4(sp)
sw x26, 26*4(sp)
sw x27, 27*4(sp)
sw x28, 28*4(sp)
sw x29, 29*4(sp)
sw x30, 30*4(sp)
sw x31, 31*4(sp)

#store mepc and mcause on stack

csrr	x7,mepc
csrr	x8,mcause

sw	x7,32*4(sp)
sw	x8,33*4(sp)


jal mtraphandler

#retreive context
lw x1, 1*4(sp)
lw x2, 2*4(sp)
lw x3, 3*4(sp)
lw x4, 4*4(sp)
lw x5, 5*4(sp)
lw x6, 6*4(sp)
lw x7, 7*4(sp)
lw x8, 8*4(sp)
lw x9, 9*4(sp)
lw x10, 10*4(sp)
lw x11, 11*4(sp)
lw x12, 12*4(sp)
lw x13, 13*4(sp)
lw x14, 14*4(sp)
lw x15, 15*4(sp)
lw x16, 16*4(sp)
lw x17, 17*4(sp)
lw x18, 18*4(sp)
lw x19, 19*4(sp)
lw x20, 20*4(sp)
lw x21, 21*4(sp)
lw x22, 22*4(sp)
lw x23, 23*4(sp)
lw x24, 24*4(sp)
lw x25, 25*4(sp)
lw x26, 26*4(sp)
lw x27, 27*4(sp)
lw x28, 28*4(sp)
lw x29, 29*4(sp)
lw x30, 30*4(sp)
lw x31, 31*4(sp)

addi sp, sp, 32*4

#mcause and mepc values are stored on stack

mret

mtraphandler:


#change mepc to next instuction

csrr	x7,mepc
addi	x7,x7,4
csrw	mepc,x7

ret

.p2align 12
_smodule:



here:	j here

.p2align 12
_strapentry:
addi	sp,sp,-34*4

#save the context
sw x1, 1*4(sp)
sw x2, 2*4(sp)
sw x3, 3*4(sp)
sw x4, 4*4(sp)
sw x5, 5*4(sp)
sw x6, 6*4(sp)
sw x7, 7*4(sp)
sw x8, 8*4(sp)
sw x9, 9*4(sp)
sw x10, 10*4(sp)
sw x11, 11*4(sp)
sw x12, 12*4(sp)
sw x13, 13*4(sp)
sw x14, 14*4(sp)
sw x15, 15*4(sp)
sw x16, 16*4(sp)
sw x17, 17*4(sp)
sw x18, 18*4(sp)
sw x19, 19*4(sp)
sw x20, 20*4(sp)
sw x21, 21*4(sp)
sw x22, 22*4(sp)
sw x23, 23*4(sp)
sw x24, 24*4(sp)
sw x25, 25*4(sp)
sw x26, 26*4(sp)
sw x27, 27*4(sp)
sw x28, 28*4(sp)
sw x29, 29*4(sp)
sw x30, 30*4(sp)
sw x31, 31*4(sp)

#store sepc and scause on stack

csrr	x7,sepc
csrr	x8,scause

sw	x7,32*4(sp)
sw	x8,33*4(sp)

#check if it is page fault


addi	t0,x0,12
csrr	t2,scause

bne	t0,t2,nxt1

#setting up s loop page entry in 3 level page table (identically mapped to 10011000)
#this only changes in level zero i.e. vpn[1] and vpn[2] are same as before.
#vpn[0]=17
#offset to level 0=17*8=0x88
#here d bit is enabled as page could involve writing.

li	t0, 0x10022088
li	t1, 0x40044cf
sd	t1,0(t0)
j	nend

nxt1:
jal straphandler

nend:

#retreive context
lw x1, 1*4(sp)
lw x2, 2*4(sp)
lw x3, 3*4(sp)
lw x4, 4*4(sp)
lw x5, 5*4(sp)
lw x6, 6*4(sp)
lw x7, 7*4(sp)
lw x8, 8*4(sp)
lw x9, 9*4(sp)
lw x10, 10*4(sp)
lw x11, 11*4(sp)
lw x12, 12*4(sp)
lw x13, 13*4(sp)
lw x14, 14*4(sp)
lw x15, 15*4(sp)
lw x16, 16*4(sp)
lw x17, 17*4(sp)
lw x18, 18*4(sp)
lw x19, 19*4(sp)
lw x20, 20*4(sp)
lw x21, 21*4(sp)
lw x22, 22*4(sp)
lw x23, 23*4(sp)
lw x24, 24*4(sp)
lw x25, 25*4(sp)
lw x26, 26*4(sp)
lw x27, 27*4(sp)
lw x28, 28*4(sp)
lw x29, 29*4(sp)
lw x30, 30*4(sp)
lw x31, 31*4(sp)

addi sp, sp, 32*4

#scause and sepc values are stored on stack
sret

straphandler:


#change sepc to next instuction

csrr	x7,sepc
addi	x7,x7,4
csrw	sepc,x7

ret

