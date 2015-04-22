import VUART_tb as tb
import logging, numpy
logging.basicConfig(level=logging.DEBUG)

if 1:
    tb.init("sim.vcd")
else:
    tb.init()

dev = tb.get_dev()
d = {}
execfile("../terminals.py", d)
dev.set_di(d["di"])

dev.set("UART_CTRL", "clk_div", 16) # speed up clock

def check():
    a = (numpy.random.rand(16) * 255).astype(numpy.uint16)
    dev.write("UART", 0, a)
    b = numpy.zeros_like(a)
    dev.read("UART", 0, b)
    return (b==a).all()

def checkN(N):
    for i in range(N):
        if check():
            passing += 1
        else:
            failing += 1

#dev.set("UART", 0, 0x01)
dev.set("UART_CTRL", "parity_mode", 3)
#print "Pass count=", passing, "/", (passing + failing)
#dev.set("UART", 0, 0xaa)
#dev.set("UART", 0, 0x55)
#dev.set("UART", 0, 0xFE)

tx_bytes = [ 0x6b, 0x00, 0xDE, 0x07 ]

for x in tx_bytes:
    dev.set("UART", 0, x)

tb.adv(300)
rx_bytes = []

while dev.get("UART_CTRL", "rx_data_available") > 0:
    rx_bytes.append(dev.get("UART", 0))

for x,y in zip(tx_bytes, rx_bytes):
    print "%02x %02x" % (x,y)

print "PASS = ", rx_bytes == tx_bytes
        
    
#buf1 = "\xAA\x55" * 8
#dev.write("DRAM", 0, buf1)
#
#buf2 = "\x00" * len(buf1)
#dev.read("DRAM", 0, buf2)



tb.adv(100)
tb.end()
