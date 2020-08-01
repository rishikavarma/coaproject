

_start:

la	x17,_data1
lw	sp,0(x17)

#changing m and s mode trap handler addresses

la	t0,_mtrapentry
csrw	mtvec,t0


la	t0,_strapentry
csrw	stvec,t0

#delegating all possible traps to supervisor mode

mv	t0,x0
li	t0,0xfffff
csrrs	zero,medeleg,t0


#a0 indicates the function called.
#for bite a0=1,cite a0=2,kite a0=3
#call using ecall

li	a0,1
ecall

li	a0,2
ecall

li	a0,3
ecall

ebreak
end:
j	end


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

#in case it is an ecall from machine mode go to fcall to manually delegate it to s mode 

addi	t0,x0,11
csrr	t1,mcause

beq	t0,t1,fcall
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

fcall:

#change sepc and scause to mepc and mcause values

csrr	t0,mcause
csrw	scause,t0

csrr	t0,mepc
csrw	sepc,t0

#change mpp to 01 and mepc to syscall and then jump using mret

li	t0, 0x1800
csrrc	zero,mstatus,t0 

li	t0,0x800  #setting mpp to 01
csrrs	zero,mstatus, t0

la	t0,syscall
csrw	mepc,t0


mret

.p2align 0x2
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

#check if it is u or s ecall and if so go to syscall

addi	t0,x0,8
addi	t1,x0,9

csrr	t2,scause

beq	t0,t2,syscall
beq	t1,t2,syscall

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

syscall:

#jump to appropriate label based on a0 value

addi	t0,x0,1
addi	t1,x0,2
addi	t2,x0,3

bne	t0,a0,next
jal	barg
next:
bne	t1,a0,next1
jal	carg
next1:
bne	t2,a0,next2
jal	karg
next2:

#change sepc to next instuction

csrr	x7,sepc
addi	x7,x7,4
csrw	sepc,x7

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

barg:

#it is bite which has 3 arguments. as it is less than 5 we can put in a1 a2.. directly.
#bite(10,95,66)

li	a1,10
li	a2,95
li	a3,66

j	bite



carg:

#it is cite which has 2 arguments. as it is less than 5 we can put in a1 a2.. directly.
#cite(23,67)

li	a1,23
li	a2,67

j	cite

karg:

#it is kite which has 14 arguments.
#as it is greater than 5 so we put starting address of data in a1 
#kite (35, 99, 12, 13, 0, 4, 5, 9, 12, 1, 2, 2, 3, 9)

la	a1,_dataofkite
j	kite

bite:
ret

cite:
ret


kite:
ret

.p2align 0x2
_data1:

.word 0x10011000

.p2align 0x2
_dataofkite:

.word 35
.word 99
.word 12
.word 13
.word 0
.word 4
.word 5
.word 9
.word 12
.word 1
.word 2
.word 2
.word 3
.word 9
