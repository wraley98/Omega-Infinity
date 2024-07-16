
# python imports
import numpy as np
from matplotlib import pyplot as plt
import scipy.io

# realsense imports
import pyrealsense2 as rs

# matlab import
import matlab.engine

class Camera:
#CAMERA Class for the realsense camera used for tracking CF

    def __init__(self , numCF):
        #CAMERA Construct an instance of this class
        #   assign values for pipeline, pointcloud, and # of cf to
        #   track
       
        # initiates how many cfs will be tracked
        self.numCF = numCF

        # initiates realsense properties
        self.pipe = rs.pipeline()
        self.pointcloud = rs.pointcloud()
        self.activePipe = False

        # initiates ranges for search
        self.depthRange = 2
        self.widthRange = 1
        self.heigthRange = 1

        # assigns camera location
        self.cameraLocArr = [2.3 , 2.173 , 0.396]

        # load in yolo object
        #self.nn = scipy.io.loadmat('cfNN.mat')

        # initiates matlab engine
        self.eng = matlab.engine.start_matlab()
        self.tracker = self.eng.TrackCF()

    def startCamera(self):
        #STARTCAMERA starts camera tracking of enviroment
        self.pipe.start()
        self.activePipe = True

    def stopCamera(self):
        #STOPCAMERA ends camera tracking of enviroment
        self.pipe.stop()

    def addCF(self):
        #ADDCF increases the number of cf that are being tracked

        self.numCF = self.numCF + 1

    def removeCF(self):
        #REMOVECF decreases the number of cf that are being tracked

        self.numCF = self.numCF - 1

    def currNumCF(self):
        #CURRNUMCF gives the current number of cfs currently being
        #tracked

        numCF = self.numCF

        return numCF

    def translatePts(self , ptArr):
        #TRANSLATEPTS takes array of pts wrt to camera and translates
        # them into array of pts wrt to global reference frame
        # Pts must be in [x , y , z] structure

        # creates array to store global points
        globalPtArr = np.array([] , [] , [])

        # updates the local camera pts to global pts
        globalPtArr[: , 1] = ptArr[: , 1] - self.cameraLocArr[1]
        globalPtArr[: , 2] = ptArr[: , 2] - self.cameraLocArr[2]
        globalPtArr[: , 3] = ptArr[: , 3] - self.cameraLocArr[3]

    def locateCF(self):
        #LOCATECOLOR takes the cf color scheme and determines the
        #location in the current RGB frame

        [depth , clr , camInfo] = self.alignColorToDepth()

        bbox = self.eng.LocateCF(self.tracker , clr) 

        if len(bbox) == 0:
            return self.locateCF()

        [ depth , minRow , minCol ] = self.findMinDepth(depth , bbox)

        #dist = self.getDepthPoint(cfLoc , depth)
        cf3DPoint = self.convertTo3D([minCol, minRow], depth , camInfo)

        return cf3DPoint

    def findMinDepth(self , depth, bbox):

        maxCol = int(bbox[0][0] + bbox[0][2])
        maxRow = int(bbox[0][1] + bbox[0][3])

        minDepth = np.inf
        minRow = 0
        minCol = 0

        for ii in range(int(bbox[0][2]) , maxCol):
            for jj in range(int(bbox[0][1]) , maxRow):
                
                currDepth = depth.get_distance(ii , jj)

                if currDepth < minDepth and currDepth != 0:

                    minDepth = currDepth
                    minRow = jj
                    minCol = ii
        
        
        return [ minDepth , minRow , minCol ]

    def alignColorToDepth(self):

        align = rs.align(rs.stream.color)
        
        try:
            frames = self.pipe.wait_for_frames()
        except:
            self.stopCamera()
            self.startCamera()
            align = rs.align(rs.stream.color)
            frames = self.pipe.wait_for_frames()

        aligned_frames = align.process(frames)
        color_frame = aligned_frames.first(rs.stream.color)
        aligned_depth_frame = aligned_frames.get_depth_frame()

        alignedDepthProfile = aligned_depth_frame.get_profile()
        depthProfile = rs.video_stream_profile(alignedDepthProfile.as_video_stream_profile())
        camInfo = depthProfile.get_intrinsics()

        depthImage = aligned_depth_frame
        colorImage = np.asanyarray(color_frame.get_data())

        return [depthImage , colorImage , camInfo]
    
  

    def convertTo3D(self , cfLoc, depth ,camInfo):
        
       # profile = self.pipe.get_active_profile()
        #depthProfile = rs.video_stream_profile(profile.get_stream(rs.stream.depth))
        #camInfo = depthProfile.get_intrinsics()

        cf3DPoint = rs.rs2_deproject_pixel_to_point( camInfo, cfLoc, depth)

        return cf3DPoint

    def closeProgram(self):

        self.stopCamera()
        self.eng.quit()

    """
    def getDepth(self):
        #GETDEPTHCLOUD retrieves the current depth cloud frame of the
        #enviroment

        # perpares camera for capture frame
        frameSet = self.pipe.wait_for_frames()
        # retrieves current depth frame
        df = frameSet.get_depth_frame()
       
        depthImageArray = np.asanyarray(df.get_data())

        return depthImageArray
    
   
    def getRGBFrame(self):
        #GETRGBFRAME retrieves the current RGB frame of the enviroment
    
        if self.activePipe == False:
            self.startCamera

        # perpares camera for capture frame
        frameSet = self.pipe.wait_for_frames()
        # retrieves current RGB frame
        cf = frameSet.get_color_frame()
        # manipulates frame into usable RBG image
        colorImageArray = np.asanyarray(cf.get_data())
        #img = cv2.cvtColor(colorImageArray , cv2.COLOR_BGR2RGB)
  
        return colorImageArray


    def getCamInfo(self):
    #GETCAMINFO retrieves the camera information for converting
    #points from 2D to 3D

    profile = self.pipe.get_active_profile()
    depthProfile = rs.video_stream_profile(profile.get_stream(rs.stream.depth))
    camInfo = depthProfile.get_intrinsics()
    
    return profile

    def getDepthPoint(self , cfLoc , depthFrame):
    #GETDEPTHPOINT uses the cf location estimated by the nn and
    #the depth frames to estimate the current cf distance from the camera
    
    dist = depthFrame.get_distance(int(cfLoc[0][0]), int(cfLoc[0][1]))
    
    return dist
"""
    