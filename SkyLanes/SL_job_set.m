function [reservations,flights,job_set] = SL_job_set(airways,...
    reservations)
% SL_job_set - generate a variety of job sets
% On input:
%     airways (airways struct): airways info
%     reservations (reservations struct): reservations info
% On output:
%     reservations (reservations struct): reservations info
%     flights (flights struct): flights info
%     job_set (requests struct): set of requests
%       .request (request struct): individual request
% Call:
%     [R,F,JS] = SL_job_set(airways);
% Author:
%     T. Henderson
%     UU
%     spring 2024
%

job_set = [];
flights = [];

launch_vertexes = airways.launch_lane_vertexes;
num_launch_vertexes = length(launch_vertexes);
land_vertexes = airways.land_lane_vertexes;
num_land_vertexes = length(land_vertexes);

display('Menu: Enter 1 for Random Flights');

index = input('Choose job set: ');
switch index
    case 1  % random flights
        t_min = input('t_min: ');
        t_max = input('t_max: ');
        num_requests = input('Number of flights: ');
        min_speed = input('Enter min_speed: ');
        max_speed = input('Enter max_speed: ');
        min_hd = input('Enter min hd: ');
        max_hd = input('Enter max hd: ');
        for f = 1:num_requests
            request.flight_id = f;
            request.flight_slot = 0;
            request.request_time = datetime;
            index = randi(num_launch_vertexes);
            launch_index = launch_vertexes(index);
            request.launch_index = launch_index;
            index = randi(num_land_vertexes);
            land_index = land_vertexes(index);
            request.land_index = land_index;
            t1 = rand*(t_max-t_min) + t_min;
            t2 = t1 + 10;
            request.launch_interval = [t_min,t_max];
%            request.launch_interval = [t1,t2];
            [path,path_vertexes] = SL_get_path(airways,launch_index,...
                land_index,[]);
            request.path = path;
            request.path_vertexes = path_vertexes;
            len_path = length(path);
            speed = rand*(max_speed-min_speed) + min_speed;
            speeds = speed*ones(1,len_path);
            request.speeds = speeds;
            hd = rand*(max_hd-min_hd) + min_hd;
            request.headway = hd;
            [reservations,flights] = SL_request2reservation(airways,...
                request,reservations,flights);
            job_set = [job_set;request];
        end
end
