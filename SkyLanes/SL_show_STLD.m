function SL_show_STLD(airways,reservations,flights)
% SL_show_STLD - show space time lane diagram
% On input:
%     airways (airways struct): airways info
%     reservations (reservations struct): reservations info
%     flights (flights struct): flights info
% On output:
%     <displays figure of STLD>
% Call:
%     SL_show_STLD(airways,rservations,flights);
% Author:
%     T. Henderson
%     UU
%     Fall 2020
%

lane_index = input('Pick a lane: ');
lanes = airways.lanes;
lane_dist = norm(lanes(lane_index,1:3)-lanes(lane_index,4:6));
lane_flights = reservations(lane_index).flights;
[num_lane_flights,~] = size(lane_flights);
t1 = Inf;
t2 = -Inf;
t1_k = 0;
t2_k = 0;
for k = 1:num_lane_flights
    t1_k = min(t1,lane_flights(k,2));
    t2_k = max(t2,lane_flights(k,3));
end

clf
plot([0,t2_k+10],[0,0],'k');
if t2_k==0
    text(0.5,.5,'No Flights');
else
    hold on
    plot([0,t2_k+10],[lane_dist,lane_dist],'k');
    for k = 1:num_lane_flights
        t1 = lane_flights(k,2);
        t2 = lane_flights(k,3);
        plot([t1,t2],[0,lane_dist]);
    end
end
