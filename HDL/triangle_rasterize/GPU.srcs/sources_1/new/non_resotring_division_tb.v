`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2020 11:46:29
// Design Name: 
// Module Name: non_resotring_division_tb
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


module non_resotring_division_tb(

    );
    
    localparam 
        FXP_SHIFT = 16;
    
    reg signed [31:0] Q;
    reg signed [31:0] M;
    reg signed [31:0] A;
    reg [5:0] N;
    real resultFP;
    initial 
    begin
        
        Q = 1 <<< FXP_SHIFT;
        M = 50;
        A = 0; 
        N = 16;      
        #5
        
        while( N != 0 )begin
            if( A < 0 )begin
                Q = Q <<< 1;
                A = A <<< 1;
                A = A + M;
            end
            else begin
                Q = Q <<< 1;
                A = A <<< 1;
                A = A - M;
            end
            #5
        
            if( A <0 ) Q[0] = 0;
            else Q[0] = 1;
        
            #5 
            N = N-1;
            
        end
        
        if( A[31] == 1 ) A = A+M;
        
        $display("Binary result is = %b", Q);
        resultFP = Q;
        resultFP = resultFP / 2**16;
        $display("Real value is = %f", resultFP);
        $finish;
    end
    
    
    
endmodule
