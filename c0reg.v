module c0reg(sta,cau,epc,
inta,data,PC,cause,mtc,clk,eret);
    output reg [31:0] sta,cau,epc;
    input inta;
    input [31:0] data;
    input [31:0] PC;
    input [31:0] cause;
    input [4:0] mtc;
    input eret;
    input clk;
    wire pcplus4;

    wire wsta;
    wire wcau;
    wire wepc;

    assign pcplus4 = (cause==0)?0:1; 

    assign wsta = (mtc == 12) || inta || eret;
    assign wcau = (mtc == 13) || inta;
    assign wepc = (mtc == 14) || inta;

    initial 
    begin
        sta = 32'b0;
        cau = 32'b0;
        epc = 32'b0;      
    end

    wire [31:0]Status_mux_1_out;
    mux #(2,1,32) Status_mux_1(.s(inta), .y(Status_mux_1_out), .d0(sta >> 4), .d1(sta << 4));
    wire [31:0]Status_mux_2_out;
    mux #(2,1,32) Status_mux_2(.s(mtc==0?0:1),.y(Status_mux_2_out),.d0(Status_mux_1_out),.d1(data));

    wire [31:0]Cause_mux_out;
    mux #(2,1,32) Cause_mux(.s(mtc==0?0:1),.y(Cause_mux_out),.d0(cause),.d1(data));

    wire [31:0] EPC_mux_1_out;
    mux #(2,1,32) EPC_mux_1(.s(pcplus4),.y(EPC_mux_1_out),.d0(PC-4),.d1(PC));
    wire [31:0] EPC_mux_2_out;
    mux #(2,1,32) EPC_mux_2(.s(mtc==0?0:1),.y(EPC_mux_2_out),.d0(EPC_mux_1_out),.d1(data));

    always @(negedge clk)
    begin
        if (wsta)
            sta <= Status_mux_2_out;
        if (wcau)
            cau <= Cause_mux_out;
        if (wepc)
            epc <= EPC_mux_2_out; 
    end
endmodule
