import VUART_tb as tb

def get_dev():
    dev = tb.get_dev()
    d = {}
    execfile("../terminals.py", d)
    
    di=d["di"]
    t = di["UART"].clone()
    t.addr = di["UART"].addr + 2
    t.name = "UART2"
    di.add_child(t)
    t = di["UART_CTRL"].clone()
    t.addr = di["UART_CTRL"].addr + 2
    t.name = "UART_CTRL2"
    di.add_child(t)
    
    dev.set_di(di)
    
    return dev
