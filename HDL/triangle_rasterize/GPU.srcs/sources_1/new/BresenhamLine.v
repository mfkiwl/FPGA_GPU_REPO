`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2020 15:28:06
// Design Name: 
// Module Name: BresenhamLine
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


module BresenhamLine(

    input wire clk,
    input wire rst,
    input wire req,
    input wire [15:0]start_x,
    input wire [15:0]start_y,
    input wire [15:0]end_x,
    input wire [15:0]end_y,
    
    output reg [15:0]out_x,
    output reg [15:0]out_y,
    output reg ack
    
    );
    
    localparam 
        LINE_START    = 4'b000,
        DIRECTION_SET = 4'b001,
        DRAW_HI_SLOPE = 4'b011,
        DRAW_LO_SLOPE = 4'b010,
        LINE_FINISH   = 4'b110;
    
    reg [15:0]out_x_nxt;
    reg [15:0]out_y_nxt; 
    reg ack_nxt;
    reg [3:0] state;
    
    reg signed [15:0] d; 
    reg signed [15:0] delta_A; 
    reg signed [15:0] delta_B; 
    reg signed [15:0] dx; 
    reg signed [15:0] dy;

    reg signed y_inc; 
    reg signed x_inc;
    

    
    always @(posedge clk or posedge rst)
    begin
        if( rst == 1'b1) 
        begin
            out_x <= 0;
            out_y <= 0;
            ack   <= 0;
            d  <= 0;             
            state <= LINE_START;
            
            delta_A  <= 0;
            delta_B  <= 0;
            dx <= 0;
            dy <= 0;
            
        end
        else 
        begin
            
            case( state )
            
                LINE_START:
                begin
                    
                    if( req == 1) begin
                        
                        if( start_x > end_x ) begin
                            dx <= start_x - end_x;
                            x_inc <= -1;
                        end
                        else begin
                            dx <= end_x - start_x;
                            x_inc <= 1;
                        end
                        
                        if( start_y > end_y ) begin
                            dy <= start_y - end_y;
                            y_inc <= -1;
                        end
                        else begin
                            dy <= end_y - start_y;
                            y_inc <= 1;
                        end
                        
                        state <= DIRECTION_SET;
                        
                    end
                    else 
                    begin
                        dx = 0;
                        dy = 0;
                        y_inc <= 0;
                        x_inc <= 0;
                        state <= LINE_START;
                    end    
                end
                
                DIRECTION_SET:
                begin
                    
                    out_x <= start_x;
                    out_y <= start_y;
                    ack   <= 1; 
                    
                    if( dx  > dy ) begin
                        
                        d       <= 2*dy - dx;
                        delta_A <= 2*dy;
                        delta_B <= 2*dy - 2*dx;
                        state   <= DRAW_LO_SLOPE;
                    end
                    else 
                    begin
                        d       <= 2*dx - dy;
                        delta_A <= 2*dx;
                        delta_B <= 2*dx - 2*dy;
                        state  <= DRAW_HI_SLOPE;
                    end
                    
                end
                
                DRAW_LO_SLOPE:
                begin
                    ack <= 1;
                    if( d > 0 ) begin
                        d <= d + delta_B;
                        out_x <= out_x + x_inc;
                        out_y <= out_y + y_inc;
                    end
                    else begin
                        d <= d + delta_A;
                        out_x <= out_x + x_inc;                       
                    end
                    
                    if( out_x + x_inc == end_x ) state = LINE_FINISH;
                    else state = DRAW_LO_SLOPE;
                    
                end
                
                DRAW_HI_SLOPE:
                begin
                    ack <= 1;
                    if( d > 0 ) begin
                        d <= d + delta_B;
                        out_x <= out_x + x_inc;
                        out_y <= out_y + y_inc;
                    end
                    else begin
                        d <= d + delta_A;
                        out_y <= out_y + y_inc;                       
                    end       
                    
                    if( out_y + y_inc == end_y ) state = LINE_FINISH;
                    else state = DRAW_HI_SLOPE;
                end
                
                LINE_FINISH:
                begin 
                    
                    ack <= 0;
                    if( req == 0)
                        state <= LINE_START;
                    else
                        state <= LINE_FINISH;
                end
            
            endcase
            
        end
    end
    
endmodule
