module Reg_Mux#(
    parameter DATAWIDTH = 18, 
    parameter RSTTYPE = "SYNC",
    parameter PIPLINE = 0
)(
    input [DATAWIDTH-1:0] in1,
    input CLK, rst, clkenable,
    output reg [DATAWIDTH-1:0] out
);

generate
    if (PIPLINE == 1) begin
        if (RSTTYPE == "SYNC") begin : sync_reset
            always @(posedge CLK) begin
                if (rst)
                    out <= 0;
                else if(clkenable)
                    out <= in1;
            end
        end else if (RSTTYPE == "ASYNC") begin : async_reset
            always @(posedge CLK or posedge rst) begin
                if (rst)
                    out <= 0;
                else if (clkenable)
                    out <= in1;
            end
        end
    end else if(PIPLINE == 0) begin : no_pipeline
        always @(*) begin
            out = in1;
        end
    end
endgenerate
endmodule
