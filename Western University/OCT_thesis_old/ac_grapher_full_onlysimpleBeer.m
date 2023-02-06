function ac_grapher_full_onlysimpleBeer(muSB,I,pxlLength,murange,path)
%m is the data matrix
%colorbar          
%standard unscaled colorbar
figure(5)
clims = [0 murange];
sgtitle(path{2},'FontWeight','Bold','Interpreter','none');
%%
subplot('Position',[0.05 0.08 0.4 0.8])
% imshow(I,[]);
dispfig1(I,pxlLength);
axis image
xlabel('Transverse length')
ylabel('Depth (mm)')
title('OCT Image')
ax = gca;
ax.FontSize = 10;
%%
subplot('Position',[0.50 0.08 0.4 0.8])
imagesc(muSB,clims);
xlabel('Transverse length (mm)')
% ylabel('Depth [um]')
title('Log Simple Beer')
h = colorbar;
ylabel(h, 'Attenuation Coefficient [mm^-^1]', 'Fontsize',18)

[numrow, numcol] = size(I);

org_xticks = [100 200 300 400 500];
org_yticks = [100 200 300 400 500 600 700 800 900 1000];

xticklabels(strsplit(num2str(round(org_xticks*pxlLength,2))));
yticklabels(strsplit(num2str(round(org_yticks*pxlLength,2))));
%% 
%  prompt = {'Type in the file name:'};
%             dlgtitle = 'Image saver';
%             dims = [1 50];
%             userinput = inputdlg(prompt,dlgtitle,dims);
%             filename = userinput{1};

path = fullfile(path{1},path{2});

saveas(figure(5), path, 'png')

end

