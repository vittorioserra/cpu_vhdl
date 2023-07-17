.global main
main:
	li s0, 0x77770000
main_loop:
	lw t0, 0(s0)
    andi t1, t0, 0x80
    bnez t1, main_loop_buttons
    srli t0, t0, 8
main_loop_buttons:
    sw t0, 0(s0)
    j main_loop