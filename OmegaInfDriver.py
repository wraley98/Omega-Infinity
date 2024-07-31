# CF Imports
from cflib.utils import uri_helper
import Crazyflie

# Python Imports
import numpy as np
import threading
import time
import pandas as pd

# Camera imports
from RSCamera import Camera

class OmegaInfDriver:
    """
    OmegaInfDriver: Driving class for running the crazyflie and camera code together. 
    On input:
        N/A
    On output:
        N/A
    Call:
        python3 .\OmegaInfDriver.py 
    Author:   
        W.Raley    
        UU
        Summer 2024
    """
    def __init__(self):
        
        self.cfInstruct = pd.read_excel('crazyflieRunInstruct.xlsx').values

        # Create radios
        self.numCF =  self.cfInstruct[-1 , 0]
        self.uriList = np.array([])

        for ii in range(int(self.numCF)):

            uri = str(ii + 1)
            self.uriList = np.append(self.uriList , uri)

        # Create camera object
        self.rsCam = Camera(self.numCF)
        
        # Run code
        self.run()

    def run(self):
        
        self.rsCam.startCamera()

        cfList = np.array([])

        startIndex = 0
        endIndex = 0

        for uriNum in self.uriList:
            
            while self.cfInstruct[endIndex , 0] != 99:

                endIndex += 1

            inst = self.cfInstruct[startIndex:endIndex , 0:9]

            endIndex += 1
            startIndex = endIndex 
            
            cf = Crazyflie.CrazyFlie(uriNum , self.rsCam , inst)
            cfList = np.append(cfList , cf)

        threads = []

        timeIndex = 0

        for cf in cfList:    
            thread = threading.Thread(target=cf.run , args=())
            threads.append(thread)
            thread.start()

            time.sleep(self.cfInstruct[timeIndex ,7])
            timeIndex += 8

        numCFFlying = self.numCF
        cfIsFlying = True

        while cfIsFlying:
            for cf in cfList:
                if cf.cfState():
                    cf.updateLoc()
                else:
                    numCFFlying -= 1
            if numCFFlying == 0:
                cfIsFlying = False

        for thread in threads:
            thread.join()

        self.rsCam.closeProgram()


OID = OmegaInfDriver()





        

            
