module mips(clock,rst,MIO_ready,inst_in,Data_in,
mem_w,PC_out,Addr_out,Data_out,CPU_MIO,INT,asd);
	input MIO_ready;
									
	input [31:0]inst_in;
	input [31:0]Data_in;	
									
	output mem_w;
	output[31:0]PC_out;
	output[31:0]Addr_out;
	output[31:0]Data_out; 
	output CPU_MIO;
	input INT;
	output [31:0]asd; 
	input clock;
    input rst;
	reg clk_div;
    //---add INT
    wire inta;
    wire [31:0] sta,cau,epc;
    wire [31:0] dataToc0;
    wire [31:0] cause;
    wire [4:0] mtc;
    wire eret;
    //------------

    initial 
    begin
        clk_div = 0;
    end

	always @(negedge clock or posedge rst)
	begin
		if (rst)
			clk_div = 0;
		else
            clk_div = ~clk_div;
	end



    //##Special use##
    wire RFtoBranch; //judge if RF is ready 


    wire IDflush;
    wire EXflush;
    wire EXflush_2;
    wire [1:0] IFIDSIG;
    wire [1:0] IDEXSIG;
    // MIPS Control Signals
    wire clk;
	 assign clk = clock;

    // PC & wires
    wire [31:0] pc_in;
    wire [31:0] pc_out;
    wire [31:0] pc;
    wire pc_change; assign pc_change = 1;
    PCUnit my_pc(.in(pc_in), .PC(pc_out), .clk(clk), .sig(pc_change),.rst(rst));

    //PC mux
    wire [2:0]PCSrc;
    wire [31:0] PC_branch;
    wire [31:0] RD1;
    wire [31:0] PC_jump;
    mux #(8,3,32) pcmux(.s(PCSrc),.y(pc_in),.d0(pc_out + 4),.d1(PC_branch), .d2(RD1), .d3(PC_jump), .d4(pc_out), .d5(pc_out - 4), .d6(32'h0000_0004),.d7(epc));

    // im & wires
    wire [31:0]im_out;
    im_4k my_im(.addr(pc_out[11:2]), .dout(im_out));
	/* assign PC_out = pc_out;
	 assign im_out = inst_in;
	 */

    // IF->ID
    wire IFIDEN; assign IFIDEN = 1;
    wire [31:0] instruction;
    floprf IFIDINS(.clk(clk), .sig(IFIDSIG), .d(im_out), .q(instruction),.rst(rst));
    flopr IFIDPC(.clk(clk), .sig(IFIDEN), .d(pc_out + 4), .q(pc),.rst(rst));

    // RF & wires
    wire RFWr;
    wire [4:0] WB_address;
    wire [31:0] WB_data;
    wire [31:0] WB_data_true;
    wire [31:0] RD2;
    RF my_RF(.A1(instruction[25:21]), .A2(instruction[20:16]), 
        .A3(WB_address), .WD(WB_data_true), .RFWr(RFWr), 
        .clk(clk), .RD1(RD1), .RD2(RD2),
        .RFtoBranch(RFtoBranch),.rst(rst));


    //SE & UE
    wire [31:0]SE_out;
    wire [31:0]UE_out;
    SE my_SE(.in(instruction[15:0]), .out(SE_out));
    UE my_UE(.in(instruction[15:0]), .out(UE_out));
    assign PC_branch = (SE_out<<2) + pc;
    assign PC_jump = {pc[31:28],instruction[25:0],2'b0};
    
    //ID -> EX
    wire [31:0] EX_A;
    wire [31:0] EX_B;
    flopr IDEX_A(.clk(clk), .sig(2'b1), .d(RD1), .q(EX_A), .rst(rst));
    flopr IDEX_B(.clk(clk), .sig(2'b1), .d(RD2), .q(EX_B), .rst(rst));
    wire [31:0] EX_UE;
    wire [31:0] EX_SE;
    flopr IDEX_UE(.clk(clk), .sig(2'b1), .d(UE_out), .q(EX_UE),.rst(rst));
    flopr IDEX_SE(.clk(clk), .sig(2'b1), .d(SE_out), .q(EX_SE),.rst(rst));
    wire [31:0] EX_ins;
    floprf IDEX_ins(.clk(clk),.sig(IDEXSIG), .d(instruction), .q(EX_ins),.rst(rst));
    wire [31:0] ex_pc;
    flopr IDEXPC(.clk(clk), .sig(2'b1), .d(pc), .q(ex_pc),.rst(rst));

    //ALU
    wire [1:0] ALUASrc;
    wire [1:0] ALUBSrc;
    wire [31:0] ALU_A;
    wire [31:0] ALU_B;
    wire [31:0] ALU_out;
    wire [3:0] ALUOp;
    wire [31:0] ans_for1;
    wire [31:0] ans_for2;
    mux #(4,2,32) ALU_A_Src(.s(ALUASrc), .y(ALU_A), .d0(ans_for1), .d1({27'b0,EX_ins[10:6]}), .d2(1), .d3(1));
    mux #(4,2,32) ALU_B_Src(.s(ALUBSrc), .y(ALU_B), .d0(ans_for2), .d1(EX_SE), .d2(EX_UE), .d3(1));
    ALU my_alu(.C(ALU_out), .A(ALU_A), .B(ALU_B), .ALUOp(ALUOp));

    //forwarding
    wire [1:0]forward1;
    wire [1:0]forward2;
    wire[31:0] WB_MEM_out;
    wire[31:0] WB_ALU_out;
    wire [31:0] MEM_ALU_out;
    mux #(4,2,32) forwarding1(.s(forward1), .y(ans_for1), .d0(EX_A), .d1(MEM_ALU_out), .d2(WB_MEM_out),.d3(WB_ALU_out));
    mux #(4,2,32) forwarding2(.s(forward2), .y(ans_for2), .d0(EX_B), .d1(MEM_ALU_out), .d2(WB_MEM_out),.d3(WB_ALU_out));

    //EX -> MEM
    wire [31:0] MEM_ALU_B;
    wire [31:0] MEM_data_in;
    flopr EXMEMALUout(.clk(clk), .sig(2'b1), .d(ALU_out), .q(MEM_ALU_out),.rst(rst));
    flopr EXMEMALUB(.clk(clk), .sig(2'b1), .d(ans_for2), .q(MEM_data_in),.rst(rst));

    wire [31:0] MEM_ins;
    flopr EXMEM_ins(.clk(clk),.sig(2'b1), .d(EX_ins), .q(MEM_ins),.rst(rst));

    wire [31:0] mem_pc;
    flopr EXMEMPC(.clk(clk), .sig(IFIDEN), .d(ex_pc), .q(mem_pc),.rst(rst));

    //MEM
    wire DMWr;
    wire [31:0] MEM_out;
    wire [31:0] LHANDLE_out;
    wire [3:0] beout;
    BEUnit my_BEUnit(MEM_ALU_out[1:0],MEM_ins[31:26],beout);
    LHandle my_LHANDLE(MEM_ins[31:26],MEM_ALU_out[1:0],MEM_out,LHANDLE_out);
    dm_4k my_dm(.addr(MEM_ALU_out[11:2]), .be(beout), .din(MEM_data_in), .DMWr(DMWr), .clk(clk), .dout(MEM_out));
	/*
     assign Addr_out = MEM_ALU_out;
	 assign Data_out = MEM_data_in;
	 assign mem_w = DMWr;
	 assign MEM_out = Data_in;
    */
    //MEM -> WB
    flopr MEMWB1(.clk(clk), .sig(2'b1), .d(LHANDLE_out), .q(WB_MEM_out),.rst(rst));
    flopr MEMWB2(.clk(clk), .sig(2'b1), .d(MEM_ALU_out), .q(WB_ALU_out),.rst(rst));
    
    wire [31:0] WB_ins;
    flopr MEMWB_ins(.clk(clk),.sig(2'b1), .d(MEM_ins), .q(WB_ins),.rst(rst));

    wire [31:0] wb_pc;
    flopr MEMWBPC(.clk(clk), .sig(IFIDEN), .d(mem_pc), .q(wb_pc),.rst(rst));

    //WB
    wire [1:0]WBdSrc;
    wire [1:0]WBaSrc;
    wire [1:0] WBc0Src;
    mux #(4,2,32) WBdSrcmux(.s(WBdSrc), .y(WB_data), .d0(WB_MEM_out), .d1(WB_ALU_out), .d2(wb_pc));
    mux #(4,2,5) WBaSrcmux(.s(WBaSrc), .y(WB_address), .d0(WB_ins[15:11]), .d1(WB_ins[20:16]), .d2(5'b11111));
    mux #(4,2,32) WBc0Srcmux(.s(WBc0Src), .y(WB_data_true) ,.d0(WB_data),.d1(cau),.d2(sta),.d3(epc));

    //ctrl
    ctrl my_ctrl(.ID_ins(instruction), .EX_ins(EX_ins), .MEM_ins(MEM_ins), .WB_ins(WB_ins),
        .ALUOp(ALUOp), .PCSrc(PCSrc), .ALUASrc(ALUASrc), .ALUBSrc(ALUBSrc), 
        .WBdSrc(WBdSrc), .WBaSrc(WBaSrc), .DMWr(DMWr), .RFWr(RFWr),
        .clk(clk),.RFtoBranch(RFtoBranch),.RD1(RD1),.RD2(RD2), .IDflush(IDflush), .EXflush(EXflush),
        .forward1(forward1),.forward2(forward2),.EXflush_2(EXflush_2),.IFIDSIG(IFIDSIG),.IDEXSIG(IDEXSIG),
        .INT(INT),.inta(inta),.dataToc0(dataToc0),.cause(cause),.mtc(mtc),.eret(eret),
        .sta(sta),.WBc0Src(WBc0Src));
    


    c0reg my_c0(.sta(sta),.cau(cau),.epc(epc),.inta(inta),.data(dataToc0),.PC(pc_out),
    .cause(cause),.mtc(mtc),.clk(clk),.eret(eret));
		  
	 assign asd = {30'b0,clk_div};
endmodule
