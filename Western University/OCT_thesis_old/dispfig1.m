function dispfig1(I1,pxlLength)
%Function for displaying a full grayscale image I1
% figure;

% set(gcf,'Units','centimeters')%,'Position',[1 1 12 17])
imshow(I1, []);
% title('OCT B Scan')
axis on
fontSize=17;
ylabel('Depth [mm]','FontSize', fontSize)
xlabel('Lateral Length [mm]','FontSize', fontSize)
title('OCT Signal','FontSize', fontSize)

[numrow, numcol] = size(I1);

xticklabels(strsplit(num2str(round(xticks*pxlLength,1))));
yticklabels(strsplit(num2str(round(yticks*pxlLength,1))));


%title(sprintf('Exponential Regression (mu= %.3f [mm^-^1])', u))
% xlabel('X', 'FontSize', fontSize);
% ylabel('Y', 'FontSize', fontSize);
% legendHandle = legend('Real curve', 'Fitted Curve', 'Location', 'north');
% legendHandle.FontSize = 10;
end