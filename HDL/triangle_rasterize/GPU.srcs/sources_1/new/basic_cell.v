`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2020 19:37:04
// Design Name: 
// Module Name: basic_cell
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


module basic_cell(
    input wire clk,
    input wire rst,
    
    input wire pp_req,
    
    input wire [15:0]upper_x,
    input wire [15:0]upper_y,
    input wire [15:0]upper_z,
    input wire [15:0]mid_x,
    input wire [15:0]mid_y,
    input wire [15:0]mid_z,
    input wire [15:0]lower_x,
    input wire [15:0]lower_y, 
    input wire [15:0]lower_z,
    
    input wire [7:0]grad_in,
    input wire [23:0]base_color,
    
    output wire [15:0] out_x,
    output wire [15:0] out_y,    

    
    output wire ack_out,
    
    
    output wire [7:0]R_out,
    output wire [7:0]G_out,
    output wire [7:0]B_out,
    
    output wire ack_in
    
    
    );
    
    wire ack_out_rast;
    
    wire [15:0]upper_x_inter;
    wire [15:0]upper_y_inter;

    wire [15:0]mid_x_inter;
    wire [15:0]mid_y_inter; 

    wire [15:0]lower_x_inter;
    wire [15:0]lower_y_inter; 
    

    
    
    wire pp_req_out_upper;
    wire pp_req_out_mid;
    wire pp_req_out_lower;
    
    triangle_rasterize triangle1(
        .clk(clk),
        .rst(rst),
        .req(pp_req_out_lower & pp_req_out_mid & pp_req_out_upper),  
        .upper_x(upper_x_inter),
        .upper_y(upper_y_inter),     
        .mid_x(mid_x_inter),
        .mid_y(mid_y_inter), 
        .lower_x(lower_x_inter),
        .lower_y(lower_y_inter),
        .out_x(out_x),
        .out_y(out_y), 
        .ack_out(ack_out),
        .ack_in(ack_out_rast),
        .R_out(R_out),
        .G_out(G_out),
        .B_out(B_out),
        .base_color(base_color),
        .grad(grad_in)
        );
    
    wire rec_req_upper;
    wire [31:0]reciprocal_upper;
    wire [31:0]result_upper;
    wire rec_ack_upper;
    wire pp_ack_upper;
        
    NR_reciprocal NR_upper(
        .clk(clk),
        .rst(rst),
        .req(rec_req_upper),
        .num(reciprocal_upper),
        .reciprocal(result_upper),
        .ack(rec_ack_upper)
        );
        
    perspective_projection_fxp upper(
        .clk(clk),
        .rst(rst),
        .pp_req_in(pp_req),
        .in_x({upper_x}),   
        .in_y({upper_y}),   
        .in_z({upper_z}), 
        .rec_ack(rec_ack_upper), 
        .reciprocal_out(result_upper),
        .pp_ack_in(pp_ack_upper),
        .rec_req(rec_req_upper),
        .out_x(upper_x_inter),
        .out_y(upper_y_inter),
        .reciprocal_in(reciprocal_upper),
        .pp_ack_out(ack_out_rast),
        .pp_req_out(pp_req_out_upper)    
    );


    wire rec_req_mid;
    wire [31:0]reciprocal_mid;
    wire [31:0]result_mid;
    wire rec_ack_mid;
    wire pp_ack_mid;
        
    NR_reciprocal NR_mid(
        .clk(clk),
        .rst(rst),
        .req(rec_req_mid),
        .num(reciprocal_mid),
        .reciprocal(result_mid),
        .ack(rec_ack_mid)
        );
            
    perspective_projection_fxp mid(
        .clk(clk),
        .rst(rst),
        .pp_req_in(pp_req),
        .in_x({mid_x}),   
        .in_y({mid_y}),   
        .in_z({mid_z}), 
        .rec_ack(rec_ack_mid), 
        .reciprocal_out(result_mid),
        .pp_ack_in(pp_ack_mid),
        .rec_req(rec_req_mid),
        .out_x(mid_x_inter),
        .out_y(mid_y_inter),
        .reciprocal_in(reciprocal_mid),
        .pp_ack_out(ack_out_rast),
        .pp_req_out(pp_req_out_mid)
                
    );
    
    wire rec_req_lower;
    wire [31:0]reciprocal_lower;
    wire [31:0]result_lower;
    wire rec_ack_lower;
    wire pp_ack_lower;
        
    NR_reciprocal NR_lower(
        .clk(clk),
        .rst(rst),
        .req(rec_req_lower),
        .num(reciprocal_lower),
        .reciprocal(result_lower),
        .ack(rec_ack_lower)
        );
    
    perspective_projection_fxp low(
        .clk(clk),
        .rst(rst),
        .pp_req_in(pp_req),
        .in_x({lower_x}),   
        .in_y({lower_y}),   
        .in_z({lower_z}), 
        .rec_ack(rec_ack_lower), 
        .reciprocal_out(result_lower),
        .pp_ack_in(pp_ack_lower),
        .rec_req(rec_req_lower),
        .out_x(lower_x_inter),
        .out_y(lower_y_inter),
        .reciprocal_in(reciprocal_lower),
        .pp_ack_out(ack_out_rast),
        .pp_req_out(pp_req_out_lower)
                
    );
    
    assign ack_in = pp_ack_upper & pp_ack_mid & pp_ack_lower;
    
    
    
    
    
    
    
endmodule
