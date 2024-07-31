function [airways,reservations,flights,path,request,job_set] = ...
    SL_save_load(airways,reservations,flights,path,request,job_set)
% SL_save_load - save and load the scenario in the interactive session
% On input:
%     airways (airways struct): airways info
%     reservations (reservations struct): reservations info
%     flights (flights struct): flights info
%     path (axn vector): lane index sequence for most recent path
%     request (request struct): most recent request
%     job_set (job_set struct): job set info
% On output:
%     airways (airways struct): updated airways info
%     reservations (reservations struct): reservations info
%     flights (flights struct): updated flights info
%     path (1xn vector): updated lane index sequence for path
%     request (request struct): updated recent request
%     job_set (job_set struct): updated job set info
% Call:
%     [a2,r2,f2,p2,r2,js2] = SL_save_load(a1,r1,f1,p1,r1,js1);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

cmd = input('Enter 1 for save; 2 for load: ');
fname = input('File name: ');
fnamejson = [fname,'json'];

if cmd==1 % save
    DD.airways = airways;
    DD.reservations = reservations;
    DD.flights = flights;
    DD.path = path;
    DD.request = request;
    DD.job_set = job_set;
    txt = SL_json_encode(DD);
    SL_json_write(txt,fnamejson);
    save(fname,'DD');
else % load
    load(fname);
%    DD = SL_json_read(fname);
    airways = DD.airways;
    if ~isempty(DD.reservations)
        reservations = DD.reservations;
    else
        num_lanes = length(airways.lane_lengths);
        for j = 1:num_lanes
            reservations(j).flights = [];
        end
    end
    flights = DD.flights;
    path = DD.path;
    request = DD.request;
    job_set = DD.job_set;
end
