`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/30 16:38:46
// Design Name: 
// Module Name: PE_tb
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


module PE_tb_1
#(
  parameter IN_BIT = 8,
	parameter WEIGHT_BIT = 8,
	parameter MESH_OUT_BIT = 20,
  parameter OUT_BIT = 32,
	parameter MESH_X = 8,
	parameter MESH_Y = 8,
	parameter MESH_N = 4
	)(

    );
    reg clk=0;    
    reg ena=0;
    reg rst_n=0;
    reg data_valid=0;
    reg valid=0;
    reg [1:0]state_x=2'd0;
    reg [1:0]state_y=2'd0;
    
    reg [WEIGHT_BIT-1:0] weight_reg_array[MESH_N*3*3-1:0];
    reg [IN_BIT-1:0] feature_reg_array[MESH_N*(MESH_X+2)*(MESH_Y+2)-1:0];
    reg [OUT_BIT-1:0] result_reg_array[MESH_X*MESH_Y-1:0];
    
    reg [OUT_BIT*MESH_X*MESH_Y-1:0] inter_reg_array;
    reg [WEIGHT_BIT-1:0]weight_reg_in[MESH_N-1:0];
    reg [IN_BIT-1:0]data_reg_in[MESH_N*MESH_X*MESH_Y-1:0];
    
    integer i,j,k;
    
    wire [OUT_BIT*MESH_X*MESH_Y-1:0] data_wire_out;
    wire [OUT_BIT-1:0] data_wire_out_array[MESH_X*MESH_Y-1:0];
    wire [WEIGHT_BIT*MESH_N-1:0]weight_wire_in;
    wire [IN_BIT*MESH_N*MESH_X*MESH_Y-1:0]data_wire_in;
    
    generate
    genvar gen_id;
    for(gen_id=0;gen_id<MESH_N;gen_id=gen_id+1)
    begin:weight_line
        assign weight_wire_in[(1+gen_id)*WEIGHT_BIT-1:gen_id*WEIGHT_BIT]=weight_reg_in[gen_id];
    end
    
    for(gen_id=0;gen_id<MESH_N*MESH_X*MESH_Y;gen_id=gen_id+1)
    begin:data_in_line
        assign data_wire_in[(1+gen_id)*IN_BIT-1:gen_id*IN_BIT]=data_reg_in[gen_id];
    end
    for(gen_id=0;gen_id<MESH_X*MESH_Y;gen_id=gen_id+1)
    begin:data_out_line
        assign data_wire_out_array[gen_id]=data_wire_out[(1+gen_id)*OUT_BIT-1:gen_id*OUT_BIT];
    end
    
    endgenerate
    
    always #10 clk=~clk;
    
    initial
    begin
        $readmemh ("D:/jiantao/TB_data_gener/weight.txt",weight_reg_array);
        $readmemh ("D:/jiantao/TB_data_gener/feature.txt",feature_reg_array);
        $readmemh ("D:/jiantao/TB_data_gener/result.txt",result_reg_array);
        @(posedge clk);
        rst_n<=1;
        ena<=1;
        data_valid<=1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        valid<=1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        data_valid<=0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        valid<=0;
        
    end

    always @(posedge clk)
    begin
        inter_reg_array<=(~rst_n?(0):(valid?(data_wire_out):(inter_reg_array)));
        state_x<=(~rst_n?(0):((state_y==2'd2)?((state_x==2'd2)?0:state_x+1):state_x));
        state_y<=(~rst_n?(0):((state_y==2'd2)?0:state_y+1));
    end
    
    always @(posedge clk)
    begin
        for(i=0;i<MESH_N;i=i+1)
        begin
            weight_reg_in[i]<=(~rst_n?(0):((data_valid)?weight_reg_array[i*9+state_y+state_x*3]:0));
        end
    end

    always @(posedge clk)
    begin
        for(i=0;i<MESH_N;i=i+1)
        begin
            for(j=0;j<MESH_Y;j=j+1)
            begin
                for(k=0;k<MESH_X;k=k+1)
                begin
                    data_reg_in[k+j*MESH_X+i*MESH_X*MESH_Y]<=(~rst_n?(0):((data_valid)?feature_reg_array[(i*(MESH_X+2)+j+state_x)*(MESH_Y+2)+(k+state_y)]:0));
                end
            end
        end
    end

    PE #(
        .IN_BIT(IN_BIT),
        .WEIGHT_BIT(WEIGHT_BIT),
        .MESH_OUT_BIT(MESH_OUT_BIT),
        .OUT_BIT(OUT_BIT),
        .MESH_X(MESH_X),
        .MESH_Y(MESH_Y),
        .MESH_N(MESH_N)
        )
    pe(
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .data_valid(valid),
        .data_in(data_wire_in),
        .weight(weight_wire_in),
        .data_out(data_wire_out),
        //.inter_data(inter_reg_array)
        .inter_data(0)
        );
        
        
endmodule
