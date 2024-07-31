function request = SL_flight_request_arb(airways)
% SL_flight_request_arb - generate a flight request through any nodes
% On input:
%     airways (airways struct): airways info
% On output:
%     request (request struct): request info
%       flight_id (int): UAS identifier
%       flight_slot (int): index in flights data
%       request_imte (date): date-time of request
%       launch_index (int): ground vertex index for launching
%       land_index (int): ground vertex index for landing
%       launch_interval (1x2 vector): earliest and latest launch times
%       path (1xn vector): path lane indexes
%       path_vertexes (1x(n+1) vector): lane vertexes
%       speeds (1xn vector): desired speed in each lane
%       headway (float): minimal distance from any other aircraft during
%                        flight
% Call:
%     request = SL_flight_request_arb('req101',airways);
% Author:
%     T. Henderson
%     UU
%     Spring 2024/Summer 2024
%

request = [];

if isempty(airways)
    return
end

fname = input('Load request? Enter filename: ');
if ~isempty(fname)
    request = load(append(string(fname), '.mat'));
    return
end

lane_edges = airways.lane_edges;
lane_vertexes = airways.lane_vertexes;

flight_id = input('Give flight ID: ');
flight_slot = 0;
t1 = input('Pick launch interval start time: ');
t2 = input('Pick launch interval end time: ');
launch_interval = [t1,t2];
vertexes = [];  % lane vertex index path sequence
indexes = [];  % ground indexes
path = [];
done = 0;
while done==0
    pathk = [];
    path_vertexes = [];
    if isempty(vertexes)
        display('Ground Launch Vertexes:');
        airways.launch_vertexes
        launch_index = input('Enter launch (ground) index): ');
        indexes = [launch_index];
        ind1 = find(launch_index==airways.launch_vertexes);
        launch_vertex = airways.launch_lane_vertexes(ind1);
        vertexes = launch_vertex;
        ind = find(lane_edges(:,1)==launch_vertex);
        vertex = lane_edges(ind,2);
        vertexes = [vertexes,vertex];
        lane_index = find(lane_edges(:,1)==vertexes(1));
        path = lane_index;
    else
        land = input('Type 1 to enter land vertex, else 0: ');
        if ~isempty(land)&land==1
            display('Ground Land Indexes: ');
            airways.land_vertexes
            land_index = input('Enter ground land vertex: ');
            ind2 = find(land_index==airways.land_vertexes);
            land_vertex = airways.land_lane_vertexes(ind2);
            [pathk,path_vertexes] = SL_get_path(airways,vertexes(end),...
                land_vertex,[]);
            vertexes = [vertexes,path_vertexes(2:end)];
            path = [path,pathk];
            done = 1;
        else
            display('Successor Ground Indexes: ');
            index1 = indexes(end);
            indexes_out = find(airways.edges(:,1)==index1);
            indexes_in = find(airways.edges(:,2)==index1);
            indexes2 = unique([airways.edges(indexes_out,2)',...
                airways.edges(indexes_in,1)'])
            index = input('Give next ground index: ');
            r_pts = airways.roundabouts_dn(index).info.r_pts;
            [num_r_pts,~] = size(r_pts);
            min_dist = Inf;
            min_index = 0;
            v = zeros(num_r_pts,1);
            for k = 1:num_r_pts
                v(k) = find(lane_vertexes(:,1)==r_pts(k,1)...
                    &lane_vertexes(:,2)==r_pts(k,2)...
                    &lane_vertexes(:,3)==r_pts(k,3));
                [pathk,path_vertexes] = SL_get_path(airways,...
                    vertexes(end),v(k),[]);
                if length(path_vertexes)<min_dist
                    min_dist = length(path_vertexes);
                    min_index = k;
                end
            end
            [pathk,path_vertexes] = SL_get_path(airways,vertexes(end),...
                v(min_index),[]);
            vertexes = [vertexes,path_vertexes(2:end)];
            indexes = [indexes,index];
            path = [path,pathk];
        end
    end
end
len_path = length(path);
speed = input('Same speed in all lanes (speed if yes, else 0): ');
if speed>0
    speeds = speed*ones(1,len_path);
else
    for p = 1:len_path
        display(['Lane ',num2str(p),': ']);
        speed = input('Input speed: ');
        speeds(p) = speed;
    end
end
headway = input('Set headway distance: ');

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

fname = input('Save request? Enter filename: ');
if ~isempty(fname)

    save(append(string(fname), '.mat'));
    % txt = SL_json_encode(request);
    % SL_json_write(txt,fname);
end
