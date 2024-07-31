function [M,model] = SL_traj_analysis_driver(airways,traj)
% SL_traj_analysis_driver - analyze how trajectory fits lane network
% On input:
%     airways (airways struct): airways info
%     traj (nx4 array): trajectory data (time, x,y,z) local in ft
% On output:
%     M (): measures
%     model (struct): model of data
%       .xyzuvw (px6 array): location and lane dir at each sample point
%       .kdt (kd tree): kd tree for lane sample points
% Call:
%     [M,model] = SL_traj_analysis_driver(airways,traj);
% Author:
%     T. Henderson
%     UU
%     Summer 2024 (from LEM_traj_analysis_driver)
%

roads.vertexes = airways.vertexes;
roads.edges = airways.edges;
[model3,mlanes3] = SL_lanes2model(airways.lanes,.1);

model.xyzuvw = model3;
kdt = createns(model3(:,1:3));
model.kdt = kdt;
model.lane = mlanes3;
%M = SL_traj_measures(model,traj);
M = SL_traj_measures(airways,model,traj);

% figure(1);
% clf
% plot(M(:,1));
% figure(2);
% clf
% plot(M(:,2));
