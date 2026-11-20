<!---
This file is used to generate your project datasheet.
-->

## How it works

**ChronIO** is a 4-lane barrel time-division-multiplexed (TDM) software-defined protocol emulator ASIC designed for the Jane Street × Tiny Tapeout competition on the IHP 130nm SG13CMOS5L process (`8x4` tile allocation).

Key architectural highlights:
- **Shared 4 KB (`1024x32`) IHP Hard SRAM Macro (`RM_IHPSG13_1P_1024x32_c2_bm_bist`)** storing up to 1,024 32-bit fixed-width instructions shared across 4 concurrent protocol lanes.
- **4-Stage Hazard-Free Barrel Pipeline** executing 4 independent hardware threads at 15 MIPS per lane (60 MHz core clock) with provable cross-lane timing non-interference.
- **Cycle-Exact Timed I/O Ports (`.AT`)** with hardware `TCMP += TPER` auto-stepping and edge timestamp capture (`TSTAMP`) providing 16.67 ns edge placement resolution.
- **Programmable Bitstream Conditioning Pipeline** supporting serial bit-streaming (`.SER`), NRZI, Manchester encoding/decoding, bit stuffing, edge-locking DPLL clock recovery, and a universal 32-bit reflected LFSR CRC engine.

## How to test

In the Phase 1.3 SRAM baseline verification wrapper, commands are issued over `ui_in[7:6]` with data/address bytes on `uio_in[7:0]` and readback on `uo_out[7:0]`. Run the cocotb test suite in `test/` for both RTL and Gate-Level simulation (`GATES=yes`).

## External hardware

Controlled by the onboard RP2350 microcontroller over a 4-wire Host SPI interface (`ui_in[2:0]` and `uo_out[0]`). External protocol targets connect via the remaining digital I/O pins and Pmod headers.
