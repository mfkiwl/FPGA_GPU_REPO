`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2020 21:56:16
// Design Name: 
// Module Name: matrix_4x4_buff_tb
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


module matrix_4x4_buff_tb();
reg clock;
reg valid_in;
wire ready_out;
reg [11:0] a_in;
reg [11:0] b_in;
reg ready_in;
wire valid_out;
wire [3:0][11:0] aC1;
wire [3:0][11:0] aC2;
wire [3:0][11:0] aC3;
wire [3:0][11:0] aC4;
wire [3:0][11:0] bC1;
wire [3:0][11:0] bC2;
wire [3:0][11:0] bC3;
wire [3:0][11:0] bC4;
//Instantiation
matrix_buff matrix_buff_rtl(
    .clk(clock), 
    .valid_in(valid_in),
    .a_in(a_in),
    .b_in(b_in),
    .ready_out(ready_out),
    
    .ready_in(ready_in),
    .valid_out(valid_out),
    .aC1(aC1),
    .aC2(aC2),
    .aC3(aC3),
    .aC4(aC4),
    .bC1(bC1),
    .bC2(bC2),
    .bC3(bC3),
    .bC4(bC4)
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
