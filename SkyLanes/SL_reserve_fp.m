function [flight_plan,reservations] = SL_reserve_fp(reservations,...
    airways,t1,t2,speeds,path,hd,flight_id,flights)
% SL_reserve_fp - find flight plan, if possible
% On input:
%     reservations (reservations struct): flight reservation info
%       (k).flights (n_k x 4 array)  [flight_id t_in t_out speed]
%     airways (airway struct): airway info
%     t1 (float): initial possible launch time
%     t2 (float): final possible launch time
%     speeds (1xk vector): speed in each lane
%     path (kx1 vector): lane indexes
%     hd (float): headway distance
%     flight_id (int): UAS identifier
% On output:
%     flight_plan (nx5 array): flight plan
%       (i,:): [ti1, ti2, speed, lane_i, headway]
%     reservations (reservations struct): updated reservation info
% Call:
%     [fp,reservations] = SL_reserve_fp(reservations,airways1,0,10,...
%                         speeds,p,5,flight_id);
% Author:
%     T. Henderson
%     UU
%     Fall 2020/ modified Spring 2024
%

flight_plan = [];
reservations_out = reservations;

lanes = airways.lanes;
len_path = length(path);
lane_lengths = airways.lane_lengths;

possible = SL_multispeed(flights,t1,t2,path,speeds,hd,airways);

if isempty(possible)
    return
end

t_start = possible(1);

flight_plan = zeros(len_path,6); % t_in, t_out, speed, lane, hd, ht
t1 = t_start;
theta = airways.smallest_angle;
hda = hd/sin(theta);
for c = 1:len_path
    speed = speeds(c);
    flight_plan(c,1) = t1;
    t2 = t1 + lane_lengths(path(c))/speed;
    flight_plan(c,2) = t2;
    flight_plan(c,3) = speed;
    flight_plan(c,4) = path(c);
    flight_plan(c,5) = hda;
    flight_plan(c,6) = hda/speed;
    t1 = t2;
end

for c = 1:len_path
    reservations(path(c)).flights = [reservations(path(c)).flights;...
        -1,flight_plan(c,:)];
    flights = reservations(path(c)).flights;
    [vals,indexes] = sort(flights(:,2));
    flights = flights(indexes,:);
    reservations(path(c)).flights = flights;
end

tch = 0;
