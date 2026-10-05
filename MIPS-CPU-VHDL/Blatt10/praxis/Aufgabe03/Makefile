COMPILE  := proc_config.vhd flashRAM.vhd mipsISA.vhd leftShifter.vhd signExtend.vhd adder_1bit.vhd alu_1bit.vhd aluCtrlExt.vhd mipsAlu.vhd mipsCtrlFsm.vhd addrDecoder.vhd reg.vhd regFile.vhd bin2Char.vhd mipsCpu_mc.vhd mipsCpu_mc_ref.vhd mipsCpu_mc_tb.vhd
SIMULATE := mipsCpu_mc_tb

OBJDUMP  := ../../../tools/ROrgPrLLVM/llvm-objdump
OBJCOPY  := ../../../tools/ROrgPrLLVM/llvm-objcopy
CC       := ../../../tools/ROrgPrLLVM/clang-16
LD       := ../../../tools/ROrgPrLLVM/ld.lld

all: ghdl

-include ../../../tools/ghdl.mk
-include ../../../tools/gtkwave.mk

%.mif: $(GHDLWORKDIR)/%.pad.bin %.objdump
	od $< -t x4 -w4 -v -An --endian=little | sed 's/^ //' > $@

.PRECIOUS: %.objdump
.PHONY: %.objdump
%.objdump: $(GHDLWORKDIR)/%.out
	$(OBJDUMP) -S -x $< > $@

$(GHDLWORKDIR)/%.pad.bin: $(GHDLWORKDIR)/%.bin proc_config.vhd
	$(eval TMP := $(shell grep -E "constant NUM_RAM_ELEMENTS : integer := [[:digit:]]+;" proc_config.vhd | sed 's/[[:space:]]*constant NUM_RAM_ELEMENTS : integer := \([[:digit:]]*\);/\1/'))
	$(eval TMP := $(shell echo $$(( $(TMP) * 4 )) ))
	dd if=/dev/zero of=$@ bs=1 count=$(TMP)
	dd if=$< of=$@ conv=notrunc

$(GHDLWORKDIR)/%.bin: $(GHDLWORKDIR)/%.out
	$(OBJCOPY) $< -O binary $@

$(GHDLWORKDIR)/%.out: $(GHDLWORKDIR)/%.o linker.ld
	$(LD) $< -Tlinker.ld -o $@

$(GHDLWORKDIR)/%.o: %
	mkdir -p $(GHDLWORKDIR)
	$(CC) -c -ffreestanding -nostdlib --target=mipsel-none-eabi -O0 -fno-stack-protector $< -o $@
