function [x1,z1,current_profile_WHOI,current_profile_WHOI_East,current_profile_WHOI_North,time1]...
    =select_poi(sumOppSide,site_depth_at_deployment,adcpTime,adcpCurrentHor,adcpCurrentHorEast,...
    adcpCurrentHorNorth,pNoTide,adcpBinDepth)
handle(1);
[time1,y]=ginput(1);
x1 = sumOppSide(:,adcpTime>=time1); x1 = x1(:,1);
z1 = pNoTide(:,adcpTime>=time1); z1 = z1(:,1); %z1 = site_depth_at_deployment - z1; z1 = sort(z1,'ascend');

current1 = adcpCurrentHor(:,adcpTime>=time1); current1 = current1(:,1);
current_x = adcpCurrentHorEast(:,adcpTime>=time1); current_x = current_x(:,1);
current_y = adcpCurrentHorNorth(:,adcpTime>=time1); current_y = current_y(:,1);

adcpCurrentHor_interp = interp1(adcpBinDepth,current1,z1);
adcpCurrentHorEast_interp = interp1(adcpBinDepth,current_x,z1);
adcpCurrentHorNorth_interp = interp1(adcpBinDepth,current_y,z1);

%fill NaN with maximum current values in surface
a = isnan(adcpCurrentHor_interp); 
dum = adcpCurrentHor_interp; dum(a == 1)= max(adcpCurrentHor_interp);

a = isnan(adcpCurrentHor_interp); 
dum_x = adcpCurrentHor_interp; dum_x(a == 1)= max(adcpCurrentHor_interp);

a_y = isnan(adcpCurrentHorNorth_interp);
dum_y = adcpCurrentHorNorth_interp; dum_y(a_y == 1)= max(adcpCurrentHorNorth_interp);

current1 = sort(dum,'descend');
current_x = sort(dum_x,'descend');
current_y = sort(dum_y,'descend');

%profile_WHOI = sort([z1 current1],'ascend');
profile_WHOI = [z1 current1]; profile_WHOI = num2cell(profile_WHOI);
profile_WHOI_East = [z1 current_x]; profile_WHOI_East = num2cell(profile_WHOI_East);
profile_WHOI_North = [z1 current_y]; profile_WHOI_North = num2cell(profile_WHOI_North);

for i = 1:length(z1)
     current_profile_WHOI{i} = ['(' num2str(profile_WHOI{i,1}) ',' ...
         num2str(profile_WHOI{i,2}) ')'];
     current_profile_WHOI_East{i} = ['(' num2str(profile_WHOI_East{i,1}) ',' ...
         num2str(profile_WHOI_East{i,2}) ')'];
     current_profile_WHOI_North{i} = ['(' num2str(profile_WHOI_North{i,1}) ',' ...
         num2str(profile_WHOI_North{i,2}) ')'];
end
current_profile_WHOI = strjoin(current_profile_WHOI)
current_profile_WHOI_East = strjoin(current_profile_WHOI_East)
current_profile_WHOI_North = strjoin(current_profile_WHOI_North)
% [~,c] = size(pNoTide);
% for i = 1:c
% adcpCurrentHor_interp(:,i) = interp1(adcpBinDepth,current1,pNoTide(:,i));
% a = isnan(adcpCurrentHor_interp(:,i)); %fill NaN with maximum current values in surface
% dum = adcpCurrentHor_interp(:,i); 
% dum(a == 1)= max(adcpCurrentHor_interp(:,i));
% adcpCurrentHor_interp(:,i) = dum;
% end
end

