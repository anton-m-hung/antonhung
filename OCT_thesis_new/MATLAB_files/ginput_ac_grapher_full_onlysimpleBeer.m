function ac_grapher_full_onlysimpleBeer(whichModel,muSB,I,pxlLength,pxlWidth,murange,path,blockWidth,blockHeight)
%m is the data matrix
%colorbar          
%standard unscaled colorbar

f = figure();
clims = [0 murange];

[filepath,name] = fileparts(path);

t = tiledlayout(1,2,'Padding','compact');
title(t,strcat('Sample ID:',{' '},name),'FontWeight','Bold','Interpreter','none')
%%
nexttile(1)
dispfig1(I,pxlLength,pxlWidth);
axis image
ax = gca;
ax.FontSize = 10;

%%
nexttile(2)
% subplot('Position',[0.50 0.08 0.4 0.8])
imagesc(muSB,clims);
xlabel('Transverse length (mm)')
% ylabel('Depth [um]')

if isequal(whichModel,'simpleBeer')
    title('Simple Beer')
elseif isequal(whichModel,'modifiedBeer')
    title('Modified Beer')
end
    
h = colorbar;
ylabel(h, 'Attenuation Coefficient [mm^-^1]', 'Fontsize',18)

[numrow, numcol] = size(I);

org_xticks = [100 200 300 400 500];
org_yticks = [100 200 300 400 500 600 700 800 900 1000];

xticklabels(strsplit(num2str(round(org_xticks*pxlWidth,1))));
yticklabels(strsplit(num2str(round(org_yticks*pxlLength,1))));
%% 
%  prompt = {'Type in the file name:'};
%             dlgtitle = 'Image saver';
%             dims = [1 50];
%             userinput = inputdlg(prompt,dlgtitle,dims);
%             filename = userinput{1};

% path = fullfile(path{1},path{2});

%%
% implementing ability to select 2 points on the OCT image (left)
% these points indicate the corners of your "box" of interest
% MATLAB will output/save a csv containing the coordinates, and the
% attenuation coefficient inside the box

% The box will be drawn, the attenuation coefficient will be printed, and
% the new image will be saved as a png

% This while loop permits the box to be reselected if you misclicked or are
% not satisfied.
confirmed = 0;
while confirmed <= 0
    [x,y] = ginput(2);
    x1 = round(min(x));
    x2 = round(max(x));
    y1 = round(min(y));
    y2 = round(max(y));
    
    nexttile(1)
%     subplot('Position',[0.05 0.08 0.4 0.8])
    p1 = patch('Xdata',[x1,x2,x2,x1],'YData',[y1,y1,y2,y2],'FaceColor','red','FaceAlpha', 0.1,'EdgeColor','red', 'LineWidth', 1);

    x3 = round(x1/blockWidth);
    x4 = round(x2/blockWidth);
    y3 = round(y1/blockHeight);
    y4 = round(y2/blockHeight);
    
    nexttile(2)
%     subplot('Position',[0.50 0.08])
    p2 = patch('Xdata',[x3,x4,x4,x3],'YData',[y3,y3,y4,y4],'FaceColor','red','FaceAlpha', 0.1,'EdgeColor','red', 'LineWidth', 1);
%     p2 = patch('Xdata',[x1,x2,x2,x1],'YData',[y1,y1,y2,y2],'FaceColor','red','FaceAlpha', 0.1,'EdgeColor','red', 'LineWidth', 1);
    attenuation_coefficient = mean(muSB(y3:y4,x3:x4),'All');
%     attenuation_coefficient = mean(muSB(y1:y2,x1:x2),'All');
    legend(p2, strcat('Att. coef.', {' = '},num2str(attenuation_coefficient)),'Location','North')
    
    confirmed = menu('Is the selected area ok?','No','Yes')-1;
    
    if confirmed <= 0
        delete(p1);
        delete(p2);
    end
end

box_width = x2-x1;
box_height = y2-y1;

% saving the results (att. coef., coordinates, box size) as a row .csv.
% saved in a folder called "results"
results_table = table(attenuation_coefficient,x1,x2,y1,y2,box_width,box_height);
results_filename = strcat('results_',name, '.csv');
results_path = fullfile(filepath,'results');
mkdir(results_path);
writetable(results_table,fullfile(results_path,results_filename));

% saving the image in a folder called "images"
figure_path = fullfile(filepath,'images');
mkdir(figure_path);
saveas(f, fullfile(figure_path,name), 'png')

end

