module uart_di
  #(parameter LOG2_RX_BUFFER_LEN=4)
  (
   input 	     resetb, 
   input 	     ifclk, 

   input [15:0]      di_term_addr,
   input [31:0]      di_reg_addr,
   input 	     di_read_mode,
   input 	     di_read_req,
   input 	     di_read,
   input 	     di_write_mode,
   input 	     di_write,
   input [15:0]      di_reg_datai,
   output reg 	     di_read_rdy,
   output reg [15:0] di_reg_datao,
   output reg 	     di_write_rdy,
   output reg [15:0] di_transfer_status,
   output reg 	     di_UART_en,

   input [15:0] ctrl_term_addr,
   input [15:0] uart_term_addr,
   
   input rx,
   output tx
   );

   wire   di_clk = ifclk;
   reg [15:0] rx_data_available;

`include "UART_CTRLTerminalInstance.v"

   wire   rx, tx, re, rx_error, rx_busy, tx_done, tx_busy;
   wire [7:0] rx_data;
   wire       uart_we = (di_term_addr == uart_term_addr) && di_write;
   
   uart_duplex #(.CLK_DIV_WIDTH(16))
   uart_duplex
     (
      .clk(ifclk),
      .resetb(resetb),
      .clk_div(clk_div),
      .parity_mode(parity_mode),
      .rx(rx),
      .re(re),
      .rx_error(rx_error),
      .rx_data(rx_data),
      .rx_busy(rx_busy),
      
      .tx(tx),
      .tx_data(di_reg_datai[7:0]),
      .we(uart_we),
      .tx_busy(tx_busy),
      .tx_done(tx_done)
      );

   reg [7:0]  rx_buffer [0:(1<<LOG2_RX_BUFFER_LEN)-1];
   reg [LOG2_RX_BUFFER_LEN-1:0] rp, wp;
   wire [LOG2_RX_BUFFER_LEN-1:0] next_rp = rp+1;
   wire [LOG2_RX_BUFFER_LEN-1:0] next_wp = wp+1;

   wire	di_read_uart = (di_term_addr == uart_term_addr) && di_read;
   wire rx_buf_full  = next_wp == rp;
   wire rx_buf_empty = wp == rp;
   wire [LOG2_RX_BUFFER_LEN-1:0] rx_buf_num   = wp - rp;
   reg [7:0] rx_buffer_data;
   reg 	     rx_buffer_ready;
   reg [15:0] rx_transfer_status;
   
   always @(posedge ifclk or negedge resetb) begin
      if(!resetb) begin
	 rp <= 0;
	 wp <= 0;
	 rx_buffer_data <= 0;
	 rx_transfer_status <= 0;
	 rx_buffer_ready <= 0;
	 rx_data_available <= 0;
      end else begin
	 if(clear_rx_buffer) begin
	    rp <= 0;
	    wp <= 0;
	 end else begin
	    if(re) begin
	       wp <= next_wp;
	       rx_buffer[wp] <= rx_data;
	    end

	    if(di_read_uart || (re && (next_wp == rp))) begin
	       rp <= next_rp;
	    end
	 end
	 rx_buffer_data <= rx_buffer[rp];
	 rx_buffer_ready <= !rx_buf_empty;

         if(!di_read_mode && !di_write_mode) begin // clear status between read/
	    rx_transfer_status <= 0;
	 end else begin
	    if(rx_error) begin
	       rx_transfer_status <= 1;
	    end
	 end
	 /* verilator lint_off WIDTH */
	 rx_data_available <= rx_buf_num;
	 /* verilator lint_on WIDTH */
      end
   end
   
   
   always @(*) begin
      if(di_term_addr == ctrl_term_addr) begin
         di_UART_en   = 1;
         di_reg_datao = UART_CTRLTerminal_reg_datao;
         di_read_rdy  = 1;
         di_write_rdy = 1;
         di_transfer_status = 0;
      end else if(di_term_addr == uart_term_addr) begin
         di_UART_en   = 1;
         di_reg_datao =  { 8'h0, rx_buffer_data };
         di_read_rdy  =  ~rx_buf_empty;
         di_write_rdy = ~tx_busy && !di_write;
         di_transfer_status = (rx_transfer_status && di_read_mode);
      end else begin
         di_UART_en   = 0;
         di_reg_datao = 16'hAAAA;
         di_read_rdy  = 1;
         di_write_rdy = 1;
         di_transfer_status = 16'hFFFE; // undefined terminal, return error code
      end
   end

   
endmodule