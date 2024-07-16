function [T , d] = PlotData()
% PlotData - Reads in data set for cf and camera, calculates the
% transformation matrix, transforms the camera frame to the cf frame, and
% finally plots the resultant data sets
% On input:
%
% On output:
%     T (4x4 array): linear regression transform matrix from set 1 to set 2
%     d ( nx1 array): differences between the transformed camera data
%     points and the cf data points
% Call:
%     [T , d] = PlotData();
% Author:
%     W.Raley & T. Henderson
%     UU
%     Summer 2024
%

telData = table2array(readtable('cfLocData.xlsx' ,'Sheet', ...
    'Telemetry Data'));
camData = table2array(readtable('cfLocData.xlsx' ,'Sheet', ...
    'Cam Data'));
transitData = table2array(readtable('cfLocData.xlsx' ,'Sheet', ...
    'Transit Data'));
transitionPts = table2array(readtable('cfLocData.xlsx' ,'Sheet', ...
    'Transition Points'));

camData = [camData(: , 1) , camData(: , 3) , -camData(: , 2)];

[numPts , ~] = size(telData);
transformMatrixFound = false;


while ~transformMatrixFound

    randIndex = randperm(numPts);
    randSelection = randIndex(1:20);

    transformTel = telData(randSelection , :);
    transformCam =  camData(randSelection , :);

%     T = CF_find_transform( transformTel, transformCam);
      T = CF_find_transform( transformCam, transformTel);

    if abs(T(1 , 4) - 2.25) < 0.2 && abs(T(2 , 4) - 2.0) < 0.2  ...
            && abs(T(3 , 4) - 0.5) < .1

        transformMatrixFound = true;

    end

end

% nn = load('transformNN.mat');
% transformedCamData = nn.net(camData');
% transformedCamData = transformedCamData';

% telData = ( T * [telData , ones(numPts , 1)]')';
camData = ( T * [camData , ones(numPts , 1)]')';

% determines distances for each point to the expected transit line

initPt = 1;
ptsIndex = 1;
camDistArr = zeros(numPts);
telDistArr = zeros(numPts);

for ii = 1:size(floor(transitData(: , 1)/2))

   lineArr = [transitData(ii , :); transitData(ii + 1 , :)];
   
    if ptsIndex > size(transitionPts(: , 1))

        for jj = transitionPts(7 , 2):size(camData(: , 1))

            camDistArr(jj)  = cv_dist_pt_line(camData(jj , 1:3) , lineArr);
            telDistArr(jj)  = cv_dist_pt_line(telData(jj, 1:3) , lineArr);

        end
        break
    end

   for jj = initPt:transitionPts(ptsIndex , 2)

        camDistArr(jj)  = cv_dist_pt_line(camData(jj , 1:3) , lineArr);
        telDistArr(jj)  = cv_dist_pt_line(telData(jj, 1:3) , lineArr);

   end
    
   initPt = ptsIndex + 1;
   ptsIndex = ptsIndex + 1;

end

% Plots transit line and points

figure(1)
hold on
xlabel 'x'
ylabel 'y'
zlabel 'z'


d = zeros(numPts , 1);

plot3(telData(: , 1) , telData(: , 2) ,telData(: , 3) ,'r.');
plot3(camData(: , 1) , camData(: , 2) , camData(: , 3) , 'b.');

for ii = 1:height(camData)

    d(ii) = norm(camData(ii,1:3) - telData(ii , 1:3));

%     errLine = line([telData(ii , 1) camData(ii , 1)] ...
%         , [telData(ii , 2) camData(ii , 2)] ...
%         , [telData(ii , 3) camData(ii , 3)] ...
%         , 'Color' , 'green');

end

plot3(transitData(: , 1) , transitData(: , 2) , transitData(: ,3), 'k');

legend('CF' , 'Camera' , 'Transit Line')

fprintf('Distance information from each point is as follows:\n\n')

varDist = var(d);
meanDist = mean(d);
maxDist = max(d);

fprintf('Mean Dist: %f\nMax Dist: %f\nVariance Dist: %f\n\n' , meanDist , ...
    maxDist , varDist)

fprintf('Distance information from the transit line is as follows:\n\n');
fprintf('Camera Points:\n')

camDistArr =  camDistArr(~isnan(camDistArr(: , 1)));

stdDist = std(camDistArr(: , 1));
meanDist = mean(camDistArr(: , 1));
maxDist = max(camDistArr(: , 1));

fprintf('Mean: %f\nMax: %f\nStd: %f\n\n' , meanDist ,maxDist , stdDist)

fprintf('CF Points:\n')

telDistArr =  telDistArr(~isnan(telDistArr(: , 1)));

stdDist = std(telDistArr(: , 1));
meanDist = mean(telDistArr(: , 1));
maxDist = max(telDistArr(: , 1));

fprintf('Mean: %f\nMax: %f\nStd: %f\n' , meanDist ,maxDist , stdDist)

end

