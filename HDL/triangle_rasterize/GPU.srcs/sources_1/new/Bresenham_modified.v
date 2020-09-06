`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.05.2020 18:59:53
// Design Name: 
// Module Name: Bresenham_modified
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


module Bresenham_modified #(
    parameter DATA_WIDTH = 15
)
(
    input wire req,
    input wire rst,
    input wire clk,
    input wire [DATA_WIDTH : 0] start_x,
    input wire [DATA_WIDTH : 0] start_y,
    input wire [DATA_WIDTH : 0] end_x,
    input wire [DATA_WIDTH : 0] end_y,
    output reg [DATA_WIDTH : 0] out_x,
    output reg ack
    );
    
    localparam
        START           = 4'b0,
        DIRECTION_SET   = 4'b0001,
        SLOPE_SET       = 4'b0010,
        LOW_SLOPE       = 4'b0011, 
        HIGH_SLOPE      = 4'b0100,
        POINT_FINISH_HI = 4'b0101,
        POINT_FINISH_LO = 4'b0110;
        
    reg [3:0]status_reg;
    reg signed [DATA_WIDTH:0]dx;
    reg signed [DATA_WIDTH:0]dy;
    reg signed[DATA_WIDTH:0]decision;
    reg signed [15:0] delta_A;
    reg signed [15:0] delta_B; 
    reg [DATA_WIDTH:0]x; 
    reg signed [DATA_WIDTH:0]inc_x; 
    
    
    always @(posedge clk or posedge rst)
    begin
        
        if( rst == 1) begin
            out_x <= 0;
            status_reg <= START;
            dx <=0;
            dy <= 0;
            decision <= 0;
            delta_A <= 0; 
            delta_B <= 0; 
            inc_x <= 0; 
            x <= 0;
            ack <= 0;
        end
        else begin
            
            case( status_reg )
                
                START:
                begin
                    ack <= 0;
                    if( req == 1) begin                       
                        status_reg <= DIRECTION_SET;               
                        x<= start_x;
                    end
                    else begin
                        status_reg <= START;                     
                    end

                    
                end
                DIRECTION_SET:
                begin
                    ack <= 0;
                    dy <= end_y - start_y;
                    if(start_x > end_x) begin
                        dx <= start_x - end_x;
                        inc_x <= -1;
                    end
                    else begin
                        dx <= end_x - start_x;
                        inc_x <= 1; 
                    end
                    status_reg <= SLOPE_SET; 
                end
                SLOPE_SET:
                begin
                    ack <= 0;
                    if( dx  > dy ) begin
                        decision<= 2*dy - dx;
                        delta_A <= 2*dy;
                        delta_B <= 2*dy - 2*dx;
                        status_reg<= POINT_FINISH_LO;
                    end
                    else 
                    begin
                        decision <= 2*dx - dy;
                        delta_A <= 2*dx;
                        delta_B <= 2*dx - 2*dy;
                        status_reg  <= POINT_FINISH_HI;
                    end
                end
                
                HIGH_SLOPE:
                begin
                    ack <= 0;
                    if( decision > 0 ) begin
                        decision <= decision + delta_B;
                        x <= x + inc_x;
                    end
                    else begin
                        decision <= decision + delta_A; 
                        x<= x;                      
                    end       
                
                    status_reg = POINT_FINISH_HI;
              
                    
                end
                
                LOW_SLOPE:
                begin
                    ack <= 0;
                    x <= x + inc_x;

                    if( decision > 0 ) begin
                        decision <= decision + delta_B;                  
                         status_reg <= POINT_FINISH_LO;
                    end
                    else begin
                        decision <= decision + delta_A;   
                        status_reg <= LOW_SLOPE;                  
                    end
                
                end
                POINT_FINISH_HI:
                begin
                    ack <= 1;
                    out_x <= x;     
                    if(req == 1) status_reg <= HIGH_SLOPE; 
                    else         status_reg <= POINT_FINISH_HI;             
                end
                POINT_FINISH_LO:
                begin
                    ack <= 1;
                    out_x <= x;  
                    if(req == 1) status_reg <= LOW_SLOPE;    
                    else         status_reg <= POINT_FINISH_LO;                    
                end

                
            endcase
            
            
        end
        
        
    
    end
    
endmodule
