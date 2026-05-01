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

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

## Set up your Verilog project

1. Add your Verilog files to the `src` folder.
2. Edit the [info.yaml](info.yaml) and update information about your project, paying special attention to the `source_files` and `top_module` properties. If you are upgrading an$
3. Edit [docs/info.md](docs/info.md) and add a description of your project.
4. Adapt the testbench to your design. See [test/README.md](test/README.md) for more information.

The GitHub action will automatically build the ASIC files using [LibreLane](https://www.zerotoasiccourse.com/terminology/librelane/).

## Enable GitHub actions to build the results page

- [Enabling GitHub Pages](https://tinytapeout.com/faq/#my-github-action-is-failing-on-the-pages-part)

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)

## What next?

- [Submit your design to the next shuttle](https://app.tinytapeout.com/).
- Edit [this README](README.md) and explain your design, how it works, and how to test it.
- Share your project on your social network of choice:
  - LinkedIn [#tinytapeout](https://www.linkedin.com/search/results/content/?keywords=%23tinytapeout) [@TinyTapeout](https://www.linkedin.com/company/100708654/)
  - Mastodon [#tinytapeout](https://chaos.social/tags/tinytapeout) [@matthewvenn](https://chaos.social/@matthewvenn)
  - X (formerly Twitter) [#tinytapeout](https://twitter.com/hashtag/tinytapeout) [@tinytapeout](https://twitter.com/tinytapeout)
  - Bluesky [@tinytapeout.com](https://bsky.app/profile/tinytapeout.com)

