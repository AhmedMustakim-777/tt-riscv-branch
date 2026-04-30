# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


def safe_read(dut):
    try:
        return dut.uo_out.value.to_unsigned()
    except ValueError:
        return 0


async def write_reg(dut, reg_idx, value):
    """Write 32-bit value to register reg_idx"""
    bytes_v = [(value >> (8*i)) & 0xFF for i in range(4)]

    # Phase 0 — byte 0 + reg index + write mode
    dut.ui_in.value  = (0b00 << 6) | (0 << 5) | reg_idx
    dut.uio_in.value = bytes_v[0]
    await ClockCycles(dut.clk, 1)

    # Phase 1 — byte 1
    dut.ui_in.value  = (0b01 << 6)
    dut.uio_in.value = bytes_v[1]
    await ClockCycles(dut.clk, 1)

    # Phase 2 — byte 2
    dut.ui_in.value  = (0b10 << 6)
    dut.uio_in.value = bytes_v[2]
    await ClockCycles(dut.clk, 1)

    # Phase 3 — byte 3 + trigger write
    dut.ui_in.value  = (0b11 << 6)
    dut.uio_in.value = bytes_v[3]
    await ClockCycles(dut.clk, 1)

    # Settle
    await ClockCycles(dut.clk, 2)


async def read_reg(dut, reg_idx):
    """Read 32-bit value from register reg_idx"""
    result = 0

    # Select register to read
    dut.ui_in.value  = (0b00 << 6) | (1 << 5) | reg_idx
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 2)

    # Read 4 bytes
    for i in range(4):
        dut.ui_in.value  = (0b01 << 6) | i
        dut.uio_in.value = i
        await ClockCycles(dut.clk, 2)
        byte_val = safe_read(dut)
        result |= (byte_val << (8 * i))
        dut._log.info(f"  read byte[{i}] = {hex(byte_val)}")

    return result


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1
    await ClockCycles(dut.clk, 5)

    # Test 1 — write 0x12345678 to register 1, read back
    dut._log.info("Test 1: Write 0x12345678 to reg[1]")
    await write_reg(dut, 1, 0x12345678)
    result = await read_reg(dut, 1)
    dut._log.info(f"Read back: {hex(result)}")
    assert result == 0x12345678, \
        f"Reg write/read failed: expected 0x12345678 got {hex(result)}"

    # Test 2 — write 0xDEADBEEF to register 5, read back
    dut._log.info("Test 2: Write 0xDEADBEEF to reg[5]")
    await write_reg(dut, 5, 0xDEADBEEF)
    result = await read_reg(dut, 5)
    dut._log.info(f"Read back: {hex(result)}")
    assert result == 0xDEADBEEF, \
        f"Reg write/read failed: expected 0xDEADBEEF got {hex(result)}"

    # Test 3 — register 0 must always read 0 (RISC-V spec)
    dut._log.info("Test 3: Write to reg[0] should read back 0")
    await write_reg(dut, 0, 0xFFFFFFFF)
    result = await read_reg(dut, 0)
    dut._log.info(f"reg[0] = {hex(result)}")
    assert result == 0, \
        f"reg[0] must be 0: got {hex(result)}"

    # Test 4 — multiple registers independent
    dut._log.info("Test 4: Write different values to reg[1] and reg[2]")
    await write_reg(dut, 1, 0x000000AA)
    await write_reg(dut, 2, 0x000000BB)
    result1 = await read_reg(dut, 1)
    result2 = await read_reg(dut, 2)
    dut._log.info(f"reg[1]={hex(result1)} reg[2]={hex(result2)}")
    assert result1 == 0xAA, \
        f"reg[1] failed: expected 0xAA got {hex(result1)}"
    assert result2 == 0xBB, \
        f"reg[2] failed: expected 0xBB got {hex(result2)}"

    dut._log.info("All register file tests passed!")
