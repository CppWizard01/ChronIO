////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 IHP PDK Authors
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    https://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////
`timescale 1ns/10ps
module SRAM_1P_behavioral_bm_bist (
    A_ADDR,
    A_DIN,
    A_BM,
    A_MEN,
    A_WEN,
    A_REN,
    A_CLK,
    A_DLY,
    A_DOUT,
    A_BIST_EN,
    A_BIST_ADDR,
    A_BIST_DIN,
    A_BIST_BM,
    A_BIST_MEN,
    A_BIST_WEN,
    A_BIST_REN,
    A_BIST_CLK
);

parameter P_DATA_WIDTH = 32;
parameter P_ADDR_WIDTH = 10;

input  wire [P_ADDR_WIDTH-1:0] A_ADDR;
input  wire [P_DATA_WIDTH-1:0] A_DIN;
input  wire [P_DATA_WIDTH-1:0] A_BM;
input  wire                    A_MEN;
input  wire                    A_WEN;
input  wire                    A_REN;
input  wire                    A_CLK;
input  wire                    A_DLY;
output wire [P_DATA_WIDTH-1:0] A_DOUT;

input  wire                    A_BIST_EN;
input  wire [P_ADDR_WIDTH-1:0] A_BIST_ADDR;
input  wire [P_DATA_WIDTH-1:0] A_BIST_DIN;
input  wire [P_DATA_WIDTH-1:0] A_BIST_BM;
input  wire                    A_BIST_MEN;
input  wire                    A_BIST_WEN;
input  wire                    A_BIST_REN;
input  wire                    A_BIST_CLK;

reg [P_DATA_WIDTH-1:0] memory [0:(1<<P_ADDR_WIDTH)-1];
reg [P_DATA_WIDTH-1:0] dr_r;

wire [P_ADDR_WIDTH-1:0] ADDR_MUX = (A_BIST_EN == 1'b1) ? A_BIST_ADDR : A_ADDR;
wire [P_DATA_WIDTH-1:0] DIN_MUX  = (A_BIST_EN == 1'b1) ? A_BIST_DIN  : A_DIN;
wire [P_DATA_WIDTH-1:0] BM_MUX   = (A_BIST_EN == 1'b1) ? A_BIST_BM   : A_BM;
wire                    MEN_MUX  = (A_BIST_EN == 1'b1) ? A_BIST_MEN  : A_MEN;
wire                    WEN_MUX  = (A_BIST_EN == 1'b1) ? A_BIST_WEN  : A_WEN;
wire                    REN_MUX  = (A_BIST_EN == 1'b1) ? A_BIST_REN  : A_REN;
wire                    CLK_MUX  = (A_BIST_EN == 1'b1) ? A_BIST_CLK  : A_CLK;

always @(posedge CLK_MUX) begin
    if (MEN_MUX == 1'b1 && WEN_MUX == 1'b1) begin
        memory[ADDR_MUX] <= (memory[ADDR_MUX] & ~BM_MUX) | (DIN_MUX & BM_MUX);
        if (REN_MUX == 1'b1) begin
            dr_r <= (memory[ADDR_MUX] & ~BM_MUX) | (DIN_MUX & BM_MUX);
        end
    end else if (MEN_MUX == 1'b1 && REN_MUX == 1'b1) begin
        dr_r <= memory[ADDR_MUX];
    end
end

assign A_DOUT = dr_r;

endmodule
