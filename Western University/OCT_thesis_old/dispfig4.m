function dispfig4(z,I)
figure(4)
clf
set(gcf,'Units','centimeters','Position',[19.5 1.3 10 16.7])
plot(I,z,'k','Linewidth',1.5); set ( gca, 'ydir','reverse' );
title('Average A-Scan')
axis on
fontSize=15;
ylim([0 z(end)])
xlim([0 max(I)+0.03])
set(gca,'XTick',[0:0.1:max(I)+0.03],'FontSize', fontSize)
set(gca,'XTickLabel',[0 1 2 3 4 5])
set(gca,'YTick',[0:0.5:z(end)],'FontSize', fontSize)
set(gca,'YTickLabel',[0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5])
ylabel('Depth [mm]','FontSize', fontSize)
xlabel('OCT Signal','FontSize', fontSize)
grid on
%title(sprintf('Exponential Regression (mu= %.3f [mm^-^1])', u))
% xlabel('X', 'FontSize', fontSize);
% ylabel('Y', 'FontSize', fontSize);
% legendHandle = legend('Real curve', 'Fitted Curve', 'Location', 'north');
% legendHandle.FontSize = 10;
end