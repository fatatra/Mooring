function tideSignal=tide(adcpTime, dataPath, dataFiles)
% %input:
%   adcpTime= row vector obtain from adcpCurrent.m
%   dataFiles= struct obtain from dir(dataPath);

% %output
%   tideSignal= row vector, obtain from lowest pressure sensor in dataFiles
%   and resample according to adcpTime.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%preallocating
fileCount   =   length(dataFiles);
instrumentsNominalDepth     =   zeros(20,1);


%loop on every file in data directory
for i = 1:fileCount
    instrumentsNominalDepth(i)  = nan;
    %add data path
    
    dataFiles(i).name=[dataPath '\' dataFiles(i).name];
    %check if file is a netCDF 
    if isempty(strfind(dataFiles(i).name,'.nc'))
        continue
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %only keep pressure data from instrument with a real pressure sensors
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %check if DEPTH variable is present in NETCDF file
    fileInfo = ncinfo(dataFiles(i).name);
    %if the file doesn't contains depth data, go to the next iteration
    if all(strcmp({fileInfo.Variables.Name},'DEPTH'))
        continue
    end
    %check if variables DEPTH is interpolated
    fileInfo=ncreadatt(dataFiles(i).name,'DEPTH','comment');
    %if pressure are interpolated a go to the next iteration
    if ~isempty(strfind(fileInfo,'nearest'))
        continue
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    instrumentsNominalDepth(i)  =   ncreadatt(dataFiles(i).name,'/','instrument_nominal_depth');
    
end

%%%%%%%%%%%find  deepest sensor%%%%%%%%%%%%%%%%%%%%%%%
[~, deepestInstrumentIndex]=max(instrumentsNominalDepth);
%output file name to be processed
%fprintf('Reading File %s \n',dataFiles(deepestInstrumentIndex,1).name);
%read time data
time    =   ncread(dataFiles(deepestInstrumentIndex,1).name, 'TIME')+ datenum('1950-01-01 00:00:00');
%read pressure data
depth   =   ncread(dataFiles(deepestInstrumentIndex,1).name, 'DEPTH');
%change variable to colum vector
depth   =   squeeze(depth);
%plot
% Construct a questdlg
choice = questdlg('Want Tide plot?', 'Dialog','Yes','No','Yes');
% Handle response
switch choice
    case 'Yes'
        htideFigure= figure;
        htideFigureSubplot(1)= subplot(2,1,1);
        plot(time,depth);
        ylabel('Depth (m)')
        hold all;
        %give a name for plot title and legend
        deployment_code                 =   {ncreadatt(dataFiles(i).name,'/','deployment_code')};
        instrument                   =   {ncreadatt(dataFiles(i).name,'/','instrument')};
        instrumentSerialNumber       =   {ncreadatt(dataFiles(i).name,'/','instrument_serial_number')};
    case 'No'
        disp([choice ' worries.'])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%find out tide and residual signa%%%%%%%%%%%%%%%%%55
residualSignal=pl66tn(depth,(time(2)-time(1))*24,33);  %need more info on pl66tn input!!!
tideSignal= depth - residualSignal;
if strcmp(choice,'Yes')
        figure(htideFigure);
        plot(time,residualSignal)
        legend(strcat(instrument, ' #', instrumentSerialNumber), 'Residual')
        title(deployment_code);
        set(gca,'YDir','reverse')
        setDate4zoom;
        htideFigureSubplot(2)= subplot(2,1,2);
        plot (time,tideSignal);
        set(gca,'YDir','reverse')
        legend( 'Tide variation')
        ylabel('(m)')
        linkaxes (htideFigureSubplot, 'x');
        setDate4zoom;
end
clear choice;

%resample at adcpSampling regime
tideSignal = interp1(time, tideSignal, adcpTime);
end





function xf=pl66tn(x,dt,T)
% PL66TN: pl66t for variable dt and T
% xf=PL66TN(x,dt,T) computes low-passed series xf from x
% using pl66 filter, with optional sample interval dt (hrs)
% and filter half amplitude period T (hrs) as input for
% non-hourly series.
%
% INPUT:  x=time series (must be column array)
%         dt=sample interval time [hrs] (Default dt=1)
%         T=filter half-amp period [hrs] (Default T=33)
%
% OUTPUT: xf=filtered series

% NOTE: both pl64 and pl66 have the same 33 hr filter
% half-amplitude period. pl66 includes additional filter weights
% upto and including the fourth zero crossing at 2*T hrs.

% The PL64 filter is described on p. 21, Rosenfeld (1983), WHOI
% Technical Report 85-35. Filter half amplitude period = 33 hrs.,
% half power period = 38 hrs. The time series x is folded over
% and cosine tapered at each end to return a filtered time series
% xf of the same length. Assumes length of x greater than 132.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 10/30/00
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% default to pl64
if (nargin==1); dt=1; T=33; end

cutoff=T/dt;
fq=1./cutoff;
nw=2*T./dt;
nw=round(nw);
%disp(['number of weights = ',int2str(nw)]);
nw2=2.*nw;

[npts,ncol]=size(x);
if (npts<ncol);x=x';[npts,ncol]=size(x);
end
xf=x;

% generate filter weights
j=1:nw;
t=pi.*j;
den=fq.*fq.*t.^3;
wts=(2.*sin(2.*fq.*t)-sin(fq.*t)-sin(3.*fq.*t))./den;
% make symmetric filter weights
wts=[wts(nw:-1:1),2.*fq,wts];
wts=wts./sum(wts);% normalize to exactly one
% plot(wts);grid;
% title(['pl64t filter weights for dt = ',num2str(dt),' and T = ',num2str(T)])
% xlabel(['number of weights = ',int2str(nw)]);pause;

% fold tapered time series on each end
cs=cos(t'./nw2);
jm=[nw:-1:1];

for ic=1:ncol
    % ['column #',num2str(ic)]
    jgd=find(~isnan(x(:,ic)));
    npts=length(jgd);
    if (npts>nw2)
        %detrend time series, then add trend back after filtering
        xdt=detrend(x(jgd,ic));
        trnd=x(jgd,ic)-xdt;
        y=[cs(jm).*xdt(jm);xdt;cs(j).*xdt(npts+1-j)];
        % filter
        yf=filter(wts,1.0,y);
        % strip off extra points
        xf(jgd,ic)=yf(nw2+1:npts+nw2);
        % add back trend
        xf(jgd,ic)=xf(jgd,ic)+trnd;
    else
        'warning time series is too short'
    end
end
end


