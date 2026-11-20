/*
 * Copyright (c) 2026 Dhairya Sharma
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// ChronIO Phase 1.3 Walking-Skeleton Verification:
// Validates the 1024x32 (4KB) IHP SRAM Macro (RM_IHPSG13_1P_1024x32_c2_bm_bist)
// on the 8x4 SG13CMOS5L tile with registered I/O boundary flops.
//
// Command interface (sampled on rising clk edge):
//   ui_in[7:6] = 2'b00: READ        - read 32-bit word at addr_q[9:0]
//                2'b01: SET_ADDR_LO - addr_q[7:0] <= uio_in; addr_q[9:8] <= ui_in[5:4]
//                2'b10: WRITE_BYTE  - write uio_in into byte lane ui_in[3:2] of word at addr_q[9:0]
//                2'b11: WRITE_ALL   - replicate uio_in across all 4 bytes of word at addr_q[9:0]
//   ui_in[1:0] = byte select for uo_out (0: [7:0], 1: [15:8], 2: [23:16], 3: [31:24])

module tt_um_chronio (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  reg  [1:0]  cmd_q;
  reg  [1:0]  wsel_q;
  reg  [7:0]  data_q;
  reg         men_q;
  reg  [9:0]  addr_q;

  wire        write = cmd_q[1];
  wire [31:0] dout;

  wire [31:0] bmask = (cmd_q == 2'b11) ? 32'hFFFF_FFFF :
                      (wsel_q == 2'd0) ? 32'h0000_00FF :
                      (wsel_q == 2'd1) ? 32'h0000_FF00 :
                      (wsel_q == 2'd2) ? 32'h00FF_0000 :
                                         32'hFF00_0000;

  always @(posedge clk) begin
    men_q  <= rst_n;
    cmd_q  <= rst_n ? ui_in[7:6] : 2'b00;
    wsel_q <= ui_in[3:2];
    data_q <= uio_in;
    if (!rst_n) begin
      addr_q <= 10'd0;
    end else if (ui_in[7:6] == 2'b01) begin
      addr_q <= {ui_in[5:4], uio_in};
    end
  end

  // The instance name ("sram") is referenced by MACROS and PDN_MACRO_CONNECTIONS in src/config.json
  RM_IHPSG13_1P_1024x32_c2_bm_bist sram (
      .A_CLK      (clk),
      .A_MEN      (men_q),
      .A_WEN      (write),
      .A_REN      (~write),
      .A_ADDR     (addr_q),
      .A_DIN      ({4{data_q}}),
      .A_DLY      (1'b1),
      .A_DOUT     (dout),
      .A_BM       (bmask),
      .A_BIST_CLK (1'b0),
      .A_BIST_EN  (1'b0),
      .A_BIST_MEN (1'b0),
      .A_BIST_WEN (1'b0),
      .A_BIST_REN (1'b0),
      .A_BIST_ADDR(10'd0),
      .A_BIST_DIN (32'd0),
      .A_BIST_BM  (32'd0)
  );

  assign uo_out = (ui_in[1:0] == 2'd0) ? dout[7:0]   :
                  (ui_in[1:0] == 2'd1) ? dout[15:8]  :
                  (ui_in[1:0] == 2'd2) ? dout[23:16] :
                                         dout[31:24];

  assign uio_out = 8'd0;
  assign uio_oe  = 8'd0;

  wire _unused = &{ena, 1'b0};

endmodule
