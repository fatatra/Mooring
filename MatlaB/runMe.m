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
        roi=200:6000;
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

%create .cab files with x and y current to use in whoi cables
createWhoiExperiment(adcpCurrentNorth,adcpCurrentEast,adcpCurrentVert,adcpPitch,adcpRoll,acdpBinDepth,sumOppSide,adcpTime,pNoTide)

%plot simulation
plotSim






