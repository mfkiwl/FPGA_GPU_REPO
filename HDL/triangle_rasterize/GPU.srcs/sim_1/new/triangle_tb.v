`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.05.2020 15:55:55
// Design Name: 
// Module Name: triangle_tb
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


module triangle_tb(

    );
    reg clk;
    reg rst;
    reg req;
    wire ack_in;
    wire ack_out;
    wire [15:0] out_x;
    wire [15:0] out_y;

    reg [15:0]upper_x;
    reg [15:0]upper_y;
    reg [15:0]mid_x;
    reg [15:0]mid_y; 
    reg [15:0]lower_x;
    reg [15:0]lower_y; 

    reg [23:0]base_color;
    wire [7:0]R_out;
    wire [7:0]G_out;
    wire [7:0]B_out;
    reg [7:0]grad_in;
    

triangle_rasterize triangle1(
    .clk(clk),
    .rst(rst),
    .req(req),  
    .upper_x(upper_x),
    .upper_y(upper_y),     
    .mid_x(mid_x),
    .mid_y(mid_y), 
    .lower_x(lower_x),
    .lower_y(lower_y),
    .out_x(out_x),
    .out_y(out_y), 
    .ack_out(ack_out),
    .ack_in(ack_in),
    .R_out(R_out),
    .G_out(G_out),
    .B_out(B_out),
    .base_color(base_color),
    .grad(grad_in)
    );
    

    localparam 
        
        TEST_SET_DATA       = 4'b0000,
        TEST_PROCESSING     = 4'b0001,
        TEST_SAVE_RESULTS   = 4'b0010,
        TEST_FINISH         = 4'b0011,
        TEST_RETRIGGER      = 4'b0100,
        TEST_TRIGGER_ON     = 4'b0101,
        TEST_NUMBER         = 5;     
        
    reg [15:0] vector_test_upper_x[TEST_NUMBER:0];  
    reg [15:0] vector_test_upper_y[TEST_NUMBER:0]; 
    reg [15:0] vector_test_mid_x[TEST_NUMBER:0]; 
    reg [15:0] vector_test_mid_y[TEST_NUMBER:0]; 
    reg [15:0] vector_test_lower_x[TEST_NUMBER:0]; 
    reg [15:0] vector_test_lower_y[TEST_NUMBER:0]; 
    integer file_ptr;
    integer file_open;
    integer test_num;
    reg[23:0] color_out;
    
    reg [4:0] test_state;
    
    task OPEN_FILE;
        reg [10*8:1] file_name;
    begin
        file_name = {"dziadostwo", ".txt"};
        file_ptr = $fopen("C:\\Users\\Karol\\Desktop\\dziadostwo.txt", "wb"); 
        file_open = 1;
    end
    endtask
    
    task CLOSE_FILE;
    begin
        $fclose(file_ptr);
        file_open = 0;
    end
    endtask    
    
initial
begin 
    
vector_test_upper_x[0] = 100;  
vector_test_upper_y[0] = 200; 
vector_test_mid_x[0]   = 300; 
vector_test_mid_y[0]   = 60; 
vector_test_lower_x[0] = 10; 
vector_test_lower_y[0] = 10; 

vector_test_upper_x[1] = 400;  
vector_test_upper_y[1] = 200; 
vector_test_mid_x[1]   = 600; 
vector_test_mid_y[1]   = 60; 
vector_test_lower_x[1] = 310; 
vector_test_lower_y[1] = 10; 

vector_test_upper_x[2] = 700;  
vector_test_upper_y[2] = 200; 
vector_test_mid_x[2]   = 610; 
vector_test_mid_y[2]   = 60; 
vector_test_lower_x[2] = 900; 
vector_test_lower_y[2] = 10; 

vector_test_upper_x[3] = 100;  
vector_test_upper_y[3] = 500; 
vector_test_mid_x[3]   = 300; 
vector_test_mid_y[3]   = 360; 
vector_test_lower_x[3] = 10; 
vector_test_lower_y[3] = 360; 

vector_test_upper_x[4] = 400;  
vector_test_upper_y[4] = 500; 
vector_test_mid_x[4]   = 600; 
vector_test_mid_y[4]   = 500; 
vector_test_lower_x[4] = 310; 
vector_test_lower_y[4] = 310;

    clk = 0;
    rst = 1;
    #1 rst = 0;
end

always 
begin
    #5 clk = !clk;
end

initial
begin
    OPEN_FILE;
    req = 0;
    test_num = 0;
    test_state = TEST_SET_DATA;
    base_color = 24'hffff0f;
    grad_in = 1;
    
end

always @(negedge clk)
begin
    
    case(test_state)
    
    TEST_SET_DATA: 
    begin
       $display("Test number %d, data in upper(%d, %d  ), mid(%d, %d ), upper( %d, %d)", test_num,  vector_test_upper_x[test_num],  vector_test_upper_y[test_num], vector_test_mid_x[test_num], vector_test_mid_y[test_num], vector_test_lower_x[test_num],  vector_test_lower_y[test_num]);
       upper_x = vector_test_upper_x[test_num];
       upper_y = vector_test_upper_y[test_num];
       mid_x = vector_test_mid_x[test_num];
       mid_y = vector_test_mid_y[test_num]; 
       lower_x = vector_test_lower_x[test_num];
       lower_y = vector_test_lower_y[test_num];      
       req = 1'b0;
       test_state = TEST_TRIGGER_ON;
    end
    

    TEST_PROCESSING:
    begin
        req = 1'b1;
        if(ack_in == 1'b1) test_state = TEST_FINISH;
        else if( ack_out == 1'b1 ) test_state = TEST_SAVE_RESULTS;
        else test_state = TEST_PROCESSING;
    end
    TEST_SAVE_RESULTS:
    begin 
        req = 1'b1;
        $display("X = %d, Y= %d", out_x, out_y);
        color_out = ((R_out<<16)|(G_out<<8)|B_out);
        $fwriteb(file_ptr, "%d,%d,#%x\n", out_x, out_y, color_out) ;
        if(ack_in == 1'b1) test_state = TEST_FINISH;
        else if( ack_out == 1'b0 ) test_state = TEST_PROCESSING;
        else test_state =  TEST_SAVE_RESULTS; 
    end  
    TEST_TRIGGER_ON:
    begin 
        req = 1'b1;
        test_state =  TEST_PROCESSING; 
    end     
     
    TEST_FINISH:
    begin 
        req = 1'b0;
        test_num = test_num + 1;
        grad_in = grad_in+1;
        if(test_num == TEST_NUMBER ) begin
            CLOSE_FILE;
            $finish;
        end
        else test_state = TEST_SET_DATA;
        
    end
    endcase
    

    

end


endmodule
