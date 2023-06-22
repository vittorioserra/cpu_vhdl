setup:
	addi t0, zero, 1
	addi t1, zero, 1849
	xor t1, t1, t1
	addi t2, zero, 0x00000020
	lui t3, 0xDEAD0
    addi t4, zero, 0xBE
    addi t5, zero, 0xEF
    lui a0, 0x77770
loop:
	bne t0, zero, after_set_one
    addi t0, zero, 1
after_set_one:
	slli t0, t0, 1
    add t1, t1, t0
    blt t1, t2, after_set_zero
	andi t1, t1, 0
after_set_zero:
	sw t1, 0(a0)
	slli t6, t4, 16
    or t6, t6, t3
    or t6, t6, t5
    sub t6, t6, t1
    sra t6, t6, t0
	j loop