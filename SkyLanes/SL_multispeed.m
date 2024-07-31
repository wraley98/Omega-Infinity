function possible = SL_multispeed(flights,t1,t2,path,speeds,hd,airways)
% SL_multispeed - strategic deconfliction of multiple speed UAS
% On input:
%     flights (flights struct): flights info
%     t1 (float): earliest launch time
%     t2 (float): latest launch time
%     path (1xn vector): list of path lane indexes
%     speeds (1xn vector): speeds of flight in lanes
%     hd (float): headway distance
%     airways (airways struct): airways info
% On output:
%     possible (float): first possible launch time
% Call:
%     possible = SL_multispeed(flights,t1,t2,path,speeds,hd,airways);
% Author:
%     T. Henderson
%     UU
%     Sumer 2024
%

LAUNCH_DT = 0.1;
TRAJ_DT = 0.1;

possible = [];

if isempty(flights)
    possible = t1;
    return
end

num_flights = length(flights);
len_path = length(path);
times = [t1:LAUNCH_DT:t2];
num_times = length(times);
lanes = airways.lanes;
lane_lengths = airways.lane_lengths;

for k = 1:num_times
    t = times(k);
    t_start = t;
    % create route
    for p = 1:len_path
        l_index = path(p);
        route(p,1:3) = lanes(l_index,1:3);
        route(p,4:6) = lanes(l_index,4:6);
        route(p,7) = t;
        t = t + lane_lengths(l_index)/speeds(p);
        route(p,8) = t;
        route(p,9) = speeds(p);
    end
    flight.route = route;
    flight.speeds = speeds;
    ftraj = SL_gen_traj(flight,TRAJ_DT);
    traj = ftraj.traj;
    c_pts = SL_closest_traj(flights,traj);
    if isempty(c_pts)|min(c_pts(:,end))>hd
        possible = t_start;
        return
    end
end
