function txt = SL_json_read(fn)
% SL_json_read - read json file
% On input:
%     fn (string): name of json file
% On output:
%     txt (string): text version of json file
% Call:
%     txt = SL_json_read('r1');
% Author:
%     T. Henderson
%     UU
%     Spring 2024
%

fid = fopen(fn,"r");
txt = fscanf(fid,"%s");
aspec = SL_json_decode(txt);
fclose(fid);


request.flight_id = flight_id;
request.flight_slot = flight_slot;
request.request_time = datetime;
request.launch_index = launch_vertex;
request.land_index = land_vertex;
request.launch_interval = launch_interval;
request.speeds = speeds;
request.path = path;
request.path_vertexes = path_vertexes;
request.headway = headway;