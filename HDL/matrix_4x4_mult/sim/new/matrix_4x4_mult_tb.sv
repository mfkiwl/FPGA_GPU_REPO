`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.05.2020 12:28:58
// Design Name: 
// Module Name: matrix_mult_tb
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


module matrix_4x4_mult_tb();
reg clock;
reg valid_in;
wire ready_out;
reg [11:0] a_in;
reg [11:0] b_in;
reg ready_in;
wire valid_out;
wire [3:0][11:0] cC1;
wire [3:0][11:0] cC2;
wire [3:0][11:0] cC3;
wire [3:0][11:0] cC4;
//Instantiation
matrix_4x4_mult matrix_4x4_mult_rtl(
    .clk(clock), 
    .valid_in(valid_in),
    .a_in(a_in),
    .b_in(b_in),
    .ready_out(ready_out),
    
    .ready_in(ready_in),
    .valid_out(valid_out),
    .cC1(cC1),
    .cC2(cC2),
    .cC3(cC3),
    .cC4(cC4)
    );
//Clock generator stimuli
initial
begin
    clock <= 1'b1;
end
always
    #5 clock <= ~clock;
//Signals stimuli
initial
begin
    #20
    @(posedge clock)
    begin
        valid_in <= 1'b1;
        ready_in <= 1'b0;
    end
    @(posedge clock)
    begin
        a_in <= 12'd1;
        b_in <= 12'd1;
    end
    @(posedge clock)
    @(posedge clock)
    @(posedge clock)
    @(posedge clock)
    begin
        a_in <= 12'd2;
        b_in <= 12'd2;
    end
    @(posedge clock)
    @(posedge clock)
    @(posedge clock)
    @(posedge clock)
    begin
        a_in <= 12'd3;
        b_in <= 12'd3;
    end
    @(posedge clock)
    @(posedge clock)
    @(posedge clock)
    @(posedge clock)
    begin
        a_in <= 12'd4;
        b_in <= 12'd4;
    end
end
    
endmodule