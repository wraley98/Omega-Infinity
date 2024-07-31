function wayptsd = SL_dense_xyz_waypts(waypts,dx)
% SL_dense_xyz_waypts - produces more samples along path
% On input:
%     waypts (nx4 array): waypts as x,y,z,t
%     dx (float): new distance between samples
% On output:
%     wayptsd (mx4 array): new set of dense waypoints
% Call:
%     AFA2wd = SL_dense_xyz_waypts(AFA2w,1);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

[num_waypts,~] = size(waypts);
wayptsd = [];
wayptsd = [wayptsd; waypts(1,:)];
for k = 1:num_waypts-1
    pt1 = waypts(k,1:3);
    pt2 = waypts(k+1,1:3);
    dir = pt2 - pt1;
    dir = dir/norm(dir);
    pt = pt1;
    d = norm(pt2-pt1);
    t1 = waypts(k,4);
    t2 = waypts(k+1,4);
    td = t2 - t1;
    while norm(pt-pt1)<d
        pt = pt + dx*dir;
        t = t1 + td*norm(pt-pt1)/d;
        if norm(pt-pt1)<d
            wayptsd = [wayptsd; pt,t];
        end
    end
    wayptsd = [wayptsd; pt2,t2];
end
d_last = norm(wayptsd(end,1:3)-pt1);
if d_last<d
    wayptsd = [wayptsd; waypts(end,:)];
elseif d_last>d
    wayptsd(end,:) = waypts(end,:);
end

tch = 0;
