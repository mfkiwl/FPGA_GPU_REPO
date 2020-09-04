`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.09.2020 20:41:36
// Design Name: 
// Module Name: basic_cell_tb
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


module basic_cell_tb(

    );
    
    localparam 
        
    TEST_SET_DATA       = 4'b0000,
    TEST_PROCESSING     = 4'b0001,
    TEST_SAVE_RESULTS   = 4'b0010,
    TEST_FINISH         = 4'b0011,
    TEST_RETRIGGER      = 4'b0100,
    TEST_TRIGGER_ON     = 4'b0101,
    TEST_NUMBER         = 4;    
    
    reg [15:0] vector_test_upper_x[TEST_NUMBER:0];  
    reg [15:0] vector_test_upper_y[TEST_NUMBER:0]; 
    reg [15:0] vector_test_upper_z[TEST_NUMBER:0]; 
    reg [15:0] vector_test_mid_x[TEST_NUMBER:0]; 
    reg [15:0] vector_test_mid_y[TEST_NUMBER:0]; 
    reg [15:0] vector_test_mid_z[TEST_NUMBER:0]; 
    reg [15:0] vector_test_lower_x[TEST_NUMBER:0]; 
    reg [15:0] vector_test_lower_y[TEST_NUMBER:0]; 
    reg [15:0] vector_test_lower_z[TEST_NUMBER:0]; 
    
    reg clk;
    reg rst;

    wire ack_out_rast;
    wire [15:0] out_x;
    wire [15:0] out_y;

    reg [15:0]upper_x;
    reg [15:0]upper_y;
    reg [15:0]upper_z;
    reg [15:0]mid_x;
    reg [15:0]mid_y; 
    reg [15:0]mid_z;
    reg [15:0]lower_x;
    reg [15:0]lower_y; 
    reg [15:0]lower_z;
    
    wire [15:0]upper_x_inter;
    wire [15:0]upper_y_inter;

    wire [15:0]mid_x_inter;
    wire [15:0]mid_y_inter; 

    wire [15:0]lower_x_inter;
    wire [15:0]lower_y_inter; 


    reg [23:0]base_color;
    wire [7:0]R_out;
    wire [7:0]G_out;
    wire [7:0]B_out;
    reg [7:0]grad_in;
    
    wire ack_out;
    
    reg pp_req;
    
    
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
        .in_x({16'b0,upper_x}),   
        .in_y({16'b0,upper_y}),   
        .in_z({16'b0,upper_z}), 
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
        .in_x({16'b0,mid_x}),   
        .in_y({16'b0,mid_y}),   
        .in_z({16'b0,mid_z}), 
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
        .in_x({16'b0,lower_x}),   
        .in_y({16'b0,lower_y}),   
        .in_z({16'b0,lower_z}), 
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
        
    vector_test_lower_x[0] = 600;  
    vector_test_lower_y[0] = 10; 
    vector_test_mid_x[0]   = 310; 
    vector_test_mid_y[0]   = 60; 
    vector_test_upper_x[0] = 400; 
    vector_test_upper_y[0] = 200;
        vector_test_upper_z[0] = 50;  
    vector_test_mid_z[0]   = 50; 
    vector_test_lower_z[0] = 50; 
 
    vector_test_lower_x[1] = 600;  
    vector_test_lower_y[1] = 10; 
    vector_test_mid_x[1]   = 310; 
    vector_test_mid_y[1]   = 60; 
    vector_test_upper_x[1] = 400; 
    vector_test_upper_y[1] = 200;
        vector_test_upper_z[1] = 40;  
    vector_test_mid_z[1]   = 40; 
    vector_test_lower_z[1] = 40; 

    vector_test_lower_x[2] = 600;  
    vector_test_lower_y[2] = 10; 
    vector_test_mid_x[2]   = 310; 
    vector_test_mid_y[2]   = 60; 
    vector_test_upper_x[2] = 400; 
    vector_test_upper_y[2] = 200;
        vector_test_upper_z[2] = 30;  
    vector_test_mid_z[2]   = 30; 
    vector_test_lower_z[2] = 30; 
    
    vector_test_lower_x[3] = 600;  
    vector_test_lower_y[3] = 10; 
    vector_test_mid_x[3]   = 310; 
    vector_test_mid_y[3]   = 60; 
    vector_test_upper_x[3] = 400; 
    vector_test_upper_y[3] = 200;
        vector_test_upper_z[3] = 25;  
    vector_test_mid_z[3]   = 25; 
    vector_test_lower_z[3] = 25; 

 
    
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
        pp_req = 0;
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
           lower_z = vector_test_lower_z[test_num]; 
            mid_z = vector_test_mid_z[test_num]; 
            upper_z = vector_test_upper_z[test_num];   
           pp_req = 1'b0;
           test_state = TEST_TRIGGER_ON;
        end
        
    
        TEST_PROCESSING:
        begin
            pp_req = 1'b1;
            if(pp_ack_lower == 1'b1) test_state = TEST_FINISH;
            else if( ack_out == 1'b1 ) test_state = TEST_SAVE_RESULTS;
            else test_state = TEST_PROCESSING;
        end
        TEST_SAVE_RESULTS:
        begin 
            pp_req = 1'b1;
            $display("X = %d, Y= %d", out_x, out_y);
            color_out = ((R_out<<16)|(G_out<<8)|B_out);
            $fwriteb(file_ptr, "%d,%d,#%x\n", out_x, out_y, color_out) ;
            if(pp_ack_lower == 1'b1) test_state = TEST_FINISH;
            else if( ack_out == 1'b0 ) test_state = TEST_PROCESSING;
            else test_state =  TEST_SAVE_RESULTS; 
        end  
        TEST_TRIGGER_ON:
        begin 
            pp_req = 1'b1;
            test_state =  TEST_PROCESSING; 
        end     
         
        TEST_FINISH:
        begin 
            pp_req = 1'b0;
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
