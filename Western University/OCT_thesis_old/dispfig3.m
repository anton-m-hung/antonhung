function dispfig3(z,mu)
%Function to display Scattering coefficient as a function of depth. where z
%is depth and mu is the coefficient from depth resolved methods. 
figure(3)
fontSize=15;  %Font size for title and axes markers
set(gcf,'Units','centimeters','Position',[19 16 20 10])   %Setting the position of figure 2. The position vector is in cm where [xposition  yposition   width   height]
plot(z,mu,'Linewidth',2.5);         %Plotting depth 'z' with coefficient vector 'mu'. Change Linewidth for the thickness of the plotting line
xlim([0 z(end)])                   %x-axis limiter, change according to your preferences     
ylim([0 4])                        %Y limiter, change acording to your preferences. Deffault at 6 (mm^-1) for scattering coefficient
set(gca,'XTick',[0:0.5:z(end)],'FontSize', fontSize)
xlabel('Depth [mm]','FontSize', fontSize)
ylabel('Scattering Coefficient [mm^-^1]','FontSize', fontSize)
title('Scattering Coefficient as a Function of Depth')
grid on
%title(sprintf('Exponential Regression (mu= %.3f [mm^-^1])', u))
% xlabel('X', 'FontSize', fontSize);
% ylabel('Y', 'FontSize', fontSize);
% legendHandle = legend('Real curve', 'Fitted Curve', 'Location', 'north');
% legendHandle.FontSize = 10;
end