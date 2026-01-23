module controller(

    input logic clk,
    input logic rst,
    input logic init,

    input logic [3:0] TX_DLC,
    input logic [7:0] TX_DATA [7:0],
    input logic [10:0] TX_ID,
    input logic TX_REQ,
    output logic TX_BUSY,
    output logic TX_COMPLETE,

    // output logic [3:0] RX_DLC,
    // output logic [7:0] RX_DATA [7:0],
    // output logic [10:0] RX_ID,
    // output logic RX_VALID,
    // output logic RX_BUSY,

    // input logic bit_in,
    output logic bit_out

);

    logic [6:0] tx_index;
    logic [3:0] tx_dlc_copy;
    logic [7:0] tx_data_copy [7:0];
    logic [10:0] tx_id_copy;

    // Tx
    always_ff @(posedge clk) begin
        if (init) begin
            TX_BUSY <= '0;
            TX_COMPLETE <= '0;
            bit_out <= '0;
            tx_index <= '0;
        end
        else if (rst) begin
            TX_BUSY <= '0;
            TX_COMPLETE <= '0;
            bit_out <= '0;
            tx_index <= '0;
        end
        else if (TX_BUSY) begin
            
            if (tx_index == 0) begin
                bit_out <= 0;
            end 
            else if (tx_index >= 1 && tx_index <= 11) begin
                bit_out <= tx_id_copy[11 - tx_index];
            end 
            else if (tx_index >= 12 && tx_index <= 14) begin
                bit_out <= 0;
            end 
            else if (tx_index >= 15 && tx_index <= 18) begin
                bit_out <= tx_dlc_copy[18 - tx_index];
            end 
            else if (tx_index >= 19 && tx_index <= (19 + (tx_dlc_copy * 8) - 1)) begin
                bit_out <= tx_data_copy[(tx_index - 19) / 8][7 - ((tx_index - 19) % 8)];
            end 
            else if (tx_index == (19 + (tx_dlc_copy * 8))) begin
                TX_COMPLETE <= 1;
                bit_out <= 1;
            end

            tx_index <= tx_index+1;

        end
        else if(TX_COMPLETE) begin
            bit_out <= 1;
            tx_index <= 0;
            TX_BUSY <= 0;
            TX_COMPLETE <= 0;
        end
        else if (TX_REQ) begin
            TX_BUSY <= 1;
            tx_index <= 0;
            for (int i = 0; i < 8; i++) begin
                tx_data_copy[i] <= TX_DATA[i];
            end
            tx_dlc_copy <= TX_DLC;
            tx_id_copy <= TX_ID;
        end
    end

    // // rx
    // always_ff @(posedge clk) begin
    //     if (init) begin
    //         packet <= '0;
    //         can_id <= '0;
    //     end
    //     else if (rst) begin
    //         packet <= '0;
    //         can_id <= '0;
    //     end
    //     else if (id_en)
    //         can_id <= {can_id[9:0], bit_in};
    //     else if (data_en) begin
    //         packet <= {packet[22:0], bit_in};
    //         data_count++;
    //     end
    // end

endmodule