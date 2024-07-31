function [cT , d] = PlotData()
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

%% loads in data

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

%% Determines transformation matrix

% SVD Method
% T = SVDTransformation(telData' , camData');
% T = SVDTransformation(camData' , telData');

% [tT1,tT2,tT3] = CF_find_transform_SVD(telData,camData);
[cT1,cT2,cT3] = CF_find_transform_SVD(camData , telData);

% tT = tT3 * tT2 * tT1;
cT = cT3 * cT2 * cT1;

% Linear Regression Method
% transformMatrixFound = false;

% while ~transformMatrixFound
% 
%     randIndex = randperm(numPts);
%     randSelection = randIndex(1:10);
% 
%     transformTel = telData(randSelection , :);
%     transformCam =  camData(randSelection , :);
% 
%     % T = CF_find_transform( transformTel, transformCam);
%     T = CF_find_transform( transformCam, transformTel);
% 
%     if abs(T(1 , 4) - 2.25) < 0.2 && abs(T(2 , 4) - 2.0) < 0.2  ...
%             && abs(T(3 , 4) - 0.5) < .1
% 
%         transformMatrixFound = true;
% 
%     end
% 
% end

% Neural Net Method
% nn = load('transformNN.mat');
% transformedCamData = nn.net(camData');
% transformedCamData = transformedCamData';

%telDataTransformed = ( tT * [telData , ones(numPts , 1)]')';
camDataTransformed = ( cT * [camData , ones(numPts , 1)]')';

%% determines distances for each point to the expected transit line

initPt = 1;
ptsIndex = 1;
camDistArr = zeros(numPts , 1);
telDistArr = zeros(numPts , 1);

for ii = 1:floor(length(transitData(: , 1))/2) + 1

    if ptsIndex > size(transitionPts(: , 1))

        for jj = transitionPts(end , 1):size(camDataTransformed(: , 1))

            camDistArr(jj) = cv_dist_pt_line( ...
                camDataTransformed(jj , 1:3), lineArr);
            telDistArr(jj)  = cv_dist_pt_line(telData(jj, 1:3) , lineArr);

        end
        break
    end

    lineArr = [transitData(ii , :); transitData(ii + 1 , :)];

    for jj = initPt:transitionPts(ptsIndex , 1) / 3

        camDistArr(jj)  = cv_dist_pt_line(camDataTransformed(jj , 1:3) ...
            , lineArr);
        telDistArr(jj)  = cv_dist_pt_line(telData(jj, 1:3) , lineArr);

    end

    initPt = initPt + 1;
    ptsIndex = ptsIndex + 1;

end

d = zeros(numPts , 1);

for ii = 1:height(camDataTransformed)

    d(ii) = norm(camDataTransformed(ii,1:3) - telData(ii , 1:3));

end

%% Prints Data

fprintf('\nDistance information from each point is as follows:\n\n')

varDist = var(d);
meanDist = mean(d);
maxDist = max(d);

fprintf('Mean Dist: %f\nMax Dist: %f\nVariance Dist: %f\n\n' , meanDist,...
    maxDist , varDist)

fprintf('Distance information from the transit line is as follows:\n\n');
fprintf('Camera Points:\n')

camDistArr =  camDistArr(~isnan(camDistArr(: , 1)));
telDistArr =  telDistArr(~isnan(telDistArr(: , 1)));

camStdDist = std(camDistArr(: , 1));
meanDist = mean(camDistArr(: , 1));
maxDist = max(camDistArr(: , 1));

fprintf('Mean: %f\nMax: %f\nStd: %f\n\n' , meanDist ,maxDist , camStdDist)

fprintf('CF Points:\n')

telStdDist = std(telDistArr(: , 1));
meanDist = mean(telDistArr(: , 1));
maxDist = max(telDistArr(: , 1));

fprintf('Mean: %f\nMax: %f\nStd: %f\n' , meanDist ,maxDist , telStdDist)

%% Plots transit line and points

figure(3)
hold on
axis equal
xlabel 'x'
ylabel 'y'
zlabel 'z'

plot3(telData(: , 1) , telData(: , 2) , telData(: , 3) ,'r.');
plot3(camDataTransformed(: , 1) , camDataTransformed(: , 2) , ...
    camDataTransformed(: , 3) , 'b.');
plot3(transitData(: , 1) , transitData(: , 2) , transitData(: ,3), 'k');



% creates and plots approx. transit lanes

% if camStdDist > telStdDist
% 
%     r = camStdDist * 3;
% 
% else
% 
%     r = telStdDist * 3;
% 
% end

r = telStdDist * 3;

% t = linspace(0 , 2 * pi , 100);

% for ii = 1:3
% 
%     if ii == 2
% 
%         [ii , ~] = size(transitData);
%         ii = ceil(ii / 2);
% 
%         x = 0 * t + transitData(1,1);
%         y = sin(t) * r + transitData(ii,2);
%         z = cos(t) * r + transitData(ii,3);
% 
%         for jj = 1:75
%             inc = jj * .01;
%            % plot3(x + inc,y,z , 'y')
%         end
% 
%         continue
% 
%     elseif ii == 3
% 
%         x = cos(t) * r + transitData(end,1);
%         y = sin(t) * r + transitData(end,2);
%         z = 0 * t + transitData(end,3);
% 
%         for jj = 1:50
%             inc = jj * .01;
%             % plot3(x,y,z + inc , 'y')
%         end
% 
%         continue
%     end
% 
%     x = cos(t) * r + transitData(ii,1);
%     y = sin(t) * r + transitData(ii,2);
%     z = 0 * t + transitData(ii,3);
% 
% 
%     for jj = 1:50
%         inc = jj * .01;
%         % plot3(x,y,z + inc , 'y')
%     end
% end

fprintf('\nThe radius of a transit lane must be %f\n' , r);
fprintf('\nAll values in meters(m)\n')
legend('CF' , 'Camera' , 'Transit Line')

%PlotOnPicture(telDataTransformed);

end

