module UART_TX (
    input clk,
    input rst,
    input tx_start,
    input parity_mode,
    input [7:0] data_in,
    output reg data_out,
    output reg LED
);

reg [10:0] baud_counter;
reg [3:0] bit_count;
reg [1:0] state;
reg [7:0] data;
reg parity_bit;

parameter
    IDLE = 2'b00,
    MAIN = 2'b01;

always @(posedge clk or negedge rst)
begin
    if (~rst)
    begin
        baud_counter <= 0;
        bit_count    <= 0;
        data_out     <= 1'b1;
        state        <= IDLE;
        data         <= 0;
        parity_bit   <= 0;
        LED          <= 0;
    end

    else if (baud_counter == 1084)//125MHZ/115200 baud
    begin
        baud_counter <= 0;

        case (state)

            IDLE:
            begin
                data_out <= 1'b1;

                if (tx_start)
                begin
                    data <= data_in;
                    if (parity_mode == 1'b0)
                        parity_bit <= ^data_in; 
                    else
                        parity_bit <= ~^data_in;

                    data_out  <= 1'b0;
                    bit_count <= 0;
                    state     <= MAIN;
                    LED       <= 1'b1;
                end
            end

            MAIN:
            begin
                if (bit_count < 8)
                begin
                    data_out  <= data[bit_count];
                    bit_count <= bit_count + 1'b1;
                end

                else if (bit_count == 8)
                begin
                    data_out  <= parity_bit;
                    bit_count <= bit_count + 1'b1;
                end

                else if (bit_count == 9)
                begin
                    data_out  <= 1'b1;
                    bit_count <= bit_count + 1'b1;
                end

                else if (bit_count == 10)
                begin
                    state     <= IDLE;
                    bit_count <= 0;
                    LED       <= 1'b0;
                    data_out  <= 1'b1;
                end
            end
        endcase
    end

    else
    begin
        baud_counter <= baud_counter + 1'b1;
    end
end

endmodule
