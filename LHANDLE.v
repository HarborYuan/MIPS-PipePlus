module LHandle(instr,addr,in,out);
    input [5:0]instr;
    input [1:0]addr;
    input [31:0]in;
    output reg [31:0]out;

    always@(*)
    begin
        case(instr)
            6'h20:case(addr)
                    2'b00:out<={{24{in[7]}},in[7:0]};
                    2'b01:out<={{24{in[15]}},in[15:8]};
                    2'b10:out<={{24{in[23]}},in[23:16]};
                    2'b11:out<={{24{in[31]}},in[31:24]};
                    endcase
            6'h24:case(addr)
                    2'b00:out<={24'b0,in[7:0]};
                    2'b01:out<={24'b0,in[15:8]};
                    2'b10:out<={24'b0,in[23:16]};
                    2'b11:out<={24'b0,in[31:24]};
                    endcase
            6'h21:case(addr)
                    2'b00:out<={{16{in[15]}},in[15:0]};
                    2'b10:out<={{16{in[31]}},in[31:16]};
                    endcase
            6'h25:case(addr)
                    2'b00:out<={16'b0,in[15:0]};
                    2'b10:out<={16'b0,in[31:16]};
                    endcase
            6'h23:out<=in;
        endcase
    end
endmodule