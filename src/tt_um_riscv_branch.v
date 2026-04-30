`default_nettype none

// rv32i RISC-V Branch Condition Unit
// Implements BEQ BNE BLT BGE BLTU BGEU
// UCF EEE-5390C Full Custom VLSI Design

module tt_um_riscv_branch (
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
    wire _unused = &{ena, clk, rst_n};

    // ui_in[7:4] = operand A (4-bit)
    // ui_in[3:0] = operand B (4-bit)
    // uio_in[2:0] = branch function
    //   000 = BEQ  branch if A == B
    //   001 = BNE  branch if A != B
    //   010 = BLT  branch if A < B  signed
    //   011 = BGE  branch if A >= B signed
    //   100 = BLTU branch if A < B  unsigned
    //   101 = BGEU branch if A >= B unsigned
    // uo_out[0] = 1 branch taken 0 not taken

    wire [3:0] A    = ui_in[7:4];
    wire [3:0] B    = ui_in[3:0];
    wire [2:0] func = uio_in[2:0];

    wire signed [3:0] As = A;
    wire signed [3:0] Bs = B;

    reg taken;
    always @(*) begin
        case (func)
            3'b000: taken = (A == B);
            3'b001: taken = (A != B);
            3'b010: taken = (As < Bs);
            3'b011: taken = (As >= Bs);
            3'b100: taken = (A < B);
            3'b101: taken = (A >= B);
            default: taken = 1'b0;
        endcase
    end

    assign uo_out = {7'b0, taken};

endmodule
