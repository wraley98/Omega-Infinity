function SL_analyze_traj(airways)
% SL_analyze_traj - get closest lane and distance from it for each
%                   telemetry sample
% On input:
%     airways (airways struct): airways info
% On output:
%     N/A  save a file with info
%     M (k-1 x 4 array): traj measures
%       (:,1): distance from traj point to closest model point
%       (:,2): cosine of angle between traj & model directions
%       (:,3): lane change measure (number of bad lane changes)
%       (:,4): lane sequence
%       (:,5): stationary 
%       model1 (kd-tree struct): lane sample points and directions 
% Call:
%    SL_analyze_traj(airways);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

M2FT = 3.28;

f_tel = input('Enter name of UAS telemetry data file: ');
f_latlon = input('Is telemetry data lat/lon (1 yes; 0 no): ');
f_meas = input('Enter name of analysis file: ');
f_traj = load(f_tel);
roads = airways.roads;
if f_latlon==1
    lat0 = roads.lat_min;
    lon0 = roads.lon_min;
    crs = roads.crs;
    p_mercator_co = projcrs(crs);
    [x0,y0] = projfwd(p_mercator_co,lat0,lon0);
    cmd = input('Make best fit to Lane Network (0 no; 1 yes): ');
    [X1,Y1] = projfwd(p_mercator_co,f_traj(:,2),f_traj(:,3));
    X1 = X1 - X1(1);
    Y1 = Y1 - Y1(1);
    alt1 = M2FT*(f_traj(:,4) - roads.origin_alt);
    T1 = f_traj(:,1);
    traj = [T1,X1,Y1,alt1];
else
    cmd = input('Make best fit to Lane Network (0 no; 1 yes): ');
    traj1 = f_traj.traj;
    traj = traj1;
    traj(:,1) = traj1(:,4);
    traj(:,2) = traj1(:,1);
    traj(:,3) = traj1(:,2);
    traj(:,4) = traj1(:,3);
end
if cmd==0
    [M,model1] = SL_traj_analysis_driver(airways,traj);
else
    [B,M,model1,offx,offy] = SL_grid_fit(airways,traj,-10,10,-10,10,1,1);
end
save(f_meas,"M","model1");
figure(1);
clf
plot(M(:,1));
title('Distance to Closest Lane');
xlabel('Telemetry Sample Index');
ylabel('Distance to Closest Lane');
figure(2);
clf
plot(M(:,2));
title('Cosine of Heading vs Lane Angles');
xlabel('Telemetry Sample Index');
ylabel('Cosine of Heading vs. Lane Angle');
figure(3);
clf
plot(M(:,3));
title('Closest Lane Index');
xlabel('Telemetry Sample Index');
ylabel('Lane Index');
tch = 0;
