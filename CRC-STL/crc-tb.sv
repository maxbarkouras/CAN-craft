module crc_tb;
    timeunit 1ns;
    timeprecision 1ps;

    bit bit_in;
    bit clk, rst = 0, init = 0, enable = 0;
    bit [7:0] crc;
    reg [7:0] data; 

    crc_create maker(
        .clk(clk),
        .rst(rst),
        .bit_in(bit_in),
        .init(init),
        .enable(enable),
        .crc(crc)
    );

    always begin
        #5 clk = 1;
        #5 clk = 0;
    end
	 
	initial begin

        data = 8'hA2;

        init = 1;
        @(posedge clk);
        init = 0;

        enable = 1;
        for(int i=0;i<8;i++) begin
            @(negedge clk);
            bit_in = data[7-i];
            @(posedge clk);
            //$display("%d %b", bit_in, crc);

        end

        enable = 0;
        @(posedge clk);
        $display("complete: 0x%h", crc);
        $stop;

    end
		 
endmodule
