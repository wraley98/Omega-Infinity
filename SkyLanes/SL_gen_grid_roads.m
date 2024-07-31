function roads = SL_gen_grid_roads(xmin,xmax,ymin,ymax,dx,dy)
% SL_gen_grid_roads - generate roads using grid layout
% On input:
%     xmin (float): min x coord
%     xmax (float): max x coord
%     ymin (float): min y coord
%     ymax (float): max y coord
%     dx (float): dx space between vertexes
%     dy (float): dy space between vertexes
% On output:
%     roads (road struct): road info
%       .vertexes (nx3 array): x,y,z coords of endpoints
%       .edges (mx2 array): indexes of vertexes defining lanes
%       .xmin (float): min x value
%       .xmax (float): max x value
%       .ymin (float): min y value
%       .ymax (float): max y value
%       .dx (float): step in x
%       .dy (float): step in y
%       .num_rows (int): number of y rows
%       .num_cols (int): number of x xolumns
% Call:
%     roadsg = SL_gen_grid_roads(-20,20,-20,20,5,5);
% Author:
%    T. Henderson
%    UU
%    Fall 2020
%

x_vals = [xmin:dx:xmax]';
if isempty(x_vals)
    x_vals = xmin;
end
y_vals = [ymin:dy:ymax]';
if isempty(y_vals)
    y_vals = ymin;
end
num_x_vals = length(x_vals);
num_y_vals = length(y_vals);
num_vertexes = num_x_vals*num_y_vals;
vertexes = zeros(num_vertexes,3);
count = 0;
for ind1 = 1:num_x_vals
    x = x_vals(ind1);
    for ind2 = 1:num_y_vals
        count = count + 1;
        y = y_vals(ind2);
        vertexes(count,1:2) = [x,y];
    end
end

edges = [];
for ind1 = 1:num_vertexes-1
    pt1 = vertexes(ind1,:);
    for ind2 = ind1+1:num_vertexes
        pt2 = vertexes(ind2,:);
        if norm(pt2-pt1)<1.1*dx|norm(pt2-pt1)<1.1*dy
            edges = [edges;ind1,ind2];
        end
    end
end
roads.vertexes = vertexes;
roads.edges = edges;
roads.xmin = xmin;
roads.xmax = xmax;
roads.ymin = ymin;
roads.ymax = ymax;
roads.delx = dx;
roads.dely = dy;
roads.num_rows = num_y_vals;
roads.num_cols = num_x_vals;

tch = 0;
