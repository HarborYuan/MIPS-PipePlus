module BEUnit(addr,instr,beout);
    input [1:0]addr;
    input [5:0]instr;
    output [3:0]beout;

    assign beout[3] = (instr==6'h2b) || (instr==6'h29&&addr[1]==1) || (instr==6'h28&&addr==2'b11);
    assign beout[2] = (instr==6'h2b) || (instr==6'h29&&addr[1]==1) || (instr==6'h28&&addr==2'b10);
    assign beout[1] = (instr==6'h2b) || (instr==6'h29&&addr[1]==0) || (instr==6'h28&&addr==2'b01);
    assign beout[0] = (instr==6'h2b) || (instr==6'h29&&addr[1]==0) || (instr==6'h28&&addr==2'b00);
endmodule

