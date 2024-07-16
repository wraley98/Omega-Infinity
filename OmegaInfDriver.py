# CF Imports
from cflib.utils import uri_helper
import Crazyflie

# Python Imports
import numpy as np
import threading
import time

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

        numCF = 1

        # Create radios
        self.numCF = numCF
        self.uriList = np.array([])

        for ii in range(numCF):
            
            uriName = 'radio://0/80/2M/E7E7E7E70' + '1'
            self.uriList = np.append(self.uriList , uriName)

        # Create camera object
        self.rsCam = Camera(numCF)
        
        # Run code
        self.run()

    def run(self):
        
        self.rsCam.startCamera()

        cfList = np.array([])

        for uri in self.uriList:
            
            cf = Crazyflie.CrazyFlie(uri , self.rsCam)
            cfList = np.append(cfList , cf)

        threads = []

        for cf in cfList:    
            thread = threading.Thread(target=cf.run , args=())
            threads.append(thread)
            thread.start()

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





        

            
