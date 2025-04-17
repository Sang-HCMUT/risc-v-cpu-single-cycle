module imem (
    input  logic       /* i_clk,*/ i_reset,
    input  logic [31:0] i_addr,
    output logic [31:0] o_rdata
);

    logic [31:0] mem [0:511];  // 2KB instruction memory (512 x 32-bit)

    // Đọc file hex vào bộ nhớ
    initial begin
        $readmemh("D:/milestone_2/02_test/dump/game.dump", mem);
    end

    // Địa chỉ đã căn chỉnh (bỏ qua 2 bit thấp)
    logic [12:0] addr_aligned;
    assign addr_aligned = i_addr[10:2];  // 9 bit để truy cập 512 word

    // Đọc đồng bộ
    always @(*) begin
        if (i_reset) begin
            o_rdata = 32'h0000_0000;
        end else begin
            o_rdata = mem[addr_aligned];
        end
    end
endmodule
