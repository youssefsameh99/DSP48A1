module DSP_tb();

reg CLK;
reg [17:0] A;
reg [17:0] B;
reg [17:0] D;
reg [47:0] C;
reg        CARRYIN;
reg [7:0]  OPMODE;
reg [17:0] BCIN;
reg        RSTA, RSTB, RSTM, RSTC, RSTD, RSTCARRYIN, RSTOPMODE, RSTP;
reg        CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE;
reg [47:0] PCIN;

wire [17:0] BCOUT;
wire [47:0] PCOUT;
wire [47:0] P;
wire [35:0] M;
wire        CARRYOUT;
wire        CARRYOUTF;

DSP #(
    .A0REG(0),
    .A1REG(1),
    .B0REG(0),
    .B1REG(1),
    .CREG(1),
    .DREG(1),
    .MREG(1),
    .PREG(1),
    .CARRYINREG(1),
    .CARRYOUTREG(1),
    .OPMODEREG(1),
    .CARRYINSEL("OPMODE5"),
    .B_INPUT("DIRECT"),
    .RSTTYPE("SYNC")
) dut (
    .A(A),
    .B(B),
    .D(D),
    .C(C),
    .CLK(CLK),
    .CARRYIN(CARRYIN),
    .OPMODE(OPMODE),
    .BCIN(BCIN),
    .RSTA(RSTA),
    .RSTB(RSTB),
    .RSTM(RSTM),
    .RSTC(RSTC),
    .RSTD(RSTD),
    .RSTCARRYIN(RSTCARRYIN),
    .RSTOPMODE(RSTOPMODE),
    .RSTP(RSTP),
    .CEA(CEA),
    .CEB(CEB),
    .CEM(CEM),
    .CEP(CEP),
    .CEC(CEC),
    .CED(CED),
    .CECARRYIN(CECARRYIN),
    .CEOPMODE(CEOPMODE),
    .PCIN(PCIN),
    .BCOUT(BCOUT),
    .PCOUT(PCOUT),
    .P(P),
    .M(M),
    .CARRYOUT(CARRYOUT),
    .CARRYOUTF(CARRYOUTF)
);

initial begin
    CLK = 0;
    forever #1 CLK = ~CLK;
end
reg [47:0] prev_P;
reg prev_CARRYOUT;
initial begin

    $display("Starting Test 2.1");
    RSTA = 1;
    RSTB = 1;
    RSTM = 1;
    RSTC = 1;
    RSTD = 1;
    RSTCARRYIN = 1;
    RSTOPMODE = 1;
    RSTP = 1;
    A = $random;
    B = $random;
    D = $random;
    C = $random;
    CARRYIN = $random;
    OPMODE = $random;
    BCIN = $random;
    CEA = $random;
    CEB = $random;
    CEM = $random;
    CEP = $random;
    CEC = $random;
    CED = $random;
    CECARRYIN = $random;
    CEOPMODE = $random;
    PCIN = $random;
    @(negedge CLK);
    if (P !== 48'd0 || M !== 36'd0 || CARRYOUT !== 1'b0 || CARRYOUTF !== 1'b0 || BCOUT !== 18'd0 || PCOUT !== 48'd0) begin
        $display("2.1 Self-check FAILED");
        $display("P = %h, M = %h, CARRYOUT = %b, CARRYOUTF = %b, BCOUT = %h, PCOUT = %h", P, M, CARRYOUT, CARRYOUTF, BCOUT, PCOUT);
    end else begin
        $display("2.1 Self-check PASSED");
    end

    RSTA = 0;
    RSTB = 0;
    RSTM = 0;
    RSTC = 0;
    RSTD = 0;
    RSTCARRYIN = 0;
    RSTOPMODE = 0;
    RSTP = 0;
    CEA = 1;
    CEB = 1;
    CEM = 1;
    CEP = 1;
    CEC = 1;
    CED = 1;
    CECARRYIN = 1;
    CEOPMODE = 1;
    $stop;

    $display("Starting Test 2.2");
    OPMODE = 8'b11011101;
    A = 20;
    B = 10;
    C = 350;
    D = 25;
    BCIN = $random;
    PCIN = $random;
    CARRYIN = $random;
    repeat(4) @(negedge CLK);
    if (BCOUT !== 18'h0000F || M !== 36'h00000000012C || 
        P !== 48'h000000000032 || PCOUT !== 48'h000000000032 || 
        CARRYOUT !== 1'b0 || CARRYOUTF !== 1'b0) begin
        $display("2.2 Self-check FAILED");
        $display("Expected -> BCOUT = %h, M = %h, P = %h, PCOUT = %h, CARRYOUT = %b, CARRYOUTF = %b", 
                 18'h0000F, 36'h12C, 48'h32, 48'h32, 1'b0, 1'b0);
        $display("Actual   -> BCOUT = %h, M = %h, P = %h, PCOUT = %h, CARRYOUT = %b, CARRYOUTF = %b", 
                 BCOUT, M, P, PCOUT, CARRYOUT, CARRYOUTF);
    end else begin
        $display("2.2 Self-check PASSED");
    end
    $stop;
    $display("Starting Test 2.3");
    OPMODE = 8'b00010000;
    A = 20;
    B = 10;
    C = 350;
    D = 25;
    BCIN = $random;
    PCIN = $random;
    CARRYIN = $random;
    repeat(3) @(negedge CLK);
    if (BCOUT !== 18'h00023 || M !== 36'h0000000002BC || 
        P !== 48'h000000000000 || PCOUT !== 48'h000000000000 || 
        CARRYOUT !== 1'b0 || CARRYOUTF !== 1'b0) begin
        $display("Self-check FAILED at time %0t", $time);
        $display("Expected -> BCOUT = %h, M = %h, P = %h, PCOUT = %h, CARRYOUT = %b, CARRYOUTF = %b", 
                 18'h00023, 36'h2BC, 48'h0, 48'h0, 1'b0, 1'b0);
        $display("Actual   -> BCOUT = %h, M = %h, P = %h, PCOUT = %h, CARRYOUT = %b, CARRYOUTF = %b", 
                 BCOUT, M, P, PCOUT, CARRYOUT, CARRYOUTF);
    end else begin
        $display("2.3 Self-check PASSED");
    end
    $stop;
    $display("Starting Test 2.4");
    OPMODE = 8'b00001010;
    A = 20;
    B = 10;
    C = 350;
    D = 25;
    BCIN = $random;
    PCIN = $random;
    CARRYIN = $random;
    prev_P = P;
    prev_CARRYOUT = CARRYOUT;

    repeat(3) @(negedge CLK);
    if (BCOUT !== 18'h0000A || M !== 36'h0000000000C8 ||
        P !== PCOUT || P !== prev_P || 
        CARRYOUT !== CARRYOUTF || CARRYOUT !== prev_CARRYOUT) begin

        $display("Test 2.4 Self-check FAILED");
        $display("Expected -> BCOUT = %h, M = %h, P = PCOUT = previous P = %h, CARRYOUT = CARRYOUTF = previous CARRYOUT = %b", 
                 18'hA, 36'hC8, prev_P, prev_CARRYOUT);
        $display("Actual   -> BCOUT = %h, M = %h, P = %h, PCOUT = %h, CARRYOUT = %b, CARRYOUTF = %b", 
                 BCOUT, M, P, PCOUT, CARRYOUT, CARRYOUTF);

    end else begin
        $display("Test 2.4 Self-check PASSED");
    end
    $stop;
    $display("Starting Test 2.5");
    OPMODE = 8'b10100111;
    A = 5;
    B = 6;
    C = 350;
    D = 25;
    BCIN = $random;
    PCIN = 3000;
    CARRYIN = $random;
    repeat(3) @(negedge CLK);
    if (BCOUT !== 18'h00006 || M !== 36'h00000000001E ||
        P !== 48'hFE6FFFEC0BB1 || PCOUT !== 48'hFE6FFFEC0BB1 ||
        CARRYOUT !== 1'b1 || CARRYOUTF !== 1'b1) begin
        $display("Test 2.5 Self-check FAILED");
        $display("Expected -> BCOUT = %h, M = %h, P = PCOUT = %h, CARRYOUT = CARRYOUTF = %b",
                 18'h6, 36'h1E, 48'hFE6FFFEC0BB1, 1'b1);
        $display("Actual   -> BCOUT = %h, M = %h, P = %h, PCOUT = %h, CARRYOUT = %b, CARRYOUTF = %b",
                 BCOUT, M, P, PCOUT, CARRYOUT, CARRYOUTF);
    end else begin
        $display("Test 2.5 Self-check PASSED");
    end    
    $stop;

end

    

endmodule

