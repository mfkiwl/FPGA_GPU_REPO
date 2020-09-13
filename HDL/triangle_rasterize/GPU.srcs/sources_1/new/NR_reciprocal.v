module NR_reciprocal(
  input wire clk,
  input wire rst,
  input wire req,
  input wire [31:0]num,
  output reg [31:0]reciprocal,
  output reg ack
 );

// Constants

localparam 
 A                   = 32'h01E1E1, // Fixed point [5:19] representation of 1.88235
 B                   = 32'h02D2D2, // Fixed point [5:19] representation of 2,82353
 HALF                = 2<<<14, // Fixed point [4:19] representation of 0.5
 TWO                 = 2<<<16, // Fixed point [4:19] representation of 2
 FXP_SHIFT           = 16,
 MUL_SCALED          = 4'b0000,
 SHIFT_SCALED        = 4'b0001,
 SUB_2               = 4'b0010,
 MUL_NEW             = 4'b0011,
 SCALING_2           = 4'b0100,
 COMPARE             = 4'b0110,
 NEXT_ITERATION      = 4'b0111,
 FINISH              = 4'b1000,
 PRE_SCALING         = 4'b1001,
 LINEAR_APPROX_MUL   = 4'b1010,
 LINEAR_APPROX_SHIFT = 4'b1011,
 LINEAR_APPROX_SUB   = 4'b1100, 
 START               = 4'b1101,
 FINAL_SCALING       = 4'b1110; 
 
// Variables
reg [5:0] scaling; // Keeps scaling factor
reg [63:0] mulResult; // Temporary result of multiplication [5:19] * [5;19]
reg [31:0] scaledVal;
reg [31:0] approxVal;
reg [31:0] newVal;
reg [3:0] st_reg;



reg [5:0]  scaling_nxt; // Keeps scaling factor
reg [63:0] mulResult_nxt; // Temporary result of multiplication [5:19] * [5;19]
reg [31:0] scaledVal_nxt;
reg [31:0] approxVal_nxt;
reg [31:0] newVal_nxt;
reg [3:0]  st_reg_nxt;
reg ack_nxt;
reg [31:0]reciprocal_nxt;

 

always@(posedge clk or posedge rst) begin
    
    if( rst == 1'b1 )
    begin
        scaling    <=  0;
        mulResult  <=  0; 
        scaledVal  <=  0; 
        approxVal  <=  0;
        newVal     <=  0;
        st_reg     <=  START;
        ack        <=  0;
        reciprocal <= 0;
    
    end
    else
    begin
        scaling    <=  scaling_nxt;
        mulResult  <=  mulResult_nxt; 
        scaledVal  <=  scaledVal_nxt; 
        approxVal  <=  approxVal_nxt;
        newVal     <=  newVal_nxt;
        st_reg     <=  st_reg_nxt;
        ack        <=  ack_nxt;
        reciprocal <= reciprocal_nxt;
    end

end

    // fsm 
always@* begin

   case( st_reg )
        
        START:
        begin
            if( req == 1'b1 ) st_reg_nxt = PRE_SCALING;
            else st_reg_nxt = START;
        end
        
        PRE_SCALING:                  if( scaledVal < HALF ) st_reg_nxt = PRE_SCALING;
                                      else                       st_reg_nxt = LINEAR_APPROX_MUL;
        LINEAR_APPROX_MUL:            st_reg_nxt = LINEAR_APPROX_SHIFT; 
        LINEAR_APPROX_SHIFT:          st_reg_nxt = LINEAR_APPROX_SUB;
        LINEAR_APPROX_SUB:            st_reg_nxt = MUL_SCALED;   
        MUL_SCALED:                   st_reg_nxt = SHIFT_SCALED;
        SHIFT_SCALED:                 st_reg_nxt = SUB_2; 
        SUB_2:                        st_reg_nxt = MUL_NEW;
        MUL_NEW:                      st_reg_nxt = SCALING_2;      
        SCALING_2:                    st_reg_nxt = COMPARE;
        COMPARE:                      if( approxVal == newVal ) st_reg_nxt = FINAL_SCALING;
                                      else                      st_reg_nxt = NEXT_ITERATION;
        NEXT_ITERATION:               st_reg_nxt = MUL_SCALED;      
        FINAL_SCALING:                st_reg_nxt = FINISH;     
        FINISH:                       if(req == 0) st_reg_nxt = START;
                                      else         st_reg_nxt = FINISH;        
       default:                       st_reg_nxt = START;       
     endcase
     
end

// scaling

always@* begin

   case( st_reg )
        
        START:
        begin
            scaledVal_nxt = num;
            scaling_nxt = FXP_SHIFT;
        end
        
        PRE_SCALING:
        begin
            if( scaledVal_nxt < HALF )begin
                scaledVal_nxt = scaledVal << 1; // Multiply by two i.e. LSR
                scaling_nxt = scaling - 1;
            end
            else 
            begin
                scaledVal_nxt = scaledVal; // Multiply by two i.e. LSR
                scaling_nxt = scaling;
            end
        end
       
       default:
       begin
                scaledVal_nxt = scaledVal; // Multiply by two i.e. LSR
                scaling_nxt = scaling;
       end 
       
     endcase
     
end
     


    // approx val
always@* begin

   case( st_reg )
        
        LINEAR_APPROX_SHIFT:   approxVal_nxt = mulResult >> FXP_SHIFT;
        LINEAR_APPROX_SUB:     approxVal_nxt = B - approxVal;
        NEXT_ITERATION:        approxVal_nxt = newVal; // ASSIGN_NEW        
        FINAL_SCALING:         approxVal_nxt = approxVal>> scaling;
        default:               approxVal_nxt = approxVal;      
     endcase
     
end

// mul result

always@* begin
   case( st_reg )      
        LINEAR_APPROX_MUL:     mulResult_nxt = scaledVal * A;  
        MUL_SCALED:            mulResult_nxt = approxVal * scaledVal; 
        MUL_NEW:               mulResult_nxt = approxVal * newVal;   
       default:                mulResult_nxt = mulResult;  
     endcase   
end

// new val

always@* begin
   case( st_reg )      
        SHIFT_SCALED:   newVal_nxt = mulResult >> FXP_SHIFT;
        SUB_2:          newVal_nxt = TWO - newVal;
        SCALING_2:      newVal_nxt = mulResult >> FXP_SHIFT;  
        default:        newVal_nxt = newVal;
     endcase   
end

always@* begin

   case( st_reg )

        FINISH:
        begin
            reciprocal_nxt = approxVal;
            ack_nxt = 1'b1;                   
        end
       default:
        begin
            ack_nxt = 0;
            reciprocal_nxt = reciprocal;       
        end
       
     endcase
     
end
endmodule