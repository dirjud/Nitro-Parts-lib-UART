NITRO_PARTS_DIR ?= ../..

#INC_PATHS += $(NITRO_PARTS_DIR)/lib/imager/rtl \
#                    $(NITRO_PARTS_DIR)/Aptina/MT9M032/sim/ddr2 \
#                    $(NITRO_PARTS_DIR)/Aptina/MT9M032/lib/rtl/xilinx \

UART_DIR = $(NITRO_PARTS_DIR)/lib/uart

#MT9M032_INC_FILES = 

#SIM_FILES += \

SYN_FILES += \
	$(UART_DIR)/rtl/uart_tx.v \
	$(UART_DIR)/rtl/uart_rx.v \
	$(UART_DIR)/rtl/uart_duplex.v \
	$(UART_DIR)/rtl/uart_di.v \
	rtl_auto/UART_CTRLTerminal.v \
	$(NITRO_PARTS_DIR)/lib/HostInterface/rtl/byter.v \

