`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2020 21:55:23
// Design Name: 
// Module Name: matrix_4x4_mult
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


module matrix_4x4_mult
#(  parameter  W = 12, //Width of the fixed-point (12:10) representation
    parameter FXP_MUL = 1024 //Scaling factor for fixed-point (12:10) representation
)(
    input wire clk,
    
    input wire valid_in,
    input wire [W-1:0] a_in,
    input wire [W-1:0] b_in,
    output reg ready_out,
    
    input wire ready_in,
    output reg valid_out,
    output wire [3:0][W-1:0] cC1,
    output wire [3:0][W-1:0] cC2,
    output wire [3:0][W-1:0] cC3,
    output wire [3:0][W-1:0] cC4
    );
    
    wire ready_out_mult;
    wire valid_out_buff;
    wire [3:0][11:0] aC1;
    wire [3:0][11:0] aC2;
    wire [3:0][11:0] aC3;
    wire [3:0][11:0] aC4;
    wire [3:0][11:0] bC1;
    wire [3:0][11:0] bC2;
    wire [3:0][11:0] bC3;
    wire [3:0][11:0] bC4;
    
    matrix_4x4_buff matrix_4x4_buff_rtl(
        .clk(clk), 
        .valid_in(valid_in),
        .ready_out(ready_out),
        .a_in(a_in),
        .b_in(b_in),
        
        .valid_out(valid_out_buff),
        .ready_in(ready_out_mult),
        .aC1(aC1),
        .aC2(aC2),
        .aC3(aC3),
        .aC4(aC4),
        .bC1(bC1),
        .bC2(bC2),
        .bC3(bC3),
        .bC4(bC4)
        );
        
        matrix_4x4_compute matrix_4x4_compute_rtl(
        .clk(clk),
        
        .valid_in(valid_out_buff),
        .ready_out(ready_out_mult),
        .aC1(aC1),
        .aC2(aC2),
        .aC3(aC3),
        .aC4(aC4),
        .bC1(bC1),
        .bC2(bC2),
        .bC3(bC3),
        .bC4(bC4),
         
        .valid_out(valid_out),
        .ready_in(ready_in),
        .cC1(cC1),
        .cC2(cC2),
        .cC3(cC3),
        .cC4(cC4)
    );
    
endmodule
