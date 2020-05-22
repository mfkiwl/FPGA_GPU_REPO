`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mateusz Wygrzywalski
// 
// Create Date: 20.05.2020 21:53:20
// Design Name: 
// Module Name: matrix_4x4_buff
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


module matrix_4x4_buff
#(  parameter  W = 12, //Width of the fixed-point (12:10) representation
    parameter FXP_MUL = 1024 //Scaling factor for fixed-point (12:10) representation
)(
    input wire clk,
    
    input wire valid_in,
    output reg ready_out,
    input wire [W-1:0] a_in,
    input wire [W-1:0] b_in,
    
    output reg valid_out,
    input wire ready_in,
    output wire [3:0][W-1:0] aC1,
    output wire [3:0][W-1:0] aC2,
    output wire [3:0][W-1:0] aC3,
    output wire [3:0][W-1:0] aC4,
    output wire [3:0][W-1:0] bC1,
    output wire [3:0][W-1:0] bC2,
    output wire [3:0][W-1:0] bC3,
    output wire [3:0][W-1:0] bC4
);
 
    reg [3:0][W-1:0] aC1_buf, aC2_buf, aC3_buf, aC4_buf, bC1_buf, bC2_buf, bC3_buf, bC4_buf;
    assign aC1 = aC1_buf;
    assign aC2 = aC2_buf;
    assign aC3 = aC3_buf;
    assign aC4 = aC4_buf;
    assign bC1 = bC1_buf;
    assign bC2 = bC2_buf;
    assign bC3 = bC3_buf;
    assign bC4 = bC4_buf;
    reg [1:0] iterator;
    
    enum {IDLE=0, BUFFOR_C1, BUFFOR_C2, BUFFOR_C3, BUFFOR_C4, DONE} state;
    
    always_ff @(posedge clk) begin: fsm
        case(state)
            IDLE: begin
                ready_out <= 1'b1;
                valid_out <= 1'b0;
                state <= (valid_in) ? BUFFOR_C1 : IDLE;
                aC1_buf <= 0;
                aC2_buf <= 0;
                aC3_buf <= 0;
                aC4_buf <= 0;
                bC1_buf <= 0;
                bC2_buf <= 0;
                bC3_buf <= 0;
                bC4_buf <= 0;
                iterator <= 0;
            end
            BUFFOR_C1: begin
                aC1_buf[iterator] <= a_in;
                bC1_buf[iterator] <= b_in;
                state <= (iterator == 2'd3) ? BUFFOR_C2 : BUFFOR_C1;
                iterator <= (iterator == 2'd3) ? 2'd0 : iterator + 1;
            end
            BUFFOR_C2: begin
                aC2_buf[iterator] <= a_in;
                bC2_buf[iterator] <= b_in;
                state <= (iterator == 2'd3) ? BUFFOR_C3 : BUFFOR_C2;
                iterator <= (iterator == 2'd3) ? 2'd0 : iterator + 1;
            end
            BUFFOR_C3: begin
                aC3_buf[iterator] <= a_in;
                bC3_buf[iterator] <= b_in;
                state <= (iterator == 2'd3) ? BUFFOR_C4 : BUFFOR_C3;
                iterator <= (iterator == 2'd3) ? 2'd0 : iterator + 1;
            end
            BUFFOR_C4: begin
                aC4_buf[iterator] <= a_in;
                bC4_buf[iterator] <= b_in;
                state <= (iterator == 2'd3) ? DONE : BUFFOR_C4;
                iterator <= (iterator == 2'd3) ? 2'd0 : iterator + 1;
            end
            DONE: begin
                ready_out <= 1'b0;
                valid_out <= 1'b1;
                state <= (ready_in) ? IDLE : DONE;
//                state <= (ready_in && (iterator == 2'd3)) ? IDLE : DONE;
//                iterator <= (iterator == 2'd3) ? 2'd0 : iterator + 1;
            end
        endcase
     end: fsm
       
endmodule
