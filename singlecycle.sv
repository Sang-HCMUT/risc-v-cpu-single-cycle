module singlecycle (
    input  logic        i_clk, i_reset,
    input  logic [16:0] i_io_sw,
    output logic [31:0] o_pc_debug,
    output logic        o_insn_vld,
    output logic [31:0] o_io_ledr,
    output logic [7:0]  o_io_ledg, 
    output logic [7:0]  o_io_lcd_data, // Dữ liệu LCD (8 bit)
    output logic        o_io_lcd_rs, o_io_lcd_en, o_io_lcd_rw, // Điều khiển LCD
    output logic [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3,
    output logic [6:0]  o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7
);
    logic [31:0] pc, pc_next, pc_four;
    logic [31:0] instr;
    logic PCSel, RegWEn, BrUn, Bsel, Asel, MemRW, insn_vld;
    logic [2:0] ImmSel, lsu_sel;
    logic [1:0] WBSel;
    logic [3:0] ALUSel;
    logic BrEq, BrLT;
    logic [31:0] rs1_data, rs2_data, wb_data;
    logic [31:0] imm;
    logic [31:0] alu_op_a, alu_op_b, alu_data;
    logic [31:0] ld_data;
    logic reset_internal;

    // Đảo tín hiệu reset (KEY[0] là tích cực thấp)
    assign reset_internal = ~i_reset;

    // Program Counter
    assign pc_four = pc + 32'h0000_0004;
    assign pc_next = (PCSel == 1'b1) ? alu_data : pc_four;

    always_ff @(posedge i_clk or posedge reset_internal) begin
        if (reset_internal) begin
            pc <= 32'h0000_0000;
        end else begin
            pc <= pc_next;
        end
    end

    always_ff @(posedge i_clk) begin
        o_pc_debug <= pc;
    end

    // Instruction Memory
    imem imem_inst (.i_reset(reset_internal), .i_addr(pc), .o_rdata(instr));

    // Control Unit
    control_unit ctrl (
        .i_inst(instr), .i_BrEq(BrEq), .i_BrLT(BrLT), .o_PCSel(PCSel),
        .o_RegWEn(RegWEn), .o_BrUn(BrUn), .o_Bsel(Bsel), .o_Asel(Asel),
        .o_MemRW(MemRW), .o_insn_vld(insn_vld), .o_ImmSel(ImmSel),
        .o_WBSel(WBSel), .o_ALUSel(ALUSel), .o_lsu_sel(lsu_sel)
    );

    // Register File
    regfile regfile_inst (
        .i_clk(i_clk), .i_reset(reset_internal), .i_rs1_addr(instr[19:15]),
        .i_rs2_addr(instr[24:20]), .i_rd_addr(instr[11:7]), .i_rd_data(wb_data),
        .i_rd_wren(RegWEn), .o_rs1_data(rs1_data), .o_rs2_data(rs2_data)
    );

    // Immediate Generation
    imm_gen imm_gen_inst (.i_immsel(ImmSel), .i_inst(instr), .o_imm(imm));

    // Branch Comparator
    brc brc_inst (
        .i_rs1_data(rs1_data), .i_rs2_data(rs2_data), .i_br_un(BrUn),
        .o_br_less(BrLT), .o_br_equal(BrEq)
    );

    // ALU
    assign alu_op_a = Asel ? pc : rs1_data;
    assign alu_op_b = Bsel ? imm : rs2_data;
    alu alu_inst (
        .i_op_a(alu_op_a), .i_op_b(alu_op_b), .i_alu_op(ALUSel),
        .o_alu_data(alu_data)
    );

    // Load-Store Unit
    lsu lsu_inst (
        .i_clk(i_clk), .i_reset(reset_internal), .i_lsu_wren(MemRW),
        .i_lsu_addr(alu_data), .i_st_data(rs2_data), .i_io_sw(i_io_sw),
        .i_type(lsu_sel), .o_ld_data(ld_data), .o_io_ledr(o_io_ledr),
        .o_io_ledg(o_io_ledg) // Chỉ dùng 8 bit
    );

    // Write-Back Mux
    always_comb begin
        case (WBSel)
            2'b00: wb_data = ld_data;  // Load data
            2'b01: wb_data = alu_data; // ALU result
            2'b10: wb_data = pc_four;  // PC + 4 (JAL, JALR)
            default: wb_data = 32'h0000_0000;
        endcase
    end

    // LCD Controller
    lcd_controller lcd_inst (
        .i_clk(i_clk), .i_reset(reset_internal), .i_data(pc[7:0]), // Hiển thị 8 bit thấp của PC
        .o_lcd_data(o_io_lcd_data), .o_lcd_rs(o_io_lcd_rs),
        .o_lcd_en(o_io_lcd_en), .o_lcd_rw(o_io_lcd_rw)
    );

    // Assign HEX outputs (vẫn giữ 7'h00, có thể thêm giải mã nếu cần)
    assign o_io_hex0 = 7'h00;
    assign o_io_hex1 = 7'h00;
    assign o_io_hex2 = 7'h00;
    assign o_io_hex3 = 7'h00;
    assign o_io_hex4 = 7'h00;
    assign o_io_hex5 = 7'h00;
    assign o_io_hex6 = 7'h00;
    assign o_io_hex7 = 7'h00;

endmodule

// Mô-đun điều khiển LCD (HD44780-compatible)
module lcd_controller (
    input  logic        i_clk, i_reset,
    input  logic [7:0]  i_data, // Dữ liệu để hiển thị
    output logic [7:0]  o_lcd_data,
    output logic        o_lcd_rs, o_lcd_en, o_lcd_rw
);
    logic [7:0] state;
    logic [31:0] counter;
    logic lcd_busy;

    // Trạng thái khởi tạo và hiển thị
    always_ff @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            state <= 8'h00;
            counter <= 32'h0000_0000;
            o_lcd_rs <= 1'b0;
            o_lcd_rw <= 1'b0;
            o_lcd_en <= 1'b0;
            o_lcd_data <= 8'h00;
            lcd_busy <= 1'b1;
        end else begin
            case (state)
                // Khởi tạo LCD
                8'h00: begin // Chờ 15ms sau khi bật nguồn
                    counter <= counter + 1;
                    if (counter > 750_000) begin // 15ms @ 50MHz
                        state <= 8'h01;
                        counter <= 0;
                    end
                end
                8'h01: begin // Gửi lệnh chức năng (8-bit, 2 dòng)
                    o_lcd_rs <= 1'b0;
                    o_lcd_rw <= 1'b0;
                    o_lcd_data <= 8'h38;
                    o_lcd_en <= 1'b1;
                    state <= 8'h02;
                end
                8'h02: begin
                    o_lcd_en <= 1'b0;
                    counter <= counter + 1;
                    if (counter > 50) begin // Chờ 1us
                        state <= 8'h03;
                        counter <= 0;
                    end
                end
                8'h03: begin // Bật hiển thị
                    o_lcd_rs <= 1'b0;
                    o_lcd_rw <= 1'b0;
                    o_lcd_data <= 8'h0C;
                    o_lcd_en <= 1'b1;
                    state <= 8'h04;
                end
                8'h04: begin
                    o_lcd_en <= 1'b0;
                    counter <= counter + 1;
                    if (counter > 50) begin
                        state <= 8'h05;
                        counter <= 0;
                    end
                end
                8'h05: begin // Xóa màn hình
                    o_lcd_rs <= 1'b0;
                    o_lcd_rw <= 1'b0;
                    o_lcd_data <= 8'h01;
                    o_lcd_en <= 1'b1;
                    state <= 8'h06;
                end
                8'h06: begin
                    o_lcd_en <= 1'b0;
                    counter <= counter + 1;
                    if (counter > 50) begin
                        state <= 8'h07;
                        counter <= 0;
                        lcd_busy <= 1'b0;
                    end
                end
                // Hiển thị dữ liệu
                8'h07: begin // Gửi dữ liệu (i_data)
                    if (!lcd_busy) begin
                        o_lcd_rs <= 1'b1;
                        o_lcd_rw <= 1'b0;
                        o_lcd_data <= i_data;
                        o_lcd_en <= 1'b1;
                        state <= 8'h08;
                    end
                end
                8'h08: begin
                    o_lcd_en <= 1'b0;
                    counter <= counter + 1;
                    if (counter > 50) begin
                        state <= 8'h07;
                        counter <= 0;
                    end
                end
                default: state <= 8'h00;
            endcase
        end
    end
endmodule