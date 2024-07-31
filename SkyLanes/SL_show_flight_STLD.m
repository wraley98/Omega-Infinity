function SL_show_flight_STLD(airways,flights)
% SL_show_flight_STLD - show space time lane diagram for a flight
% On input:
%     airways (airways struct): airways info
%     flights (flights struct): flights info
% On input:
%     N/A shows STLD in figure
% Call:
%     SL_show_STLD(airways,flights);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

num_flights = length(flights);
lanes = airways.lanes;

flight_id = input('Give flight id: ');
indexes = [];
for k = 1:num_flights
    if flights(k).flight_id==flight_id
        indexes = [indexes,k];
    end
end

if isempty(indexes)
    return
end

flight_slot = input('Flight slot: ');
index = 1;
if length(indexes)>1
    for k = 1:length(indexes);
        ind = indexes(k);
        if flights(ind).flight_slot==flight_slot
            index = ind;
        end
    end
end

flights(index)
path = flights(index).path
len_path = length(path);
total_distance = 0;
distances = zeros(len_path,1);
for k = 1:len_path
    lane = path(k);
    d = norm(lanes(lane,1:3)-lanes(lane,4:6));
    distances(k) = d;
    total_distance = total_distance + d;
end
speeds = flights(index).speeds;
plan = flights(index).plan;
t1 = plan(1,1);
t2 = plan(end,2);

clf
plot([t1,t2],[0,total_distance]);
hold on
for k = 1:len_path
    d = sum(distances(1:k));
    plot([t1,t2],[d,d],'k');
end
