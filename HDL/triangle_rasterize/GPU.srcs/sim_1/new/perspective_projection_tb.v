`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2020 10:26:44
// Design Name: 
// Module Name: perspective_projection_tb
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

module perspective_projection_tb(

    );
        
    reg clk;
    reg rst;
    reg pp_req;

    wire [31:0]result;
    wire rec_ack;
    
    wire rec_req;
    wire pp_ack;
    wire [31:0] reciprocal;
    
    wire [31:0]out_x;
    wire [31:0]out_y;
    
    reg  [31:0]in_x;
    reg  [31:0]in_y; 
    reg  [31:0]in_z;  
    
    reg ack_out_pp;
    wire req_out_pp;
    
    real r1, r2;
    integer iterator; 
    
    reg [31:0]x_vector[5:0];
    reg [31:0]y_vector[5:0]; 
    reg [31:0]z_vector[5:0]; 
    
    NR_reciprocal NR(
      .clk(clk),
      .rst(rst),
      .req(rec_req),
      .num(reciprocal),
      .reciprocal(result),
      .ack(rec_ack)
     );
     
     perspective_projection_fxp perspective_projection(
         .clk(clk),
         .rst(rst),
         .pp_req_in(pp_req),
         .in_x(in_x),   
         .in_y(in_y),   
         .in_z(in_z), 
         .rec_ack(rec_ack), 
         .reciprocal_out(result),
         .pp_ack_in(pp_ack),
         .rec_req(rec_req),
         .out_x(out_x),
         .out_y(out_y),
         .reciprocal_in(reciprocal),
         .pp_ack_out(ack_out_pp),
         .pp_req_out(req_out_pp)
         
         );
    
    initial 
    begin
        z_vector[0] = 50;
        z_vector[1] = 40;
        z_vector[2] = 30;
        z_vector[3] = 25;
        in_x = 600;
        in_y = 10;
    end
    
    
    // clk generation    
    always
    begin
        #5 clk = !clk;
    end
         
    initial 
    begin
        iterator = 0;
        clk = 0;
        rst = 1;
        #5 rst = 0;
        in_z = z_vector[iterator];        
        pp_req = 1'b1;
        
    end
    always @( posedge req_out_pp )begin
        ack_out_pp = 1'b1;
        #10;
    end
    always @( posedge pp_ack )
    begin
        $display(" SIMULATION START");
        
         $display("coordinates 2d %d %d", out_x, out_y);
         if(iterator == 3 ) $finish;
         pp_req = 0; 
         iterator=iterator+1;
         in_z = z_vector[iterator];    
         #20
         pp_req = 1;
        
    end
    
endmodule
