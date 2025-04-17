module brc(
	input logic [31:0] i_rs1_data,
	input logic [31:0] i_rs2_data,
	input logic i_br_un,
	output logic o_br_less,
	output logic o_br_equal);
	
	//=====Compare equal or not equal for signed bit and unsigned bit=====//
	reg [31:0] tmp;
	assign tmp = ~(i_rs1_data ^ i_rs2_data);
	assign o_br_equal = &tmp; //equal thi bang 1, not eual thi bang 0.
	
	//=====Compare less than for unsigned bit=====//
		logic [31:0] eq;
	   logic [31:0] eq_so_far;
	   logic [31:0] lt_i;
		logic [31:0] cltu_result;
		
	  assign eq = ~(i_rs1_data ^ i_rs2_data); //Giong nhau = 1; khac nhau = 0;
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
			 assign lt_i[j] = eq_so_far[j] & (~i_rs1_data[j] & i_rs2_data[j]); //all bit = 0 ngoai tru bit ngay cho khac nhau ma rs1=0,rs2 =1 thi` = 1
		 end
	  endgenerate
	  assign cltu_result = |lt_i[31:0];
	  
	//=====Compare less than for signed bit=====//
   reg [31:0] sub_result;
	reg [31:0] clt_result;	
	reg tmp0;
	
	ADD_SUB dut(.x(i_rs1_data),.y(i_rs2_data),.c_in(1'b1),.s(sub_result),.c_out(tmp0));
		
	always @(*) begin
		if (~i_rs1_data[31] & i_rs2_data[31]) clt_result = 32'h0000_0000; //r1 duong, r2 am.
		else if (i_rs1_data[31] & ~i_rs2_data[31]) clt_result = 32'h0000_0001;//r1 am, r2 duong.
		else clt_result = sub_result[31]; //r1 va r2 cung` dau.
	end //Phai chia case v do so co dau co the bi out_range.	
	
	//=====Main=====//
	assign o_br_less = (i_br_un)? clt_result : cltu_result; //1 if signed, 0 if unsigned
	
endmodule 
