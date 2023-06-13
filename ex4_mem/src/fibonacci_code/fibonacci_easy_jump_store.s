setup:
    addi x1, zero, 1
    addi x2, zero, 1
    addi x15, zero, -2048
    slli x15, x15, 2
    
loop:
    add x3, x2, x1
    add x1, zero, x2
    add x2, zero, x3
    sw  x3, 0(x15)
    jal zero, loop

