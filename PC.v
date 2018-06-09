module PCUnit(in,PC,clk,sig,rst);
    output reg [31:0] PC;
    input [31:0] in;
    input clk;
    input sig;
    input rst;

    initial
    begin
        PC = 32'h0000_000;
    end
    always@(negedge clk or posedge rst)
	begin
        if (rst)
        begin
            PC = 32'h0000_000;
        end
		else if (sig)
            begin
                PC = in;
            end
    end
endmodule