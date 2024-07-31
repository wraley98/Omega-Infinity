function res = SL_run_simulation(airways,flights)
% SL_run_simulation - indirect call to SL_run_flights
% On input:
%     airways (airways struct): airways info
%     flights (flights struct): flights info
% On output:
%     res (empty): returns empty
% Call:
%     res = SL_run_simulation(airways,flights);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

res = [];

SL_run_flights(airways,flights);
