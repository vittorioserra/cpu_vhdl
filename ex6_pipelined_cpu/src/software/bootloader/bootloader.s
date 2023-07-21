.section .init
.global _start
_start:
    la sp, __stack_top
    j main
    