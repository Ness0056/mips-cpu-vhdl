# Project Overview

This repository documents the incremental implementation of a MIPS-style processor in VHDL.

## Architecture path

1. **Combinational logic** — gates, multiplexers, comparison logic
2. **Datapath utilities** — sign extension, shifting, arithmetic components
3. **Sequential logic** — D flip-flops, registers, RAM
4. **Register subsystem** — address decoder and register file
5. **ALU** — 1-bit slices combined into a MIPS ALU
6. **Control path** — opcode decoding and ALU control
7. **Single-cycle processor** — datapath + control + instruction/data memories
8. **Multi-cycle processor** — FSM-based control and staged execution
9. **FPGA integration** — wrapper and Basys 3 constraints

## Portfolio entry point

For a quick code review, start with:

- `Blatt08/praxis/Aufgabe02/mipsCpu.vhd`
- `Blatt08/praxis/Aufgabe02/mipsCpu_tb.vhd`
- `Blatt10/praxis/Aufgabe03/mipsCpu_mc.vhd`
- `Blatt10/praxis/Aufgabe03/mipsCtrlFsm.vhd`
- `Blatt11/praxis/mipsCpu_mc_wrapper.vhd`
