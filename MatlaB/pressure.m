function pNoTide=pressure(tideSignal, adcpTime, dataPath, dataFiles)
% %input:
%   adcpTime= row vector obtain from adcpCurrent.m
%   dataFiles= struct obtain from dir(dataPath);
%   dataPat= path to data folder
%   tideSignal= obtain from tide.m

% %output
%   pNoTide= matrice sorted from top to bottom of pressure data corrected
%   with tideSignal , resample according to ADCP time.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%preallocating
fileCount   =   length(dataFiles);
pNoTide = zeros(fileCount, length(adcpTime));
pTide   = zeros(fileCount, length(adcpTime));


%loop on every file in data directory
for i = 1:fileCount

    %add data path
    dataFiles(i).name=[dataPath '\' dataFiles(i).name];
    %check if file is a netCDF 
    if isempty(strfind(dataFiles(i).name,'.nc'))
        continue
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %only keep pressure data from instrument with a real pressure sensors
    % & No adcp cause pressure sensors is shit.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %check if DEPTH variable is present in NETCDF file
    fileInfo = ncinfo(dataFiles(i).name);
    %if the file doesn't contains depth data, go to the next iteration
    if all(strcmp({fileInfo.Variables.Name},'DEPTH'))
        continue
    end
    %check if file got a CSPD data ie cur speed, adcp, if yes...next
%     if any(strcmp({fileInfo.Variables.Name},'CSPD'))
%         continue
%     end
    %check if variables DEPTH is interpolated
    fileInfo=ncreadatt(dataFiles(i).name,'DEPTH','comment');
    %if pressure are interpolated a go to the next iteration
    if ~isempty(strfind(fileInfo,'nearest'))
        continue
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %read time data
    pTime    =   (ncread(dataFiles(i).name, 'TIME'))'+ datenum('1950-01-01 00:00:00');
    %read pressure data
    temp   =   ncread(dataFiles(i).name, 'DEPTH');    
    %change variable to colum vector
    temp   =   (squeeze(temp))';
    %resampling depth data according to adcp sampling rate minus side.
    pTide(i,:) = interp1(pTime, temp, adcpTime);
    pNoTide(i,:)= pTide(i,:)- tideSignal;
end


%delete rows from preallocated  matrice and sort rows..
temp    =   find(all(pNoTide~=0,2));%find index of rows still fill with zeros
pTide   =   sortrows(pTide(temp,:));%delete these index and sort
pNoTide =   sortrows(pNoTide(temp,:));

%delete row that contains NaN
pNoTide=pNoTide(~any(isnan(pNoTide),2),:);

% Construct a questdlg
choice = questdlg('Want Pressure plot?', 'Dialog','Yes','No','Yes');
% Handle response
switch choice
    case 'Yes'
        figure
        plot(adcpTime,pTide,adcpTime,pNoTide);
        set(gca,'YDir','reverse')
    case 'No'
        disp([choice ' worries.'])
end
clear choice;






