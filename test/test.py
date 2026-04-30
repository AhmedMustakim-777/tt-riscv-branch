# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

BEQ  = 0b000
BNE  = 0b001
BLT  = 0b010
BGE  = 0b011
BLTU = 0b100
BGEU = 0b101

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1
    await ClockCycles(dut.clk, 2)

    async def check(A, B, func, expected, name):
        dut.ui_in.value  = (A << 4) | B
        dut.uio_in.value = func
        await ClockCycles(dut.clk, 2)
        result = dut.uo_out.value.to_unsigned() & 0x1
        dut._log.info(f"{name}: A={A} B={B} taken={result}")
        assert result == expected, \
            f"{name} FAILED: expected {expected} got {result}"

    await check(5, 5, BEQ,  1, "BEQ 5==5 taken")
    await check(5, 3, BEQ,  0, "BEQ 5==3 not taken")
    await check(5, 3, BNE,  1, "BNE 5!=3 taken")
    await check(5, 5, BNE,  0, "BNE 5==5 not taken")
    await check(3, 5, BLT,  1, "BLT 3<5 taken")
    await check(5, 3, BLT,  0, "BLT 5<3 not taken")
    await check(5, 5, BLT,  0, "BLT 5==5 not taken")
    await check(5, 3, BGE,  1, "BGE 5>=3 taken")
    await check(5, 5, BGE,  1, "BGE 5==5 taken")
    await check(3, 5, BGE,  0, "BGE 3>=5 not taken")
    await check(3, 5, BLTU, 1, "BLTU 3<5 taken")
    await check(5, 3, BLTU, 0, "BLTU 5<3 not taken")
    await check(5, 3, BGEU, 1, "BGEU 5>=3 taken")
    await check(5, 5, BGEU, 1, "BGEU 5==5 taken")
    await check(3, 5, BGEU, 0, "BGEU 3<5 not taken")

    dut._log.info("All branch tests passed!")
