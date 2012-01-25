module uart_rx
  #(parameter CLK_DIV_WIDTH=8,
    parameter START_BIT = 0,
    parameter STOP_BIT  = 1
    )
   (
    input clk,
    input resetb,
    input [CLK_DIV_WIDTH-1:0] clk_div,
    input rx,
    input [1:0] parity_mode,
    output reg re,
    output reg error,
    output reg [7:0] datao,
    output reg busy
    );
   
   
   
   reg [CLK_DIV_WIDTH-1:0] clk_div_counter;
   wire [CLK_DIV_WIDTH-1:0] next_clk_div_counter = clk_div_counter + 1;
   wire clk_pulse_wire = next_clk_div_counter >= clk_div;
   reg 	clk_pulse, clk_sync;
   
   always@(posedge clk or negedge resetb) begin
      if(!resetb) begin
	 clk_div_counter <= 0;
	 clk_pulse <= 0;
      end else begin
	 clk_pulse <= clk_pulse_wire;

	 if(clk_sync) begin
	    clk_div_counter <= clk_div >> 1;
	 end else if(clk_pulse_wire) begin
	    clk_div_counter <= 0;
	 end else begin
	    clk_div_counter <= next_clk_div_counter;
	 end
      end
   end 

   reg  [10:0] data_s;
   wire [10:0] next_data_s = { rx_s, data_s[10:1] };
   reg 	      rx_s, rx_ss;
   wire       start_detect = (rx_s == START_BIT) && (rx_ss == STOP_BIT);
   reg [3:0]  bit_counter;
   wire [3:0] stop_count = (parity_mode[0]) ? 11 : 10;
   wire       parity_raw = data_s[8] + data_s[7] + data_s[6] + data_s[5] + data_s[4] + data_s[3] + data_s[2] + data_s[1];
   wire       parity_calc = (parity_mode[1]) ? ~parity_raw : parity_raw;
   
   always@(posedge clk or negedge resetb) begin
      if(!resetb) begin
	 busy   <= 0;
	 data_s <= 0;
	 rx_s   <= 0;
	 rx_ss  <= 0;
	 clk_sync <= 0;
	 bit_counter <= 0;
      end else begin
	 rx_s <= rx;
	 rx_ss <= rx_s;

	 if(busy) begin
	    clk_sync <= 0;
	    if(clk_pulse) begin
	       data_s <= next_data_s;
	       bit_counter <= bit_counter + 1;
	       if(bit_counter == stop_count) begin
		  busy <= 0;
		  if((next_data_s[0] == START_BIT) && 
		     (next_data_s[stop_count] == STOP_BIT) &&
		     (!parity_mode[0] || (parity_calc == next_data_s[9]))) begin
		     re <= 1;
		  end else begin
		     error <= 1;
		  end
		  datao <= next_data_s[8:1];
	       end
	    end
	 end else begin
	    re          <= 0;
	    error       <= 0;
	    bit_counter <= 0;
	    if(start_detect) begin
	       clk_sync <= 1;
	       busy     <= 1;
	    end
	 end
      end
   end 
endmodule