function [B,M,m,offx,offy] = SL_grid_fit(airways,traj,x_min,x_max,...
    y_min,y_max,dx,dy)
% SL_grid_fit - find best match for trajectory to airway lanes
% On input:
%     airways (airways struct): airways info
%     traj (nx4 array): telemetry data (time, x,y,z)
%     x_min (float): min x for search range
%     x_max (float): max x for search range
%     y_min (float): min y for search range
%     y_max (float): max y for search range
%     dx (float): x offset from origin
%     dy (float): y offset from origin
% On output:
%     B (px1 array): sum of all distances from closest lane
%     M (traj model struct): traj model
%     m (traj mode struct): traj model
%     offx (float): x offset
%     offy (float): y offset
% Call:
%     [B,M,m,offx,offy] = LS_grid_fit(airways,traj,x_min,x_max,y_min,...
%                         y_max,dx,dy);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

Tt = traj(:,1);
Xt = traj(:,2);
Yt = traj(:,3);
Zt = traj(:,4);
X0 = traj(1,2);
Y0 = traj(1,3);
x_vals = [x_min:dx:x_max];
y_vals = [y_min:dy:y_max];
num_x = length(x_vals);
num_y = length(y_vals);
B = zeros(num_y,num_x);
Bx = zeros(num_y,num_x);
By = Bx;

f = waitbar(0,'Grid Search');
for k1 = 1:num_x
    waitbar(k1/num_x);
    k1;
    X = Xt + x_vals(k1);
    for k2 = 1:num_y
        Y = Yt + y_vals(k2);
        [M,m] = SL_traj_analysis_driver(airways,[Tt,X,Y,Zt]);
        B(num_y-k2+1,k1) = sum(M(:,1));
        Bx(num_y-k2+1,k1) = x_vals(k1);
        By(num_y-k2+1,k1) = y_vals(k2);
    end
end
close(f);
B = B/max(B(:));
[r,c] = find(B==min(B(:)));
offx = Bx(r,c);
offy = By(r,c);
[M,m] = SL_traj_analysis_driver(airways,[Tt,Xt+Bx(r,c),Yt+By(r,c),Zt]);
