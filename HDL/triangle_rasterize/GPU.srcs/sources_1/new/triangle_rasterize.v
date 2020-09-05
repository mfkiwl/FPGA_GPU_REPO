`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.05.2020 11:21:30
// Design Name: 
// Module Name: triangle_rasterize
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


module triangle_rasterize#(
    parameter DATA_WIDTH = 15
)
(

    input wire clk,
    input wire rst,
    input wire req,
    
    input wire [DATA_WIDTH:0]upper_x,
    input wire [DATA_WIDTH:0]upper_y,
     
    input wire [DATA_WIDTH:0]mid_x,
    input wire [DATA_WIDTH:0]mid_y,
    
    input wire [DATA_WIDTH:0]lower_x,
    input wire [DATA_WIDTH:0]lower_y,
    
    input wire [23:0]base_color,
    
    input wire [7:0]grad,
    
    output reg [DATA_WIDTH:0]out_x,
    output reg [DATA_WIDTH:0]out_y,
    
    output reg ack_out,
    output reg ack_in,
    output reg [7:0]R_out,
    output reg [7:0]G_out,
    output reg [7:0]B_out
    
    );
    
    wire line1_ack;
    wire line2_ack;
    wire line3_ack;
    
    reg line1_req;
    reg line2_req;
    reg line3_req;
    reg [3:0]status_reg;
    
    reg limiter_reset, limiter_reset_nxt;
    reg [DATA_WIDTH:0] y_ctr;
    reg [DATA_WIDTH:0] lower_limit;
    reg [DATA_WIDTH:0] upper_limit;
    
    wire [DATA_WIDTH:0] line1;
    wire [DATA_WIDTH:0] line2;
    wire [DATA_WIDTH:0] line3;
    
    
    
    reg [3:0]status_reg_nxt;
    reg [DATA_WIDTH:0] y_ctr_nxt;
    reg [DATA_WIDTH:0] lower_limit_nxt;
    reg [DATA_WIDTH:0] upper_limit_nxt;
    
    reg [DATA_WIDTH:0]out_x_nxt;
    reg [DATA_WIDTH:0]out_y_nxt;
    
    reg line1_req_nxt;
    reg line2_req_nxt;
    reg line3_req_nxt;
    
    reg ack_out_nxt;
    reg ack_in_nxt;
    
    reg [7:0]R_out_nxt;
    reg [7:0]G_out_nxt;
    reg [7:0]B_out_nxt;
    
        
    
    Bresenham_modified draw_line1
    (
        .req(line1_req),
        .rst(rst | limiter_reset),
        .clk(clk),
        .start_x(lower_x),
        .start_y(lower_y),
        .end_x(upper_x),
        .end_y(upper_y),
        .out_x(line1),
        .ack(line1_ack)
        );
        
     Bresenham_modified draw_line2
     (
        .req(line2_req),
        .rst(rst | limiter_reset),
        .clk(clk),
        .start_x(lower_x),
        .start_y(lower_y),
        .end_x(mid_x),
        .end_y(mid_y),
        .out_x(line2),
        .ack(line2_ack)        
      );
    
      Bresenham_modified draw_line3
      (
         .req(line3_req),
         .rst(rst | limiter_reset),
         .clk(clk),
         .start_x(mid_x),
         .start_y(mid_y),
         .end_x(upper_x),
         .end_y(upper_y),
         .out_x(line3),
         .ack(line3_ack)
       );
    localparam
    
    START             = 4'b0000,
    PRE_TRIGGER       = 4'b0001,
    GET_LIMITS_LOWER  = 4'b0010,
    DRAW_LOWER        = 4'b0011,
    GET_LIMITS_UPPER  = 4'b0100,
    DRAW_UPPER        = 4'b0101,
    LAST_POINT        = 4'b0110,
    FINISH            = 4'b0111,
    RETRIGGER_LOW     = 4'b1000,
    RETRIGGER_UP      = 4'b1001,
    INTERMEDIATE_UP   = 4'b1010,
    INTERMEDIATE_DOWN = 4'b1011,
    VERTICAL_INC_LOW  = 4'b1100,
    VERTICAL_INC_HI   = 4'b1101;
    
    always @(posedge clk or posedge rst)
    begin
    
        if(rst == 1'b1)begin
             status_reg = START;
             
             out_x <= 0;
             out_y <= 0;             
             ack_out <= 0;
             ack_in <= 0;             
             y_ctr <= 0;
             lower_limit <= 0 ;
             upper_limit <= 0;
             limiter_reset <= 1;
             line1_req <= 0;
             line2_req <= 0;
             line3_req <= 0; 
             R_out <= 0;
             G_out <= 0;
             B_out <= 0;
        
        end
        
        else 
        begin 
            status_reg <= status_reg_nxt;
            limiter_reset <= limiter_reset_nxt;
            out_x <= out_x_nxt;
            out_y <= out_y_nxt;
        
            ack_out <= ack_out_nxt;
            ack_in <= ack_in_nxt;
        
            y_ctr <= y_ctr_nxt;
            lower_limit <= lower_limit_nxt ;
            upper_limit <= upper_limit_nxt;
        
            line1_req <= line1_req_nxt;
            line2_req <= line2_req_nxt;
            line3_req <= line3_req_nxt; 
            
            R_out <= R_out_nxt;
            G_out <= G_out_nxt;
            B_out <= B_out_nxt;
        
        end
        
    end
    
    always @*
    begin 
     case(status_reg)
                   
                   START: 
                   begin                      
                       if(req == 0) status_reg_nxt = START;
                       else         status_reg_nxt = PRE_TRIGGER;                    
                   end 
                             
                   PRE_TRIGGER:     status_reg_nxt = GET_LIMITS_LOWER;  
                      
                   GET_LIMITS_LOWER:
                   begin                       
                       if( out_y == mid_y)      status_reg_nxt = GET_LIMITS_UPPER;     
                       else if((line1_ack == 1'b1) && (line2_ack == 1'b1)) status_reg_nxt = RETRIGGER_LOW;                           
                       else status_reg_nxt = GET_LIMITS_LOWER;                                      
                   end     
                   
                   VERTICAL_INC_LOW: status_reg_nxt = GET_LIMITS_LOWER;  
                                                     
                   RETRIGGER_LOW:
                   begin                                            
                      if( (line1_ack == 1'b0) && (line2_ack == 1'b0) ) status_reg_nxt = INTERMEDIATE_DOWN;                      
                      else status_reg_nxt = RETRIGGER_LOW;           
                   end  
                   INTERMEDIATE_DOWN:
                   begin
                       if( out_x == upper_limit ) status_reg_nxt =  VERTICAL_INC_LOW;  
                       else                       status_reg_nxt = DRAW_LOWER;                       
                   end
                     
                   DRAW_LOWER:
                   begin
                       if( out_x+1 == upper_limit ) status_reg_nxt =  VERTICAL_INC_LOW;  
                       else                         status_reg_nxt = DRAW_LOWER;
                   end       
                   
                   GET_LIMITS_UPPER:
                   begin                                             
                       if( out_y == upper_y+1) status_reg_nxt = FINISH;    
                       else if((line1_ack == 1'b1) && (line3_ack == 1'b1)) status_reg_nxt = RETRIGGER_UP;    
                   end    
                      
                   DRAW_UPPER:
                   begin
                       if( out_x+1 == upper_limit ) status_reg_nxt =  VERTICAL_INC_HI;                    
                       else                         status_reg_nxt = DRAW_UPPER;    
                   end  
                   
                   RETRIGGER_UP:
                   begin
                       if( (line1_ack == 1'b0) && (line3_ack == 1'b0) ) status_reg_nxt = INTERMEDIATE_UP;                
                       else                                             status_reg_nxt = RETRIGGER_UP;
                   end
                                     
                   INTERMEDIATE_UP:
                   begin
                       if( out_x == upper_limit ) status_reg_nxt =  VERTICAL_INC_HI;    
                       else                       status_reg_nxt = DRAW_UPPER;                      
                   end
                   
                   VERTICAL_INC_HI:              status_reg_nxt = GET_LIMITS_UPPER;                  
                   
                   FINISH:
                   begin
                      if(req == 0) status_reg_nxt = START;
                      else status_reg_nxt = FINISH;
                    end
               endcase
    
    end
    
    // limits controller
    always @*
    begin 
     case(status_reg)
        GET_LIMITS_LOWER:
        begin                       
                if(line1 > line2)  upper_limit_nxt = line1;
                else               upper_limit_nxt = line2;                                                                                                                
        end     
        
        GET_LIMITS_UPPER:
        begin                                             
                if(line1 > line3)   upper_limit_nxt = line1;
                else                upper_limit_nxt = line3;                                                       
        end 
        
        default: upper_limit_nxt = upper_limit;
           
     endcase

end 
     
        // output controller
    always @*
    begin 
     case(status_reg)
                           
                   PRE_TRIGGER:
                   begin
                       out_x_nxt = lower_x;
                       out_y_nxt = lower_y;
                   end                       
                   GET_LIMITS_LOWER :
                   begin   
                        out_y_nxt = out_y;                    
                        if(line1 > line2) out_x_nxt = line2;
                        else              out_x_nxt  = line1;                                                                                      
                   end     
                   VERTICAL_INC_LOW:
                   begin
                       out_y_nxt = out_y+1;
                       out_x_nxt = out_x;                  
                   end                                       
                   DRAW_LOWER:
                   begin
                        out_x_nxt = out_x+1;
                        out_y_nxt = out_y;  
                   end                         
                   GET_LIMITS_UPPER:
                   begin        
                        out_y_nxt = out_y;                                      
                        if(line1 > line3) out_x_nxt = line3;
                        else              out_x_nxt  = line1;                                                    
                   end    
                      
                   DRAW_UPPER:
                   begin
                           out_x_nxt = out_x+1;
                           out_y_nxt = out_y;   
                   end                                      
                   VERTICAL_INC_HI:
                   begin                   
                        out_y_nxt = out_y+1;
                        out_x_nxt = out_x;                
                   end
                   default:
                   begin
                        out_y_nxt = out_y;
                        out_x_nxt = out_x;
                   end
               endcase
    
    end
    
    
    // handshake controller
    
    always @*
    begin 
     case(status_reg)         
                   
                   RETRIGGER_LOW:
                   begin
                      ack_in_nxt = 0;                        
                      if( (line1_ack == 1'b0) && (line2_ack == 1'b0) ) ack_out_nxt = 1;                      
                      else ack_out_nxt = 0;
               
                   end  
                   INTERMEDIATE_DOWN:
                   begin
                       ack_in_nxt = 0;  
                       if( out_x == upper_limit ) ack_out_nxt = 0;
                       else                       ack_out_nxt = 1;                                           
                   end
                     
                   DRAW_LOWER:
                   begin
                       ack_in_nxt = 0; 
                       if( out_x+1 == upper_limit ) ack_out_nxt = 0;
                       else                         ack_out_nxt = 1; 
   
                   end       
                                       
                   DRAW_UPPER:
                   begin
                       ack_in_nxt = 0;
                       if( out_x+1 == upper_limit ) ack_out_nxt = 0; 
                       else                         ack_out_nxt = 1; 
                   end  
                   
                   RETRIGGER_UP:
                   begin
                       ack_in_nxt = 0;
                       if( (line1_ack == 1'b0) && (line3_ack == 1'b0) ) ack_out_nxt = 1;                                 
                       else                                             ack_out_nxt = 0;
                   end
                   
                   INTERMEDIATE_UP:
                   begin
                       ack_in_nxt = 0; 
                       if( out_x == upper_limit ) ack_out_nxt = 0;
                       else                       ack_out_nxt = 1;                      
                   end
                                      
                   FINISH:
                   begin                      
                      ack_out_nxt = 0;
                      ack_in_nxt = 1;
                    end
                    
                    default:
                    begin                      
                       ack_out_nxt = 0;
                       ack_in_nxt = 0;
                     end
               endcase
    
    end
    
    
    // limiter controller
    always @*
    begin 
     case(status_reg)
                   
                   START: 
                   begin            
                       line3_req_nxt = 0;
                       line2_req_nxt = 0;
                       line1_req_nxt = 0;          
                       limiter_reset_nxt = 0;                  
                   end           
                   PRE_TRIGGER:
                   begin
                       limiter_reset_nxt = 0;
                       line3_req_nxt = 0;
                       line2_req_nxt = 1;
                       line1_req_nxt = 1;
                   end       
                   GET_LIMITS_LOWER:
                   begin
                       line3_req_nxt = 0;
                       limiter_reset_nxt = 0;                                             
                       if( out_y == mid_y) begin    
                            line3_req_nxt = 1;
                            line1_req_nxt = 1;   
                       end   
                       if((line1_ack == 1'b1) && (line2_ack == 1'b1))
                       begin                   
                           line2_req_nxt = 1;
                           line1_req_nxt = 1;                                  
                       end
                       else
                       begin
                           line2_req_nxt = 0;
                           line1_req_nxt = 0;
                       end                                      
                   end
                                                                                        
                   GET_LIMITS_UPPER:
                   begin

                       limiter_reset_nxt = 0;
                       line2_req_nxt = 0;
                       if( out_y == upper_y+1) begin
                            line3_req_nxt = 0;
                            line1_req_nxt = 0;
                       end
                       else if((line1_ack == 1'b1) && (line3_ack == 1'b1))
                       begin                        
                           line3_req_nxt = 1;
                           line1_req_nxt = 1;         
                       end
                       else 
                       begin
                           line3_req_nxt = 0;
                           line1_req_nxt = 0;
                       end                       
                       
                   end    
                                          
                   FINISH:
                   begin                       
                       line3_req_nxt = 0;
                       line2_req_nxt = 0;
                       line1_req_nxt = 0;          
                       limiter_reset_nxt = 1;                         
                    end
                   
                   default:
                   begin
                       line3_req_nxt = 0;
                       line2_req_nxt = 0;
                       line1_req_nxt = 0;          
                       limiter_reset_nxt = 0;          
                   end 
                   
               endcase
    
    end
    
    // color processing 
    always @*
    begin 
        
        case(status_reg)
        PRE_TRIGGER:
        begin
            R_out_nxt = base_color[23:16];
            G_out_nxt = base_color[15:8];
            B_out_nxt = base_color[7:0];
        end
        INTERMEDIATE_UP:
        begin
            R_out_nxt = R_out > grad ? R_out - grad : R_out;
            G_out_nxt = G_out > grad ? G_out - grad : G_out;
            B_out_nxt = B_out > grad ? B_out - grad : B_out;
        end
        INTERMEDIATE_DOWN:
        begin
            R_out_nxt = R_out > grad ? R_out - grad : R_out;
            G_out_nxt = G_out > grad ? G_out - grad : G_out;
            B_out_nxt = B_out > grad ? B_out - grad : B_out;    
        end
        
        default:
        begin
            R_out_nxt = R_out;
            G_out_nxt = G_out;
            B_out_nxt = B_out;
        end
        
        endcase  
    
    end
    
    
    
       
endmodule

