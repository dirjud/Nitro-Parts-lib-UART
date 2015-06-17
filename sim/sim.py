import VUART_tb as tb
import logging, numpy
logging.basicConfig(level=logging.DEBUG)
import sim_setup

if 0:
    tb.init("sim.vcd")
else:
    tb.init()

dev = sim_setup.get_dev()




def test():
    dev.set("UART_CTRL2", "clear_rx_buffer", 1)
    x = numpy.array([ 0x6b, 0x00, 0xde, 0x07 ], dtype=numpy.uint8)
    dev.write("UART", 0, x)
    y = numpy.zeros(len(x), dtype=numpy.uint8)
    dev.read("UART2", 0, y, 1)
    if not((x == y).all()):
        raise Exception("Mismatch TX="+str(x) + " RX="+str(y))
    
    dev.set("UART_CTRL2", "clear_rx_buffer", 1)
    x = 0x55
    dev.set("UART", 0, x)
    y = dev.get("UART2", 0, 1)
    if(x != y):
        raise Exception("Mismatch TX="+str(x) + " RX="+str(y))
    
    dev.set("UART_CTRL2", "clear_rx_buffer", 1)
    x = numpy.array([ 0x6b, 0x00, 0xde, 0x07, 0xAA ], dtype=numpy.uint8)
    dev.write("UART", 0, x)
    y = numpy.zeros(len(x), dtype=numpy.uint8)
    dev.read("UART2", 0, y, 1)
    if not((x == y).all()):
        raise Exception("Mismatch TX="+str(x) + " RX="+str(y))

    dev.set("UART_CTRL2", "clear_rx_buffer", 1)
    x = numpy.random.random_integers(0,255,15).astype(numpy.uint8)
    dev.write("UART", 0, x)
    y = numpy.zeros(len(x), dtype=numpy.uint8)
    dev.read("UART2", 0, y, 1)
    if not((x == y).all()):
        raise Exception("Mismatch TX="+str(x) + " RX="+str(y))

# Test for normal operation
dev.set("UART_CTRL",  "clk_div", 16) # speed up clock
dev.set("UART_CTRL2", "clk_div", 16) # speed up clock
for parity_mode in [0, 2, 3]:
    print "Normal Op Test, parity_mode=", parity_mode
    dev.set("UART_CTRL",  "parity_mode", parity_mode)
    dev.set("UART_CTRL2", "parity_mode", parity_mode)
    test()



# Test for parity mismatch
print "Parity Mismatch Tests"
dev.set("UART_CTRL",  "clk_div", 16) # speed up clock
dev.set("UART_CTRL2", "clk_div", 16) # speed up clock
for parity_error_mode in [2, 0, 1]:
    dev.set("UART_CTRL2", "parity_error_mode", parity_error_mode)
    for parity_mode1,parity_mode2 in [(2,3),(3,2)]:
        dev.set("UART_CTRL",  "parity_mode", parity_mode1)
        dev.set("UART_CTRL2", "parity_mode", parity_mode2)
        try:
            test()
            if parity_error_mode in [1,2]:
                raise Exception("Parity check didn't fail parity_error_mode=" + str(parity_error_mode))
        except Exception, e:
            if parity_error_mode == 1:
                if e.args[0] == -298 and e.args[2] == 0:
                    pass # timeout like it should
                else:
                    raise
            elif parity_error_mode == 2:
                if e.args[0] == -298 and e.args[2] == 4:
                    pass # non-zero ack status, which is correct behavior
                else:
                    raise
            else:
                raise
        

    
# Test for clock speed mismatch
for clk_div2 in [65, 62]:

    dev.set("UART_CTRL",  "clk_div", 64) # speed up clock
    dev.set("UART_CTRL2", "clk_div", clk_div2) # speed up clock
    for parity_mode in [0, 2, 3]:
        dev.set("UART_CTRL",  "parity_mode", parity_mode)
        dev.set("UART_CTRL2", "parity_mode", parity_mode)
        dev.set("UART_CTRL2", "parity_error_mode", 0)
    
        for i in range(100): # repeat test
            print "Clock Mismatch Stress test", i
            x = 9
            dev.set("UART_CTRL",  "clk_div", 60) # speed up clock
            tb.adv(numpy.random.randint(1000))
            dev.set("UART_CTRL",  "clk_div", 64) # speed up clock
            dev.set("UART", 0, x)
            y = dev.get("UART2", 0)
            if x != y:
                raise Exception("Mismatch " + str(x) + " " + str(y))


print "Everythin PASSED"


tb.adv(100)
tb.end()
