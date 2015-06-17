// The parity characteristic can be none=0, even=2, or odd=3.  If even
// parity, then the last data bit transmitted will be a logical 1 if
// the data transmitted had an even amount of 0 bits. If odd parity,
// then the last data bit transmitted will be a logical 1 if the data
// transmitted had an odd amount of 0 bits.

module uart_tx
  #(parameter CLK_DIV_WIDTH=8,
    parameter START_BIT = 0,
    parameter STOP_BIT  = 1
    )
   (
    input clk,
    input resetb,
    input [CLK_DIV_WIDTH-1:0] clk_div,
    output reg tx,
    input [7:0] datai,
    input [1:0] parity_mode,
    input we,
    output reg busy,
    output reg done
    );
   

   reg [CLK_DIV_WIDTH-1:0] clk_div_counter;
   wire [CLK_DIV_WIDTH-1:0] next_clk_div_counter = clk_div_counter + 1;
   wire clk_pulse_wire = next_clk_div_counter >= clk_div;
   reg 	clk_pulse;
   
   always@(posedge clk or negedge resetb) begin
      if(!resetb) begin
	 clk_div_counter <= 0;
	 clk_pulse <= 0;
      end else begin
	 clk_pulse <= clk_pulse_wire;
	 
	 if(clk_pulse_wire) begin
	    clk_div_counter <= 0;
	 end else begin
	    clk_div_counter <= next_clk_div_counter;
	 end
      end
   end 

   wire endtx    = 1'b1;
   wire startbit = START_BIT;
   wire stopbit  = STOP_BIT;
   wire parity_raw = datai[7] + datai[6] + datai[5] + datai[4] + datai[3] + datai[2] + datai[1] + datai[0];
   wire paritybit = parity_mode[0] ? !parity_raw : parity_raw;

   wire [11:0] data_tx_parity = { endtx, stopbit, paritybit, datai, startbit };
   wire [11:0] data_tx_noparity={ 1'b0,  endtx,   stopbit,   datai, startbit };
   wire [11:0] data_tx = (parity_mode[1]) ? data_tx_parity : data_tx_noparity;
   reg [11:0]  data_s;

   always@(posedge clk or negedge resetb) begin
      if(!resetb) begin
	 busy   <= 0;
	 done   <= 0;
	 data_s <= 0;
	 tx     <= stopbit;
      end else begin
	 if(busy) begin
	    if(clk_pulse) begin
	       data_s <= data_s >> 1;
	       if(data_s == 1) begin
		  busy <= 0;
		  done <= 1;
	       end else begin
		  tx <= data_s[0];
	       end
	    end
	 end else begin
	    if(we) begin
	       busy <= 1;
  	       data_s <= data_tx;
	    end
	    done <= 0;
	 end
      end
   end 
endmodule
