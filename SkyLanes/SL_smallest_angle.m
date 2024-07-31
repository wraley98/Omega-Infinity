function smallest_angle = SL_smallest_angle(airways)
% SL_smallest_angle - find smallest angle between two connected lanes
% On input:
%     airways (airways struct): airways info
% On output:
%     smallest_angle (float): smallest angle between two connected lanes
% Call:
%     SL_smallest_angle(airways);
% Author:
%     T. Henderson
%     UU
%     Fall 2020
%

lanes = airways.lanes;
G = airways.G;
E = table2array(airways.G.Edges);
[num_E,~] = size(E);
V = table2array(airways.G.Nodes);
[num_V,~] = size(V);
smallest_angle = Inf;
for n = 1:num_V
    indexes_in = find(E(:,2)==n);
    num_in = length(indexes_in);
    indexes_out = find(E(:,1)==n);
    num_out = length(indexes_out);
    if num_in==0&num_out==0  % isolated node
        tch = 0;
    elseif num_in==0&num_out==1 % launch (entry) lane
        tch = 0;
    elseif num_in==1&num_out==1 % land (exit) lane
        tch = 0;
    elseif num_in>1&num_out>1
        display('SL_smallest_angle: In-out node error');
    elseif num_in==1 % through or diverging node
        index1 = E(indexes_in,1);
        index2 = n;
        pt1 = V(index1,:);
        pt2 = V(index2,:);
        v1 = pt2 - pt1;
        v1 = v1/norm(v1);
        for k = 1:num_out
            index3 = E(indexes_out(k),2);
            pt3 = V(index3,:);
            v2 = pt3 - pt2;
            v2 = v2/norm(v2);
            theta = acos(dot(v1,v2));
            smallest_angle = min(smallest_angle,theta);
        end
    elseif num_in>1&num_out==1 % convering node
        index3 = E(indexes_out,2);
        index2 = n;
        pt2 = V(index2,:);
        pt3 = V(index3,:);
        v2 = pt3 - pt2;
        v2 = v2/norm(v2);
        for k = 1:num_in
            index1 = E(indexes_in(k),1);
            pt1 = V(index1,:);
            v1 = pt2 - pt1;
            v1 = v1/norm(v1);
            theta = acos(dot(v1,v2));
            smallest_angle = min(smallest_angle,theta);
        end
    end
end
