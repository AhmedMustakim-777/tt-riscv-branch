[![GDS](../../actions/workflows/gds.yaml/badge.svg)](../../actions/workflows/gds.yaml)
[![Docs](../../actions/workflows/docs.yaml/badge.svg)](../../actions/workflows/docs.yaml)
[![Test](../../actions/workflows/test.yaml/badge.svg)](../../actions/workflows/test.yaml)
[![FPGA](../../actions/workflows/fpga.yaml/badge.svg)](../../actions/workflows/fpga.yaml)

# rv32i RISC-V Branch Condition Unit

## What it does

Evaluates all six RISC-V rv32i branch conditions
BEQ BNE BLT BGE BLTU BGEU. This is the branch
decision logic from a complete rv32imsu RISC-V SoC
implemented in Synopsys DC Shell and ICC2 on sky130A
130nm PDK for EEE-5390C at University of Central Florida.

Works alongside the rv32i ALU tile to demonstrate
the execution stage of the RISC-V pipeline.

## Branch Operations

| func[2:0] | Instruction | Condition         |
|-----------|-------------|-------------------|
| 000       | BEQ         | branch if A == B  |
| 001       | BNE         | branch if A != B  |
| 010       | BLT         | branch if A < B signed   |
| 011       | BGE         | branch if A >= B signed  |
| 100       | BLTU        | branch if A < B unsigned |
| 101       | BGEU        | branch if A >= B unsigned|

## How to test

Set ui_in[7:4] to operand A (0-15).
Set ui_in[3:0] to operand B (0-15).
Set uio_in[2:0] to branch function (0-5).
Read uo_out[0]: 1 = branch taken, 0 = not taken.

Example BEQ 5 == 5 taken:
  ui_in=8'b0101_0101 uio_in=8'b000 uo_out[0]=1

Example BNE 5 != 3 taken:
  ui_in=8'b0101_0011 uio_in=8'b001 uo_out[0]=1

Example BLT 3 < 5 taken:
  ui_in=8'b0011_0101 uio_in=8'b010 uo_out[0]=1

## Design Context

Part of rv32imsu RISC-V SoC at UCF EEE-5390C:
- 32-bit pipeline with M S U privilege modes
- 10 SRAM macros (6x 2kB + 4x 1kB)
- AXI4 interconnect GPIO UART SPI Timer
- Synopsys ICC2 on sky130A 130nm PDK
- 29,470 leaf cells 60ns clock at SS corner

## Reuse

Copy tt_um_riscv_branch.v into your RISC-V project.
The always block implements all six branch conditions
with correct signed and unsigned comparison semantics
matching the RISC-V ISA specification exactly.

## External hardware

None required.
