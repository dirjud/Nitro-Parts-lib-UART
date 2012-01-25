include ../../lib/Makefiles/project.mk

uart.xml: terminals.py
	diconv terminals.py uart.xml
