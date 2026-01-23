module crc_create(

    input logic clk,
    input logic rst,
    input logic init,
    input logic data_en,
    input logic bit_in,
    input logic id_en,

    output logic [63:0] packet,
    output logic [10:0] can_id

);

    always_ff @(posedge clk) begin
        if (init) begin
            packet <= '0;
            can_id <= '0;
        end
        else if (rst) begin
            packet <= '0;
            can_id <= '0;
        end
        else if (id_en)
            can_id <= {can_id[9:0], bit_in};
        else if (data_en)
            packet <= {packet[22:0], bit_in};
    end

endmodule