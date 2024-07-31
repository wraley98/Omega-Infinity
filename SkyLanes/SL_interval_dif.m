function int_out = SL_interval_dif(intervals,interval)
% SL_interval_dif - find difference of two intervals
% On input:
%     intervals (nx2 array): set of intervals (1 per row)
%     interval (1x2 vector): interval to take difference
% On output:
%     int_out (mx2 array): resulting difference
% Call:
%     int3 = SL_interval_dif(in1,int2);
% Author:
%     T. Henderson
%     UU
$     Summer 2024
%

int_out = intervals;

if isempty(intervals)|isempty(interval)
    return
end
[num_intervals,~] = size(intervals);
u1 = interval(1);
u2 = interval(2);
for k = 1:num_intervals
    t1 = intervals(k,1);
    t2 = intervals(k,2);
    int_dif(k).int = intervals(k,:);
    if u2<=t1
        noop = 1;
    elseif u1<=t1&u2>t1&u2<t2
        int_dif(k).int = [u2,t2];
    elseif u1<=t1&t2<=t2
        int_dif(k).int = [-1,-1];
    elseif u1>t1&u2<t2
        int_dif(k).int = [t1,u1; u2,t2];
    elseif u1>t1&u1<t2&u2>=t2
        int_dif(k).int = [t1,u1];
    else
        noop = 1;
    end
end
int_out = [];
for k = 1:num_intervals
    int_k = int_dif(k).int;
    [n,~] = size(int_k);
    if n==1
        if int_k(1)==-1&int_k(2)==-1
            noop = 1;
        else
            int_out = [int_out; int_k];
        end
    else
        int_out = [int_out; int_k];
    end
end
tch = 0;
