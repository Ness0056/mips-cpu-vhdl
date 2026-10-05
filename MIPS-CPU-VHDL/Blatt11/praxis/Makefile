TOP := mipsCpu_mc_wrapper
COMPILE := \
  proc_config.vhd flashRAM.vhd mipsISA.vhd mipsCtrlFsm.vhd aluCtrlExt.vhd \
  reg.vhd addrDecoder.vhd regFile.vhd leftShifter.vhd signExtend.vhd \
  adder_1bit.vhd alu_1bit.vhd mipsAlu.vhd bin2Char.vhd mipsCpu_mc.vhd \
  btnDebounce.vhd mipsCpu_mc_wrapper.vhd
XDC     := mipsCpu_mc_wrapper.xdc

FAMILY  := artix7
PART    := xc7a35tcpg236-1
BOARD   := basys3

DBPART = $(shell echo $(PART) | sed -e 's/-[0-9]//g')

GHDLWORKDIR := ghdl-work
REPORTDIR := reports
GHDLPARAM := --std=08 -fsynopsys -frelaxed --workdir=$(GHDLWORKDIR)
SIMLIBPATH := ../../tools/ROrgPrSimLib++/
SIMLIBPARAM := -P$(SIMLIBPATH)

GHDLDEPS := $(foreach FILE,$(COMPILE),$(GHDLWORKDIR)/$(basename $(FILE)).o)

XC7FRAMES2BIT ?= openxc7.xc7frames2bit
FASTM2FRAMES ?= openxc7.fasm2frames
NEXTPNR_XILINX ?= openxc7.nextpnr-xilinx
YOSYS ?= yosys
GHDL ?= ghdl

# We want the build to fail on error, despite the "| tee"
SHELL=/bin/bash -o pipefail
# We need a slightly newer version of GHDL...
export PATH := /opt/rorgpr/ghdl/bin/:$(PATH)

NEXTPNR_XILINX_DIR ?= /snap/openxc7/current/opt/nextpnr-xilinx
NEXTPNR_XILINX_PYTHON_DIR ?= $(NEXTPNR_XILINX_DIR)/python
PRJXRAY_DB_DIR ?= $(NEXTPNR_XILINX_DIR)/external/prjxray-db
CHIPDB ?= /opt/rorgpr/openxc7/chipdb/$(FAMILY)/$(DBPART).bin

all: $(TOP).bit

FMT_BOLD := $(shell tput bold)
FMT_NORMAL := $(shell tput sgr0)

$(TOP).bit: $(GHDLWORKDIR)/$(TOP).frm
	@echo "$(FMT_BOLD)Generating bitstream and writing it to \"$@\"...$(FMT_NORMAL)"
	$(XC7FRAMES2BIT) --part_file $(PRJXRAY_DB_DIR)/$(FAMILY)/$(PART)/part.yaml --part_name $(PART) --frm_file $< --output_file $@

$(GHDLWORKDIR)/$(TOP).frm: $(GHDLWORKDIR)/$(TOP).fasm
	$(FASTM2FRAMES) --part $(PART) --db-root $(PRJXRAY_DB_DIR)/$(FAMILY) $< $@

$(GHDLWORKDIR)/$(TOP).fasm: $(GHDLWORKDIR)/$(TOP).json $(CHIPDB)
	@echo "$(FMT_BOLD)Running Place and Route...$(FMT_NORMAL)"
	$(NEXTPNR_XILINX) --chipdb $(CHIPDB) --xdc $(XDC) --json $< --fasm $@ 2>&1 | tee $(REPORTDIR)/pnr.log

YOSYS_SYNTH_COMMAND=\
  synth_xilinx -flatten -abc9 -arch xc7 -top $(TOP) -run :map_cells; \
  log; log ROrgPr: Cleaning up design to prevent out-of-memory during IOPADMAP pass.; \
  clean -purge; \
  synth_xilinx -flatten -abc9 -arch xc7 -top $(TOP) -run map_cells:

$(GHDLWORKDIR)/$(TOP).json: $(GHDLWORKDIR)/$(TOP).v
	@echo "$(FMT_BOLD)Running synthesis (2/2)...$(FMT_NORMAL)"
	$(YOSYS) -p "$(YOSYS_SYNTH_COMMAND); write_json $@" $< 2>&1 | tee $(REPORTDIR)/synth_yosys.log

$(GHDLWORKDIR)/$(TOP).v: $(GHDLDEPS) | $(REPORTDIR)
	@echo "$(FMT_BOLD)Running synthesis (1/2)...$(FMT_NORMAL)"
	$(GHDL) synth $(GHDLPARAM) $(SIMLIBPARAM) --out=verilog $(TOP) 2>&1 >$@ | tee $(REPORTDIR)/synth_ghdl.log

$(GHDLWORKDIR):
	mkdir -p $(GHDLWORKDIR)
$(REPORTDIR):
	mkdir -p $(REPORTDIR)

$(GHDLWORKDIR)/%.o: %.vhd | $(GHDLWORKDIR) ghdlcheck
	@echo "$(FMT_BOLD)Analysing \"$<\"...$(FMT_NORMAL)"
	$(GHDL) analyse $(GHDLPARAM) $(SIMLIBPARAM) $< 2>&1

.PHONY: clean
clean:
	rm -rf $(GHDLWORKDIR) $(REPORTDIR) $(TOP).bit

ghdlcheck: precompile

precompile:
	@echo ===============================
	@echo Building ROrgPrSimLib.
	@echo Errors here are most likely never your fault.
	@echo Please report them in the ISIS forum or directly to rorgpr@aes.tu-berlin.de.
	@echo "cd $(SIMLIBPATH) && ./prepare.sh"
	@cd $(SIMLIBPATH) && ./prepare.sh || (echo "ROrgPrSimLib build failed. Please try using \"make cleanlib\" and them \"make clean all\" again." && exit 1)
	@echo Finished building ROrgPrSimLib.
	@echo ===============================
cleanlib:
	@echo ===============================
	@echo Cleaning ROrgPrSimLib.
	cd $(SIMLIBPATH) && ./cleanup.sh
	@echo Finished cleaning ROrgPrSimLib.
	@echo ===============================
