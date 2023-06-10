main:
	addi x1, zero, 1
	addi x2, zero, 1

loop:
	add x3, x2, x1
	add x1, zero, x2
        add x2, zero, x3
        jal zero, loop

