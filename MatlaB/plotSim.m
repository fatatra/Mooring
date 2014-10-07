cd('whoiExperiment');
h1= figure; 
hold on
h2=figure;
hold on
for i=1:9
 str=strcat('simulation', num2str(i), 'Static3D.mat');
 load(str)
 figure(h1)
 plot3(x,y,z,'k')
 plot3(x,zeros(length(y),1),z,'r')
 plot3(zeros(length(x),1),y,z,'b')
 plot3([x(end) ; x(end); 0],[0;y(end);y(end)],[z(end);z(end);z(end)],'g');
 figure(h2)
 plot(sqrt(x.*x+y.*y),z)
end
load('xySamples.mat');
plot(xSamples,202-ySamples,'r');
hold off;
clear i h1 h2;