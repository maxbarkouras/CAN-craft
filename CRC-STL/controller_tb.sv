module controller_tb;
    timeunit 1ns;
    timeprecision 1ps;

    bit clk, rst, init;

    bit TX_REQ, TX_BUSY, TX_COMPLETE;
    bit [3:0] TX_DLC;
    reg [7:0] TX_DATA [7:0];
    bit [10:0] TX_ID;

    bit bit_out;

    bit [127:0] collector;

    controller maker(
        .clk(clk),
        .rst(rst),
        .init(init),
        .TX_DLC(TX_DLC),
        .TX_DATA(TX_DATA),
        .TX_ID(TX_ID),
        .bit_out(bit_out),
        .TX_REQ(TX_REQ),
        .TX_BUSY(TX_BUSY),
        .TX_COMPLETE(TX_COMPLETE)
    );

    always begin
        #5 clk = 1;
        #5 clk = 0;
    end
	 
	initial begin

        TX_DLC = 3'd6;
        TX_DATA[0] = 8'h55;
        TX_DATA[1] = 8'h32;
        TX_DATA[2] = 8'h18;
        TX_DATA[3] = 8'h10;
        TX_DATA[4] = 8'h01;
        TX_DATA[5] = 8'h5;
        TX_ID = 11'h150;

        init = 1;
        @(posedge clk);
        init = 0;

        TX_REQ = 1;

        while(!TX_COMPLETE) begin
            @(negedge clk);
            collector = {collector[126:0], bit_out};
            @(posedge clk);
        end

        TX_REQ = 0;

        $display("%b", collector);

        $finish;

        // id_en = 1;
        // for(int i=11; i>0; i--) begin

        //     @(negedge clk);
        //     bit_in = can_id[i-1];
        //     @(posedge clk);
        //     $display("sending: %b", bit_in);

        // end

        // id_en = 0;
        // @(posedge clk);
        // $display("id recieved: 0x%x",id_recv);

        // data_en = 1;
        // for(int i=data_bytes; i>0; i--) begin
        //     for(int j=0; j<8; j++) begin

        //         @(negedge clk);
        //         bit_in = can_data[data_bytes-i][7-j];
        //         @(posedge clk);
        //         $display("sending: %b", bit_in);

        //     end
        //     $display("sent: 0x%x", can_data[data_bytes-i]);
        // end

        // data_en = 0;
        // @(posedge clk);
        // $display("data recieved: 0x%x",data_recv);
        // $finish;

    end
		 
endmodule
