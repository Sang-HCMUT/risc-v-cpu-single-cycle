module control_unit(
	input logic [31:0] i_inst,
	input logic i_BrEq, i_BrLT,
	output logic o_PCSel,o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_insn_vld,
	output logic [2:0] o_ImmSel,
	output logic [1:0] o_WBSel,
	output logic [3:0] o_ALUSel,
	output logic [2:0] o_lsu_sel);
	
	parameter add_sub = 3'b000;
	parameter sll = 3'b001;
	parameter slt = 3'b010;
	parameter sltu = 3'b011;
	parameter xorr = 3'b100;
	parameter srl_sra = 3'b101;
	parameter orr = 3'b110;
	parameter andd = 3'b111;

	always @(*) begin
		//R-Format
		if (i_inst[6:0] == 7'b0110_011) begin //Op_code
			o_insn_vld = 1'b0;
			if (i_inst[31:25] == 7'b0000_000) begin //Function 7
				{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'bxxx, 1'b1, 1'bx, 1'b0,1'b0, 1'b0, 2'b01};
				o_lsu_sel = 3'bxxx;
				case (i_inst[14:12]) //Function 3
					add_sub: begin
									o_ALUSel = 4'b0000;	//add
									o_insn_vld = 1'b1;
								end
					sll:		begin 
									o_ALUSel = 4'b0111;
									o_insn_vld = 1'b1;
								end
					slt: 		begin
									o_ALUSel = 4'b0010;
									o_insn_vld = 1'b1;
								end
					sltu: 	begin 
									o_ALUSel = 4'b0011;
									o_insn_vld = 1'b1;
								end
					xorr: 	begin 
									o_ALUSel = 4'b0100;
									o_insn_vld = 1'b1;
								end
					srl_sra:	begin
									o_ALUSel = 4'b1000; //srl
									o_insn_vld = 1'b1;
								end
					orr: 		begin 
									o_ALUSel = 4'b0101;
									o_insn_vld = 1'b1;
								end
					default:	begin
									o_ALUSel = 4'b0110; //and
									o_insn_vld = 1'b0;
								end
				endcase
			end else if (i_inst[31:25] == 7'b0100_000) begin //Function7
				{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'bxxx, 1'b1, 1'bx, 1'b0,1'b0, 1'b0, 2'b01};
				 o_lsu_sel = 3'bxxx;
				 case (i_inst[14:12])
					add_sub: begin
									o_ALUSel = 4'b0001;	//add
									o_insn_vld = 1'b1;
								end
					srl_sra:	begin
									o_ALUSel = 4'b1001; //srl
									o_insn_vld = 1'b1;
								end
					default:	begin
                                                        o_insn_vld = 1'b0;
				{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b0, 1'b0, 1'b0,1'b0, 1'b0, 2'b00};
							o_lsu_sel = 3'bxxx;
							o_ALUSel = 4'b1111; //Chi co PC duoc cap nhat thanh PC + 4, con` lai khong thuc hien gi` ca

								end
				 endcase
			end else begin
				o_insn_vld = 1'b0;
				{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b0, 1'b0, 1'b0,1'b0, 1'b0, 2'b00};
				o_lsu_sel = 3'bxxx;
				o_ALUSel = 4'b1111; //Chi co PC duoc cap nhat thanh PC + 4, con` lai khong thuc hien gi` ca
			end
//I-format
end else if (i_inst[6:0] == 7'b001_0011) begin //Op_code
    o_insn_vld = 1'b1;
    if (i_inst[31:25] == 7'b0000_000) begin //Function 7
        if (i_inst[14:12] == sll) begin //slli
            {o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b1, 1'bx, 1'b1, 1'b0, 1'b0, 2'b01};
            o_lsu_sel = 3'bxxx;
            o_ALUSel = 4'b0111;
        end else if (i_inst[14:12] == srl_sra) begin
            {o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b1, 1'bx, 1'b1, 1'b0, 1'b0, 2'b01};
            o_lsu_sel = 3'bxxx;
            o_ALUSel = 4'b1000; //srli
        end else begin
            {o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b1, 1'bx, 1'b1, 1'b0, 1'b0, 2'b01};
            o_lsu_sel = 3'bxxx;
            case (i_inst[14:12])
                add_sub: o_ALUSel = 4'b0000; //addi
                slt:     o_ALUSel = 4'b0010; //slti
                sltu:    o_ALUSel = 4'b0011; //sltiu
                xorr:    o_ALUSel = 4'b0100; //xori
                orr:     o_ALUSel = 4'b0101; //ori
                andd:    o_ALUSel = 4'b0110; //andi
                default: begin
                    o_insn_vld = 1'b0;
                    {o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b0, 1'b0, 1'b0,1'b0, 1'b0, 2'b00};
                    o_ALUSel = 4'b0000;
                end
            endcase
        end
    end else if (i_inst[31:25] == 7'b0100_000) begin
        if (i_inst[14:12] == srl_sra) begin
            {o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b1, 1'bx, 1'b1, 1'b0, 1'b0, 2'b01};
            o_lsu_sel = 3'bxxx;
            o_ALUSel = 4'b1001; //srai
        end else begin
            o_insn_vld = 1'b0;
            {o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b0, 1'b0, 1'b0,1'b0, 1'b0, 2'b00};
            o_lsu_sel = 3'bxxx;
            o_ALUSel = 4'b0000;
        end
    end else begin
        {o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b1, 1'bx, 1'b1, 1'b0, 1'b0, 2'b01};
        o_lsu_sel = 3'bxxx;
        case (i_inst[14:12])
            add_sub: o_ALUSel = 4'b0000;
            slt:     o_ALUSel = 4'b0010;
            sltu:    o_ALUSel = 4'b0011;
            xorr:    o_ALUSel = 4'b0100;
            orr:     o_ALUSel = 4'b0101;
            andd:    o_ALUSel = 4'b0110;
            default: begin
                o_insn_vld = 1'b0;
                {o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b0, 1'b0, 1'b0,1'b0, 1'b0, 2'b00};
                o_lsu_sel = 3'bxxx;
                o_ALUSel = 4'b0000;
            end
        endcase
    end		//Load-Format 
		end else if(i_inst[6:0] == 7'b0000_011) begin
			o_insn_vld = 1'b1;
			{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b1, 1'bx, 1'b1,1'b0, 1'b0, 2'b00};
         o_ALUSel = 4'b0000;
			case(i_inst[14:12])//function_3
				3'b000: o_lsu_sel = 3'b010; //LB
				3'b001: o_lsu_sel = 3'b100; //LH
				3'b010: o_lsu_sel = 3'b000; //LW
				3'b100: o_lsu_sel = 3'b011; //LBU
				3'b101: o_lsu_sel = 3'b101; //LHU
				default: begin
					o_insn_vld = 1'b0;
                			{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b0, 1'b0, 1'b0,1'b0, 1'b0, 2'b00};
                			o_lsu_sel = 3'bxxx;
                			o_ALUSel = 4'b0000;
					end
			endcase
		//Store - Format 
		end else if (i_inst[6:0] == 7'b0100_011) begin
			{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b001, 1'b0, 1'bx, 1'b1,1'b0, 1'b1, 2'bxx};
         o_ALUSel = 4'b0000;
			o_insn_vld = 1'b1;
			case(i_inst[14:12])//function_3
				3'b000: o_lsu_sel = 3'b110; //SB
				3'b001: o_lsu_sel = 3'b111; //SH
				3'b010: o_lsu_sel = 3'b001; //SW
				default: begin
					o_insn_vld = 1'b0;
                			{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b0, 1'b0, 1'b0,1'b0, 1'b0, 2'b00};
                			o_lsu_sel = 3'bxxx;
                			o_ALUSel = 4'b0000;
					end
			endcase
		//Branch-Format
		end else if (i_inst[6:0] == 7'b1100_011) begin //Op_code
			{o_ALUSel, o_ImmSel, o_RegWEn,o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {3'b000, 3'b010, 1'b0,1'b1, 1'b1,1'b1, 1'b0, 2'bxx};
			o_lsu_sel = 3'bxxx;
			case (i_inst[14:12])
				3'b000: begin	//beq	
					o_insn_vld = 1'b1;
					if (i_BrEq) o_PCSel = 1'b1;
					else o_PCSel = 1'b0;
				end
				3'b001: begin //bne
					o_insn_vld = 1'b1;
					if (~i_BrEq) o_PCSel = 1'b1;
					else o_PCSel = 1'b0;
				end
				3'b100: begin //blt
					o_insn_vld = 1'b1;
					if (i_BrLT) o_PCSel = 1'b1;
					else o_PCSel = 1'b0;
				end
				3'b101: begin //bge
					o_insn_vld = 1'b1;
					if (~i_BrLT) o_PCSel = 1'b1;
					else o_PCSel = 1'b0;
				end
				3'b110: begin //bltu
					o_insn_vld = 1'b1;
					o_BrUn = 1'b0;
					if (i_BrLT) o_PCSel = 1'b1;
					else o_PCSel = 1'b0;
				end
				3'b111: begin //bgeu
					o_insn_vld = 1'b1;
					o_BrUn = 1'b0;
					if (~i_BrLT) o_PCSel = 1'b1;
					else o_PCSel = 1'b0;
				end
				default: begin
					o_insn_vld = 1'b0;
					{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b0, 1'b0, 1'b0,1'b0, 1'b0, 2'b00};
					o_lsu_sel = 3'bxxx;
					o_ALUSel = 4'b1111; //Chi co PC duoc cap nhat thanh PC + 4, con` lai khong thuc hien gi` ca
				end
			endcase
		end else if (i_inst[6:0] == 7'b1101_111) begin //JAL
			o_insn_vld = 1'b1;
			o_lsu_sel = 3'bxxx;
			{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_ALUSel, o_MemRW, o_WBSel} = {1'b1, 3'b011, 1'b1, 1'bx, 1'b1, 1'b1, 4'b0000, 1'b0, 2'b10};
		end else if (i_inst[6:0] == 7'b0110_111) begin//lui 
			o_lsu_sel = 3'bxxx;
			o_insn_vld = 1'b1;
			{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_ALUSel, o_MemRW, o_WBSel} = {1'b0, 3'b111, 1'b1, 1'bx, 1'b1, 1'bx, 4'b1010, 1'b0, 2'b01};
		end else if (i_inst[6:0] == 7'b0010_111) begin//auipc
			o_insn_vld = 1'b1;
			o_lsu_sel = 3'bxxx;
			{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_ALUSel, o_MemRW, o_WBSel} = {1'b0, 3'b111, 1'b1, 1'bx, 1'b1, 1'b1, 4'b0000, 1'b0, 2'b01};
		end else if (i_inst[6:0] == 7'b1100_111) begin//JALR
			o_lsu_sel = 3'bxxx;
			if (i_inst[14:12] == 3'b000) begin
				o_insn_vld = 1'b1;
				{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_ALUSel, o_MemRW, o_WBSel} = {1'b1, 3'b000, 1'b1, 1'bx, 1'b1, 1'b0, 4'b0000, 1'b0, 2'b10};
			end else begin
				o_insn_vld = 1'b0;
				{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b0, 1'b0, 1'b0,1'b0, 1'b0, 2'b00};
				o_ALUSel = 4'b1111; //Chi co PC duoc cap nhat thanh PC + 4, con` lai khong thuc hien gi` ca
			end
		end else begin
			o_insn_vld = 1'b0;
			o_lsu_sel = 3'bxxx;
			{o_PCSel, o_ImmSel, o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_WBSel} = {1'b0, 3'b000, 1'b0, 1'b0, 1'b0,1'b0, 1'b0, 2'b00};
			o_ALUSel = 4'b1111; //Chi co PC duoc cap nhat thanh PC + 4, con` lai khong thuc hien gi` ca
		end
	end
endmodule
