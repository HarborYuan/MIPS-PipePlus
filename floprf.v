module floprf(clk, sig, d, q,rst);
    parameter width=32;
    input clk;
    input [1:0]sig;
    input [width-1:0] d;
    output reg [width-1:0] q;
    input rst;
    initial
    begin
        q <= 0;
    end

    always @(negedge clk or posedge rst)
    begin
        if (rst)
            q<=0;
        else case (sig)
            0: q<=0;
            1: q<=d;
            default: q<=q;
        endcase
    end
endmodule