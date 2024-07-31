function index = SL_rc2index(r,c,m,n)
% SL_rc2index - convert row, col index to linear index in grid
% On input:
%     r (int): row
%     c (int): col
%     m (int): number of rows
%     n (int): number of cols
% On output:
%     index (int): linear index into grid
% Call:
%     index = SL_rc2index(2,2,4,4);
% Author:
%     T. Henderson
%     UU
%     Spring 2024
%

index = c*m - r + 1;
