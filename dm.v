module dm_4k( addr, be, din, DMWr, clk, dout);
    input   [11:2]  addr;
    input   [3:0]   be;
    input   [31:0]  din;
    input           DMWr;
    input           clk;
    output  [31:0]  dout;

    reg [31:0]  data[1023:0];
	integer i;

    initial
	begin
		for (i=0;i<1024;i=i+1)
			data[i]<=0;
	end

    always@(negedge clk)
	begin
		if(DMWr)
			case (be)
				4'b1111:data[addr] <= din;
				4'b1100:data[addr][31:16] <= din[15:0];
				4'b0011:data[addr][15:0]  <= din[15:0];
				4'b0001:data[addr][7:0]   <= din[7:0];
				4'b0010:data[addr][15:8]  <= din[7:0];
				4'b0100:data[addr][23:16] <= din[7:0];
				4'b1000:data[addr][31:24] <= din[7:0];
			endcase
	end
	assign dout = data[addr];
endmodule
