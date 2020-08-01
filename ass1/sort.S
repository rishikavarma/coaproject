_start:
	la    x5, _data1   # setting sp to point to 0x10011000
        lwu   sp, 0(x5)
        mv    x3,x0	   # x3=i
        mv    x4,x0	#x4=j
        mv    x11,x0	#n-i value
        mv    x6,x0	#array address
	mv    x9,x0	#arr[j]
	mv    x10,x0 	#arr[j+1]
        lw    x7,4(x5) #value of n
        jal   ra,_sort
	ebreak
	j     _start



_sort:

        addi  sp,sp,-32    # sp= sp-32
        sd    ra,24(sp)    # STORE return Address,    Memory[24+sp]=ra
        sd    s0,16(sp)    # STORE s0, Memory[16+sp]=s0
        addi  s0,sp,32     # s0=sp+32 Frame pointer

loop1:	
	addi	x12,x7,-1
	beq     x12,x3,fend
	mv	x4,x0
	sub	x11,x7,x3
	addi	x11,x11,-1
loop2:
	beq	x4,x11,l2end
	mv	x6,x0
	addi	x6,x6,4
	mul	x6,x6,x4
	add	x6,x6,x5
	addi	x6,x6,8
	lw	x9,0(x6)	
	lw	x10,4(x6)

	ble	x9,x10,ifend
	sw	x9,4(x6)
	sw	x10,0(x6)
ifend:
	addi	x4,x4,1
	j	loop2	
l2end:
	addi	x3,x3,1
	j	loop1

fend:
        ld    ra,24(sp)    # ra = Memory[sp+24]
        ld    s0,16(sp)    # s0 = Memory[sp+16]
        addi  sp,sp,32     # sp=sp+32
        ret                # return to main function




    .section .data         # data section starts
    .p2align 0x2           # aligned to eight bytes
    _data1:
    .word 0x10011000       # First data in data section
    .word 0x5             # n
    .word 0x5
    .word 0x4
    .word 0x3
    .word 0x2
    .word 0x1

