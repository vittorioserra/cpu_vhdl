.global main
main:                       # @ 0x00000008
    addi a1,  sp, -64       # helper fc010593
    fld  fa4,  16(a1)       # 2998   0105b707
    lw   a4,  8(a1)         # 4598   0085a703
    flw  fa4,  8(a1)        # 6598   0085a707
    fsd  fa3, 16(a1)        # a994   00d5b827
    sw a3, 8(a1)            # c594   00d5a423
    fsw fa3, 8(a1)          # e594   00d5a427

    addi sp, sp, -64        # 7139   fc010113
    fld fs0, 16(sp)         # 2442   01013407
    lw s0, 8(sp)            # 4422   00812403
    flw fs0, 8(sp)          # 6422   00812407
    fsd ft1, 16(sp)         # a806   00113827
    sw t1, 8(sp)            # c41a   00612423
    fsw ft1, 8(sp)          # e406   00112427

    addi t0, t0, -4         # 12f1   ffc28293
    li t0, -4               # 52f1   ffc00293
    lui t0, 4               # 6291   000042b7
    srli a4, a4, 6          # 8319   00675713
    srai a4, a4, 6          # 8719   40675713
    andi a4, a4, -4         # 9b71   ffc77713
    sub a4, a4, a3          # 8f15   40d70733
    or a4, a4, a3           # 8f55   00d76733
    and a4, a4, a3          # 8f75   00d77733
    slli t0, t0, 7          # 029e   00729293
    mv t0, t1               # 829a   006002b3
    add t0, t0, t1          # 929a   006282b3
next0:                                
    ebreak                  # 9002   00100073
    beqz a1, next0          # ddfd   fe058fe3
    xor a1, a1, a1          # 8dad   00b5c5b3
    bne a1, zero, next0     # fded   fe059de3
    la t0, next1            # helper 00000297 00c28293
    jalr t0                 # 9282   000280e7
next1:                                
    la t0, next2            # helper 00000297 00c28293
    jr t0                   # 8282   00028067
next2:                                
    j next3                 # a009   0020006f
next3:                                
    jal main                # 3775   fadff0ef
