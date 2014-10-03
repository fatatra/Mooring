function [site_depth_at_deployment,hcsm,cdm,vcsm,uecsm,uncsm,binDepth,date,pitch,roll]=adcpCurrent(adcpFile)
% %input: 
%     adcpFile= a string containing the name of an netCDF adcp file.
%     ex: IMOS_ANMN-QLD_AETVZ_20120818T080600Z_PIL200_FV01_PIL200-1208-Workhorse-ADCP-194_END-20130201T222400Z_C-20130424T062043Z.nc
% %output
%     hcsm= horizontal current speed matrice, one row per adcp bin, each correspond of the horizontal current speed.
%     cdm= current speed direction, direction of horizontale speed in degree
%     vcsm= vertical current speed matrice, one row per adcp bin, each correspond of the  upward current speed.
%     bindepth= bindepth in meter
%     date= number of days since 0000

%read time data
date    =   ncread(adcpFile, 'TIME') + datenum('1950-01-01 00:00:00');
date=date';

%read binDepth data
site_depth_at_deployment = ncreadatt(adcpFile,'/','instrument_nominal_depth');
binDepth    = site_depth_at_deployment  - ncread(adcpFile, 'HEIGHT_ABOVE_SENSOR');
%top to bottom
binDepth    =   flip(binDepth);

%read vcsm and Qc data
vcsm    =   ncread(adcpFile, 'WCUR');
vcsmQc  =   ncread(adcpFile, 'WCUR_quality_control');
vcsm(vcsmQc~=1) =   NaN;
vcsm    =   squeeze(vcsm);
vcsm    =   flip(vcsm);
%read uecsm and Qc data
uecsm    =   ncread(adcpFile, 'UCUR');
uecsmQc  =   ncread(adcpFile, 'UCUR_quality_control');
uecsm(uecsmQc~=1) =   NaN;
uecsm    =   squeeze(uecsm);
uecsm    =   flip(uecsm);
%read uncsm and Qc data
uncsm    =   ncread(adcpFile, 'VCUR');
uncsmQc  =   ncread(adcpFile, 'VCUR_quality_control');
uncsm(uncsmQc~=1) =   NaN;
uncsm    =   squeeze(uncsm);
uncsm    =   flip(uncsm);
% Construct a questdlg
choice = questdlg('Want current plot?', 'Dialog','Yes','No','Yes');
% Handle response
switch choice
    case 'Yes'
        figure;
        subplot(2,1,1);
        pcolor(date,binDepth,vcsm);
        shading interp; colorbar('location','southoutside'); colormap(jet); %caxis ([-2 2]);
        set(gca,'YDir','reverse');
        ylim([0 binDepth(end)+10]); xlabel('Date'); ylabel('Depth (m)'); title('Vertical current Speed (m/s)');
        setDate4zoom;
    case 'No'
        disp([choice ' worries.'])
end




%read hcsm and Qc data
hcsm    =   ncread(adcpFile, 'CSPD');
hcsmQc  =   ncread(adcpFile, 'CSPD_quality_control');
hcsm(hcsmQc~=1) =   NaN;
hcsm    =   squeeze(hcsm);
hcsm    =   flip(hcsm);
if strcmp(choice,'Yes')
        disp([choice ', coming right up!'])
        subplot(2,1,2);
        pcolor(date,binDepth,hcsm);
        shading interp; colorbar('location','southoutside'); %caxis ([-2 2]);
        set(gca,'YDir','reverse');
        ylim([0 binDepth(end)+10]); xlabel('Date'); ylabel('Depth (m)'); title('Horizontal current Speed (m/s)');
        setDate4zoom;
end


%read cdm and Qc data
cdm    =   ncread(adcpFile, 'CDIR');
cdmQc  =   ncread(adcpFile, 'CDIR_quality_control');
cdm(cdmQc~=1) =   NaN;
cdm    =   squeeze(cdm);
cdm    =   flip(cdm);
% if strcmp(choice,'Yes')
%     figure;
%     pcolor(date,binDepth,cdm);
%     shading interp; colorbar('location','southoutside'); colormap(hsv); %caxis ([-2 2]);
%     set(gca,'YDir','reverse');
%     ylim([0 binDepth(end)+10]); xlabel('Date'); ylabel('Depth (m)'); title('Current direction. Degrees clockwise from true North.');
%     setDate4zoom;
% end

%readPitchRoll
%read adcp pitch
pitch   =   ncread(adcpFile, 'PITCH');
pitch   =   squeeze(pitch);
%read adcp roll
roll    =   ncread(adcpFile, 'ROLL');
roll    =   squeeze(roll);
% Construct a questdlg
choice = questdlg('Want roll/pitch plot?', 'Dialog','Yes','No','Yes');
% Handle response
switch choice
    case 'Yes'
        figure;
        plot(date,pitch,date,roll);
        xlabel('Degres'); ylabel('Date'); title('Pitch and Roll.');
        setDate4zoom;
    case 'No'
        disp([choice ' worries.'])
end
clear choice;


end