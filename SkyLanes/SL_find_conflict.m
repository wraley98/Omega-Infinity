function indexes = SL_find_conflict(reservations,ht)
% SL_find_conflict - see if headway conflict exists
% On input:
%     reservations (reservations struct): reservations info
%     ht (float): headway time
% On output:
%     indexes (1xn vector): flights with conflict
% Call:
%     indexes = SL_find_conflict(reservations,ht);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

OFFSET = 0.00001;

indexes = [];

num_lanes = length(reservations);
for e = 1:num_lanes
    flights = reservations(e).flights;
    if ~isempty(flights)
        dd = flights(2:end,2) - flights(1:end-1,2);
        bad = find(dd+OFFSET<ht);
        if ~isempty(bad)
            indexes = [indexes;e, bad+1,bad];
        end
    end
end
