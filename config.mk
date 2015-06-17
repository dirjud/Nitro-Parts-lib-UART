NITRO_PARTS_DIR = ../..

# INC_PATHS specifies a space separated list of paths to the files
# that are `included in any of the verilog source files.  See also
# the SIM_LIBS variable.
INC_PATHS = rtl_auto \


# INC_FILES specifies a list of files that are included in the verilog
# and are thus dependancies of the simulation.  It is not strictly
# necessary to list all of them here, but you can list any here
# that you want to use trigger a verilator rebuild or that need
# auto generated themselves.
INC_FILES = rtl_auto/UART_CTRLTerminalInst.v     \
	    config.mk \

# SIM_FILES is a list of simulation files that are common to all
# simulations.  Use the VERILATOR_FILES, IVERILOG_FILES, etc.
# variables to specify simulator specific files
SIM_FILES = \
	sim/UART_tb.v \
	$(NITRO_PARTS_DIR)/lib/HostInterface/models/fx3.v \
	$(NITRO_PARTS_DIR)/lib/HostInterface/rtl/Fx3HostInterface.v \

#	$(NITRO_PARTS_DIR)/Aptina/MT9M032/sim/UXN1230DaughterBoard.v \

SIM_TOP_MODULE=UART_tb


# VERILATOR specific options
#VERILATOR_ARGS=-Wno-UNOPTFLAT
VERILATOR_ARGS=
VERILATOR_FILES=

# ISE_SIM specific options
ISE_SIM_ARGS = isim_tests -L unisims_ver -L secureip
ISE_SIM_FILES = sim/isim_tests.v

# SIM_DEFS specifies and `defines you want to set from the command
# line
SIM_DEFS= x512Mb sg25 x16
#SIM_DEFS+= TRACE
SIM_DEFS = USER_DATA_WIDTH=4

# SIM_LIBS specifies the directories for any verilog libraries whose
# files you want to auto include.  This should not be confused with
# the INC_PATHS variable.  SIM_LIBS paths are searched for modules
# that are not excility listed in the SIM_FILES or SYN_FILES list
# whereas INC_PATHS are searched for files that are `included in the
# verilog itself.
SIM_LIBS= 

# SYN_FILES lists the files that will be synthesized
SYN_FILES = \

VERILATOR_CPP_FILE=../sim/tb.cpp

# CUSTOM targets should go here

# DI_FILE is used by the di.mk file
DI_FILE = terminals.py
# include di.mk to auto build the di files
include ../../../lib/Makefiles/di.mk

#UCF_FILES += $(NITRO_PARTS_DIR)/BrooksEE/BR9M032/xilinx/BR9M032.ucf

include ../UART.mk
