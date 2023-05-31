C++ Code

int main()
{
    int s = 0;
    for (int i = 1 ; i <= 100 ; i++)
    {
        s += i;
    }
    return s;
}

RV32GC Assembly

main-0x2:
 nop
    R_RISCV_ALIGN *ABS*+0x2
main:
 addi	sp,sp,-32
 sw	ra,28(sp)
 sw	s0,24(sp)
 addi	s0,sp,32
 li	a0,0
 sw	a0,-12(s0)
 sw	a0,-16(s0)
 li	a0,1
 sw	a0,-20(s0)
 j	1a <main+0x18>
    R_RISCV_JAL .LBB0_1
.LBB0_1:
 lw	a1,-20(s0)
 li	a0,100
 blt	a0,a1,26 <.LBB0_1+0x8>
    R_RISCV_BRANCH .LBB0_4
 j	2a <.LBB0_1+0xc>
    R_RISCV_JAL .LBB0_2
.LBB0_2:
 lw	a1,-20(s0)
 lw	a0,-16(s0)
 add	a0,a0,a1
 sw	a0,-16(s0)
 j	3c <.LBB0_2+0xe>
    R_RISCV_JAL .LBB0_3
.LBB0_3:
 lw	a0,-20(s0)
 addi	a0,a0,1
 sw	a0,-20(s0)
 j	4a <.LBB0_3+0xa>
    R_RISCV_JAL .LBB0_1
.LBB0_4:
 lw	a0,-16(s0)
 lw	ra,28(sp)
 lw	s0,24(sp)
 addi	sp,sp,32
 ret