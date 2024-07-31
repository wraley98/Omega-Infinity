function res = SL_interactive_system
% SL_interactive_system - toplevel interactive Sky Lane driver
% On input:
%     Input is interactive
% On output:
%     res (results struct): results
%       .airways (airways struct)
%       .flights (flights struct)
%       .reservations (reservations struct)
%       .job_set (job_set struct)
% Call:
%     res = SL_interactive_system;
% Author:
%     T. Henderson
%     UU
%     Spring 2024
%

res = [];

display('Sky Lanes: Lane-Based UTM');
display('  ');
airways = [];
flights = [];
path = [];
request = [];
reservations = [];
job_set = [];

cmd = 1;
while cmd>0
    display('Menu:');
    display('   1: Create an airway');
    display('   2: Show airway');
    display('   3: Define flight request');
    display('   4: Make flight reservation');
    display('   5: Pick job set');
    display('   6: Run simulation');
    display('   7: Show flight STLD');
    display('   8: Show Lane STLD');
    display('   9: Save/Load data: ');
    display('  10: Show Flight Path: ')
    display('  11: Show performance: ');
    display('  12: Clear flights, res: ');
    display('  13: Lane availability: ');
    display('  14. Load airways: ');
    display('  15. Produce waypoints: ');
    display('  16. Show flight path on map: ');
    display('  17. Analyze Trajectory: ');
    display('  18. Run Crazyflie Flight: ');
    cmd = input('Command: ');
    if isempty(cmd)
        cmd = 1000;
    end
    switch cmd
        case -1 % no op
        case 1 % Create airway
            % d = input("Enter '1' to load aspec file: ");
            % if d==1
            %     fn = input('Enter aspec filename: ');
            %     aspec = SL_json_read(fn);
            % else
            aspec = SL_create_aspec;
            % end
            airways = SL_aspec2airways(aspec);
            [num_lanes,~] = size(airways.lanes);
            for k = 1:num_lanes
                reservations(k).flights = [];
            end
            flights = [];
        case 2 % Show airways
            if ~isempty(airways)
                SL_show_airways3D(airways,path);
            end
        case 3 % Define flight request
            request = SL_flight_request_arb(airways);
        case 4 % Make flight reservations
            [reservations,flights] = SL_request2reservation(...
                airways,request,reservations,flights);
        case 5 % Pick job set
            [reservations,flights,job_set] = SL_job_set(airways,...
                reservations);
        case 6 % Run simulation
            res = SL_run_simulation(airways,flights);
        case 7 % show flight complete STLD
            SL_show_flight_STLD(airways,flights);
        case 8 % Show lane STLD
            SL_show_STLD(airways,reservations,flights);
        case 9 % Save/Load data
            [airways,reservations,flights,path,request,job_set] = ...
                SL_save_load(airways,reservations,flights,path,...
                request,job_set);
            res.airways = airways;
            res.flights = flights;
            res.reservations = reservations;
            res.job_set = job_set;
        case 10 % Show flight path
            SL_show_flight_path(airways,flights);
        case 11 % show performance
            P = SL_performance(flights);
            f = sum(P(:,5)==1);
            fs = num2str(f);
            num_flights = length(flights);
            nfs = num2str(num_flights);
            clf
            subplot(4,1,1);
            plot(P(:,1),P(:,2));
            title('Delay');
            subplot(4,1,2);
            plot(P(:,1),P(:,3));
            title('Duration');
            subplot(4,1,3);
            plot(P(:,1),P(:,4));
            title('Deconfliction Time');
            subplot(4,1,4);
            plot(P(:,1),1-P(:,5));
            title('Succeed (1)/Fail (0)');
            xlabel('Flight id');
            hold on
            plot(0,-0.1,'w.');
            plot(-0.1,1.1,'w.');
            plot(length(P(:,1))+0.1,1.1,'w.');
            text(-1,0.5,[fs,' of ',nfs,' Failed']);
        case 12 % clear flights & reservations
            flights = [];
            num_lanes = length(airways.lanes(:,1));
            for k = 1:num_lanes
                reservations(k).flights = [];
            end
        case 13 % lane availability
            lane = input('Lane number: ');
            t1 = input('Time 1: ');
            t2 = input('Time 2: ');
            flights = reservations(lane).flights;
            I = [t1,t2];
            for k = 1:length(flights)
                intk = [flights(k,2)-flights(k,6),flights(k,2)+flights(k,6)];
                I = SL_interval_dif(I,intk);
            end
            I
        case 14 % load airways data structure
            fn = input('Enter airways filename: ');
            load(fn);
            [num_lanes,~] = size(airways.lanes);
            for k = 1:num_lanes
                reservations(k).flights = [];
                reservations_nodes(k).flights = [];
            end
            reservations_nodes(num_lanes+1).flights = [];
            flights = [];
        case 15 % produce waypoints
            SL_scenario2waypts(res);
        case 16 % show flight on map
            [zoomLevel,player,lat0,lon0,lats,lons] = ...
                SL_show_path_on_map(airways,flights);
            if ~isempty(player)
                player = geoplayer(lat0,lon0,zoomLevel);
                plotRoute(player,lats,lons);
            end
        case 17 % Analyze Trajectory
            SL_analyze_traj(airways);
        case 18 % Run flight
            SL_Fly_CF(flights);




    end
    res.airways = airways;
    res.flights = flights;
    res.reservations = reservations;
    res.job_set = job_set;
end
