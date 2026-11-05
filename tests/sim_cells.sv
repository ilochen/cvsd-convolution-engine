// Functional substitutes written for this test harness. No technology data.
module sram_512x8(output logic [7:0] Q, input CLK, CEN, WEN, input [8:0] A, input [7:0] D);
  logic [7:0] memory[512];
  always_ff @(posedge CLK) if (!CEN) begin
    if (!WEN) memory[A] <= D;
    Q <= memory[A];
  end
endmodule

module DW02_mult_3_stage #(parameter A_width=8,B_width=8)(
    input [A_width-1:0] A, input [B_width-1:0] B, input TC, CLK,
    output logic [A_width+B_width-1:0] PRODUCT);
  logic [A_width+B_width-1:0] stage1;
  always_ff @(posedge CLK) begin
    if (TC) stage1 <= $signed(A)*$signed(B);
    else stage1 <= A*B;
    PRODUCT <= stage1;
  end
endmodule
