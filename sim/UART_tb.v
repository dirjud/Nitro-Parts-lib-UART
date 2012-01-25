`timescale 1ps/1ps
`include "terminals_defs.v"

module UART_tb
  (
`ifdef verilator   
   input clk,
   input resetb
`endif   
   );

`ifndef verilator
   reg   clk;
   initial clk=0;
   always #10417 clk = !clk; // # 48MHz clock
`endif

   wire [15:0] fx2_fd;
   wire [1:0]  fx2_fifo_addr;
   wire [2:0]  fx2_flags;
   wire        fx2_ifclk, fx2_hics_b, fx2_sloe_b, fx2_slrd_b, fx2_slwr_b;
   wire        fx2_pktend_b, fx2_clkout, fx2_slcs_b, fx2_wakeup_b;

   wire [31:0] di_len, di_reg_addr;
   wire [15:0]  di_reg_datai, pt_di_reg_datao, di_term_addr, pt_di_transfer_status;
   reg [15:0]   di_reg_datao, di_transfer_status;
   reg          di_read_rdy,  di_write_rdy;
   wire di_read, di_read_mode, pt_di_read_rdy, di_read_req;
   wire di_write, di_write_mode, pt_di_write_rdy;
   wire resetb, scl, sda;                  

   fx2 fx2
     (
      .clk                                 (clk),
      .fx2_ifclk                           (fx2_ifclk),
      .fx2_clkout                          (fx2_clkout),
      .fx2_hics_b                          (fx2_hics_b),
      .fx2_sloe_b                          (fx2_sloe_b),
      .fx2_slrd_b                          (fx2_slrd_b),
      .fx2_slwr_b                          (fx2_slwr_b),
      .fx2_slcs_b                          (fx2_slcs_b),
      .fx2_pktend_b                        (fx2_pktend_b),
      .fx2_fifo_addr                       (fx2_fifo_addr),
      .fx2_fd                              (fx2_fd),
      .fx2_flags                           (fx2_flags),
      .SCL                                 (scl),
      .SDA                                 (sda)
      );

   pullup(scl);
   pullup(sda);
   
   HostInterface HostInterface
     (
      .ifclk                            (fx2_ifclk),
      .resetb                           (resetb),
      .fx2_hics_b                       (fx2_hics_b),
      .fx2_flags                        (fx2_flags),
      .di_read_rdy                      (di_read_rdy),
      .di_reg_datao                     (di_reg_datao),
      .di_write_rdy                     (di_write_rdy),
      .di_transfer_status               (di_transfer_status),
      .fx2_sloe_b                       (fx2_sloe_b),
      .fx2_slrd_b                       (fx2_slrd_b),
      .fx2_slwr_b                       (fx2_slwr_b),
      .fx2_slcs_b                       (fx2_slcs_b),
      .fx2_pktend_b                     (fx2_pktend_b),
      .fx2_fifo_addr                    (fx2_fifo_addr),
      .di_term_addr                     (di_term_addr),
      .di_reg_addr                      (di_reg_addr),
      .di_len                           (di_len),
      .di_read_mode                     (di_read_mode),
      .di_read_req                      (di_read_req),
      .di_read                          (di_read),
      .di_write                         (di_write),
      .di_write_mode                    (di_write_mode),
      .di_reg_datai                     (di_reg_datai),
      .fx2_fd                           (fx2_fd)
      );

   wire rxtx;
   wire di_UART_en;

   wire [15:0] ctrl_term_addr = `TERM_UART_CTRL;
   wire [15:0] uart_term_addr = `TERM_UART;
   uart_di
     uart_di
       (
	.resetb(resetb), 
	.ifclk(fx2_ifclk), 
	.di_term_addr(di_term_addr),       
	.di_reg_addr(di_reg_addr),	
	.di_read_mode(di_read_mode),	
	.di_read_req(di_read_req),	
	.di_read(di_read),		
	.di_write_mode(di_write_mode),	
	.di_write(di_write),		
	.di_reg_datai(di_reg_datai),	
	.di_read_rdy(di_read_rdy),	
	.di_reg_datao(di_reg_datao),	
	.di_write_rdy(di_write_rdy),	
	.di_transfer_status(di_transfer_status),	
	.di_UART_en(di_UART_en),

	.ctrl_term_addr(ctrl_term_addr),
	.uart_term_addr(uart_term_addr),
	
	.rx(rxtx),
	.tx(rxtx)
	);
   

endmodule
// Local Variables:
// verilog-library-flags:("-y ../rtl")
// End:

