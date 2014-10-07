%fin min adnn max shift with usable current data...
function [indexMatrice, current4whoi]=  createWhoiExperiment(adcpCurrentNorth,adcpCurrentEast,adcpCurrentVert,adcpPitch,adcpRoll,acdpBinDepth,sumOppSide,adcpTime,pNoTide)


%select adcpCurrentDir index with minimum nan in the colunm
soiIndex=find(...
    sum(isnan(adcpCurrentNorth))==min(sum(isnan(adcpCurrentNorth))) &...
    sum(isnan(adcpCurrentEast))==min(sum(isnan(adcpCurrentEast))) &...
	sum(isnan(adcpCurrentVert))==min(sum(isnan(adcpCurrentVert))) &...
    adcpPitch<20 &...
    adcpRoll<20 ...
);    

%find index of min and max shift
[minShiftValue,minShiftIndex]=min (sumOppSide(1,soiIndex),[],2);
minShiftIndex=soiIndex(minShiftIndex);
[maxShiftValue,maxShiftIndex]=max (sumOppSide(1,soiIndex),[],2);
maxShiftIndex=soiIndex(maxShiftIndex);
%find index of every shift in beetween min and max with a 5 meters
%increments
invervalNodeNumber=floor((maxShiftValue-minShiftValue)/5)+2;
indexMatrice=zeros(2,invervalNodeNumber);
indexMatrice(:,1)=[minShiftIndex;minShiftValue];
indexMatrice(:,end)=[maxShiftIndex;maxShiftValue];
for i=2:invervalNodeNumber-1
    val = minShiftValue+ (i-1)*5; %value to find
    tmp = abs(sumOppSide(1,soiIndex)-val);
    [~, idx] = min(tmp); %index of closest value
    indexMatrice(:,i) = [soiIndex(idx); sumOppSide(1,soiIndex(idx))]; %closest value
end


% figure
% plot(adcpTime',pNoTide','b');
% hold on;
% set(gca,'YDir','rev');
% plot(adcpTime(:,indexMatrice(1,:))',pNoTide(:,indexMatrice(1,:))','.r');

current4whoi=cell(2,invervalNodeNumber);
for i=1:invervalNodeNumber
xCurrent = 'x-current = ';
for j=1: length(acdpBinDepth) 
    if ~isnan(adcpCurrentEast(j,indexMatrice(1,i)))
        xCurrent = strcat(xCurrent, '(', num2str(acdpBinDepth(j)), ',', num2str(adcpCurrentEast(j,indexMatrice(1,i))), ')' );
    end
end
xCurrent = strcat(xCurrent,'(202,0)');
current4whoi{1,i}=xCurrent;
yCurrent = 'y-current = ';
for j=1: length(acdpBinDepth)
    if ~isnan(adcpCurrentNorth(j,indexMatrice(1,i)))
        yCurrent = strcat(yCurrent, '(', num2str(acdpBinDepth(j)), ',', num2str(adcpCurrentNorth(j,indexMatrice(1,i))), ')' );
    end
end
yCurrent = strcat(yCurrent,'(202,0)');
current4whoi{2,i}=yCurrent;
end



whoiTemplateId = fopen('whoiTemplate.cab');
A = fread(whoiTemplateId,'*char')';
fclose(whoiTemplateId);

mkdir('whoiExperiment')
cd('whoiExperiment')
for i=1:invervalNodeNumber
AA = strrep(A, '/*MATLAB REPLACE CURRENT DATA HERE*/', strcat(current4whoi{1,i},current4whoi{2,i}));
FID = fopen( strcat('simulation', num2str(i), '.cab'), 'w' );
fwrite(FID, AA, 'uchar');
fclose(FID);
end
xSamples=sumOppSide(:,indexMatrice(1,:));
ySamples=pNoTide(:,indexMatrice(1,:));
save('xySamples','xSamples','ySamples');

cd('..')



