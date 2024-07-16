classdef TrackCF < handle
    %TRACKCF Summary of this class goes here
    %   Detailed explanation goes here

    properties
        nn
        frameNum
    end

    methods

        function cfTracker = TrackCF()

            cfTracker.nn = load('cfNN.mat');
            cfTracker.frameNum = 1;

        end

        function bboxes = LocateCF(cfTracker , img)
            % FindCF - uses a neural net (nn) to determine the location of the cf in a
            % given image
            %
            % On input:
            %    img(MxNx3): rgb image
            %    nn: trained nn used for cf detection
            % On output:
            %    cfLoc[1x2]: approximate (X , Y) location of the cf
            % Call:
            %    [cfLoc] = FindCF(img , nn);
            % Author:
            %    William Raley
            %    UU
            %    Summer 2024
            %
            
           % clear img;

            % detects cf in image using nn
            [bboxes, scores, ~] = detect(cfTracker.nn.nn,img,...
                Threshold=0.05);

            save('bboxes.mat' , 'bboxes');
            
            if isempty(bboxes)
                cfLoc = [];
                return

            elseif height(bboxes) > 1

                maxScores = 0;
                maxBBox = bboxes(1 , :);

                for ii = 1:height(bboxes)

                    if scores(ii) > maxScores

                        maxScores = scores(ii);
                        maxBBox = bboxes(ii , :);

                    end
                end

                bboxes = maxBBox;
            end
         
            % center of box of approximate cf location
            cpX = bboxes(3) / 2 + bboxes(1);
            cpY = bboxes(4) / 2 + bboxes(2);

            % cf location (X , Y) in array to be returned
            cfLoc = [cpX , cpY];
            detectedImg = insertMarker(img , [cpX , cpY] , '*' , 'MarkerColor','green' ,'Size', 20);
            
            cd('DetectedImgs\');

            fileName = append(string(cfTracker.frameNum) , '.jpg');
            imwrite(detectedImg , fileName);
            cfTracker.frameNum = cfTracker.frameNum + 1;
            cd('..');
                 
        end
    end
end

