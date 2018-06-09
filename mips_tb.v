module mips_tb();
    `timescale  1ns/1ps
    reg clk;
    reg rst;
    reg INT;
    initial
    begin
        clk=1;
        INT = 0;
    end
    always
    begin
        #20 clk<=~clk;
    end
    mips my_mips(.clock(clk),.rst(rst),.INT(INT));
endmodule
