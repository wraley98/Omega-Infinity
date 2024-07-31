function [reservations,flights] = SL_request2reservation(airways,...
    request,reservations,flights_in)
% SL_request2reservation - reserve lanes for a flight, if possible
% On input:
%     airways (airways struct): airways info
%     request (request struct): request info
%     reservations (reservations struct): reservations info
%     flights_in (flights struct): flights info
% On output:
%     reservations (reservations struct): reservations info
%       (k).flights (mx5 array): in_time,out_time,speed,lane_index,headway
%     flights (flights struct): flights info
%       .flight_id (int): UAS identifier
%       .flight_slot (int): index in flights stuct
%       .decon_time (float): time to deconflict (sec)
%       .plan (px4 array): in_time,out_time,speed,lane_index
%       .route (qx9 array): x1,y1,z1,x2,y2,z2,t1,t2,speed
%       .telemetry (sx7 array): x,y,z,dx,dy,dz,speed
%       .start_interval (1x2 vector): min and mx possible launch times
%       .path (1xn vector): path lane indexes
%       .path_vertexes (1xn vector): path lane vertex indexes
%       .speeds (1xn vector): speed in each lane
%       .launch_index (int): launch lane index
%       .land_index (int): land lane index
%       .start_time (float): launch time
%       .end_time (float): land time
%       .type (int): 1 success; 0 failed
% Call:
%     [rr,ff] = SL_request2reservation(airways,requests,R,F);
% Author:
%     T. Henderson
%     UU
%     Spring 2024
%

FAILED = 0;

index = length(flights_in) + 1;
flights = flights_in;

[reservations,new_flight] = SL_gen_reservation(airways,flights,...
    reservations,request);
indexes = SL_find_conflict(reservations,0.1);
if ~isempty(indexes)
    display('Conflict in reservations');
end
flights(index).flight_id = request.flight_id;
flights(index).flight_slot = index;
flights(index).decon_time = new_flight.decon_time;
flights(index).plan = new_flight.plan;
flights(index).route = new_flight.route;
flights(index).telemetry = new_flight.telemetry;
flights(index).start_interval = request.launch_interval;
flights(index).speeds = request.speeds;
flights(index).path = request.path;
flights(index).path_vertexes = request.path_vertexes;
flights(index).launch_index = request.launch_index;
flights(index).land_index = request.land_index;
if isempty(new_flight.plan)
    flights(index).start_time = Inf;
    flights(index).end_time = Inf;
else
    flights(index).start_time = new_flight.plan(1,1);
    flights(index).end_time = new_flight.plan(end,2);
end
if new_flight.type~=FAILED
    flights(index).type = new_flight.type;
else
    flights(index).type = FAILED;
end

del_t = 0.1;
f_out = SL_gen_traj(flights(index),del_t);
flights(index).traj = f_out.traj;

tch = 0;
