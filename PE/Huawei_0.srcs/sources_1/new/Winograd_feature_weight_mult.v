`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/15 19:58:32
// Design Name: 
// Module Name: Winograd_feature_weight_mult
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


module Winograd_feature_weight_mult
#(
	parameter WEIGHT_BIT = 8,
	parameter WEIGHT_SIZE =3,
	parameter RESULT_BIT = WEIGHT_BIT+4,
	parameter RESULT_SIZE = 4 
)
(
	input clk,
//	input rst_n,
	input [WEIGHT_BIT*WEIGHT_SIZE*WEIGHT_SIZE-1:0]weight,
	output [RESULT_BIT*RESULT_SIZE*RESULT_SIZE-1:0]result
);
	wire signed [WEIGHT_BIT-1:0] weight_wire [0:WEIGHT_SIZE*WEIGHT_SIZE-1];
	
	(*keep = "true"*)reg signed [WEIGHT_BIT+2-1:0] lvl1_reg[0:13];
	(*keep = "true"*)reg signed [WEIGHT_BIT+4-1:0] lvl2_reg[0:15];
	
	generate
		genvar i;
		for(i=0;i<WEIGHT_SIZE*WEIGHT_SIZE;i=i+1)
		begin:weight_for
			assign weight_wire[i]=weight[WEIGHT_BIT*(i+1)-1:WEIGHT_BIT*i];
		end
		for(i=0;i<RESULT_SIZE*RESULT_SIZE;i=i+1)
		begin:result_for
			assign result[RESULT_BIT*(i+1)-1:RESULT_BIT*i]=lvl2_reg[i];
		end
	endgenerate
	
	

	
	always@(posedge clk)
    begin
        (*dont_touch = "yes"*)lvl1_reg[0]<=weight_wire[WEIGHT_SIZE*0+0]+weight_wire[WEIGHT_SIZE*0+1]+weight_wire[WEIGHT_SIZE*0+2];
        (*dont_touch = "yes"*)lvl1_reg[1]<=weight_wire[WEIGHT_SIZE*0+0]-weight_wire[WEIGHT_SIZE*0+1]+weight_wire[WEIGHT_SIZE*0+2];
        (*dont_touch = "yes"*)lvl1_reg[2]<=weight_wire[WEIGHT_SIZE*2+0]+weight_wire[WEIGHT_SIZE*2+1]+weight_wire[WEIGHT_SIZE*2+2];
        (*dont_touch = "yes"*)lvl1_reg[3]<=weight_wire[WEIGHT_SIZE*2+0]-weight_wire[WEIGHT_SIZE*2+1]+weight_wire[WEIGHT_SIZE*2+2];
        (*dont_touch = "yes"*)lvl1_reg[4]<=weight_wire[WEIGHT_SIZE*0+0]+weight_wire[WEIGHT_SIZE*1+0]+weight_wire[WEIGHT_SIZE*2+0];
        (*dont_touch = "yes"*)lvl1_reg[5]<=weight_wire[WEIGHT_SIZE*0+0]-weight_wire[WEIGHT_SIZE*1+0]+weight_wire[WEIGHT_SIZE*2+0];
        (*dont_touch = "yes"*)lvl1_reg[6]<=weight_wire[WEIGHT_SIZE*0+2]+weight_wire[WEIGHT_SIZE*1+2]+weight_wire[WEIGHT_SIZE*2+2];
        (*dont_touch = "yes"*)lvl1_reg[7]<=weight_wire[WEIGHT_SIZE*0+2]-weight_wire[WEIGHT_SIZE*1+2]+weight_wire[WEIGHT_SIZE*2+2];
        (*dont_touch = "yes"*)lvl1_reg[8]<=weight_wire[WEIGHT_SIZE*1+0]+weight_wire[WEIGHT_SIZE*1+1]+weight_wire[WEIGHT_SIZE*1+2];
        (*dont_touch = "yes"*)lvl1_reg[9]<=weight_wire[WEIGHT_SIZE*1+0]-weight_wire[WEIGHT_SIZE*1+1]+weight_wire[WEIGHT_SIZE*1+2];
        (*dont_touch = "yes"*)lvl1_reg[10]<={{2{weight_wire[0+WEIGHT_SIZE*0][WEIGHT_BIT-1]}},weight_wire[0+WEIGHT_SIZE*0]};
        (*dont_touch = "yes"*)lvl1_reg[11]<={{2{weight_wire[2+WEIGHT_SIZE*0][WEIGHT_BIT-1]}},weight_wire[2+WEIGHT_SIZE*0]};
        (*dont_touch = "yes"*)lvl1_reg[12]<={{2{weight_wire[0+WEIGHT_SIZE*2][WEIGHT_BIT-1]}},weight_wire[0+WEIGHT_SIZE*2]};
        (*dont_touch = "yes"*)lvl1_reg[13]<={{2{weight_wire[2+WEIGHT_SIZE*2][WEIGHT_BIT-1]}},weight_wire[2+WEIGHT_SIZE*2]};
    end
	
	always@(posedge clk)
	begin
		(*dont_touch = "yes"*)lvl2_reg[0]<={lvl1_reg[10],2'b00};lvl2_reg[1]<={{lvl1_reg[0][WEIGHT_BIT+1]},lvl1_reg[0],1'b0};lvl2_reg[2]<={{lvl1_reg[1][WEIGHT_BIT+1]},lvl1_reg[1],1'b0};lvl2_reg[3]<={lvl1_reg[11],2'b00};
		(*dont_touch = "yes"*)lvl2_reg[4]<={{lvl1_reg[4][WEIGHT_BIT+1]},lvl1_reg[4],1'b0};
		(*dont_touch = "yes"*)lvl2_reg[5]<=lvl1_reg[0]+lvl1_reg[8]+lvl1_reg[2];
		(*dont_touch = "yes"*)lvl2_reg[6]<=lvl1_reg[1]+lvl1_reg[9]+lvl1_reg[3];
		(*dont_touch = "yes"*)lvl2_reg[7]<={{lvl1_reg[6][WEIGHT_BIT+1]},lvl1_reg[6],1'b0};
		(*dont_touch = "yes"*)lvl2_reg[8]<={{lvl1_reg[5][WEIGHT_BIT+1]},lvl1_reg[5],1'b0};
		(*dont_touch = "yes"*)lvl2_reg[9]<=lvl1_reg[0]-lvl1_reg[8]+lvl1_reg[2];
		(*dont_touch = "yes"*)lvl2_reg[10]<=lvl1_reg[1]-lvl1_reg[9]+lvl1_reg[3];
		(*dont_touch = "yes"*)lvl2_reg[11]<={{lvl1_reg[7][WEIGHT_BIT+1]},lvl1_reg[7],1'b0};
		(*dont_touch = "yes"*)lvl2_reg[12]<={lvl1_reg[12],2'b00};lvl2_reg[13]<={{lvl1_reg[2][WEIGHT_BIT+1]},lvl1_reg[2],1'b0};lvl2_reg[14]<={{lvl1_reg[3][WEIGHT_BIT+1]},lvl1_reg[3],1'b0};lvl2_reg[15]<={lvl1_reg[13],2'b00};
		
	end
	
	
endmodule
