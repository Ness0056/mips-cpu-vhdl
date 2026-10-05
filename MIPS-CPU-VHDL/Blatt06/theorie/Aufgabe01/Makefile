COMPILE  := fulladd.vhd adder.vhd
SIMULATE := adder

all: ghdl_compile

-include ../../../tools/ghdl.mk

ghdl_compile: | $(GHDLWORKDIR)/e~$(SIMULATE).o
	@echo
	@echo ALLES ERFOLGREICH KOMPILIERT
	@echo
