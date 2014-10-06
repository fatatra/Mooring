
function [minShiftIndex,maxShiftIndex]=  minMaxShiftIndex(adcpCurrentNorth,adcpCurrentEast,adcpCurrentVert,adcpPitch,adcpRoll,sumOppSide)


%select adcpCurrentDir index with minimum nan in the colunm
soiIndex=find(...
    sum(isnan(adcpCurrentNorth))==min(sum(isnan(adcpCurrentNorth))) &...
    sum(isnan(adcpCurrentEast))==min(sum(isnan(adcpCurrentEast))) &...
	sum(isnan(adcpCurrentVert))==min(sum(isnan(adcpCurrentVert))) &...
    adcpPitch<20 &...
    adcpRoll<20 ...
);    


[~,minShiftIndex]=min (sumOppSide(1,soiIndex),[],2);
minShiftIndex=soiIndex(minShiftIndex);
[~,maxShiftIndex]=max (sumOppSide(1,soiIndex),[],2);
maxShiftIndex=soiIndex(maxShiftIndex);


