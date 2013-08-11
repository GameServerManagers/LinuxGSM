#!/usr/bin/python
# serverquery.py part of 
# Server Management Script
#
# Website: http://danielgibbs.co.uk
# Version: 010813

import errno
import sys
import socket
import re

if __name__ == "__main__":
   sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
   sock.settimeout(0.5)

   ip = sys.argv[1]
   port = sys.argv[2]
   try:
     sock.connect((ip, int(port)))
   except socket.error:
     sys.exit("ERROR 1")

   sock.send("\xFF\xFF\xFF\xFFTSource Engine Query\0")
   data = ""
   try:
     data = sock.recv(1024)
   except socket.error:
     sys.exit("ERROR 2")

   sock.close()

   if(len(data) > 10):
     sys.exit("OK")
sys.exit("ERROR 3")