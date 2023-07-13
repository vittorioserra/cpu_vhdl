TARGET := bootloader
SOURCES := $(wildcard *.cpp)
SOURCES += $(wildcard *.s)
OBJECTS := $(patsubst %.cpp,%.o,$(SOURCES))
OBJECTS := $(patsubst %.s,%.o,$(OBJECTS))

COMPILEFLAGS := -march=rv32i -mabi=ilp32 -O0

$(TARGET) : $(TARGET).elf
	riscv64-unknown-elf-objcopy -O ihex $^ $@.hex
	del -rf *.o
	del -rf $(TARGET).elf
	riscv64-unknown-elf-objdump -D -m riscv $@.hex

$(TARGET).elf : $(OBJECTS)
	riscv64-unknown-elf-ld -o $@ -T ../toolchain/riscv32.ld $^
	riscv64-unknown-elf-objcopy --remove-section .eh_frame $@

%.o : %.s
	riscv64-unknown-elf-gcc $(COMPILEFLAGS) -c -o $@ $<
	
%.o : %.cpp
	riscv64-unknown-elf-gcc $(COMPILEFLAGS) -c -o $@ $<
