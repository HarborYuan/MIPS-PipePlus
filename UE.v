module UE(in,out);
    input [15:0] in;
    output [31:0] out;

    assign out = {16'b0,in};
endmodule

