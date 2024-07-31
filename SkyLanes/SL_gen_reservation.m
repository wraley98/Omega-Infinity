function [reservations_out,new_flight] = SL_gen_reservation(airways,...
    flights,reservations,request)
% SL_gen_reservation - generate new lane reservations
% On input:
%     airways (airways struct): airways info
%     flights (flight struct): flights info
%     reservations (reservations struct): lane reservations
%     request (request struct): request info
%       .flight_id (int): UAS id number
%       .flight_slot (int): index in flights (unknown until assigned)
%       .request_time (float): time request arrives
%       .launch_index (int): launch lane index
%       .land_index (int): land lane index
%       .launch_interval (1x2 vector): [min start, max start]
%       .speeds (1xn vector): desired speed in each lane
%       .path (1xn vector): lane sequence
%       .path_vertexes (1x(n+1) vector): lane vertexes
%       .headway (float): safe minimum distance from other UAS
% On output:
%     reservations_out (reservations struct): updated lane reservations
%     new_flight (flight struct): new flight plan
% Call:
%     [r1,f1] = SL_gen_reservations(airways,flights,reservations,req);
% Author:
%     T. Henderson
%     UU
%     Fall 2020/ modified Spring 2024
%

FAILED = 0;
PLANNED = 1;

reservations_out = reservations;

hd = request.headway;
path = request.path;

num_flights_plus1 = length(flights) + 1;
t1 = request.launch_interval(1);
t2 = request.launch_interval(2);
flight_id = request.flight_id
speeds = request.speeds;
tic
[fp,reservations_out] = SL_reserve_fp(reservations,airways,t1,...
    t2,speeds,path,hd,flight_id,flights);
dct = toc;
if ~isempty(fp)
    num_steps = length(fp(:,4));
    for s = 1:num_steps
        index = find(reservations_out(fp(s,4)).flights(:,1)==-1);
        reservations_out(fp(s,4)).flights(index,1) = num_flights_plus1;
    end
    new_flight(1).type = PLANNED;
    new_flight(1).decon_time = dct;
    new_flight(1).plan = fp;
    new_flight(1).route = SL_plan2route(fp,airways);
    lane_index = fp(1,4);
    lane_vertex1 = airways.lane_edges(lane_index,1);
    pt1 = airways.lane_vertexes(lane_vertex1,:);
    lane_vertex2 = airways.lane_edges(lane_index,2);
    pt2 = airways.lane_vertexes(lane_vertex2,:);
    dir1 = pt2 - pt1;
    dir1 = dir1/norm(dir1);
    new_flight(1).telemetry = [pt1 dir1 fp(1,3)];
else
    new_flight(1).type = FAILED;
    new_flight(1).decon_time = dct;
    new_flight(1).plan = [];
    new_flight(1).route = [];
    new_flight(1).telemetry = [];
end

tch = 0;
