function v = SL_interp(x,y,q)
% SL_interp - interpolate y(q) = x(q) for time samples q
% On input:
%     x (1xn vector): independent variable values
%     y (1xn vector): dependent variable values
%     q (1xm vector): independent values at which to sample
% On output:
%     v (1xm vector): dependent values at q
% Call:
%     v = SL_interp(x,y,q);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

num_q = length(q);
v = zeros(num_q,1);
num_x = length(x);

for k = 1:num_q
    if q(k)<x(1)
        v(k) = y(1);
    elseif q(k)>x(end)
        v(k) = y(end);
    else
        for p = 1:num_x-1
            if x(p)<=q(k)&q(k)<=x(p+1)
                x1 = x(p);
                x2 = x(p+1);
                r = (q(k)-x1)/(x2-x1);
                y1 = y(p);
                y2 = y(p+1);
                v(k) = y1 + r*(y2-y1);
            end
        end
    end
end
