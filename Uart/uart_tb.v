`timescale 1ns/1ps

module uart_tb;

  parameter CLKS_PER_BIT = 217;

  // Signals
  reg clk = 0;
  reg rst_n = 0;
  reg tx_start = 0;
  reg [7:0] tx_data = 8'hFF; // Example data byte to transmit

  wire tx_serial;
  wire tx_done;
  wire tx_active;
  wire rx_dv;
  wire [7:0] rx_data;

  // 50 MHz clock = 20 ns period
  always #10 clk = ~clk;

  // Instantiate UART Transmitter
  UART_Tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) tx_inst (
    .i_rst_l     (rst_n),
    .i_clk_sys   (clk),
    .i_tx_start  (tx_start),
    .i_tx_byte   (tx_data),
    .o_tx_active (tx_active),
    .o_tx_serial (tx_serial),
    .o_tx_done   (tx_done)
  );

  // Instantiate UART Receiver
  uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx_inst (
    .i_rst_l     (rst_n),
    .sys_clk     (clk),
    .i_rx_serial (tx_serial),
    .o_rx_DV     (rx_dv),
    .o_rx_data   (rx_data)
  );

  // Test sequence
  initial begin
    $dumpfile("uart_wave.vcd");
    $dumpvars(0, uart_tb);

    // Reset
    rst_n = 0;
    #100;
    rst_n = 1;

    // Start transmission
    #200;
    tx_start = 1;
    #20;
    tx_start = 0;

    // Wait for transfer to complete
    #50000;
    $finish;
  end

endmodule
