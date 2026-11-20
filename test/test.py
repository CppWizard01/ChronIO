# SPDX-FileCopyrightText: © 2026 Dhairya Sharma
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

CMD_READ = 0b00
CMD_SET_ADDR = 0b01
CMD_WRITE_BYTE = 0b10
CMD_WRITE_ALL = 0b11


async def start(dut):
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)


async def set_addr(dut, addr10):
    hi2 = (addr10 >> 8) & 0x3
    lo8 = addr10 & 0xFF
    dut.ui_in.value = (CMD_SET_ADDR << 6) | (hi2 << 4)
    dut.uio_in.value = lo8
    await ClockCycles(dut.clk, 1)


async def write_word32(dut, addr10, word32):
    await set_addr(dut, addr10)
    for b in range(4):
        byte_val = (word32 >> (8 * b)) & 0xFF
        dut.ui_in.value = (CMD_WRITE_BYTE << 6) | (b << 2)
        dut.uio_in.value = byte_val
        await ClockCycles(dut.clk, 1)


async def read_word32(dut, addr10):
    await set_addr(dut, addr10)
    for _ in range(3):
        dut.ui_in.value = (CMD_READ << 6) | 0
        await ClockCycles(dut.clk, 1)
    result = 0
    for b in range(4):
        dut.ui_in.value = (CMD_READ << 6) | b
        await ClockCycles(dut.clk, 1)
        result |= (dut.uo_out.value.to_unsigned() & 0xFF) << (8 * b)
    return result


@cocotb.test()
async def test_1024x32_sram_read_write(dut):
    await start(dut)
    test_vectors = [
        (0x000, 0xCAFEBABE),
        (0x001, 0x12345678),
        (0x155, 0xDEADBEEF),
        (0x2AA, 0xA5A55A5A),
        (0x3FF, 0x0F1E2D3C),
    ]
    for addr, word in test_vectors:
        await write_word32(dut, addr, word)

    for addr, expected in test_vectors:
        got = await read_word32(dut, addr)
        assert got == expected, f"Addr {addr:#05x}: got {got:#010x}, expected {expected:#010x}"
