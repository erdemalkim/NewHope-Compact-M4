#!/usr/bin/env python3
import serial
import sys
import os

dev = serial.Serial("/dev/ttyUSB0", 115200)

command = "st-flash --reset write " + str(sys.argv[1]) + " 0x8000000" + ">/dev/null 2>&1";
os.system(command)

while True:
    x = dev.read()
    try:
        if x.decode('utf-8')=='#':
            print("\n")
            break
        print (x.decode('utf-8'),end="")
    except:
        pass
sys.stdout.flush()
