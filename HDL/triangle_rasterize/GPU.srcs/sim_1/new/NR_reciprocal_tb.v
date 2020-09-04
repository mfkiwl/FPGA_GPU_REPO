`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.08.2020 11:09:36
// Design Name: 
// Module Name: NR_reciprocal_tb
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


module NR_reciprocal_tb(

    );
    
    localparam 
    UPPER_LIMIT = 5;
    
    real resultFP; // To display human readable
    
    reg clk;
    reg rst;
    reg req;
    reg [31:0]num;
    wire [31:0]result;
    wire ack;
    
    NR_reciprocal NR(
      .clk(clk),
      .rst(rst),
      .req(req),
      .num(num),
      .reciprocal(result),
      .ack(ack)
     );
    
    integer iterator;
    reg [31:0] test_vector [UPPER_LIMIT:0];
    
// clk generation    
always
    begin
       #5 clk = !clk;
    end

    initial begin
        test_vector[0] = 20;    
        test_vector[1] = 30;
        test_vector[2] = 50;
        test_vector[3] = 100;
        test_vector[4] = 3;
    end

//initialisation    
    initial begin
        iterator = 0;
        clk = 0;
        rst = 1'b1;        
        #1 rst = 0;
        num = test_vector[iterator]; // IDLE
        #10;
        req = 1'b1;
    end    
    
    
    always@( posedge ack )
    begin
        if(req == 1) begin
            // Print result
            $display("Binary result is = %b", result);
            resultFP = result+1'b1;
            resultFP = resultFP / 2**19;
            $display("Real value is = %f", resultFP);
            iterator = iterator + 1;
            req = 0;
        
        
            if( iterator == UPPER_LIMIT)
                $finish;
        
            else begin
                num = test_vector[iterator]; // IDLE
                #20;
                req = 1'b1;
            end
        end
    end
    
endmodule
