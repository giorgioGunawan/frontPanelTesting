# -*- coding: utf-8 -*-
"""
Created on Thu Jul 23 14:18:20 2020

@author: Giorgio
"""
"""

this program runs 
"""
import ok
import sys

#  import the okCFrontPanel class which contains a lot of functions
dev = ok.okCFrontPanel()

# check if the device is opened
if(dev.NoError != dev.OpenBySerial("")):
    print ("A device could not be opened.  Is one connected?")
    sys.exit()
    
# load PLL
dev.LoadDefaultPLLConfiguration()

# now for the first.bit thing what we do is just start the first.bit
dev.ConfigureFPGA("first.bit")


print(str(dev.IsFrontPanelEnabled()));

dev.SetWireInValue(0x00, 0x04)
dev.UpdateWireIns()








