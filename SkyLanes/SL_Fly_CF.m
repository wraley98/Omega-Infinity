function SL_Fly_CF(flightList)

cd ..

if exist ('crazyflieRunInstruct.xlsx' , 'file')

    delete('crazyflieRunInstruct.xlsx');

end

cd SkyLanes\

[~ , numCF] = size(flightList);

maxRow = 0;

for ii = 1:numCF
    
    flightData = flightList(ii);
    [row , ~] = size(flightData.route);

    if row > maxRow

        maxRow = row;

    end

end

cfList = zeros(maxRow * numCF + numCF + 1, 9);
prevRow = 1;

for ii = 1:numCF
    
    flightData = flightList(ii);
    [row , ~] = size(flightData.route);
    
    nextCF = [zeros(1,9)];
    nextCF(1) = 99;

    cfList( prevRow : row + prevRow, :) = ...
        [flightData.route ; nextCF ];
    prevRow = row + 2;

end

cfList(end , 1) = numCF;

cd ..

writematrix(cfList, 'crazyflieRunInstruct.xlsx')

cd SkyLanes\

% pyrunfile('OmegaInfDriver.py')
