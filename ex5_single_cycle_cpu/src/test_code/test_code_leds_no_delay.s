setup:
	addi x1, zero, 1
	addi x2, zero, 1
    addi x14, zero, 4
    addi x10, zero, 1
    slli x11, x10, 13
    slli x15, x14, 2
    sw   x2, 0(x15)
    
loop:
	lw  x2, 0(x15)
	add x3, x2, x1
	add x1, zero, x2
    sw  x3, 0(x15)
    sw  x3, 0(x11)
    jal zero, loop
