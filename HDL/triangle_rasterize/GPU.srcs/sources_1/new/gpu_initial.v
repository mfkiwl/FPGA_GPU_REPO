`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.09.2020 11:08:34
// Design Name: 
// Module Name: gpu_initial
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


module gpu_initial(
    output wire pp_req,
    
    output wire [15:0]upper_x,
    output wire [15:0]upper_y,
    output wire [15:0]upper_z,
    output wire [15:0]mid_x,
    output wire [15:0]mid_y,
    output wire [15:0]mid_z,
    output wire [15:0]lower_x,
    output wire [15:0]lower_y, 
    output wire [15:0]lower_z,
    
    output wire [7:0]grad_in,
    output wire [23:0]base_color
    );

    assign pp_req = 1;
    
    assign upper_x = 600;
    assign upper_y = 10;
    assign upper_z   = 310;
    assign mid_x   = 60; 
    assign mid_y = 400;
    assign mid_z = 200;
    assign lower_x = 50;
    assign lower_y   = 50; 
    assign lower_z = 50;
    
    assign grad_in = 1;
    assign base_color = 24'hffff0f;

endmodule
