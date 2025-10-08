module UART_Tx #(parameter CLKS_PER_BIT = 217) 
 (
    input i_rst_l,  //Active low reset
    input i_clk_sys,  // System clock
    input i_tx_start, // sending the data is valid
    input [7:0] i_tx_byte, // data to be sent
    output reg o_tx_active, // low when idle, high when transmitting data
    output reg o_tx_serial, // UART serial out
    output reg o_tx_done // high for 1 clock cycle when transmission is done
 );

// parameter for the state machine

 localparam IDLE        = 3'b000;  // line high (Uart waits for start bit)
 localparam Start_bit   = 3'b001;  // line low (tx start) start bit =0 
 localparam Data_bits   = 3'b010;  // 8 data bits (LSB first)
 localparam Stop_bit    = 3'b011; // tx stop sending sero bit first
 localparam Clean       = 3'b100;  // finish tx


// some registers in the module
reg [2:0] state = 0; // current state
reg [$clog2(CLKS_PER_BIT)-1:0] clk_count =0; // counter for the clock cycles in one bit
reg [2:0] bit_index =0; // index of the bit being sent 
reg [7:0] tx_data =0; // data being sent

//state machine
always @(posedge i_clk_sys or negedge i_rst_l) 
   begin
        if (~i_rst_l)
        begin 
            state <= 3'b000;
        end
        else
        begin 
            o_tx_done <= 1'b0; // default value
            case (state)
            IDLE:
                    begin 
                        o_tx_serial <= 1'b1; // line is high -> idle
                        clk_count <=0;  // counts the clock cycles in one bit
                        bit_index <=0;  // index of the bit being sent
                        if (i_tx_start == 1'b1) 
                        begin
                            o_tx_active <= 1'b1; // transmission is active
                            tx_data <= i_tx_byte; // load the data to be sent
                            state <= Start_bit;  // go to start bit state
                        end
                    else begin
                        state <= IDLE;
                        o_tx_active <= 1'b0;
                    end
                    end
            Start_bit:
                    begin
                        o_tx_serial <=1'b0; //start bit
                        if (clk_count < CLKS_PER_BIT -1) 
                            clk_count <= clk_count+1;
                        else
                        begin
                            clk_count <=0;
                            state <= Data_bits;
                        end
                    end
            Data_bits:
                    begin
                        o_tx_serial <= tx_data[bit_index]; //send the data bit]
                        if (clk_count < CLKS_PER_BIT -1) 
                        begin 
                            clk_count <= clk_count +1;
                        end

                        else
                        begin
                            clk_count <=0;
                            if (bit_index < 7)
                            begin 
                                bit_index <= bit_index +1;
                            end
                            else begin 
                                bit_index <=0;
                                state <= Stop_bit;
                            end
                        end
                    end
        Stop_bit:
        begin 
            o_tx_serial <= 1'b1; // stop_bit =1;

            if (clk_count < CLKS_PER_BIT-1)
            begin
                clk_count <= clk_count +1;
            
            end

            else 
            begin 
                o_tx_done <= 1'b1; // signal done
                clk_count <= 0;
                state <= Clean;
                o_tx_active <=1'b0; // no longer transmitting

            end
        end

        Clean:

        begin
            state <= IDLE;
        end

        default: state <= IDLE;
                
            

    endcase
    end
end

endmodule