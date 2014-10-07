function [sumOppSide]= mooringLineProfile(pNoTide, nominalSiteDepth)


%find hypotenuse, ie maxlength beetween each depth
%find adjSide, ie length beetween each depth
%find opposite side, ie horyzontal shift of single segment
adjSide=zeros(size(pNoTide));
oppSide=zeros(size(pNoTide));
hypSide=zeros(size(pNoTide,1),1);
for i=1:size(pNoTide,1)
    if i==size(pNoTide,1)
    adjSide(i,:)=   nominalSiteDepth - pNoTide(i,:);
    else
    adjSide(i,:)=   pNoTide(i+1,:)-pNoTide(i,:);
    end
    temp=sort(adjSide(i,:),'descend');
    hypSide(i)  =  temp(4);
    oppSide(i,:)=   hypSide(i)*sin(acos(adjSide(i,:)/hypSide(i)));
end

%find sum horyzontal shift segment for each sgment
sumOppSide=zeros(size(pNoTide));
sumOppSide(size(pNoTide,1),:)=oppSide(size(pNoTide,1),:);
for i=1:size(pNoTide,1)-1
    sumOppSide(size(pNoTide,1)-i,:)= sumOppSide(size(pNoTide,1)-(i-1),:)+ oppSide(size(pNoTide,1)-i,:);
end

%plot all moooring line profile
% Construct a questdlg
choice = questdlg('Want mooring line profile plot?', 'Dialog','Yes','No','Yes');
% Handle response
switch choice
    case 'Yes'
        figure
        subplot (1,4,1:3);
        plot(sumOppSide,pNoTide,'Marker','.','MarkerSize',15);
        daspect([1,1,1]);
        set(gca,'YDir','rev');
        ylabel('depth(M)');
        xlabel('shift(M)');
        title('Mooring line profile');
        
        %plot adjMonitoring
        subplot (1,4,4);
        %plot adj
        hAdj = plot(adjSide(:,1),'.b','MarkerSize',30);
        hold on
        plot(adjSide(:,2:end),'.b','MarkerSize',30);
        hHyp = plot(hypSide,'.r','MarkerSize',30);
        hold off
        ylabel('(M)')
        xlabel('Node (top to bottom)')
        title('adj monitoring')
        legend([hAdj hHyp],{'Adjacent sides', 'Hypothenuse'});


    case 'No'
        disp([choice ' worries.'])
end
clear choice;












