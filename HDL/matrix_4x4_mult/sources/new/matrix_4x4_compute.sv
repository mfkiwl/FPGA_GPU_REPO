`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2020 21:54:34
// Design Name: 
// Module Name: matrix_4x4_compute
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module matrix_4x4_compute
#(  parameter  W = 12, //Width of the fixed-point (12:10) representation
    parameter FXP_MUL = 1024 //Scaling factor for fixed-point (12:10) representation
)(
    input wire clk,
    
    input wire valid_in,
    input wire [3:0][W-1:0] aC1,
    input wire [3:0][W-1:0] aC2,
    input wire [3:0][W-1:0] aC3,
    input wire [3:0][W-1:0] aC4,
    input wire [3:0][W-1:0] bC1,
    input wire [3:0][W-1:0] bC2,
    input wire [3:0][W-1:0] bC3,
    input wire [3:0][W-1:0] bC4,
    output reg ready_out, 
    
    input wire ready_in,
    output reg valid_out,
    output wire [3:0][W-1:0] cC1,
    output wire [3:0][W-1:0] cC2,
    output wire [3:0][W-1:0] cC3,
    output wire [3:0][W-1:0] cC4
);
 
reg [3:0][W-1:0] cC1_buf, cC2_buf, cC3_buf, cC4_buf;
wire [3:0][W-1:0] aC1_tran, aC2_tran, aC3_tran, aC4_tran;
assign cC1 = cC1_buf;
assign cC2 = cC2_buf;
assign cC3 = cC3_buf;
assign cC4 = cC4_buf;
reg [1:0] iterator;

assign aC1_tran = {aC1[0], aC2[0], aC3[0], aC4[0]};
assign aC2_tran = {aC1[1], aC2[1], aC3[1], aC4[1]};
assign aC3_tran = {aC1[2], aC2[2], aC3[2], aC4[2]};
assign aC4_tran = {aC1[3], aC2[3], aC3[3], aC4[3]};

enum {IDLE=0, COMPUTE_C1, COMPUTE_C2, COMPUTE_C3, COMPUTE_C4, DONE} state;

always_ff @(posedge clk) begin: fsm
    case(state)
        IDLE: begin
            ready_out <= 1'b1;
            valid_out <= 1'b0;
            state <= (valid_in) ?  COMPUTE_C1 : IDLE;
            cC1_buf <= 0;
            cC2_buf <= 0;
            cC3_buf <= 0;
            cC4_buf <= 0;
            iterator <= 0;
        end
        COMPUTE_C1: begin
            ready_out <= 1'b0;
            valid_out <= 1'b0;
            cC1_buf[0] <= cC1_buf[0] + aC1_tran[iterator]*bC1[iterator];
            cC1_buf[1] <= cC1_buf[1] + aC2_tran[iterator]*bC1[iterator];
            cC1_buf[2] <= cC1_buf[2] + aC3_tran[iterator]*bC1[iterator];
            cC1_buf[3] <= cC1_buf[3] + aC4_tran[iterator]*bC1[iterator];
            state <= (iterator == 2'b11) ? COMPUTE_C2 : COMPUTE_C1;
            iterator <= (iterator == 2'b11) ? 2'b00 : iterator + 1;
        end
        COMPUTE_C2: begin
                    ready_out <= 1'b0;
            valid_out <= 1'b0;
            cC2_buf[0] <= cC2_buf[0] + aC1_tran[iterator]*bC2[iterator];
            cC2_buf[1] <= cC2_buf[1] + aC2_tran[iterator]*bC2[iterator];
            cC2_buf[2] <= cC2_buf[2] + aC3_tran[iterator]*bC2[iterator];
            cC2_buf[3] <= cC2_buf[3] + aC4_tran[iterator]*bC2[iterator];
            state <= (iterator == 2'b11) ? COMPUTE_C3 : COMPUTE_C2;
            iterator <= (iterator == 2'b11) ? 2'b00 : iterator + 1;
        end
        COMPUTE_C3: begin
            ready_out <= 1'b0;
            valid_out <= 1'b0;
            cC3_buf[0] <= cC3_buf[0] + aC1_tran[iterator]*bC3[iterator];
            cC3_buf[1] <= cC3_buf[1] + aC2_tran[iterator]*bC3[iterator];
            cC3_buf[2] <= cC3_buf[2] + aC3_tran[iterator]*bC3[iterator];
            cC3_buf[3] <= cC3_buf[3] + aC4_tran[iterator]*bC3[iterator];
            state <= (iterator == 2'b11) ? COMPUTE_C4 : COMPUTE_C3;
            iterator <= (iterator == 2'b11) ? 2'b00 : iterator + 1;
        end
        COMPUTE_C4: begin
            ready_out <= 1'b0;
            valid_out <= 1'b0;
            cC4_buf[0] <= cC4_buf[0] + aC1_tran[iterator]*bC4[iterator];
            cC4_buf[1] <= cC4_buf[1] + aC2_tran[iterator]*bC4[iterator];
            cC4_buf[2] <= cC4_buf[2] + aC3_tran[iterator]*bC4[iterator];
            cC4_buf[3] <= cC4_buf[3] + aC4_tran[iterator]*bC4[iterator];
            state <= (iterator == 2'b11) ? DONE : COMPUTE_C4;
            iterator <= (iterator == 2'b11) ? 2'b00 : iterator + 1;
        end
        DONE: begin
            ready_out <= 1'b0;
            valid_out <= 1'b1;
            state <= (ready_in) ? IDLE : DONE;
        end
    endcase
 end: fsm
       
endmodule
