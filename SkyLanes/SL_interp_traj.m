function traji = SL_interp_traj(traj,q)
% SL_interp_traj - interpolate a UAS trajectory
% On input:
%     traj (nx4 array): trajectory (time,x,y,z)
%     q (px1 vector): sample times
% On output:
%     traji (px4 array): interpolated trajectory (q,x,y,z)
% Call:
%     traji = SL_interp_traj(traj,q);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

[len_traj,~] = size(traj);
num_pts = length(q);
traji = zeros(num_pts,4);

t = traj(:,1);
x = traj(:,2);
y = traj(:,3);
z = traj(:,4);

vx = SL_interp(t,x,q);
vy = SL_interp(t,y,q);
vz = SL_interp(t,z,q);
traji = [q,vx,vy,vz];
