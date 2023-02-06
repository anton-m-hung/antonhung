function octrun

% Code for the extraction of the scattering coefficient. 
% cf222 is simple beer
% This code is specfically desgined to analyse data from the SANTEC OCT
% All calculations are done as microns and converted to mm at the end for display 
% This code only uses the simple beer law for comparison and torubleshooting 
    
% Declaring global variables
    
% for OCT image
currDirectory = pwd;
saveDirectory = pwd;
ds_filename = '';
workspace1 = '';

selectedDatasets = [];
ds_filenames = {};
selectedDatasets_names = {};


I1 = {};
I2 = {};
VerticalnumberPx = 0;
imageLength_mm = 6.78;
pxlLength_mm = 0.00678; %pixel length conversion 
% z = [];                  %Depth Vector (mm)(divide by 1000 to um->mm )%Displays the clean image for referencing later on

n=1.353;                      %Index of refraction. Set to 1 to use it with the new rayleigh length of 1.1mm (I determined the 1.1 using n=1)
centerlambda =1310*10^-6;     %central wavelength in mm
zmax= 6.78;                   %maximum ranging depth in mm
n1=1;                         %index of refraction 
DELTAlambda=centerlambda^2/(4*n1*zmax); %DELTA lambda in mm
zr = 0.960;                    %rayleigh length in microns 
z0 = 300;

hz = 0;
zcf = 0;

% Creating the UI
scrsz=get(0,'ScreenSize');
button_text = [0 0.4470 0.7410];
button_bkgnd = [0.9,0.9,0.9];
button_fontSize = 18;
button_fontWt = 'bold';

textFont = 'Menlo';
textFontSize = 12;
textAlignment = 'left';
textColour = [0 0 0];
textWeight = 'normal';

headerFontSize = 24;
headerFont = 'Avenir Condensed';
headerWeight = 'normal';

patchColour = [1.0 1.0 0.70];

checkboxFontsize = 10;
octImagePosition = [0.75 0.05 0.2 0.9];

% Attenuated image floating parameters
topLimit = 1;
bottomLimit = 1000; 
blockHeight = 5;
blockWidth = 5;
attimage_filename = '';
columnVectorCoords = 1;

murange = 10;
attimage_params = [];
params_filepath = '';

mu_struct_simpleBeer = [];
mu_struct_modifiedBeer = [];
mu_filepath = '';

%%
    OCTMENU=figure('Name', 'OCT - Main Menu', 'Position', [(scrsz(3)-1400)/2 (scrsz(4)-700)/2 1400 700],... 
                'menubar','none','numbertitle','off', 'Color','white', 'CloseRequestFcn',@QUIT_CALLBACK);
    
    movegui(OCTMENU, 'center');
    
    subplot(1,4,4);
    imagesc(0.7*(ones(1000, 500, 3)));   
    
%     CURVE_FITTING=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
%             [0.05 0.1 0.15 0.05],'String','Curve Fitting','HorizontalAlignment','Center',...
%             'ForegroundColor',button_text,'Callback',@CURVE_FITTING_CALLBACK);

%     DEPTH_RESOLVE=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
%             [0.25 0.1 0.15 0.05],'String','Depth Resolve','HorizontalAlignment','Center',...
%             'ForegroundColor',button_text,'Callback',@DEPTH_RESOLVE_CALLBACK);


%     QUIT_MENU=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
%             [0.1 0.3 0.15 0.05],'String','Quit','HorizontalAlignment','Center',...
%             'ForegroundColor',button_text,'Callback',@QUIT_CALLBACK);

    
    FILE_MENU=uimenu('Label','File');
    uimenu(FILE_MENU,'label','Open csv file','Callback',@OPEN_CSV_CALLBACK);
    uimenu(FILE_MENU,'label','Change save directory','separator','on','Callback',@SAVE_DIRECTORY_CALLBACK);
    
    DS_LISTBOX=uicontrol('Style','Listbox','enable','off','Units','Normalized','Position',...
    [0.05 0.77 0.22 0.15],'String',ds_filename,'HorizontalAlignment','Center','BackgroundColor','White',...
    'FontName',textFont,'FontSize',textFontSize,'min',1,'max',100,'Callback',@DS_LISTBOX_CALLBACK);    
    
    SET_WORKSPACE_BUTTON=uicontrol('Style','PushButton','enable','on','FontSize',10,'Units','Normalized','Position',...
    [0.05 0.73 0.1 0.034],'String','Change Dir','HorizontalAlignment','Left',...
    'foregroundcolor','blue','Callback',@SAVE_DIRECTORY_CALLBACK);

% Callback functions

    csvFileLabel=uicontrol('style','text','units','normalized','position',...
        [0.05 0.955 0.35 0.03],'String','OCT file:','HorizontalAlignment','left',...
        'FontName',textFont,'fontsize',textFontSize,'fontweight','bold','BackgroundColor','white');
    csvFileText=uicontrol('style','text','units','normalized','position',...
        [0.10 0.955 0.8 0.03],'String','No dataset selected','HorizontalAlignment','left',...
        'FontName',textFont,'fontsize',textFontSize,'BackgroundColor','white');

%%    
    function OPEN_CSV_CALLBACK(src, evt)
        [I0, path]=readCSVdata_original;           %reads folders and outputs the clean Bscan and the Bscan with an averaging filter (I1-original, I1-filtered)
    
        if ~isempty(I0)
            I1 = I0;
            set(csvFileText,'string',path);
        
            subplot(1,4,4);
            
            dispfig1(I1);   
            VerticalnumberPx = length(I1);
            imageLength_mm = 6.78;
            pxlLength_mm = imageLength_mm/VerticalnumberPx; %pixel length conversion 
            [row , column] = size(I1);
            z = (1:row);                  %Depth Vector (mm)(divide by 100 to um->mm )%Displays the clean image for referencing later on    
        
        else
            menu('No dataset was selected', 'Ok');
        end
    end
%%
    function DS_LISTBOX_CALLBACK(src, evt)
        selectedDatasets = get(src,'value');
        ds_idx = selectedDatasets(1);
        ds_filenames = get(src,'string');
        % selectedDatasets stores the indices relative to the listbox. 
        % selectedDatasets_idx will track the indices
        % relative to the selectedDatasets array
        selectedDatasets_idx = 1;
        I1 = {};
        
        % the following for loop enables the functionality of iterating
        % through all the selected datasets to generate images for each one
        for i = selectedDatasets
            ds_filename=char(ds_filenames(i,:));
            selectedDatasets_names{selectedDatasets_idx} = ds_filename;
            
            [I0, path] = readCSVdata(workspace1,ds_filename);           %reads folders and outputs the clean Bscan and the Bscan with an averaging filter (I1-original, I1-filtered)        
            
%             if ~isempty(I0)
            I1{selectedDatasets_idx} = I0;

                     %Depth Vector (mm)(divide by 100 to um->mm )%Displays the clean image for referencing later on    
            
            
            selectedDatasets_idx = selectedDatasets_idx + 1; 
%             else
%                 menu('No dataset was selected', 'Ok');
%             end
        
        end
        
        subplot('Position', octImagePosition);
        
%         I1{end} = max(I1{end},0);
        
        VerticalnumberPx = length(I1{end});
        imageLength_mm = 6.78;
        pxlLength_mm = imageLength_mm/VerticalnumberPx; %pixel length conversion 
        [row , column] = size(I1{end});
        z = (1:row);
        
        dispfig1(I1{end}, pxlLength_mm);   

        
        set(csvFileText,'string',path); 
        
    end

%%
    savePathLabel=uicontrol('style','text','units','normalized','position',...
        [0.05 0.93 0.35 0.03],'String','Current Folder:','HorizontalAlignment','left',...
        'FontName',textFont,'fontsize',textFontSize,'fontweight','bold','BackgroundColor','white');
    savePathText=uicontrol('style','text','units','normalized','position',...
        [0.13 0.93 0.4 0.03],'String',currDirectory,'HorizontalAlignment','left',...
        'FontName',textFont,'fontsize',textFontSize,'BackgroundColor','white');
    
    function SAVE_DIRECTORY_CALLBACK(src,evt)
        tempDirectory = uigetdir;
        if tempDirectory ~= 0
            savePath = tempDirectory;
            set(savePathText,'string',savePath);
            
            currDirectory = tempDirectory
        else
%             DS_LISTBOX=uicontrol('Style','Listbox','enable','off','Units','Normalized','Position',...
%                 [0.05 0.77 0.22 0.15],'String',ds_filename,'HorizontalAlignment','Center','BackgroundColor','White',...
%                 'FontName',textFont,'FontSize',textFontSize,'min',1,'max',1,'Callback',@DS_LISTBOX_CALLBACK);    
            return;
        end
        
        setWorkSpace(currDirectory);

        % changed - now set CWD when changing Dataset Directory
        cd(currDirectory)
        fprintf('setting current working directory to %s\n',currDirectory);
    end

%%
    function QUIT_CALLBACK(src,evt)   

           if size(get(0,'children'),1) > 1
               response = menu('Warning: Close all current windows?','Yes','No');
               if response == 1           
                   delete(OCTMENU);
                   close all
                   disp('exiting OCT...')
               else
                   delete(OCTMENU);
                   disp('exiting OCT...')
               end       
           else
               delete(OCTMENU);
               disp('exiting OCT...')
           end           
    end

%%
    function CURVE_FITTING_CALLBACK(src,evt)
        if ~isempty(I1) 
            Curvefittingfn(I1,z);
        
        else
            menu('No dataset was selected', 'Ok');
        end
    end

%%
    function DEPTH_RESOLVE_CALLBACK(src,evt)
        if ~isempty(I1) 
            Depthresolved_mu(I1,z,zr,z0);
        
        else
            menu('No dataset was selected', 'Ok');
        end
    end


%% GLOBAL PARAMETERS (Necessary imput for all three models)


headerPosition_gloParams = [0.05 1 0.17 0.05];
textPosition_gloParams = [0.05 1 0.17 0.025];
editPosition_gloParams = [0.25 1 0.03 0.025];

text_array = {'Top limit (mm):', 'Bottom limit (mm):', 'Block height (y):', 'Block width (x):', 'Total depth of image (mm):', 'Refractive index of tissue:'};
edit_array = [topLimit,bottomLimit,blockHeight,blockWidth,imageLength_mm,n];

HEADER_GLOBALPARAMETERS=uicontrol('Style','Text','Units','Normalized','Position',...
        [1 0.60 1 1].*headerPosition_gloParams,'String','Enter Paramaters:','HorizontalAlignment',textAlignment,...
        'FontName',headerFont,'Fontsize',headerFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);  

% creating the text descriptions for paramater inputs in the UI
for k=1:length(text_array)
    parameters_text(k) = uicontrol('Style','Text','Units','Normalized','Position',...
        [1.1 0.59-(0.04*k) 1 1].*textPosition_gloParams,'String',text_array(k),...
        'HorizontalAlignment',textAlignment,'FontName',textFont,...
        'Fontsize',textFontSize,'Fontweight',headerWeight,...
        'ForegroundColor',textColour,'BackgroundColor',patchColour);   
end
% creating the edit boxes for parameter inputs in the UI
for k=1:length(edit_array)
    parameters_text(k) = uicontrol('Style','Edit','Units','Normalized','Position',...
        [1 0.59-(0.04*k) 1 1].*editPosition_gloParams,'String',edit_array(k),...
        'HorizontalAlignment',textAlignment,'FontName',textFont,...
        'Fontsize',textFontSize,'Fontweight',headerWeight,...
        'ForegroundColor',textColour,'Callback',{@INPUTGLOPARAMS_CALLBACK,k});   
end
    
% INSTRUCTIONS_DATARANGE=uicontrol('Style','Text','Units','Normalized','Position',...
%         [1 0.555 1 2].*textPosition_gloParams,'String','Specify the top and bottom of your data range of interest:','HorizontalAlignment',textAlignment,...
%         'FontName',headerFont,'Fontsize',textFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);  
% 
% INSTRUCTIONS_BLOCKSIZE=uicontrol('Style','Text','Units','Normalized','Position',...
%         [1 0.435 1 1].*textPosition_gloParams,'String','Enter your block size for averaging:','HorizontalAlignment',textAlignment,...
%         'FontName',headerFont,'Fontsize',textFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);  


% The following are all related to how the results will be saved
INSTRUCTIONS_SAVEFILES=uicontrol('Style','Text','Units','Normalized','Position',...
        [1 0.27 1 2].*textPosition_gloParams,'String','Select files to save to your current folder:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour); 

save_labels = {'Curve fitting',...
            'Att. image (masked)',...
            'Att. image (unmasked)'};
% by default, only the unmasked image is selected
checklist_selection = [0 0 1];

for k=1:3
    cbh(k) = uicontrol('Style','checkbox','Units','Normalized','Position',...
        [1.1 0.27-(0.03*k) 1 1].*textPosition_gloParams,'String',save_labels(k),...
        'Value',checklist_selection(k),'HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,...
        'BackgroundColor',patchColour,'Callback',{@save_checkbox_CALLBACK,k}); 
end

text_FILENAME=uicontrol('Style','Text','Units','Normalized','Position',...
        [1 0.13 1 1].*textPosition_gloParams,'String','Save files as:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour); 
edit_FILENAME=uicontrol('Style','Edit','Units','Normalized','Position',...
        [1 0.10 1 1.2].*textPosition_gloParams,'HorizontalAlignment',textAlignment,...
        'FontName',textFont,'FontSize',textFontSize,'FontWeight',textWeight,...
        'String',attimage_filename,'ForegroundColor',textColour,'Callback',@FILENAME_CALLBACK);

% The following is for readability. Creates a box to outline the "section" for the 
% Global parameters section in the UI.
subplot('Position', [0.035 0.075 0.35 0.6]);
axis off;
r = rectangle('Position', [0 0 1 1],...
    'FaceColor', patchColour,...
    'EdgeColor', [1 1 1],...
    'Curvature', [0.15 0.1]);
    
%% SIMPLE BEER LAMBERT LAW

% Attenuated image, alternative method - divide into blocks, regression
% line for each block
ATTENUATED_IMAGE_BUTTON=uicontrol('Style','PushButton','Units','Normalized','Position',...
        [0.45 0.42 0.15 0.05],'String','Generate Image','HorizontalAlignment','Center',...
        'FontName',headerFont,'FontSize',button_fontSize,'FontWeight',button_fontWt,...
        'ForegroundColor',button_text,'Callback',@SIMPLEBEER_CALLBACK);

ATTENUATED_IMAGE_HEADER=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.64 0.17 0.05],'String','Simple Beer','HorizontalAlignment',textAlignment,...
        'FontName',headerFont,'Fontsize',headerFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);  

subplot('Position', [0.44 0.4 0.17 0.3]);
axis off;
r = rectangle('Position', [0 0 1 1],...
    'FaceColor', patchColour,...
    'EdgeColor', [1 1 1],...
    'Curvature', [0.15 0.1]);

%% MODIFIED BEER LAMBERT

% NEW - parameters for zCF and zR
att_text_ZCF=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.25 0.15 0.025],'String','zCF:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour); 
att_edit_ZCF=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.58 0.25 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',zcf,'ForegroundColor',textColour,'Callback',@ZCF_CALLBACK);

att_text_ZR=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.20 0.15 0.025],'String','Rayleigh length:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour); 
att_edit_ZR=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.58 0.20 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',zr,'ForegroundColor',textColour,'Callback',@ZR_CALLBACK);

ATTENUATED_IMAGE_BUTTON=uicontrol('Style','PushButton','Units','Normalized','Position',...
        [0.45 0.1 0.15 0.05],'String','Generate Image','HorizontalAlignment','Center',...
        'FontName',headerFont,'FontSize',button_fontSize,'FontWeight',button_fontWt,...
        'ForegroundColor',button_text,'Callback',@MODIFIEDBEER_CALLBACK);

ATTENUATED_IMAGE_HEADER=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.32 0.17 0.05],'String','Modified Beer','HorizontalAlignment',textAlignment,...
        'FontName',headerFont,'Fontsize',headerFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);    

% The following is for readability. Creates a box to outline the "section" for the 
% attenuated image options in the UI.
subplot('Position', [0.44 0.070 0.17 0.3]);
axis off;
r = rectangle('Position', [0 0 1 1],...
    'FaceColor', patchColour,...
    'EdgeColor', [1 1 1],...
    'Curvature', [0.15 0.1]);

%% CALLBACK FUNCTIONS

% The following are used in simple beer, modified beer
function INPUTGLOPARAMS_CALLBACK(src,evt,k)
    if k == 1
        topLimit = ceil(str2double(get(src,'string'))/pxlLength_mm)
        subplot('Position', octImagePosition);
        topRange = yline(topLimit,'Color','Red');

    elseif k == 2
        bottomLimit = floor(str2double(get(src,'string'))/pxlLength_mm)
        subplot('Position', octImagePosition);
        bottomRange = yline(bottomLimit,'Color','Red');
        
    elseif k == 3
        blockHeight = str2double(get(src,'string'))
    elseif k == 4
        blockWidth = str2double(get(src,'string'))
    end
end

function FILENAME_CALLBACK(src,evt)
    attimage_filename = get(src,'String');
end    
function save_checkbox_CALLBACK(src,evt,checkboxID)
    enabled_disabled = get(src,'Value');
    checklist_selection(checkboxID) = enabled_disabled;
end

% the following are used in modified beer
function ZCF_CALLBACK(src,evt)
    zcf = str2double(get(src,'string'));
end
function ZR_CALLBACK(src,evt)
    zr = str2double(get(src,'string'));
end

% callbacks to separate scripts (simple and modified beer)
function SIMPLEBEER_CALLBACK(src,evt)
    if ~isempty(I1)
        for i = 1:length(I1) % allow the ability to iterate through multiple datasets, if more than 1 are selected
            I2{i} = I1{i} * n; % multiplying by refractive index
            I2{i}(1:topLimit,:) = NaN; % masking top
            I2{i}(bottomLimit:length(I2{i}),:) = NaN; % masking bottom
            [blockedI,blockedI_error] = beerMatrix(I2{i}, pxlLength_mm, topLimit, bottomLimit, blockWidth, blockHeight);
            
            attenuationImages('simpleBeer',...
                            I1{i}, blockedI, blockedI_error,...
                            topLimit, bottomLimit,...
                            blockWidth, blockHeight,...
                            murange,...
                            attimage_filename,...
                            selectedDatasets_names{i},...
                            currDirectory,...
                            checklist_selection,...
                            pxlLength_mm,...
                            n,...
                            columnVectorCoords);
        end
    else
        menu('No dataset was selected', 'Ok');    
    end
end
function MODIFIEDBEER_CALLBACK(src,evt)
    if ~isempty(I1)
        for i = 1:length(I1) % allow the ability to iterate through multiple datasets, if more than 1 are selected

            % extra step: implementing hz
            for z = 1:length(I1{i})
                hz = 1/(((z - zcf)/zr)^2 + 1);
                I2{i}(z) = I1{1}(z) * n * hz;
            end
            I2{i}(1:topLimit,:) = NaN; % masking top
            I2{i}(bottomLimit:length(I2{i}),:) = NaN; % masking bottom
            [blockedI,blockedI_error] = beerMatrix(I2{i}, pxlLength_mm, topLimit, bottomLimit, blockWidth, blockHeight);
            attenuationImages('modifiedBeer',...
                            I1{i}, blockedI, blockedI_error,...
                            topLimit, bottomLimit,...
                            blockWidth, blockHeight,...
                            murange,...
                            attimage_filename,...
                            selectedDatasets_names{i},...
                            currDirectory,...
                            checklist_selection,...
                            pxlLength_mm,...
                            n,...
                            columnVectorCoords,...
                            hz);       
        end
    else
        menu('No dataset was selected', 'Ok');    
    end
end

%%
setWorkSpace(pwd);

function setWorkSpace(dataDir)
    
%     if isempty(dataDir)
%         return;
%     end

    workspace1=dataDir;

    % version 3.3 - rewrote to exclude Mac metadata files begining with ._
    Workspace=dir(workspace1);
    WorkSpace={Workspace.name};
    numfiles=size(WorkSpace,2);
    count=1;
    DSworkspace={};
    for k=1:numfiles
       s = WorkSpace(1,k);
       str = char(s);
       idx = strfind(str,'.csv');
       idx2 = strfind(str,'.');
       if ~isempty(idx)
           if idx2 ~= 1
               DSworkspace(1,count)={str};
               count = count+1;
           end
       end   
    end
   
    % seem to need to reset the controls each time ...
%     DS_LISTBOX=uicontrol('Style','Listbox','enable','off','Units','Normalized','Position',...
%         [0.1 0.77 0.32 0.15],'String',ds_filename,'HorizontalAlignment','Center','BackgroundColor',...
%         'White','min',1,'max',10000,'Callback',@DS_LISTBOX_CALLBACK);
    set(DS_LISTBOX,'enable','on','String',DSworkspace)

    tstr = sprintf('Data Directory: (%s%s)', workspace1, filesep);
end
end