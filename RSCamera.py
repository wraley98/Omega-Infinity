
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

    def locateCF(self , cfNum , telData):
        #LOCATECOLOR takes the cf color scheme and determines the
        #location in the current RGB frame

        [depth , clr , camInfo] = self.alignColorToDepth()

        bbox = self.eng.LocateCF(self.tracker,  clr, int(cfNum)) 
        
        if len(bbox) == 0:
            return self.locateCF(cfNum , telData)

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

