module uart_rx #(parameter CLKS_PER_BIT = 217) // 115200 baud at 10MHz clock
(
    input i_clk_sys,
    input i_rst_l,
    input i_rx_serial,
    output reg o_rx_done,
    output reg [7:0] o_rx_byte,
    output reg o_rx_active
);

endmodule