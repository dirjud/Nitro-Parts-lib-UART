import nitro, os
from nitro import DeviceInterface, Terminal, Register, SubReg

di = DeviceInterface(
    name="UART",
    comment="""These are the terminals control a serial/UART interface""",
    terminal_list = [
        Terminal(
            name="UART",
            regAddrWidth=8,
            regDataWidth=8,
            comment="UART Raw Data Interface",
            register_list = [
                Register(
                    name = "data",
                    width=8,
                    type="int", 
                    mode="write",
                    init=0, 
                    comment="Read and write data from UART using this register",
                    ),
                ],
            ),
        Terminal(
            name="UART_CTRL",
            regAddrWidth=8,
            regDataWidth=16,
            comment="UART Control Interface",
            register_list = [
                Register(
                    name = "clk_div",
                    width=16,
                    type="int", 
                    mode="write",
                    init=417, 
                    comment="Controls the BAUD rate.",
                    ),
                Register(
                    name = "parity_mode",
                    width=2,
                    type="int", 
                    mode="write",
                    init=0, 
                    comment="0=none, 2=even, 3=odd",
                    ),
                Register(
                    name = "rx_data_available",
                    width = 16,
                    type = "int",
                    mode="read",
                    comment = "Returns the number of bytes available for read from RX signal",
                    ),
                Register(
                    name = "clear_rx_buffer",
                    width = 1,
                    type = "trigger",
                    mode="write",
                    comment = "Triggers a clearing of the RX receive buffer",
                    ),
                Register(
                    name = "parity_error_mode",
                    width=2,
                    type="int", 
                    mode="write",
                    init=1, 
                    comment="0=ignore, 1=silently drop, 2=transmit status error",
                    ),
                ],
            ),
        ],
    )
