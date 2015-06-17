module uart_duplex
  #(parameter CLK_DIV_WIDTH=8
    )
   (
    input 		      clk,
    input 		      resetb,
    input [CLK_DIV_WIDTH-1:0] clk_div,
    input [1:0] 	      parity_mode,
    input [1:0]		      parity_error_mode,
    
    input 		      rx,
    output 		      re,
    output 		      rx_error,
    output [7:0] 	      rx_data,
    output 		      rx_busy,

    output 		      tx,
    input [7:0] 	      tx_data,
    input 		      we,
    output 		      tx_busy,
    output 		      tx_done
    );

   uart_tx #(.CLK_DIV_WIDTH(CLK_DIV_WIDTH))
   uart_tx
     (
      .clk(clk),
      .resetb(resetb),
      .clk_div(clk_div),
      .tx(tx),
      .datai(tx_data),
      .parity_mode(parity_mode),
      .we(we),
      .busy(tx_busy),
      .done(tx_done)
      );

   uart_rx #(.CLK_DIV_WIDTH(CLK_DIV_WIDTH))
   uart_rx
     (
      .clk(clk),
      .resetb(resetb),
      .clk_div(clk_div),
      .rx(rx),
      .parity_mode(parity_mode),
      .parity_error_mode(parity_error_mode),
      .re(re),
      .error(rx_error),
      .datao(rx_data),
      .busy(rx_busy)
      );
endmodule
