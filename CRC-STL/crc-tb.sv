module crc_tb;
    timeunit 1ns;
    timeprecision 1ps;

    bit bit_in;
    bit clk, rst = 0, init = 0, data_en = 0, id_en = 0;
    bit [63:0] data_recv;
    bit [10:0] id_recv;
    bit [7:0] data; 
    bit [10:0] can_id;
    bit [7:0] can_data [0:7];
    bit [2:0] data_bytes;

    crc_create maker(
        .clk(clk),
        .rst(rst),
        .bit_in(bit_in),
        .init(init),
        .data_en(data_en),
        .packet(data_recv),
        .id_en(id_en),
        .can_id(id_recv)
    );

    always begin
        #5 clk = 1;
        #5 clk = 0;
    end
	 
	initial begin

        data_bytes = 3'd3;
        //can_data = 0;
        can_data[0] = 8'h10;
        can_data[1] = 8'h02;
        can_data[2] = 8'h01;
        can_id = 11'h7ff;

        init = 1;
        @(posedge clk);
        init = 0;

        id_en = 1;
        for(int i=11; i>0; i--) begin

            @(negedge clk);
            bit_in = can_id[i-1];
            @(posedge clk);
            $display("sending: %b", bit_in);

        end

        id_en = 0;
        @(posedge clk);
        $display("id recieved: 0x%x",id_recv);

        data_en = 1;
        for(int i=data_bytes; i>0; i--) begin
            for(int j=0; j<8; j++) begin

                @(negedge clk);
                bit_in = can_data[data_bytes-i][7-j];
                @(posedge clk);
                $display("sending: %b", bit_in);

            end
            $display("sent: 0x%x", can_data[data_bytes-i]);
        end

        data_en = 0;
        @(posedge clk);
        $display("data recieved: 0x%x",data_recv);
        $finish;

    end
		 
endmodule
