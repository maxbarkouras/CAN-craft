module crc_create(

    input logic clk,
    input logic rst,
    input logic init,
    input logic enable,

    input logic bit_in,

	input logic crc_next,
	output logic [7:0] crc

    // output logic [14:0] crc;
);

    always_ff @(posedge clk) begin
        if (init)
            crc <= '0;
        else if (enable)
            crc <= {crc[6:0], bit_in};
    end

endmodule