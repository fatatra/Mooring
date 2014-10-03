% Compares two static solutions from WHOI-cable *.mat exported files

plot(x,z,'b')
hold on
plot(x1,202-z1,'k')
% [File.fname, File.fpath] = uigetfile('*.mat',...
%     'Select two *.mat files to compare, exported from WHOI-cable ','MultiSelect', 'on');
% 
% file = strcat(File.fpath,File.fname);
% 
% for i = 1:length(file)
%    fid(i,:) = load(file{i});
% end
% total_files = i;
% 
% color = {'b','k','r','g','m','c','y'};
% for i = 1:total_files
%     figure;
%     hold all
%     plot(fid(i).x,fid(i).z,'color',color{i});
%     hleg = cellstr(char(File.fname));
%     hleg = legend(hleg{:},'Location','SouthEast');
%     set(hleg,'Interpreter','none','Box', 'off');
% end
% 
% 
% hold on
% plot(x1,z1)
% hold off
% xlabel('Horizontal distance from anchor (m)');
% ylabel('Heigh above the bottom (m)');
% title('Static Models Comparison','fontsize',12);
% 

% figname = strcat('Static Compare','.jpg');                                                                                                                      
% print(gcf,figname,'-djpeg100','-r300');
