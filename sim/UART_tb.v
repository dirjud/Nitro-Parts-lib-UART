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

   wire [31:0] fx3_fd;
   wire [1:0]  fx3_fifo_addr;
   wire [2:0]  fx3_flags;
   wire        fx3_ifclk, fx3_hics_b, fx3_sloe_b, fx3_slrd_b, fx3_slwr_b;
   wire        fx3_pktend_b, fx3_clkout, fx3_slcs_b, fx3_wakeup_b;

   wire [31:0] di_len, di_reg_addr;
   wire [31:0] di_reg_datai, pt_di_reg_datao;
   wire [15:0] di_term_addr, pt_di_transfer_status;
   wire di_read, di_read_mode, pt_di_read_rdy, di_read_req;
   wire di_write, di_write_mode, pt_di_write_rdy;
   wire resetb, scl, sda;                  
   reg 	       di_read_rdy1, di_read_rdy2, di_read_rdy;
   reg [31:0]  di_reg_datao1, di_reg_datao2, di_reg_datao;
   reg 	       di_write_rdy1, di_write_rdy2, di_write_rdy;
   reg [15:0]  di_transfer_status1, di_transfer_status2, di_transfer_status;

   wire [31:0] 	fx3_fd_out, fx3_fd_in;
   wire 	fx3_fd_oe;
   assign fx3_fd    = (fx3_fd_oe) ? fx3_fd_out : 32'bZZZZ;
   assign fx3_fd_in = fx3_fd;
   wire 	fx3_dma_rdy_b;

   fx3 fx3
     (
      .clk(clk),
      .fx3_dma_rdy_b(fx3_dma_rdy_b),
      .fx3_ifclk (fx3_ifclk),
      .fx3_clkout (fx3_clkout),
      .fx3_hics_b (fx3_hics_b),
      .fx3_sloe_b (fx3_sloe_b),
      .fx3_slrd_b (fx3_slrd_b),
      .fx3_slwr_b (fx3_slwr_b),
      .fx3_pktend_b (fx3_pktend_b),
      .fx3_fifo_addr (fx3_fifo_addr),
      .fx3_fd (fx3_fd),
      
      .SCL (scl),
      .SDA (sda)
      );

   pullup(scl);
   pullup(sda);

   
   Fx3HostInterface Fx3HostInterface
     (
      .ifclk                            (fx3_ifclk),
      .resetb                           (resetb),
      .fx3_hics_b                       (fx3_hics_b),
      .fx3_dma_rdy_b(fx3_dma_rdy_b),
      .di_read_rdy                      (di_read_rdy),
      .di_reg_datao                     (di_reg_datao),
      .di_write_rdy                     (di_write_rdy),
      .di_transfer_status               (di_transfer_status),
      .fx3_sloe_b                       (fx3_sloe_b),
      .fx3_slrd_b                       (fx3_slrd_b),
      .fx3_slwr_b                       (fx3_slwr_b),
//      .fx3_slcs_b                       (fx3_slcs_b),
      .fx3_pktend_b                     (fx3_pktend_b),
      .fx3_fifo_addr                    (fx3_fifo_addr),
      .di_term_addr                     (di_term_addr),
      .di_reg_addr                      (di_reg_addr),
      .di_len                           (di_len),
      .di_read_mode                     (di_read_mode),
      .di_read_req                      (di_read_req),
      .di_read                          (di_read),
      .di_write                         (di_write),
      .di_write_mode                    (di_write_mode),
      .di_reg_datai                     (di_reg_datai),
      .fx3_fd_out                           (fx3_fd_out),
      .fx3_fd_oe                           (fx3_fd_oe),
      .fx3_fd_in                           (fx3_fd_in)
      );

   wire rxtx0, rxtx1;
   wire di_UART1_en, di_UART2_en;

   wire [15:0] ctrl_term_addr1 = `TERM_UART_CTRL;
   wire [15:0] uart_term_addr1 = `TERM_UART;
   uart_di #(.DI_DATA_WIDTH(32))
     uart_di1
       (
	.resetb(resetb), 
	.ifclk(fx3_ifclk), 
	.di_term_addr(di_term_addr),       
	.di_reg_addr(di_reg_addr),
	.di_len(di_len),
	.di_read_mode(di_read_mode),	
	.di_read_req(di_read_req),	
	.di_read(di_read),		
	.di_write_mode(di_write_mode),	
	.di_write(di_write),		
	.di_reg_datai(di_reg_datai),	
	.di_read_rdy(di_read_rdy1),	
	.di_reg_datao(di_reg_datao1),	
	.di_write_rdy(di_write_rdy1),	
	.di_transfer_status(di_transfer_status1),
	.di_UART_en(di_UART1_en),

	.ctrl_term_addr(ctrl_term_addr1),
	.uart_term_addr(uart_term_addr1),
	
	.rx(rxtx0),
	.tx(rxtx1)
	);

   uart_di #(.DI_DATA_WIDTH(32))
     uart_di2
       (
	.resetb(resetb), 
	.ifclk(fx3_ifclk), 
	.di_term_addr(di_term_addr-2),       
	.di_reg_addr(di_reg_addr),	
	.di_len(di_len),
	.di_read_mode(di_read_mode),	
	.di_read_req(di_read_req),	
	.di_read(di_read),		
	.di_write_mode(di_write_mode),	
	.di_write(di_write),		
	.di_reg_datai(di_reg_datai),	
	.di_read_rdy(di_read_rdy2),	
	.di_reg_datao(di_reg_datao2),	
	.di_write_rdy(di_write_rdy2),	
	.di_transfer_status(di_transfer_status2),	
	.di_UART_en(di_UART2_en),

	.ctrl_term_addr(ctrl_term_addr1),
	.uart_term_addr(uart_term_addr1),
	
	.rx(rxtx1),
	.tx(rxtx0)
	);
   
   always @(*) begin
      if(di_UART1_en) begin
	 di_read_rdy        = di_read_rdy1;
	 di_reg_datao       = di_reg_datao1;
	 di_write_rdy       = di_write_rdy1;
	 di_transfer_status = di_transfer_status1;
      end else if(di_UART2_en) begin
	 di_read_rdy        = di_read_rdy2;
	 di_reg_datao       = di_reg_datao2;
	 di_write_rdy       = di_write_rdy2;
	 di_transfer_status = di_transfer_status2;
      end else begin
	 di_read_rdy        = 1;
	 di_reg_datao       = 0;
	 di_write_rdy       = 1;
	 di_transfer_status = 16'hAAAA;
      end
   end
   
endmodule
// Local Variables:
// verilog-library-flags:("-y ../rtl")
// End:

