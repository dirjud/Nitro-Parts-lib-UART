module uart_di
  #(parameter LOG2_RX_BUFFER_LEN=4,
    parameter DI_DATA_WIDTH=16)
  (
   input 			  resetb, 
   input 			  ifclk, 

   input [15:0] 		  di_term_addr,
   input [31:0] 		  di_reg_addr,
   input [31:0] 		  di_len,
   input 			  di_read_mode,
   input 			  di_read_req,
   input 			  di_read,
   input 			  di_write_mode,
   input 			  di_write,
   input [DI_DATA_WIDTH-1:0] 	  di_reg_datai,
   output reg 			  di_read_rdy,
   output reg [DI_DATA_WIDTH-1:0] di_reg_datao,
   output reg 			  di_write_rdy,
   output reg [15:0] 		  di_transfer_status,
   output reg 			  di_UART_en,

   input [15:0] 		  ctrl_term_addr,
   input [15:0] 		  uart_term_addr,
   
   input 			  rx,
   output 			  tx
   );

   wire   di_clk = ifclk;
   reg [15:0] rx_data_available;

/* verilator lint_off WIDTH */
`include "UART_CTRLTerminalInstance.v"
/* verilator lint_on WIDTH */

   wire   rx, tx, re, rx_error, rx_busy, tx_done, tx_busy;
   wire [7:0] rx_data, tx_data;
   wire       di_write_uart = (di_term_addr == uart_term_addr) && di_write;
   wire       uart_we;
   
   uart_duplex #(.CLK_DIV_WIDTH(16))
   uart_duplex
     (
      .clk(ifclk),
      .resetb(resetb),
      .clk_div(clk_div),
      .parity_mode(parity_mode),
      .parity_error_mode(parity_error_mode),
      .rx(rx),
      .re(re),
      .rx_error(rx_error),
      .rx_data(rx_data),
      .rx_busy(rx_busy),
      
      .tx(tx),
      .tx_data(tx_data),
      .we(uart_we),
      .tx_busy(tx_busy),
      .tx_done(tx_done)
      );

   reg [8:0]  rx_buffer [0:(1<<LOG2_RX_BUFFER_LEN)-1];
   reg [LOG2_RX_BUFFER_LEN-1:0] rp, wp;
   wire [LOG2_RX_BUFFER_LEN-1:0] next_rp = rp+1;
   wire [LOG2_RX_BUFFER_LEN-1:0] next_wp = wp+1;

   wire di_read_uart;// = (di_term_addr == uart_term_addr) && di_read;
   wire rx_buf_full  = next_wp == rp;
   wire rx_buf_empty = wp == rp;
   wire [LOG2_RX_BUFFER_LEN-1:0] rx_buf_num   = wp - rp;
   reg [8:0] rx_buffer_data;
   reg 	     rx_buffer_ready;
   reg [15:0] di_transfer_status_uart;
   
   always @(posedge ifclk or negedge resetb) begin
      if(!resetb) begin
	 rp <= 0;
	 wp <= 0;
	 rx_buffer_data <= 0;
	 rx_buffer_ready <= 0;
	 rx_data_available <= 0;
	 di_transfer_status_uart <= 0;
      end else begin
	 if(!di_read_mode) begin
	    di_transfer_status_uart <= 0;
	 end else if(di_read_uart && rx_buffer_data[8] && parity_error_mode == 2) begin
	    di_transfer_status_uart <= di_transfer_status_uart + 1;
	 end
	 
	 if(clear_rx_buffer) begin
	    rp <= 0;
	    wp <= 0;
	 end else begin
	    if(re) begin
	       wp <= next_wp;
	       rx_buffer[wp] <= { rx_error, rx_data };
	    end

	    if(di_read_uart || (re && (next_wp == rp))) begin
	       rp <= next_rp;
	    end
	 end
	 rx_buffer_data <= rx_buffer[rp];
	 rx_buffer_ready <= !rx_buf_empty && !di_read_uart;

	 /* verilator lint_off WIDTH */
	 rx_data_available <= rx_buf_num;
	 /* verilator lint_on WIDTH */
      end
   end

   wire di_term_UART_enable = di_term_addr == uart_term_addr;
   wire di_write_rdy_uart0  = ~tx_busy && !di_write;
   wire di_read_rdy_uart0   = ~rx_buf_empty;
   wire di_write_rdy_uart, di_read_rdy_uart;
   wire [DI_DATA_WIDTH-1:0] di_reg_datao_uart;
   
   always @(*) begin
      if(di_term_addr == ctrl_term_addr) begin
         di_UART_en   = 1;
	 /* verilator lint_off WIDTH */
         di_reg_datao = UART_CTRLTerminal_reg_datao ;
	 /* verilator lint_on WIDTH */
         di_read_rdy  = 1;
         di_write_rdy = 1;
         di_transfer_status = 0;
      end else if(di_term_UART_enable) begin
         di_UART_en   = 1;
         di_reg_datao = di_reg_datao_uart;
         di_read_rdy  = di_read_rdy_uart;
         di_write_rdy = di_write_rdy_uart;
         di_transfer_status = di_read_mode ? di_transfer_status_uart : 0;
      end else begin
         di_UART_en   = 0;
         di_reg_datao = 0;
         di_read_rdy  = 1;
         di_write_rdy = 1;
         di_transfer_status = 16'hFFFE; // undefined terminal, return error code
      end
   end

   byter #(.DI_DATA_WIDTH(DI_DATA_WIDTH))
   byter
     (
      .resetb        (resetb 	    ),
      .ifclk 	     (ifclk 	    ),
      .enable        (di_term_UART_enable),
      .di0_len	     (di_len	    ),
      .di0_write_mode(di_write_mode),
      .di0_write     (di_write_uart	    ),
      .di0_reg_datai (di_reg_datai ),
      .di0_write_rdy (di_write_rdy_uart ),
      .di1_write     (uart_we	    ),
      .di1_reg_datai (tx_data),
      .di1_write_rdy (di_write_rdy_uart0 ),

      .di0_read_mode(di_read_mode),	   // input 			  
      .di0_read_req(di_read_req),   // input 			  
      .di0_read(di_read),	   // input 			  
      .di0_reg_datao(di_reg_datao_uart),  // output reg [DI_DATA_WIDTH-1:0] 
      .di0_read_rdy(di_read_rdy_uart),   // output 			  
      .di1_read_req(),   // output reg 			  
      .di1_read(di_read_uart),	   // output reg 			  
      .di1_reg_datao(rx_buffer_data[7:0]),  // input [7:0]
      .di1_read_rdy(rx_buffer_ready)   // input 			  
      );


   
endmodule
