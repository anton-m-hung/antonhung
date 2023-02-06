function dispfig2(z,I)
%Function to display OCT signal on figure 2, where z is depth and I is the
%OCT signal
figure(2);
clf;
fontSize=15;  %Font size for the title, scale, and markers
set(gcf,'Units','centimeters','Position',[19 13 20 13])  %Setting the position of figure 2. The position vector is in cm where [xposition  yposition   width   height]
plot(z,I,'Linewidth',2.5);        %Plotting depth and OCT singal. Linewidth is the thickness of the plot. Change +2.5 for thicker lines
xlim([0 z(end)])           %Limit on the horizontal (depth) OCT A-scan plot, change according to your preferences
set(gca,'XTick',[0:0.05:z(end)],'FontSize', fontSize)  %Markers for length and depth. change vectors for different makers like 0:1:5 or 0:0.25:5
xlabel('Depth [mm]','FontSize', fontSize)   %Depth subtitle
ylabel('OCT Measurement (AU)','FontSize', fontSize)  %Y-axis subtitle
title('OCT Signal')          %Title
grid on;
hold on;

%Legend handles, remove '%' for legends
% legendHandle = legend('Real curve', 'Fitted Curve', 'Location', 'north');
% legendHandle.FontSize = 10;
end