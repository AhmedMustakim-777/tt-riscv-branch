# rv32i RISC-V Register File
## What it does

Full 32×32-bit RISC-V architectural register file
with 4 write ports and 2 read ports. This is the
actual register file extracted from a complete
rv32imsu RISC-V SoC implemented in Synopsys DC Shell
and ICC2 on sky130A 130nm PDK for EEE-5390C Full
Custom VLSI Design at University of Central Florida.

This tile works alongside the rv32i ALU tile to
demonstrate the complete execution stage of the
RISC-V pipeline.

## RISC-V Register File

The RISC-V ISA defines 32 general purpose registers:

| Register | ABI Name | Description          |
|----------|----------|----------------------|
| x0       | zero     | Always reads as 0    |
| x1       | ra       | Return address       |
| x2       | sp       | Stack pointer        |
| x3       | gp       | Global pointer       |
| x4       | tp       | Thread pointer       |
| x5-x7    | t0-t2    | Temporaries          |
| x8-x9    | s0-s1    | Saved registers      |
| x10-x17  | a0-a7    | Function arguments   |
| x18-x27  | s2-s11   | Saved registers      |
| x28-x31  | t3-t6    | Temporaries          |

## Pin Assignment

| Pin | Direction | Function |
|-----|-----------|----------|
| ui_in[7:6] | Input | Phase select (00-11) |
| ui_in[5] | Input | Mode: 1=read 0=write |
| ui_in[4:0] | Input | Register index (0-31) |
| ui_in[1:0] | Input | Output byte select |
| uio_in[7:0] | Input | Data byte to write |
| uo_out[7:0] | Output | Result byte from read |

## How to test

Write a value to register 1:
  Cycle 1: ui_in=8'b00_0_00001, uio_in=byte0
  Cycle 2: ui_in=8'b01_0_00000, uio_in=byte1
  Cycle 3: ui_in=8'b10_0_00000, uio_in=byte2
  Cycle 4: ui_in=8'b11_0_00000, uio_in=byte3

Read register 1 byte 0:
  Cycle 1: ui_in=8'b00_1_00001 (select reg 1 read mode)
  Cycle 2: ui_in=8'b01_0_00_00 (byte_sel=00)
  Read: uo_out = register[1][7:0]

Note: Register x0 always reads as 0 per RISC-V spec.
Writing to x0 has no effect.

## Design Context

Part of rv32imsu RISC-V SoC at UCF:
- Complete 32-bit pipeline with M S U privilege modes
- 10 SRAM macros (6x 2kB + 4x 1kB data/instruction cache)
- AXI4 interconnect, GPIO, UART, SPI, Timer
- Physical design: Synopsys ICC2 on sky130A 130nm
- 29,470 leaf cells, 60ns clock period at SS corner

## Reuse

Copy riscv_regfile.v and tt_um_riscv_regfile.v into
your project. The register file supports 4 simultaneous
write ports and 2 read ports for high-performance
out-of-order execution pipelines.

## External hardware

None required.
