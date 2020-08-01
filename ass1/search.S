_start:
	la    x5, _data1   # setting sp to point to 0x10011000
        lwu   sp, 0(x5)
        mv    x3,x0	#l value 
        mv    x4,x0	#r value
        mv    x11,x0	
        mv    x6,x0	#m  
	mv    x9,x0	# index of given number
        lw    x7,4(x5) #x7=value of n
	addi  x4,x7,-1
	lw    x10,8(x5) #value to be searched
	addi  x9,x9,-1
        jal   ra,_search
	addi  x11,x11,4
	mul   x11,x11,x7
	add   x11,x11,x5
	addi  x11,x11,12
	sw    x9,0(x11)
	ebreak
	j     _start


_search:

        addi  sp,sp,-32    # sp= sp-32
        sd    ra,24(sp)    # STORE return Address,    Memory[24+sp]=ra
        sd    s0,16(sp)    # STORE s0, Memory[16+sp]=s0
        addi  s0,sp,32     # s0=sp+32 Frame pointer	

	blt    x4,x3,fend

	add	x6,x3,x4
	srai	x6,x6,1
	mv	x12,x0
	addi	x12,x12,4
	mul	x12,x12,x6
	add	x12,x12,x5
	addi	x12,x12,12
	lw	x13,0(x12)
	
	bne	x13,x10,le1
	mv	x9,x6
	j	fend
le1:
	ble	x13,x10,le2
	addi	x4,x6,-1
	jal	ra,_search
	j	fend
le2:
	addi	x3,x6,1
	jal	ra,_search
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
    .word 0x2
    .word 0x1
    .word 0x2
    .word 0x3
    .word 0x4
    .word 0x5
    .word 0x0

