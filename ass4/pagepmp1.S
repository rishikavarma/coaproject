
#sv39 supports 2Mib pages by making vpn[0] also as offset(which is set by hardware).
# This is implemented as follows.

#starting va at 00010000000.(as it is same as 10010000 va due to 2 mib pages)
# vpn[1]=010000000 =>in decimal it is 128
# vpn[2]=000000000 =>0

#root page table is at 0x10020000
#Level 1 Page Table = 0x10021000
# ppn at address 0x10020000+8*0=0x10020000 must be 0x10021(pointer to level 1), v=1 and x,r,w=0
#at 0x10021000+8*0x40=0x10021400 ppn must be 0x10000000(identical mapping)
#this is leaf so v=1,x,r,w=1.

_start:

#to load program at 0x10010000 change to this value in link.ld file.

#setting pmpaddr to protect machine module

la	t0,_start
srli	t0,t0,0x2
csrw	pmpaddr0,t0
	
la	t0,_smodule
srli	t0,t0,0x2
csrw	pmpaddr1,t0

li	t0,0xfffffffffff
srli	t0,t0,0x2
csrw	pmpaddr2,t0

#setting pmp0cfg, pmp1cfg, pmp2cfg

csrs pmpcfg0,x0

li t0, 0x0f080f
csrw pmpcfg0,t0

li	sp,0x10010900
la	t0,_mtrapentry
csrw	mtvec,t0

#va is 10000000

li t0, 0x10020000
li t1, 0x4008441
sd t1,0(t0)

li t0, 0x10021400
li t1, 0x400004f
sd t1,0(t0)

#page mode =8

addi	t1,x0,8
slli	t1,t1,60

#giving ppn value

li t2,0x10020000
srli t2,t2,12
or t1, t2, t1
csrw satp, t1




#setting mpp bits which are 7th and 8th bits of mstatus to supervisor mode

li	t0, 0x1800
csrrc	zero,mstatus,t0 

li	t0,0x0800  #setting mpp to 01
csrs	mstatus, t0


#entering s mode

la	t0,_smodule
csrw	mepc,t0
mret  


endhere:

#random instructions to check whether m mode is protected

mv	t2,x0
addi	t2,t2,7

ebreak

_smodule:


#random calculations

mv	x5,x0
addi	t0,x0,5

#jump to machine mode code to check if it is protected

j	endhere



.p2align 2
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

#check if it is due to protected and if so ebreak

addi	t0,x0,1
csrr	t2,mcause

bne	t0,t2,nxt1
ebreak

nxt1:

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

