OUTPUT_FORMAT("elf32-littleriscv")
OUTPUT_ARCH(riscv)

MEMORY
{
    RAM (rwx)  : ORIGIN = 0x00000000, LENGTH = 4096 * 4
}

ENTRY(_start)

SECTIONS
{
    . = ORIGIN(RAM);

    .init BLOCK(4):
    {
       KEEP(*(.init))
    } > RAM

    .text BLOCK(4):
    {
       *(.text)
    } > RAM

    .data BLOCK(4):
    {
       *(.data)
    } > RAM

    .bss BLOCK(4):
    {
       *(.bss)
    } > RAM

    /DISCARD/ :
    {
	     *(.eh_frame .eh_frame.*)
    }

    PROVIDE(__stack_top = ORIGIN(RAM) + LENGTH(RAM));
}