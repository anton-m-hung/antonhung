function dispfig1(I1,pxlLength,pxlWidth)
%Function for displaying a full grayscale image I1

% set(gcf,'Units','centimeters')%,'Position',[1 1 12 17])
imshow(I1, []);

% uncomment these two for loops if you want to see gridlines
% for i = 1:20
%     % this allows you to end gridlines at a certain y-value, if desired
% %     line([i*25 i*25], [298 1000], 'Color', 'red', "linestyle", ":", 'linewidth', 1);
% 
%     x = xline(i*25, '-r', 'linewidth', 0.5);
%     x.Alpha = 0.7;
% end
%     
% for j = 1:50
%     y = yline(j*20, '-r', 'linewidth', 0.5);
%     y.Alpha = 0.7;
% end

% title('OCT B Scan')
axis on
fontSize=17;
ylabel('Depth [mm]','FontSize', fontSize)
xlabel('Lateral Length [mm]','FontSize', fontSize)
title('OCT Signal','FontSize', fontSize)

% [numrow, numcol] = size(I1);

xticklabels(strsplit(num2str(round(xticks*pxlWidth,1))));
yticklabels(strsplit(num2str(round(yticks*pxlLength,1))));


%title(sprintf('Exponential Regression (mu= %.3f [mm^-^1])', u))
% xlabel('X', 'FontSize', fontSize);
% ylabel('Y', 'FontSize', fontSize);
% legendHandle = legend('Real curve', 'Fitted Curve', 'Location', 'north');
% legendHandle.FontSize = 10;
end