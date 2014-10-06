close all
%user is ask for data path
dataPath='C:\Users\MG\Dropbox\Moorings Med-Cris\DATA\AllMooringLine';

% Construct a questdlg
choice = questdlg(dataPath, 'Data path?','Yes','No','Yes');
% Handle response
switch choice
    case 'Yes'
        disp([choice ', coming right up!'])
    case 'No'
        disp([choice ' worries.'])
        dataPath = uigetdir(cd,'Select a data folder');
end
clear choice;

%list all files in data directory
dataFiles    =   dir(dataPath);
fileCount=size(dataFiles,1);


%work with ADCP
for i=1:fileCount
    if ~isempty(strfind(dataFiles(i).name,'ADCP'))
        [adcpCurrentHor,adcpCurrentDir,adcpCurrentNorth, adcpCurrentEast,adcpCurrentVert,acdpBinDepth,adcpTime,adcpPitch,adcpRoll]=...
            adcpCurrent([dataPath '\' dataFiles(i).name]);
        roi=200:11900;
        adcpCurrentHor=adcpCurrentHor(:,roi);
        adcpCurrentDir=adcpCurrentDir(:,roi);
        adcpCurrentVert=adcpCurrentVert(:,roi);
        adcpCurrentNorth=adcpCurrentNorth(:,roi);
        adcpCurrentEast=adcpCurrentEast(:,roi);
        adcpTime=adcpTime(roi);
        adcpPitch=adcpPitch(roi);
        adcpRoll=adcpRoll(roi);
        continue
    end
end
clear i fileCount;


%work with tide
tideSignal=tide(adcpTime, dataPath, dataFiles);

%work withPressure
pNoTide=pressure(tideSignal, adcpTime, dataPath, dataFiles);

%construct mooringLine profile
sumOppSide= mooringLineProfile(pNoTide, 202);


%fin min adnn max shift with usable current data...
[minShiftIndex,maxShiftIndex]=  minMaxShiftIndex(adcpCurrentNorth,adcpCurrentEast,adcpCurrentVert,adcpPitch,adcpRoll,sumOppSide);
plot(adcpTime',pNoTide','b');
hold on;
set(gca,'YDir','rev');
plot(adcpTime(:,minShiftIndex)',pNoTide(:,minShiftIndex)','.r');
plot(adcpTime(:,maxShiftIndex)',pNoTide(:,maxShiftIndex)','.r');

xCurrent = 'x-current = ';
for i=1: length(acdpBinDepth) 
    if ~isnan(adcpCurrentEast(i,maxShiftIndex))
        xCurrent = strcat(xCurrent, '(', num2str(acdpBinDepth(i)), ',', num2str(adcpCurrentEast(i,maxShiftIndex)), ')' );
    end
end
xCurrent = strcat(xCurrent,'(202,0)');
yCurrent = 'y-current = ';
for i=1: length(acdpBinDepth)
    if ~isnan(adcpCurrentNorth(i,maxShiftIndex))
        yCurrent = strcat(yCurrent, '(', num2str(acdpBinDepth(i)), ',', num2str(adcpCurrentNorth(i,maxShiftIndex)), ')' );
    end
end
yCurrent = strcat(yCurrent,'(202,0)');



