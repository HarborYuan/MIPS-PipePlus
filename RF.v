module RF(A1, A2, A3, WD, RFWr, clk, RD1, RD2, RFtoBranch , rst);
  input [4:0]A1;
  input [4:0]A2;
  input [4:0]A3;
  input [31:0]WD;
  input RFWr;
  input clk;
  output [31:0]RD1;
  output [31:0]RD2;
  input RFtoBranch;
  input rst;
  
  reg[5:0] i;
  
  reg [31:0] data[31:0];
  initial
  begin
    for (i=0;i<32;i=i+1)
      data[i]=32'b0;
    data[28]=32'h00001800;
    data[29]=32'h00002ffe;
  end 
  
  assign RD1 = data[A1];
  assign RD2 = data[A2];

  always @(posedge clk or posedge rst)
  begin
  #1
  if (rst)
  begin
    for (i=0;i<32;i=i+1)
      data[i]=32'b0;
  end
  else if (RFWr&&A3!=0)
    data[A3]=WD;
  end
endmodule
