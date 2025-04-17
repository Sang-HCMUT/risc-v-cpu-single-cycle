module lsu (
    input  logic        i_clk, i_reset, i_lsu_wren,
    input  logic [31:0] i_lsu_addr, i_st_data, i_io_sw,
    input  logic [2:0]  i_type,
    output logic [31:0] o_ld_data, o_io_ledr, o_io_ledg, o_io_lcd,
    output logic [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3,
    output logic [6:0]  o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7
);
    
    //=====Khai bao mang bo nho cho tung thiet bi ngoai vi=====//
    logic [31:0] mem [0:100];  // 2KB data memory (511 x 32-bit)
    logic [31:0] ledr_buffer;
    logic [31:0] ledg_buffer;
    logic [31:0] l7seg30_buffer; // HEX3-HEX0
    logic [31:0] l7seg74_buffer; // HEX7-HEX4
    logic [31:0] lcd_buffer;
    logic [31:0] swt_buffer;
    
    //=====Gan gia tri cho cac loai store va` load=====//
    parameter LW  = 3'b000;
    parameter SW  = 3'b001;
    parameter LB  = 3'b010;
    parameter LBU = 3'b011;
    parameter LH  = 3'b100;
    parameter LHU = 3'b101;
    parameter SB  = 3'b110;
    parameter SH  = 3'b111;

    initial begin
        $readmemh("D:/milestone_2/02_test/dump/game.dump", mem);
    end
    
    //=====Write memory=====//
    always @(posedge i_clk) begin
        if (i_reset) begin
            ledr_buffer    <= 32'h0000_0000;
            ledg_buffer    <= 32'h0000_0000;
            l7seg30_buffer <= 32'h0000_0000;
            l7seg74_buffer <= 32'h0000_0000;
            lcd_buffer     <= 32'h0000_0000;
        end else if (i_lsu_wren) begin
            // Memory (0x0000_0000 to 0x0000_7FFF)
            if (i_lsu_addr[31:15] == 17'b0000_0000_0000_0000_0) begin
                case (i_type) 
                    SW: mem[i_lsu_addr[14:2]] <= i_st_data;
                    SB: begin
                        case(i_lsu_addr[1:0])
                            2'b00: mem[i_lsu_addr[14:2]][7:0]   <= i_st_data[7:0];
                            2'b01: mem[i_lsu_addr[14:2]][15:8]  <= i_st_data[7:0];
                            2'b10: mem[i_lsu_addr[14:2]][23:16] <= i_st_data[7:0];
                            2'b11: mem[i_lsu_addr[14:2]][31:24] <= i_st_data[7:0];
                        endcase
                    end
                    SH: begin
                        case(i_lsu_addr[1])
                            1'b0: mem[i_lsu_addr[14:2]][15:0]  <= i_st_data[15:0];
                            1'b1: mem[i_lsu_addr[14:2]][31:16] <= i_st_data[15:0];
                        endcase
                    end
                endcase
            // Red LEDs (0x1000_0000 to 0x1000_0FFF)
            end else if (i_lsu_addr[31:12] == 20'b0001_0000_0000_0000_0000) begin
                case (i_type) 
                    SW: ledr_buffer <= i_st_data;
                    SB: begin
                        case(i_lsu_addr[1:0])
                            2'b00: ledr_buffer[7:0]   <= i_st_data[7:0];
                            2'b01: ledr_buffer[15:8]  <= i_st_data[7:0];
                            2'b10: ledr_buffer[23:16] <= i_st_data[7:0];
                            2'b11: ledr_buffer[31:24] <= i_st_data[7:0];
                        endcase
                    end
                    SH: begin
                        case(i_lsu_addr[1])
                            1'b0: ledr_buffer[15:0]  <= i_st_data[15:0];
                            1'b1: ledr_buffer[31:16] <= i_st_data[15:0];
                        endcase
                    end
                endcase
            // Green LEDs (0x1000_1000 to 0x1000_1FFF)
            end else if (i_lsu_addr[31:12] == 20'h1000_1) begin
                case (i_type) 
                    SW: ledg_buffer <= i_st_data;
                    SB: begin
                        case(i_lsu_addr[1:0])
                            2'b00: ledg_buffer[7:0]   <= i_st_data[7:0];
                            2'b01: ledg_buffer[15:8]  <= i_st_data[7:0];
                            2'b10: ledg_buffer[23:16] <= i_st_data[7:0];
                            2'b11: ledg_buffer[31:24] <= i_st_data[7:0];
                        endcase
                    end
                    SH: begin
                        case(i_lsu_addr[1])
                            1'b0: ledg_buffer[15:0]  <= i_st_data[15:0];
                            1'b1: ledg_buffer[31:16] <= i_st_data[15:0];
                        endcase
                    end
                endcase
            // Seven-segment LEDs HEX3-HEX0 (0x1000_2000 to 0x1000_2FFF)
            end else if (i_lsu_addr[31:12] == 20'h1000_2) begin
                case (i_type) 
                    SW: l7seg30_buffer <= i_st_data;
                    SB: begin
                        case(i_lsu_addr[1:0])
                            2'b00: l7seg30_buffer[6:0]   <= i_st_data[6:0]; // HEX0
                            2'b01: l7seg30_buffer[14:8]  <= i_st_data[6:0]; // HEX1
                            2'b10: l7seg30_buffer[22:16] <= i_st_data[6:0]; // HEX2
                            2'b11: l7seg30_buffer[30:24] <= i_st_data[6:0]; // HEX3
                        endcase
                    end
                    SH: begin
                        case(i_lsu_addr[1])
                            1'b0: l7seg30_buffer[14:0]  <= i_st_data[14:0]; // HEX0 & HEX1
                            1'b1: l7seg30_buffer[30:16] <= i_st_data[14:0]; // HEX2 & HEX3
                        endcase
                    end
                endcase
            // Seven-segment LEDs HEX7-HEX4 (0x1000_3000 to 0x1000_3FFF)
            end else if (i_lsu_addr[31:12] == 20'h1000_3) begin
                case (i_type) 
                    SW: l7seg74_buffer <= i_st_data;
                    SB: begin
                        case(i_lsu_addr[1:0])
                            2'b00: l7seg74_buffer[6:0]   <= i_st_data[6:0]; // HEX4
                            2'b01: l7seg74_buffer[14:8]  <= i_st_data[6:0]; // HEX5
                            2'b10: l7seg74_buffer[22:16] <= i_st_data[6:0]; // HEX6
                            2'b11: l7seg74_buffer[30:24] <= i_st_data[6:0]; // HEX7
                        endcase
                    end
                    SH: begin
                        case(i_lsu_addr[1])
                            1'b0: l7seg74_buffer[14:0]  <= i_st_data[14:0]; // HEX4 & HEX5
                            1'b1: l7seg74_buffer[30:16] <= i_st_data[14:0]; // HEX6 & HEX7
                        endcase
                    end
                endcase
            // LCD (0x1000_4000 to 0x1000_4FFF)
            end else if (i_lsu_addr[31:12] == 20'h1000_4) begin
                case (i_type) 
                    SW: lcd_buffer <= i_st_data;
                    SB: begin
                        case(i_lsu_addr[1:0])
                            2'b00: lcd_buffer[7:0]   <= i_st_data[7:0]; // Data
                            // Chỉ cần bit 7-0 cho LCD, bỏ qua các byte khác
                        endcase
                    end
                    SH: begin
                        case(i_lsu_addr[1])
                            1'b0: lcd_buffer[15:0] <= i_st_data[15:0]; // Data + control bits
                            // Chỉ cần bit 15-0, bỏ qua half-word cao
                        endcase
                    end
                endcase
            end
        end
    end

    //=====Switch buffer=====//
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) swt_buffer <= 32'h0000_0000;
        else swt_buffer <= i_io_sw;
    end
    
    //=====Read Memory LOAD DATA=====//
    always @(*) begin
        o_ld_data = 32'h0000_0000;
        if (i_reset) begin
            o_ld_data = 32'h0000_0000;
        end else begin
            // Memory (0x0000_0000 to 0x0000_7FFF)
            if (i_lsu_addr[31:15] == 17'b0000_0000_0000_0000_0) begin
                case(i_type) 
                    LW:  o_ld_data = mem[i_lsu_addr[14:2]];
                    LB:  begin
                        case (i_lsu_addr[1:0])
                            2'b00: o_ld_data = {{24{mem[i_lsu_addr[14:2]][7]}},  mem[i_lsu_addr[14:2]][7:0]};
                            2'b01: o_ld_data = {{24{mem[i_lsu_addr[14:2]][15]}}, mem[i_lsu_addr[14:2]][15:8]};
                            2'b10: o_ld_data = {{24{mem[i_lsu_addr[14:2]][23]}}, mem[i_lsu_addr[14:2]][23:16]};
                            2'b11: o_ld_data = {{24{mem[i_lsu_addr[14:2]][31]}}, mem[i_lsu_addr[14:2]][31:24]};
                        endcase
                    end
                    LBU: begin
                        case (i_lsu_addr[1:0])
                            2'b00: o_ld_data = {24'b0, mem[i_lsu_addr[14:2]][7:0]};
                            2'b01: o_ld_data = {24'b0, mem[i_lsu_addr[14:2]][15:8]};
                            2'b10: o_ld_data = {24'b0, mem[i_lsu_addr[14:2]][23:16]};
                            2'b11: o_ld_data = {24'b0, mem[i_lsu_addr[14:2]][31:24]};
                        endcase
                    end
                    LH:  begin
                        case (i_lsu_addr[1])
                            1'b0: o_ld_data = {{16{mem[i_lsu_addr[14:2]][15]}}, mem[i_lsu_addr[14:2]][15:0]};
                            1'b1: o_ld_data = {{16{mem[i_lsu_addr[14:2]][31]}}, mem[i_lsu_addr[14:2]][31:16]};
                        endcase
                    end
                    LHU: begin
                        case (i_lsu_addr[1])
                            1'b0: o_ld_data = {16'b0, mem[i_lsu_addr[14:2]][15:0]};
                            1'b1: o_ld_data = {16'b0, mem[i_lsu_addr[14:2]][31:16]};
                        endcase
                    end
                    default: o_ld_data = mem[i_lsu_addr[14:2]]; // Default là LW
                endcase
            // Red LEDs (0x1000_0000 to 0x1000_0FFF)
            end else if (i_lsu_addr[31:12] == 20'b0001_0000_0000_0000_0000) begin
                case(i_type) 
                    LW:  o_ld_data = ledr_buffer;
                    LB:  begin
                        case (i_lsu_addr[1:0])
                            2'b00: o_ld_data = {{24{ledr_buffer[7]}},  ledr_buffer[7:0]};
                            2'b01: o_ld_data = {{24{ledr_buffer[15]}}, ledr_buffer[15:8]};
                            2'b10: o_ld_data = {{24{ledr_buffer[23]}}, ledr_buffer[23:16]};
                            2'b11: o_ld_data = {{24{ledr_buffer[31]}}, ledr_buffer[31:24]};
                        endcase
                    end
                    LBU: begin
                        case (i_lsu_addr[1:0])
                            2'b00: o_ld_data = {24'b0, ledr_buffer[7:0]};
                            2'b01: o_ld_data = {24'b0, ledr_buffer[15:8]};
                            2'b10: o_ld_data = {24'b0, ledr_buffer[23:16]};
                            2'b11: o_ld_data = {24'b0, ledr_buffer[31:24]};
                        endcase
                    end
                    LH:  begin
                        case (i_lsu_addr[1])
                            1'b0: o_ld_data = {{16{ledr_buffer[15]}}, ledr_buffer[15:0]};
                            1'b1: o_ld_data = {{16{ledr_buffer[31]}}, ledr_buffer[31:16]};
                        endcase
                    end
                    LHU: begin
                        case (i_lsu_addr[1])
                            1'b0: o_ld_data = {16'b0, ledr_buffer[15:0]};
                            1'b1: o_ld_data = {16'b0, ledr_buffer[31:16]};
                        endcase
                    end
                    default: o_ld_data = ledr_buffer; // Default là LW
                endcase
            // Green LEDs (0x1000_1000 to 0x1000_1FFF)
            end else if (i_lsu_addr[31:12] == 20'h1000_1) begin
                case(i_type) 
                    LW:  o_ld_data = ledg_buffer;
                    LB:  begin
                        case (i_lsu_addr[1:0])
                            2'b00: o_ld_data = {{24{ledg_buffer[7]}},  ledg_buffer[7:0]};
                            2'b01: o_ld_data = {{24{ledg_buffer[15]}}, ledg_buffer[15:8]};
                            2'b10: o_ld_data = {{24{ledg_buffer[23]}}, ledg_buffer[23:16]};
                            2'b11: o_ld_data = {{24{ledg_buffer[31]}}, ledg_buffer[31:24]};
                        endcase
                    end
                    LBU: begin
                        case (i_lsu_addr[1:0])
                            2'b00: o_ld_data = {24'b0, ledg_buffer[7:0]};
                            2'b01: o_ld_data = {24'b0, ledg_buffer[15:8]};
                            2'b10: o_ld_data = {24'b0, ledg_buffer[23:16]};
                            2'b11: o_ld_data = {24'b0, ledg_buffer[31:24]};
                        endcase
                    end
                    LH:  begin
                        case (i_lsu_addr[1])
                            1'b0: o_ld_data = {{16{ledg_buffer[15]}}, ledg_buffer[15:0]};
                            1'b1: o_ld_data = {{16{ledg_buffer[31]}}, ledg_buffer[31:16]};
                        endcase
                    end
                    LHU: begin
                        case (i_lsu_addr[1])
                            1'b0: o_ld_data = {16'b0, ledg_buffer[15:0]};
                            1'b1: o_ld_data = {16'b0, ledg_buffer[31:16]};
                        endcase
                    end
                    default: o_ld_data = ledg_buffer; // Default là LW
                endcase
            // Seven-segment LEDs HEX3-HEX0 (0x1000_2000 to 0x1000_2FFF)
            end else if (i_lsu_addr[31:12] == 20'h1000_2) begin
                case(i_type) 
                    LW:  o_ld_data = l7seg30_buffer;
                    LB:  begin
                        case (i_lsu_addr[1:0])
                            2'b00: o_ld_data = {{24{l7seg30_buffer[6]}},  l7seg30_buffer[6:0]};
                            2'b01: o_ld_data = {{24{l7seg30_buffer[14]}}, l7seg30_buffer[14:8]};
                            2'b10: o_ld_data = {{24{l7seg30_buffer[22]}}, l7seg30_buffer[22:16]};
                            2'b11: o_ld_data = {{24{l7seg30_buffer[30]}}, l7seg30_buffer[30:24]};
                        endcase
                    end
                    LBU: begin
                        case (i_lsu_addr[1:0])
                            2'b00: o_ld_data = {24'b0, l7seg30_buffer[6:0]};
                            2'b01: o_ld_data = {24'b0, l7seg30_buffer[14:8]};
                            2'b10: o_ld_data = {24'b0, l7seg30_buffer[22:16]};
                            2'b11: o_ld_data = {24'b0, l7seg30_buffer[30:24]};
                        endcase
                    end
                    LH:  begin
                        case (i_lsu_addr[1])
                            1'b0: o_ld_data = {{16{l7seg30_buffer[14]}}, l7seg30_buffer[14:0]};
                            1'b1: o_ld_data = {{16{l7seg30_buffer[30]}}, l7seg30_buffer[30:16]};
                        endcase
                    end
                    LHU: begin
                        case (i_lsu_addr[1])
                            1'b0: o_ld_data = {16'b0, l7seg30_buffer[14:0]};
                            1'b1: o_ld_data = {16'b0, l7seg30_buffer[30:16]};
                        endcase
                    end
                    default: o_ld_data = l7seg30_buffer; // Default là LW
                endcase
            // Seven-segment LEDs HEX7-HEX4 (0x1000_3000 to 0x1000_3FFF)
            end else if (i_lsu_addr[31:12] == 20'h1000_3) begin
                case(i_type) 
                    LW:  o_ld_data = l7seg74_buffer;
                    LB:  begin
                        case (i_lsu_addr[1:0])
                            2'b00: o_ld_data = {{24{l7seg74_buffer[6]}},  l7seg74_buffer[6:0]};
                            2'b01: o_ld_data = {{24{l7seg74_buffer[14]}}, l7seg74_buffer[14:8]};
                            2'b10: o_ld_data = {{24{l7seg74_buffer[22]}}, l7seg74_buffer[22:16]};
                            2'b11: o_ld_data = {{24{l7seg74_buffer[30]}}, l7seg74_buffer[30:24]};
                        endcase
                    end
                    LBU: begin
                        case (i_lsu_addr[1:0])
                            2'b00: o_ld_data = {24'b0, l7seg74_buffer[6:0]};
                            2'b01: o_ld_data = {24'b0, l7seg74_buffer[14:8]};
                            2'b10: o_ld_data = {24'b0, l7seg74_buffer[22:16]};
                            2'b11: o_ld_data = {24'b0, l7seg74_buffer[30:24]};
                        endcase
                    end
                    LH:  begin
                        case (i_lsu_addr[1])
                            1'b0: o_ld_data = {{16{l7seg74_buffer[14]}}, l7seg74_buffer[14:0]};
                            1'b1: o_ld_data = {{16{l7seg74_buffer[30]}}, l7seg74_buffer[30:16]};
                        endcase
                    end
                    LHU: begin
                        case (i_lsu_addr[1])
                            1'b0: o_ld_data = {16'b0, l7seg74_buffer[14:0]};
                            1'b1: o_ld_data = {16'b0, l7seg74_buffer[30:16]};
                        endcase
                    end
                    default: o_ld_data = l7seg74_buffer; // Default là LW
                endcase
            // LCD (0x1000_4000 to 0x1000_4FFF)
            end else if (i_lsu_addr[31:12] == 20'h1000_4) begin
                case(i_type) 
                    LW:  o_ld_data = lcd_buffer;
                    LB:  begin
                        case (i_lsu_addr[1:0])
                            2'b00: o_ld_data = {{24{lcd_buffer[7]}},  lcd_buffer[7:0]};
                            2'b01: o_ld_data = {{24{lcd_buffer[15]}}, lcd_buffer[15:8]};
                            2'b10: o_ld_data = {{24{lcd_buffer[23]}}, lcd_buffer[23:16]};
                            2'b11: o_ld_data = {{24{lcd_buffer[31]}}, lcd_buffer[31:24]};
                        endcase
                    end
                    LBU: begin
                        case (i_lsu_addr[1:0])
                            2'b00: o_ld_data = {24'b0, lcd_buffer[7:0]};
                            2'b01: o_ld_data = {24'b0, lcd_buffer[15:8]};
                            2'b10: o_ld_data = {24'b0, lcd_buffer[23:16]};
                            2'b11: o_ld_data = {24'b0, lcd_buffer[31:24]};
                        endcase
                    end
                    LH:  begin
                        case (i_lsu_addr[1])
                            1'b0: o_ld_data = {{16{lcd_buffer[15]}}, lcd_buffer[15:0]};
                            1'b1: o_ld_data = {{16{lcd_buffer[31]}}, lcd_buffer[31:16]};
                        endcase
                    end
                    LHU: begin
                        case (i_lsu_addr[1])
                            1'b0: o_ld_data = {16'b0, lcd_buffer[15:0]};
                            1'b1: o_ld_data = {16'b0, lcd_buffer[31:16]};
                        endcase
                    end
                    default: o_ld_data = lcd_buffer; // Default là LW
                endcase
            // Switches (0x1001_0000 to 0x1001_0FFF)
            end else if (i_lsu_addr[31:12] == 20'h1001_0) begin
                o_ld_data = swt_buffer;
            end 
        end
    end
    
    //=====Gán giá trị đầu ra=====//
    assign o_io_ledr = ledr_buffer;
    assign o_io_ledg = ledg_buffer;
    assign o_io_lcd  = lcd_buffer;
    assign o_io_hex0 = l7seg30_buffer[6:0];
    assign o_io_hex1 = l7seg30_buffer[14:8];
    assign o_io_hex2 = l7seg30_buffer[22:16];
    assign o_io_hex3 = l7seg30_buffer[30:24];
    assign o_io_hex4 = l7seg74_buffer[6:0];
    assign o_io_hex5 = l7seg74_buffer[14:8];
    assign o_io_hex6 = l7seg74_buffer[22:16];
    assign o_io_hex7 = l7seg74_buffer[30:24];

endmodule
