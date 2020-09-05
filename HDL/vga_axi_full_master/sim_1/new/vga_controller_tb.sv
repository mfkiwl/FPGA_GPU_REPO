`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.08.2020 20:59:58
// Design Name: 
// Module Name: vga_controller_tb
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

module vga_controller_tb #
(
    parameter integer BRAM_ADDR_WIDTH = 32,
	parameter integer C_M_AXI_ADDR_WIDTH = 32,
	parameter integer C_M_AXI_DATA_WIDTH = 32,
    parameter PIXEL_WIDTH = 15
)
();

    reg clock = 0; 
    reg reset = 1;
    reg finish_simulation = 0;

    reg [C_M_AXI_DATA_WIDTH-1:0] data_in_1 = 12'h888;
    wire [C_M_AXI_ADDR_WIDTH-1:0] raddr_1;
    wire rden_1;
    reg [C_M_AXI_DATA_WIDTH-1:0] data_in_2 = 12'h888;
    wire [C_M_AXI_ADDR_WIDTH-1:0] raddr_2;
    wire rden_2;

    wire vga_ready;
    reg axi_vga_ready = 0;

    wire hsync;
    wire vsync;
    wire [PIXEL_WIDTH-1:0] rgb_out;

    integer i;
    
    // 245.76 Mhz clock and simulation control
    initial begin
        #100;
        clock = 0;
        #2.0345;
        while (!finish_simulation)
            #2.0345 clock <= ~clock;
    end
    
    task drive_reset;
    begin
        @(posedge clock);
        reset <= 0;
        repeat (10) @(posedge clock);
        reset <= 1;
        @(posedge clock);
    end
    endtask

    vga_controller vga_controller_inst
    (
        .vga_clk(clock),
        .rst_n(reset),

        .data_in_1(data_in_1),
        .raddr_1(raddr_1),
        .rden_1(rden_1),
        .data_in_2(data_in_2),
        .raddr_2(raddr_2),
        .rden_2(rden_2),
    
        .vga_ready(vga_ready),
        .axi_vga_ready(axi_vga_ready),

        .hsync(hsync),
        .vsync(vsync),
        .rgb_out(rgb_out)
    );

    initial begin
        drive_reset;
    end

endmodule
