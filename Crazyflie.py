# Crazyflie Import
import cflib.crtp
from cflib.utils import uri_helper
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
from cflib.positioning.position_hl_commander import PositionHlCommander
from cflib.crazyflie.log import LogConfig

# Python Import
import time
import numpy as np
from openpyxl import Workbook
from openpyxl import load_workbook

class CrazyFlie:
    """
    CrazyFlie: Creates, flies, and tracks the crazyflie (cf). When flight is complete, creates a log to  
    store transit data.
    On input:
        uriName (int): radio number
        cam (object): camera object for third person tracking
    On output:
        N/A
        *CFLocData (.xlsx file): file with transit data, both camera and telemitry data.
    Call:
       Crazyflie.CrazyFlie(uri , rsCam)
    Author:   
        W.Raley    
        UU
        Summer 2024
    """
    def __init__ (self , uriName , cam):
        # Storage for location data
        self.telReportedLoc = []
        self.camReportedLoc = []
        self.transitData = []
        self.transitionPts = []

        self.position_estimate = [0 , 0 , 0]

        # radio information
        self.uri = uri_helper.uri_from_env(default= uriName)

        # Camera information
        self.cam = cam

        # Current state of cf
        self.state = True

    def createLog(self):
            # prepares log data
            logconf = LogConfig(name = 'Position', period_in_ms=10)
        
            logconf.add_variable('kalman.stateX' , 'float')
            logconf.add_variable('kalman.stateY' , 'float')
            logconf.add_variable('kalman.stateZ' , 'float')
       
            self.scf.cf.log.add_config(logconf)
            # prints position data
            logconf.data_received_cb.add_callback(self.log_pos_callback)

            return logconf

    # Sets the current position
    def setPos(self , logConf):
        # Starts the log
        logConf.start()
        time.sleep(0.1)
        logConf.stop()
        logConf.delete()
        
        return self.createLog()
    
    def cfState(self):

        return self.state

    def updateLoc(self):
    
        camReported = self.cam.locateCF()
    
        if camReported[0] == 0 or camReported[1] == 0 or camReported[2] == 0 or abs(camReported[0]) > 3:
            while camReported[0] == 0 or camReported[1] == 0 or camReported[2] == 0 or abs(camReported[0]) > 5:
                 camReported = self.cam.locateCF()

        self.camReportedLoc = np.append(self.camReportedLoc , [camReported[0] , camReported[2] ,camReported[1]])
        self.telReportedLoc = np.append(self.telReportedLoc , self.position_estimate)

    def fly(self):

        with PositionHlCommander(self.scf) as pc:
            
            # Sets Position
            pc._x = self.position_estimate[0]
            pc._y = self.position_estimate[1]
            pc._z = self.position_estimate[2]

            # Sets flying status to off
            pc._is_flying = False

            self.logConf.start()

            # Take Off
            self.transitData = np.append(self.transitData , [pc._x , pc._y , pc._z])
            pc.take_off(height=0.5 , velocity = 0.05)
            #pc.go_to(pc._x , pc._y , 0.5)
            
            initX = self.position_estimate[0]
            initY = self.position_estimate[1]
            initZ = self.position_estimate[2]

            time.sleep(3)

            # move
            self.transitionPts = np.append(self.transitionPts , len(self.camReportedLoc))
            [currX , currY , currZ ] = self.directTransit([0 , 0 , 0.1], [initX, initY , initZ], pc)
            [currX , currY , currZ ] = self.directTransit([0.4 , 0 , 0], [currX , currY , currZ], pc)
            [currX , currY , currZ ] = self.directTransit([0 , -0.125 , 0], [currX , currY , currZ], pc)
            [currX , currY , currZ ] = self.directTransit([0.35 , 0.25 , 0], [currX , currY , currZ], pc)
            [currX , currY , currZ ] = self.directTransit([0 , -0.125 , 0], [currX , currY , currZ], pc)
            [currX , currY , currZ ] = self.directTransit([0 , 0 , -0.05], [currX , currY , currZ], pc)

            # landing sequence
            self.transitData = np.append(self.transitData , [pc._x , pc._y  , 0.35])
            pc.go_to(pc._x , pc._y  , 0.35 , velocity = 0.05)
            time.sleep(3)
            
            pc._is_flying = True
            pc.land(velocity = 0.1)
            self.logConf.stop()
            self.state = False

    def directTransit(self , goToArr, currLoc, pc):

        xUpdate = currLoc[0] + goToArr[0]
        yUpdate = currLoc[1] + goToArr[1]
        zUpdate = currLoc[2] + goToArr[2]

        self.transitData = np.append(self.transitData , [ xUpdate , yUpdate , zUpdate])
        pc.go_to(xUpdate, yUpdate, zUpdate, velocity = 0.05)
        time.sleep(3)
        
        self.transitionPts = np.append(self.transitionPts , len(self.camReportedLoc))

        return [xUpdate , yUpdate , zUpdate]



    # Sets location to current estimate
    def log_pos_callback(self , timestamp, data, logconf):
        
        #print(data)
    
        self.position_estimate[0] = data['kalman.stateX']
        self.position_estimate[1] = data['kalman.stateY']
        self.position_estimate[2] = data['kalman.stateZ']

    # Records data to spreadsheet
    def recordData(self):
        
        filename = 'CFLocData.xlsx'
        self.createWB(filename)
        doc = load_workbook(filename)
        
        sheet = doc.active
    
        for i in range(int(len(self.telReportedLoc) / 3)) :
            ii = i * 3
            line = [self.telReportedLoc[ii] , self.telReportedLoc[ii - 2] , self.telReportedLoc[ii - 1]]
            sheet.append(line)

        doc.save(filename)
        
        sheet = doc.create_sheet("Cam Data")

        for i in range(int(len(self.camReportedLoc) / 3)) :
            ii = i * 3
            line = [self.camReportedLoc[ii] , self.camReportedLoc[ii - 1] , self.camReportedLoc[ii - 2]]
            sheet.append(line)
        

        doc.save(filename)

        sheet = doc.create_sheet("Transit Data")

        for i in range(int(len(self.transitData) / 3)) :
            ii = i * 3
            line = [self.transitData[ii] , self.transitData[ii - 2] , self.transitData[ii - 1]]
            sheet.append(line)

        doc.save(filename)

        sheet = doc.create_sheet("Transition Points")

        for i in range(len(self.transitionPts)):
            line = [self.transitionPts[i]]
            sheet.append(line)

        doc.save(filename)
    
    # Creates spreadsheet to record data
    def createWB(self, fileName):
        wb = Workbook()
        wb.create_sheet("Telemetry Data")
        del wb['Sheet']
        wb.save(fileName)
        self.wb = wb

    def run(self):

        cflib.crtp.init_drivers()

        with SyncCrazyflie(self.uri , cf=Crazyflie(rw_cache='./cache')) as scf:
           
            # save scf for access throughout class
            self.scf = scf
           
            # Creates log and sets initial estimate on postion
            logConf = self.createLog()
            self.logConf = self.setPos(logConf) 
    
            self.fly()

        self.recordData()