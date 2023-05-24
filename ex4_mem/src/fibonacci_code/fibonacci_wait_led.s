main:
addi a1, zero, 1
addi a2, zero, 1

li a5, 0x00002000
li a6, 0x00000000
li a7, 0xffffffff

j loop

reset_wait_val: 

    li a6, 0x00000000
    li a5, 0x00002000
    
j loop

loop:

    add a3, a1, a2
    add a1, zero, (a2)
    add a2, zero, (a3)
    sw a1, 0(a5)
    addi a5, zero, 4
    
    j wait_loop

j loop

wait_loop:

    addi a6, a6, 1
    beq a6, a7, reset_wait_val
    
j wait_loop   
    
    
