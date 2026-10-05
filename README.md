# MIPS CPU in VHDL

A progressively developed **MIPS processor implementation in VHDL**

The project starts with fundamental digital building blocks and develops them step by step into a complete CPU design, including an ALU, register file, control logic, memory interfaces, a single-cycle processor, a multi-cycle processor, testbenches, and an FPGA wrapper.

![MIPS CPU architecture](docs/mips-cpu-architecture.png)

## Highlights

- VHDL implementation of reusable digital logic components
- 1-bit ALU building blocks and a complete MIPS ALU
- Register file and address decoding
- Main control unit and ALU control logic
- Single-cycle MIPS CPU integration
- Multi-cycle MIPS CPU with finite-state-machine control
- GHDL-based simulations and testbenches
- Memory initialization for assembly/C programs
- Basys 3 FPGA wrapper and constraints

## Project progression

| Stage | Focus | Key components |
|---|---|---|
| `Blatt00–02` | Logic fundamentals | gates, multiplexers, comparators |
| `Blatt03–04` | Datapath helpers | clock divider, shifter, sign extension, multipliers |
| `Blatt05–06` | State & storage | D flip-flop, registers, RAM, register file, address decoder |
| `Blatt07` | Arithmetic | ALU control, 1-bit ALU, MIPS ALU |
| `Blatt08` | Single-cycle CPU | control unit, datapath integration, CPU testbench |
| `Blatt09–10` | Multi-cycle CPU | FSM control, extended ALU control, program execution |
| `Blatt11` | FPGA integration | CPU wrapper, button debounce, Basys 3 constraints |

## Important files

### Single-cycle CPU

The main single-cycle implementation is located in:

```text
Blatt08/praxis/Aufgabe02/
├── mipsCpu.vhd          # CPU datapath integration
├── mipsCtrl.vhd         # main control unit
├── aluCtrl.vhd          # ALU control
├── mipsAlu.vhd          # arithmetic logic unit
├── regFile.vhd          # register file
├── flashROM.vhd         # instruction memory
├── flashRAM.vhd         # data memory
└── mipsCpu_tb.vhd       # CPU testbench
```

### Multi-cycle CPU

The later multi-cycle implementation is located in:

```text
Blatt10/praxis/Aufgabe03/
├── mipsCpu_mc.vhd       # multi-cycle CPU
├── mipsCtrlFsm.vhd      # FSM-based control unit
├── aluCtrlExt.vhd       # extended ALU control
├── bubblesort.c         # example program
├── memcpy.s             # assembly example
└── clip.s               # assembly example
```

### FPGA integration

```text
Blatt11/praxis/
├── mipsCpu_mc_wrapper.vhd
├── mipsCpu_mc_wrapper.xdc
└── btnDebounce.vhd
```

The wrapper targets a **Digilent Basys 3 / Xilinx Artix-7** FPGA.

## Simulation

Most exercises contain an individual `Makefile` and testbench.

Example:

```bash
cd Blatt08/praxis/Aufgabe02
make
```

The supplied build scripts use **GHDL** for VHDL analysis/simulation. Waveforms can be inspected with GTKWave where supported by the course tooling.

To clean generated simulation files:

```bash
make clean
```

## Repository structure

```text
.
├── Blatt00 ... Blatt11/   # progressive exercise stages
├── docs/                  # project documentation/assets
├── tools/                 # course simulation/build utilities
├── Makefile               # original course setup helpers
└── README.md
```

The original exercise structure is intentionally preserved because later stages reuse components from earlier stages and their Makefiles assume these relative paths.

## Technologies

- **VHDL-2008**
- **GHDL**
- **GTKWave**
- **Make**
- **MIPS ISA concepts**
- **Xilinx Artix-7 / Basys 3**

## What I learned

This project gave me hands-on experience with how a processor is assembled from lower-level digital components. Instead of treating the CPU as one monolithic block, the implementation builds the datapath and control path incrementally and verifies components using dedicated testbenches before integrating them into the full processor.

Key topics included datapath design, control signal generation, ALU design, register-file access, memory interfacing, instruction decoding, branching, finite-state-machine control, simulation, and FPGA-oriented hardware design.



