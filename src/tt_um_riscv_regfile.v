`default_nettype none

// TinyTapeout wrapper for rv32i RISC-V Register File
// UCF EEE-5390C Full Custom VLSI Design
//
// Serial protocol — all operations use multiple cycles:
//
// WRITE REGISTER:
//   Phase 1: ui_in[7:6]=2'b00, ui_in[4:0]=reg_idx,
//            uio_in=data_byte0  → load byte 0
//   Phase 2: ui_in[7:6]=2'b01, uio_in=data_byte1  → load byte 1
//   Phase 3: ui_in[7:6]=2'b10, uio_in=data_byte2  → load byte 2
//   Phase 4: ui_in[7:6]=2'b11, uio_in=data_byte3  → load byte 3 + trigger write
//
// READ REGISTER:
//   Phase 1: ui_in[7:6]=2'b00, ui_in[5]=1 (read mode),
//            ui_in[4:0]=reg_idx → select register to read
//   Phase 2: ui_in[1:0]=2'b00 → read byte 0 from uo_out
//   Phase 3: ui_in[1:0]=2'b01 → read byte 1 from uo_out
//   Phase 4: ui_in[1:0]=2'b10 → read byte 2 from uo_out
//   Phase 5: ui_in[1:0]=2'b11 → read byte 3 from uo_out

module tt_um_riscv_regfile (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;
    wire _unused = &{ena};

    // Internal write data buffer
    reg [31:0] write_data_r;
    reg [4:0]  write_idx_r;
    reg        write_en_r;
    reg [4:0]  read_idx_r;
    reg [1:0]  out_sel_r;
    reg        read_mode_r;

    // Decode ui_in
    wire [1:0] phase     = ui_in[7:6];  // which byte phase
    wire       is_read   = ui_in[5];    // 1=read 0=write
    wire [4:0] reg_idx   = ui_in[4:0];  // register index
    wire [1:0] byte_sel  = ui_in[1:0];  // output byte select

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_data_r <= 32'b0;
            write_idx_r  <= 5'b0;
            write_en_r   <= 1'b0;
            read_idx_r   <= 5'b0;
            out_sel_r    <= 2'b0;
            read_mode_r  <= 1'b0;
        end else if (ena) begin
            // Default write enable off
            write_en_r <= 1'b0;

            case (phase)
                2'b00: begin
                    // Phase 0 — load byte 0 + set index + mode
                    write_data_r[7:0] <= uio_in;
                    write_idx_r       <= reg_idx;
                    read_mode_r       <= is_read;
                    if (is_read) begin
                        read_idx_r <= reg_idx;
                    end
                end
                2'b01: begin
                    // Phase 1 — load byte 1
                    write_data_r[15:8] <= uio_in;
                    out_sel_r          <= byte_sel;
                end
                2'b10: begin
                    // Phase 2 — load byte 2
                    write_data_r[23:16] <= uio_in;
                    out_sel_r           <= byte_sel;
                end
                2'b11: begin
                    // Phase 3 — load byte 3 + trigger write
                    write_data_r[31:24] <= uio_in;
                    out_sel_r           <= byte_sel;
                    if (!read_mode_r) begin
                        write_en_r <= 1'b1;  // trigger write
                    end
                end
            endcase

            // Update output byte select on every cycle
            out_sel_r <= byte_sel;
        end
    end

    // Connect to riscv_regfile
    // Only using write port 0 (rd0) for simplicity
    // Ports rd1, rd2, rd3 tied to zero (no write)
    wire [31:0] ra_value;
    wire [31:0] rb_value;

    riscv_regfile u_regfile (
        .clk_i              (clk),
        .rst_i              (~rst_n),

        // Write port 0 — active write
        .rd0_i              (write_idx_r),
        .rd0_value_i        (write_data_r),

        // Write ports 1-3 — tied off
        .rd1_i              (5'b0),
        .rd1_value_i        (32'b0),
        .rd2_i              (5'b0),
        .rd2_value_i        (32'b0),
        .rd3_i              (5'b0),
        .rd3_value_i        (32'b0),

        // Read ports
        .ra_i               (read_idx_r),
        .rb_i               (5'b0),

        // Outputs
        .ra_value_o         (ra_value),
        .rb_value_o         (rb_value)
    );

    // Output selected byte of read result
    wire [7:0] result_byte =
        (out_sel_r == 2'b00) ? ra_value[7:0]   :
        (out_sel_r == 2'b01) ? ra_value[15:8]  :
        (out_sel_r == 2'b10) ? ra_value[23:16] :
                                ra_value[31:24];

    assign uo_out = result_byte;

endmodule
