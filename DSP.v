module DSP #(
    parameter A0REG         = 0,
    parameter A1REG         = 1,
    parameter B0REG         = 0,
    parameter B1REG         = 1,
    parameter CREG          = 1,
    parameter DREG          = 1,
    parameter MREG          = 1,
    parameter PREG          = 1,
    parameter CARRYINREG    = 1,
    parameter CARRYOUTREG   = 1,
    parameter OPMODEREG     = 1,
    parameter CARRYINSEL    = "OPMODE5",
    parameter B_INPUT       = "DIRECT",
    parameter RSTTYPE       = "SYNC"
)(
    input  [17:0] A,
    input  [17:0] B,
    input  [17:0] D,
    input  [47:0] C,
    input         CLK,
    input         CARRYIN,
    input  [7:0]  OPMODE,
    input  [17:0] BCIN,
    input         RSTA,
    input         RSTB,
    input         RSTM,
    input         RSTC,
    input         RSTD,
    input         RSTCARRYIN,
    input         RSTOPMODE,
    input         RSTP,
    input         CEA,
    input         CEB,
    input         CEM,
    input         CEP,
    input         CEC,
    input         CED,
    input         CECARRYIN,
    input         CEOPMODE,
    input  [47:0] PCIN,
    output [17:0] BCOUT,
    output [47:0] PCOUT,
    output [47:0] P,
    output [35:0] M,
    output        CARRYOUT,
    output        CARRYOUTF

);

wire [17:0] Bin;
generate
    if (B_INPUT == "DIRECT") begin
        assign Bin = B;
    end else if (B_INPUT == "CASCADE") begin
        assign Bin = BCIN;
    end else begin
        assign Bin = 0;
    end
endgenerate
wire [17:0] D_reg , A_reg , B_reg;
wire [47:0] C_reg;
wire [7:0] OP_reg;
Reg_Mux #(.DATAWIDTH(18) ,.RSTTYPE(RSTTYPE), .PIPLINE(DREG)) regmux1 (.CLK(CLK), .rst(RSTD),.clkenable(CED), .in1(D), .out(D_reg));
Reg_Mux #(.DATAWIDTH(18) ,.RSTTYPE(RSTTYPE), .PIPLINE(B0REG)) regmux2 (.CLK(CLK), .rst(RSTB), .in1(Bin),.clkenable(CEB), .out(B_reg));
Reg_Mux #(.DATAWIDTH(18) ,.RSTTYPE(RSTTYPE), .PIPLINE(A0REG)) regmux3 (.CLK(CLK), .rst(RSTA), .in1(A),.clkenable(CEA), .out(A_reg));
Reg_Mux #(.DATAWIDTH(48) ,.RSTTYPE(RSTTYPE), .PIPLINE(CREG)) regmux4 (.CLK(CLK), .rst(RSTC), .in1(C),.clkenable(CEC), .out(C_reg));
Reg_Mux #(.DATAWIDTH(8) ,.RSTTYPE(RSTTYPE), .PIPLINE(OPMODEREG)) regmux5 (.CLK(CLK), .rst(RSTOPMODE), .in1(OPMODE),.clkenable(CEOPMODE), .out(OP_reg));
wire [17:0] pre_addersub_out;
wire [17:0] pre_addersub_out_mux;
assign pre_addersub_out = (OPMODE[6]) ? D_reg - B_reg : D_reg + B_reg;
assign pre_addersub_out_mux = (OPMODE[4]) ? pre_addersub_out : B_reg;


wire [17:0] B1_reg , A1_reg;
Reg_Mux #(.DATAWIDTH(18) ,.RSTTYPE(RSTTYPE), .PIPLINE(B1REG)) regmux6 (.CLK(CLK), .rst(RSTB), .in1(pre_addersub_out_mux),.clkenable(CEB), .out(B1_reg));
Reg_Mux #(.DATAWIDTH(18) ,.RSTTYPE(RSTTYPE), .PIPLINE(A1REG)) regmux7 (.CLK(CLK), .rst(RSTA), .in1(A_reg),.clkenable(CEA), .out(A1_reg));
wire [35:0] multiplier_out;
assign BCOUT = B1_reg;
assign multiplier_out = B1_reg * A1_reg;
wire [35:0] multiplier_out_reg;
Reg_Mux #(.DATAWIDTH(36) ,.RSTTYPE(RSTTYPE), .PIPLINE(MREG)) regmux8 (.CLK(CLK), .rst(RSTM), .in1(multiplier_out),.clkenable(CEM), .out(multiplier_out_reg));
assign M = multiplier_out_reg;

wire [47:0] D_A_B_concatenated;
assign D_A_B_concatenated = {D_reg[11:0],A1_reg,B1_reg};
wire [47:0] P_reg;
wire [47:0] mux_x_out, mux_z_out;
assign mux_x_out = (OPMODE[1:0] == 0) ? 0 :  (OPMODE[1:0] == 1) ? {{12{1'b0}},multiplier_out_reg} : (OPMODE[1:0] == 2) ? P_reg : D_A_B_concatenated;
assign mux_z_out = (OPMODE[3:2] == 0) ? 0 :  (OPMODE[3:2] == 1) ? PCIN : (OPMODE[3:2] == 2) ? P_reg : C_reg;






wire carryinmux_out;
generate
    if(CARRYINSEL == "OPMODE5") begin
        assign carryinmux_out = OPMODE[5];
    end else if(CARRYINSEL == "CARRYIN") begin
        assign carryinmux_out = CARRYIN;
    end
    else begin
        assign carryinmux_out = 0;
    end
endgenerate
wire cin_reg;
Reg_Mux #(.DATAWIDTH(1) ,.RSTTYPE(RSTTYPE), .PIPLINE(CARRYINREG)) regmux9 (.CLK(CLK), .rst(RSTCARRYIN), .in1(carryinmux_out),.clkenable(CECARRYIN), .out(cin_reg));
wire [47:0] post_addersub_out;
wire cout;
assign {cout,post_addersub_out} = (OPMODE[7]) ? (mux_z_out - (mux_x_out+ cin_reg)) : mux_z_out + mux_x_out + cin_reg;
Reg_Mux #(.DATAWIDTH(48) ,.RSTTYPE(RSTTYPE), .PIPLINE(PREG)) regmux10 (.CLK(CLK), .rst(RSTP), .in1(post_addersub_out),.clkenable(CEP), .out(P_reg));
assign P = P_reg;
assign PCOUT = P_reg;
wire cout_reg;
Reg_Mux #(.DATAWIDTH(1) ,.RSTTYPE(RSTTYPE), .PIPLINE(CARRYOUTREG)) regmux11 (.CLK(CLK), .rst(RSTCARRYIN), .in1(cout),.clkenable(CECARRYIN), .out(cout_reg));
assign CARRYOUT = cout_reg;
assign CARRYOUTF = cout_reg;

endmodule
