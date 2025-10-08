//////////////////////////////////////////////////////////////////////////////////
// Uart Receiver Module
// Author: Ayushi Maurya
// Clock frequency: 50MHz
// Clock per bit: 217 (for 230400 baud rate)
// just for learning purpose
//////////////////////////////////////////////////////////////////////////////////

module uart_rx #(parameter CLKS_PER_BIT = 217) 
(
    input i_rst_l, // active low reset
    input sys_clk, // system clock
    input i_rx_serial, // Uart serial input
    output reg o_rx_DV, // data high for full byte received
    output reg [7:0] o_rx_data // data received
);

// encoding the states of the state machine
localparam IDLE       = 3'b000;
localparam Start_bit   = 3'b001;
localparam Data_bits  = 3'b010;
localparam Stop_bit   = 3'b011;
localparam Clean      = 3'b100;


// some registers in the module
reg [2:0] state =IDLE;
reg [$clog2(CLKS_PER_BIT)-1:0] clk_count =0; // counter for the clock cycles in one bit]
reg [2:0] bit_index =0; // index of the bit being received

// state machine
always @(posedge sys_clk or negedge i_rst_l)
    begin 
        if (~i_rst_l)
        begin
            state <= 3'b000;
            o_rx_DV <= 1'b0;  // data valid cleared
        end 

        else
            begin
                case (state)
                IDLE: 
                begin 
                    o_rx_DV <=1'b0; 
                    clk_count <=0;
                    bit_index <=0;

                    if (i_rx_serial == 1'b0) // start bit detected
                        state <=Start_bit;
                    else
                        state<=IDLE;
                end
                Start_bit:
                begin 
                    if (clk_count == (CLKS_PER_BIT-1)/2) // middle check 
                    begin 
                        if (i_rx_serial == 1'b0) // low found at middle
                        begin 
                            clk_count <=0;
                            state <= Data_bits; // 
                        end
                        else
                            state <= IDLE; // false start bit
                    end
                    else
                    begin 
                        clk_count <= clk_count+1;
                        state <= Start_bit;
                    end
                end

                Data_bits:
                begin 
                    if (clk_count < CLKS_PER_BIT-1)  // wait for full bit period
                    begin
                        clk_count <= clk_count +1;
                        state <= Data_bits;
                    end
                    else
                    begin 
                        clk_count <= 0;
                        o_rx_data[bit_index] <= i_rx_serial;
                        if (bit_index < 7 )
                        begin 
                            bit_index <= bit_index+1;
                            state <=Data_bits;
                        end
                        else
                        begin 
                            bit_index <=0;
                            state <= Stop_bit;
                        end
                    end
                end
                Stop_bit:
                begin 
                    if (clk_count <= CLKS_PER_BIT-1)
                    begin
                        clk_count <= clk_count +1;
                        state <= Stop_bit;
                    end
                    else 
                    begin
                         clk_count <=0;
                    o_rx_DV <=1'b1; // data valid
                    state <= Clean;
                    end
                   
                end 
                Clean:
                begin 
                    state<= IDLE;
                    o_rx_DV <=1'b0;
                end
                default:
                    state <= IDLE;
                endcase

    end
end




endmodule