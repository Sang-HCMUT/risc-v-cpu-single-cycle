module alu(
	input logic [31:0] i_op_a, i_op_b,
	input logic [3:0] i_alu_op,
	output logic [31:0] o_alu_data);
	
	parameter ADD  = 4'b0000;
	parameter SUB  = 4'b0001;
	parameter SLT  = 4'b0010;
	parameter SLTU = 4'b0011;
	parameter XOR  = 4'b0100;
	parameter OR   = 4'b0101;
	parameter AND  = 4'b0110;
	parameter SLL  = 4'b0111;
	parameter SRL  = 4'b1000;
	parameter SRA  = 4'b1001;
	parameter LUI  = 4'b1010;
	
	//=====ADD/SUB=====//
	logic [31:0] add_result, sub_result;
	reg tmp0,tmp1;
	
	ADD_SUB dut(.x(i_op_a),.y(i_op_b),.c_in(1'b0),.s(add_result),.c_out(tmp0));
   ADD_SUB dut1(.x(i_op_a),.y(i_op_b),.c_in(1'b1),.s(sub_result),.c_out(tmp1));
	
	//=====Set less than=====//
		reg [31:0] check_slt;
		reg [31:0] slt_result;
		
	always @(*) begin
		if (~i_op_a[31] & i_op_b[31]) slt_result = 32'h0000_0000; //r1 duong, r2 am.
		else if (i_op_a[31] & ~i_op_b[31]) slt_result = 32'h0000_0001;//r1 am, r2 duong.
		else slt_result = {{31{1'b0}}, sub_result[31]}; //r1 va r2 cung` dau.
	end //Phai chia case v do so co dau co the bi out_range.
			
	//=====Set less than unsigned=====//	
		logic [31:0] eq;
	   logic [31:0] eq_so_far;
	   logic [31:0] lt_i;
		logic [31:0] sltu_result;
		
	  assign eq = ~(i_op_a ^ i_op_b); //Giong nhau = 1; khac nhau = 0;
	  assign eq_so_far[31] = 1'b1;
	  genvar i;
	  
	  generate 
		 for (i = 30; i >= 0; i--) begin:step_1
			 assign eq_so_far[i] = eq[i+1] & eq_so_far[i+1]; //Tu diem khac nhau ve trc = 1; con lai ve sau bang 0.
		 end
	  endgenerate
	  
	  genvar j;
	  generate
		 for (j = 0; j <32; j++) begin:step_2
			 assign lt_i[j] = eq_so_far[j] & (~i_op_a[j] & i_op_b[j]); //all bit = 0 ngoai tru bit ngay cho khac nhau = 1
		 end
	  endgenerate
	  assign sltu_result = {31'b0,|lt_i[31:0]};
		
	//=====shift left logical=====//
	function logic [31:0] sll_fc;
		input logic [31:0] r1;
		input logic [4:0] r2;
		logic [31:0] tmp0, tmp1, tmp2, tmp3, tmp4;
		begin
			tmp0 = (r2[0]==1'b1)?{r1[30:0], 1'b0}: r1;
		   tmp1 = (r2[1]==1'b1)?{tmp0[29:0], 2'b00}: tmp0;
		   tmp2 = (r2[2]==1'b1)?{tmp1[27:0], {4{1'b0}}}: tmp1;
		   tmp3 = (r2[3]==1'b1)?{tmp2[23:0], {8{1'b0}}}: tmp2;
		   sll_fc = (r2[4]==1'b1)?{tmp3[15:0], {16{1'b0}}}: tmp3;
		end
	endfunction
	
	//=====shift right logical=====//
	function logic [31:0] srl_fc;
		input logic [31:0] r1;
		input logic [4:0] r2;
		logic [31:0] tmp0, tmp1, tmp2, tmp3, tmp4;
		begin
			tmp0 = (r2[0]==1'b1)?{1'b0, r1[31:1]}: r1;
		   tmp1 = (r2[1]==1'b1)?{2'b00, tmp0[31:2]}: tmp0;
		   tmp2 = (r2[2]==1'b1)?{{4{1'b0}}, tmp1[31:4]}: tmp1;
		   tmp3 = (r2[3]==1'b1)?{{8{1'b0}}, tmp2[31:8]}: tmp2;
		   srl_fc = (r2[4]==1'b1)?{{16{1'b0}}, tmp3[31:16]}: tmp3;
		end
	endfunction
	
	//=====shift right arithmetic=====//
	function logic [31:0] sra_fc;
		input logic [31:0] r1;
		input logic [4:0] r2;
		logic [31:0] tmp0, tmp1, tmp2, tmp3, tmp4;
		begin
			tmp0 = (r2[0]==1'b1)?{r1[31], r1[31:1]}: r1;
		   tmp1 = (r2[1]==1'b1)?{{2{tmp0[31]}}, tmp0[31:2]}: tmp0;
		   tmp2 = (r2[2]==1'b1)?{{4{tmp0[31]}}, tmp1[31:4]}: tmp1;
		   tmp3 = (r2[3]==1'b1)?{{8{tmp0[31]}}, tmp2[31:8]}: tmp2;
		   sra_fc = (r2[4]==1'b1)?{{16{tmp0[31]}}, tmp3[31:16]}: tmp3;
		end
	endfunction
	
	//=====LUI=====//
	logic [31:0] lui_result;
	reg tmp3;
	ADD_SUB dut3(.x(32'h0000_0000), .y(i_op_b), .c_in(1'b0), .s(lui_result), .c_out(tmp3));
	
	always @(*) begin
		case (i_alu_op) 
			ADD:  o_alu_data = add_result;
			SUB:  o_alu_data = sub_result;
			SLT:  o_alu_data = slt_result;
			SLTU: o_alu_data = sltu_result;
			XOR:  o_alu_data = i_op_a ^ i_op_b;
			OR:   o_alu_data = i_op_a | i_op_b;
			AND:  o_alu_data = i_op_a & i_op_b;
			SLL:  o_alu_data = sll_fc(i_op_a, i_op_b[4:0]);
			SRL:  o_alu_data = srl_fc(i_op_a, i_op_b[4:0]);
			SRA:  o_alu_data = sra_fc(i_op_a, i_op_b[4:0]);
			LUI:  o_alu_data = lui_result;
			default: o_alu_data = 32'h0000_0000;
		endcase
   end
endmodule 

//Instance va generate khong duoc nam trong function.
//neu co nhieu hon 1 generate thi phai dat ten cho no.
