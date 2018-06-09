module im_4k(addr,dout);
    input   [11:2]  addr;
    output  [31:0]  dout;
    reg [31:0] IMem[1023:0];
    integer fp,count,reger,num;
    initial
	begin
      fp=$fopen("test.dat","r");
      num = 0;
      while (!$feof(fp))
      begin
        count=$fscanf(fp,"%h",reger);
        if(count==1)
          begin
          IMem[num]=reger;
          num=num+1;
          end
      end
      $fclose(fp);
	end
  assign dout = IMem[addr];
endmodule
