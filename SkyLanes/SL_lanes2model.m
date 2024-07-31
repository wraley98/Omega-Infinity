function [model,mlanes] = SL_lanes2model(lanes,del_x)
% SL_lanes2model - make a trajectory model for a set of air lanes
% On input:
%     lanes (nx6 array): x1,y1,z1,x2,y2,z2 lane endpoints
%     del_x (float): spacing for sample points along lanes
% On ouput:
%     model (kx6 array): k sample points & dirs; x,y,z,dx,dy,dz
%     mlanes (kx1 vector): lanes for each sample point
% Call:
%     [model3,mlanes3] = SL_lanes2model(airways.lanes,2);
% Author:
%     T. Henderson
%     UU
%     Spring 2021/ Summer 2024 from LEM_lanes2model
%

model = [];
mlanes = [];
[num_lanes,dummy] = size(lanes);
if num_lanes<1
    return
end

lane_lengths = zeros(num_lanes,1);
for k = 1:num_lanes
    lane_lengths(k) = norm(lanes(k,4:6)-lanes(k,1:3));
end
total_length = sum(lane_lengths);
num_samples = ceil(total_length/del_x);
model = zeros(num_samples,6);
mlanes = zeros(num_samples,1);
count = 0;
for k = 1:num_lanes-1
    k;
    pt1 = lanes(k,1:3);
    pt2 = lanes(k,4:6);
    dx = pt2 - pt1;
    dist = norm(dx);
    dir = dx/dist;
    d = 0; pt = pt1; x = []; y = []; z = [];
    while d<=dist
        pt = pt + del_x*dir;
        d = norm(pt1-pt);
        if d<=dist
            x = [x,pt(1)];
            y = [y,pt(2)];
            z = [z,pt(3)];
        end
    end
    num_pts = length(x);
    for p = 1:num_pts
        count = count + 1;
        model(count,:) = [x(p),y(p),z(p),dir(1),dir(2),dir(3)];
        mlanes(count) = k;
    end
end
model = model(1:count,:);
