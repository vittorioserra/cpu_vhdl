main:
addi a1, zero, 1
addi a2, zero, 1

li a5, 0x2000

loop:

    add a3, a1, a2
    add a1, zero, (a2)
    add a2, zero, (a3)
    sw a1, 0(a5)
    addi a5, zero, 4

j loop
