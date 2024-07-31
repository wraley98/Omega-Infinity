function ptheta = SL_posori(theta) 
% SL_posori - put angle in [0,2pi)
% On input:
%     theta (float): angle (radians)
% On output:
%     ptheta (float): angle in range [0,2pi)
% Call:
%     p = LEM_posori(8.3);
% Author:
%     T. Henderson
%     UU
%     2000
%

ptheta = mod(2*pi + theta,2*pi); 
