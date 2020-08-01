



#in machine mode initially


_start:

#delegate user mode ecall to supervisor mode which is 8th bit in medeleg register

li t0,0x100
csrrs zero,medeleg,t0

#change mtvec and stvec addresses

la	t0,mtrapentry
csrw	mtvec,t0

la	t0,strapentry
csrw	stvec,t0

# give sp value

la	x17,_data1
lw	sp,0(x17)

#setting mpp bits which are 7th and 8th bits of mstatus to supervisor mode

li	t0, 0x1800
csrrc	zero,mstatus,t0 

li	t0,0x800  #setting mpp to 01
csrrs	zero,mstatus, t0

#entering s mode

la	t0,_smode
csrw	mepc,t0
mret  #m->s

#in s mode
_smode:
mv	x3,x0
mv	x4,x0


#setting spp bit to user mode

li      x6, 0x0100
csrc    sstatus, x6    

#entering u mode

la	x6,_umode
csrw	sepc,x6
sret   #s->u

#in u mode

_umode:

mv	x3,x0
mv	x4,x0
ecall   #u->s

end:
j end

.p2align 0x2
mtrapentry:

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

#in case it is an ecall from s mode then random calculations and ebreak

addi	t0,x0,9
csrr	t1,mcause

bne	t0,t1,nxt

addi	t2,x0,4
addi	t2,t2,8
ebreak    #end program in m mode

end1:
j	end1

nxt:
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

.p2align 0x2
strapentry:

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

#check if it is u ecall and if so ecall again to go to m mode

addi	t0,x0,8

csrr	t2,scause

bne	t0,t2,nxt1
ecall   #s->m

nxt1:

jal straphandler

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




.p2align 0x2
_data1:
.word 0x10011000


