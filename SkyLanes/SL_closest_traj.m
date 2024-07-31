function c_pts = SL_closest_traj(flights,traj)
% SL_closest_traj - find closest points for all existing flights
% On input:
%     flights (flights struct): flights info
%     traj (nx4 array): proposed trajectory (time,x,y,z)
% On output:
%     c_pts (kx3 array): closest points per flight
%      col 1: flight index
%      col 2: time of closest approach
%      col 3: distance of closest points
% Call:
%     c_pts = SL_closest_traj(flights,traj);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

DT = 0.1;  % sample step (sec) for trajectory interpolation

num_flights = length(flights);
c_pts = [];
traj2 = traj;

for f1 = 1:num_flights
    traj1 = flights(f1).traj;
    if ~isempty(traj1)
        t_min = min(traj1(1,1),traj2(1,1));
        t_max = max(traj1(end,1),traj2(end,1));
        q = [t_min:DT:t_max]';
        len_q = length(q);
        d = Inf*ones(len_q,1);
        traj1i = SL_interp_traj(traj1,q);
        traj2i = SL_interp_traj(traj2,q);
        t1 = floor(max(traj1(1,1),traj2(1,1)));
        t2 = ceil(min(traj1(end,1),traj2(end,1)));
        q1 = find(q<t1);
        if isempty(q1)
            s1 = 1;
        else
            s1 = q1(end);
        end
        q2 = find(q>t2);
        if isempty(q2)
            s2 = len_q;
        else
            s2 = q2(1);
        end
        for s = s1:s2
            d(s) = norm(traj2i(s,2:4)-traj1i(s,2:4));
        end
        [val,ind] = min(d);
        c_pts = [c_pts;f1,q(ind),val];
    end
end
