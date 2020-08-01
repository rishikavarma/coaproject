/***************************************************************************
* Project           			:  Learn with Shakti
* Name of the file	     		:  mtime_trap.S
* Created date			        :  
* Brief Description of file             :  Timer Interrupt Handling. 
* Name of Author    	                :  Rishika Varma K
* mail ID                               :  

    Copyright (C) 2020  IIT Madras. All rights reserved.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

***************************************************************************/
# set the mtvec lsb to 1. vector trap will be enabled.
# on mtime > mtimecmp, auto matically timer interrupt will happen
# hardware jumps to base + 4*mcause address location (only for interrupts)


# Below are address of mtime and mtimecmp registers in spike simulator
#define mtime  0x200bff8
#define mtimecmp 0x2004000


_start:	
#intialize t4,t3,t2,t6 to 0
mv t4,x0
mv t2,x0
mv t3,x0
mv t6,x0

#resetting mtip bit to zero. pending timer interrupt is cleared.
# so that any earlier timer interrupt is handled well
li t6,mtimecmp    # t6 has mtimecmp reg location
andi t3,t3,0
addi t3,t3,-1 #reg t6 set to -1
sw t3, 0(t6) # just increment the mtimecmp.

la  x17,_data1
lw sp, 0(x17)#setting sp

#setting up vector trap mode
la t0, vtrap_entry 	# load temp register t0 with vtrap_entry
csrw mtvec,t0 		# write mtve with t0 value. This will set mtvec to trap_entry
li t1, 0x1  		#setting lsb to 1
csrs mtvec,t1 		#enable vector based interrupt, by setting lsb of mtvec to 1

#setting up timer interrupt
#enabling interrupts
li      t0, 8
csrrs   zero, mstatus, t0 #enable global interrupt (MIE bit)
li      t0, 0x80
csrrs   zero, mie, t0  # enable machine time interrupt
 

#we are doing mtimecmp = mtime + del
#del is a time period after which we need an timer interrupt

li t6,mtimecmp    # t6 has mtimecmp reg location

# reg t4 has the del value
#slli t4, t4,63
lui t4, 0x50000
addi t4, t4, 999

li t2,mtime      #reg t2 has mtime location, mtime is a 64 bit reg
ld t3, 0(t2)    # reg t3 has mtime reg value

add t3,t4,t3   # adding del value to reg t3
sd t3, 0(t6)   # store t3 value in mtimecmp reg location

#store 0 in upper 32 bit of mtimecmp
andi t3,t3,0
#addi t3,t3,1
sw t3, 4(t6)  # store 0 in mtimecmp + 4





end:
csrr t4, mip
beqz t4, end   # infinite loop

loop: j loop


.p2align 2
vtrap_entry:      
j u_sw_int_handler
nop
j s_sw_int_handler
nop
j h_sw_int_handler
nop
j m_sw_int_handler
nop
j u_ti_int_handler
nop
j s_ti_int_handler
nop
j h_ti_int_handler
nop
j m_ti_int_handler #machine mode timer interrupt handler. H/W jumps here whenever machine timer interrupt happens
nop 
j u_ex_int_handler
nop
j s_ex_int_handler
nop
j h_exint_handler
nop
j m_ex_int_handler
nop

u_sw_int_handler:
j end

s_sw_int_handler:
j end

h_sw_int_handler:
j end

m_sw_int_handler:
j end

u_ti_int_handler:
j end

s_ti_int_handler:
j end

h_ti_int_handler:
j end

m_ti_int_handler:

#increment error count in data

la	x17,_data1
lw	t1,4(x17)
addi	t1,t1,1
sw	t1,4(x17)

#clearing mtip bit
# t6 has mtimecmp reg location
mv t3,x0
addi t3,t3,-1 # writing -1 to reg t3
sd t3, 0(t6) # just increment the mtimecmp + 4 location value by 1.
j end

u_ex_int_handler:
j end

s_ex_int_handler:
j end

h_exint_handler:
j end

m_ex_int_handler:
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
_data1:
.word 	0x10011000
.word	0

