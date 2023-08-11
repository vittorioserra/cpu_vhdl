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

    .init ALIGN(4):
    {
       KEEP(*(.init))
    } > RAM

    .text ALIGN(4):
    {
       *(.text)
    } > RAM

    .data ALIGN(4):
    {
       *(.data)
    } > RAM

    .bss ALIGN(4):
    {
       *(.bss)
    } > RAM

    /DISCARD/ :
    {
	     *(.eh_frame .eh_frame.*)
    }

    PROVIDE(__stack_top = ORIGIN(RAM) + LENGTH(RAM));
}