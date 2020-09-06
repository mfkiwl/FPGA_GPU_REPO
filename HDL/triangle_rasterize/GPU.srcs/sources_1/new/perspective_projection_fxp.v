`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.09.2020 13:25:40
// Design Name: 
// Module Name: perspective_projection_fxp
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


module perspective_projection_fxp(

    input clk,
    input wire rst,
    
    // INPUT HANDSHAKING
    input wire pp_req_in,
    output reg pp_ack_in,
    
    // OUTPUT HANDSHAKING
    input wire pp_ack_out,
    output reg pp_req_out,
    
    // INPUT SIGNALS
    input wire[15:0]in_x,   
    input wire[15:0]in_y,   
    input wire[15:0]in_z,
    
    // RECIPROCAL MODULE HANDSHAKING AND DATA
    input wire rec_ack, 
    output reg rec_req,
    input wire[31:0] reciprocal_out,
    output reg[31:0] reciprocal_in,
    
    // OUTPUT 2D     
    output reg[15:0] out_x,
    output reg[15:0] out_y
    
    
    );
    
    localparam
        START                 = 4'b0000,
        RECIPROCAL_WAIT       = 4'b0001,
        NORMALIZE_COORDINATES = 4'b0010,
        SHIFT_NORMALIZED      = 4'b0011,
        TO_PIXELS             = 4'b0100,
        SHIFT_2D              = 4'b0101,
        APPLY_OFFSET          = 4'b0110,
        FINISH                = 4'b0111, 
        MUL_COEFF             = 4'b1000,  
        SHIFT_RECIPROCAL      = 4'b1001,    
        GET_DATA              = 4'b1010,
        TRIGGER_RASTERIZER    = 4'B1011, 
        FXP_PRECISSION = 16,
        C1 =  9<<<12, 
        C2 =  0,
        C3 =  1 <<<FXP_PRECISSION,
        C4 =  0 <<<FXP_PRECISSION,
        C5 = -2 <<<FXP_PRECISSION,
        C6 = -3 <<<FXP_PRECISSION,
        H  = 960, 
        W  = 540;
         
    reg [3:0] st_reg;
    reg [31:0] normalized_x;
    reg [31:0] normalized_y;
    reg [31:0] normalized_w;
    
    reg [3:0] st_reg_nxt;
    reg [31:0] normalized_x_nxt;
    reg [31:0] normalized_y_nxt;
    reg [31:0] normalized_w_nxt;
    
    reg pp_ack_nxt;
    reg rec_req_nxt;
    reg pp_req_out_nxt;
    
    reg[31:0] out_x_nxt;
    reg[31:0] out_y_nxt;
    reg[31:0] reciprocal_in_nxt;
    
    always@( posedge clk or posedge rst)
    begin
        if( rst == 1) begin
            st_reg           <=0;
            normalized_x     <=0;
            normalized_y     <=0;
            normalized_w     <=0;
            pp_ack_in        <=0;
            rec_req          <=0;      
            out_x            <=0;
            out_y            <=0;
            reciprocal_in    <=0;
            pp_req_out       <=0;
        end
        else
        begin
            st_reg        <= st_reg_nxt;
            normalized_x  <= normalized_x_nxt;
            normalized_y  <= normalized_y_nxt;
            normalized_w  <= normalized_w_nxt;
            pp_ack_in     <= pp_ack_nxt;
            rec_req       <= rec_req_nxt;    
            out_x         <= out_x_nxt[15:0];
            out_y         <= out_y_nxt[15:0];
            reciprocal_in <= reciprocal_in_nxt;
            pp_req_out    <= pp_req_out_nxt;
        end
    
    end
    
    always@*
    begin    
        case( st_reg )
            
            START:                 if( pp_req_in == 1'b1 ) st_reg_nxt = GET_DATA;  
                                   else                    st_reg_nxt = START;                                   
            GET_DATA:                                      st_reg_nxt = RECIPROCAL_WAIT;                      
            RECIPROCAL_WAIT:       if( rec_ack == 1 )      st_reg_nxt  = MUL_COEFF;
                                   else                    st_reg_nxt  = RECIPROCAL_WAIT;
            MUL_COEFF:                                     st_reg_nxt  = SHIFT_RECIPROCAL;
            SHIFT_RECIPROCAL:                              st_reg_nxt  = NORMALIZE_COORDINATES;
            NORMALIZE_COORDINATES:                         st_reg_nxt  = SHIFT_NORMALIZED;
            SHIFT_NORMALIZED:                              st_reg_nxt  = TO_PIXELS;    
            TO_PIXELS:                                     st_reg_nxt  = SHIFT_2D;
            SHIFT_2D:                                      st_reg_nxt  = APPLY_OFFSET;
            APPLY_OFFSET:                                  st_reg_nxt  = TRIGGER_RASTERIZER;
            TRIGGER_RASTERIZER:    if( pp_ack_out == 1 )   st_reg_nxt = FINISH;
                                   else                    st_reg_nxt  = TRIGGER_RASTERIZER; 
            FINISH:
            begin                
                if(pp_req_in == 0 )                        st_reg_nxt  = START;
                else                                       st_reg_nxt  = FINISH;
            end
            default:                st_reg_nxt  = START;
                    
        endcase
    end
    
    
    always@*
    begin
        case( st_reg )
            GET_DATA:
            begin
                normalized_x_nxt     ={ in_x};
                normalized_y_nxt     ={ in_y};
            end
            MUL_COEFF:
            begin
                normalized_x_nxt  = C1*normalized_x;
                normalized_y_nxt  = C3*normalized_y;
            end
            NORMALIZE_COORDINATES:
            begin
                normalized_x_nxt  = normalized_x*normalized_w; 
                normalized_y_nxt  = normalized_y*normalized_w;
            end
            SHIFT_NORMALIZED:
            begin
                normalized_x_nxt  = normalized_x>>>FXP_PRECISSION; 
                normalized_y_nxt  = normalized_y>>>FXP_PRECISSION;   
            end
            TO_PIXELS:
            begin
                normalized_x_nxt  = normalized_x*H;
                normalized_y_nxt  = normalized_y*W;
            end
            SHIFT_2D:
            begin
                normalized_x_nxt  = normalized_x >>> FXP_PRECISSION;
                normalized_y_nxt  = normalized_y >>> FXP_PRECISSION;
            end
            APPLY_OFFSET:
            begin
                normalized_x_nxt  = normalized_x + H;
                normalized_y_nxt  = normalized_y + W;
            end
            default: 
            begin
                normalized_x_nxt  = normalized_x;
                normalized_y_nxt  = normalized_y;
            end
        endcase
    end
    
    // normalized_w controller
    always@*
    begin
        case( st_reg )
            MUL_COEFF:               normalized_w_nxt  = reciprocal_out*reciprocal_out;
            SHIFT_RECIPROCAL:        normalized_w_nxt  = normalized_w >>> FXP_PRECISSION;
            default:                 normalized_w_nxt  = normalized_w;
        endcase
    end
    
    // reciprocal module controller
    always@*
    begin
        case( st_reg )
            GET_DATA: 
            begin
                reciprocal_in_nxt    = in_z;
                rec_req_nxt          = 1;
            end
            default: 
            begin
                reciprocal_in_nxt    = reciprocal_in;
                rec_req_nxt          = 0;
            end
        endcase
    end
    
    // handshaking and output controller
    always@*
    begin
        case( st_reg )
            TRIGGER_RASTERIZER: 
            begin
                pp_req_out_nxt = 1;
                pp_ack_nxt = 0;
                out_x_nxt  = normalized_x;
                out_y_nxt  = normalized_y;
            end
            FINISH: 
            begin
                pp_req_out_nxt = 0;
                pp_ack_nxt = 1;
                out_x_nxt  = normalized_x;
                out_y_nxt  = normalized_y;
            end
            default: 
            begin
                pp_req_out_nxt = 0;
                pp_ack_nxt = 0;
                out_x_nxt  = 0;
                out_y_nxt  = 0;
            end
        endcase
    end

endmodule