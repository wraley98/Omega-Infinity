function model = SL_traj2model(traj)
% SL_traj2model - make a trajectory model from a trajectory
% On input:
%     trajectory (nx4 array): t,x,y,z
% On ouput:
%     model (kx6 array): k sample points & dirs; x,y,z,dx,dy,dz
% Call:
%     model1 = SL_traj2model(traj);
% Author:
%     T. Henderson
%     UU
%     Spring 2021
%

model = [];
[num_pts,dummy] = size(traj);
if num_pts<1
    return
end

model = zeros(num_pts-1,6);
for p = 1:num_pts-1
    del_t = traj(p+1,1) - traj(p,1);
    model(p,1:3) = traj(p,2:4);
    dist = traj(p+1,2:4) - traj(p,2:4);
    dir = dist/norm(dist);
    model(p,4:6) = dir;
end
