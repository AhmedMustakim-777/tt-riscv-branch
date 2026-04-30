`default_nettype none

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

    // Internal registers
    reg [31:0] write_data_r;
    reg [4:0]  write_idx_r;
    reg        do_write_r;     // renamed from write_en_r
    reg [4:0]  read_idx_r;
    reg [1:0]  out_sel_r;
    reg        read_mode_r;

    wire [1:0] phase    = ui_in[7:6];
    wire       is_read  = ui_in[5];
    wire [4:0] reg_idx  = ui_in[4:0];
    wire [1:0] byte_sel = ui_in[1:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_data_r <= 32'b0;
            write_idx_r  <= 5'b0;
            do_write_r   <= 1'b0;
            read_idx_r   <= 5'b0;
            out_sel_r    <= 2'b0;
            read_mode_r  <= 1'b0;
        end else if (ena) begin
            do_write_r <= 1'b0;

            case (phase)
                2'b00: begin
                    write_data_r[7:0] <= uio_in;
                    write_idx_r       <= reg_idx;
                    read_mode_r       <= is_read;
                    if (is_read)
                        read_idx_r <= reg_idx;
                end
                2'b01: begin
                    write_data_r[15:8] <= uio_in;
                    out_sel_r          <= byte_sel;
                end
                2'b10: begin
                    write_data_r[23:16] <= uio_in;
                    out_sel_r           <= byte_sel;
                end
                2'b11: begin
                    write_data_r[31:24] <= uio_in;
                    out_sel_r           <= byte_sel;
                    if (!read_mode_r)
                        do_write_r <= 1'b1;
                end
            endcase

            out_sel_r <= byte_sel;
        end
    end

    // ra_value only — rb not needed
    wire [31:0] ra_value;

    riscv_regfile u_regfile (
        .clk_i          (clk),
        .rst_i          (~rst_n),

        // Write port 0 — controlled by do_write_r
        .rd0_i          (do_write_r ? write_idx_r : 5'b0),
        .rd0_value_i    (write_data_r),

        // Write ports 1-3 — tied off
        .rd1_i          (5'b0),
        .rd1_value_i    (32'b0),
        .rd2_i          (5'b0),
        .rd2_value_i    (32'b0),
        .rd3_i          (5'b0),
        .rd3_value_i    (32'b0),

        // Read port A only
        .ra_i           (read_idx_r),
        .rb_i           (5'b0),

        .ra_value_o     (ra_value),
        .rb_value_o     ()          // explicitly unconnected
    );

    // Output selected byte
    assign uo_out =
        (out_sel_r == 2'b00) ? ra_value[7:0]   :
        (out_sel_r == 2'b01) ? ra_value[15:8]  :
        (out_sel_r == 2'b10) ? ra_value[23:16] :
                                ra_value[31:24];

endmodule
