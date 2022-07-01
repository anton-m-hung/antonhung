function octrun

% Code for the extraction of the scattering coefficient. 
% This code is specfically desgined to analyse data from the SANTEC OCT
    
%% Declaring global variables - ANTON
% keeping track of directories and filenames
currDirectory = pwd; %directory where we are retrieving OCT data for input
saveDirectory = pwd; %directory where we are saving results of the analysis

ds_filename = '';
selectedDatasets = [];
ds_foldernames = {};
selectedDatasets_names = {};

attimage_filename = ''; % savename for the resulting images

% Initializing default image dimensions
numPxlVertical = 1000;
imageLength_mm = 6.78; % height of input OCT image in milimetres (floating)
pxlLength_mm = imageLength_mm/numPxlVertical; % pixel length conversion
numPxlHorizontal = 500;
imageWidth_mm = 5.00; % Width of input OCT image in milimetres (floating)
pxlWidth_mm = imageWidth_mm/numPxlHorizontal;

% initializing calculation parameters and data structures for storing OCT data
I1 = {};
I2 = {};

n=1.353;  %Index of refraction
zr = 0.239 ;  %rayleigh length in millimetres 
zcf = 3.4; % (millimetres) TBD experimentally

topLimit = 1; % top and bottom limit can be used for masking part of the image
bottomLimit = 1000; 
blockHeight = 5; % block height and block width specify the size of blocks used for averaging and fitting the data
blockWidth = 5;
columnVectorCoords = 1; % limited utility - used early on for plotting the data for a single column vector in intralipid images
murange = 20; % range of values on the colourbar for attenuation images

% Other variables - ROHITH
z = [];                  %Depth Vector (mm)(divide by 1000 to um->mm )%Displays the clean image for referencing later on
centerlambda =1310*10^-6;     %central wavelength in mm
zmax= 6.78;                   %maximum ranging depth in mm
n1=1;                         %Index of refraction. Set to 1 to use it with the new rayleigh length of 1.1mm (Rohith determined the 1.1 using n=1) 
DELTAlambda=centerlambda^2/(4*n1*zmax); %DELTA lambda in mm
z0 = 300;

% font size, colours, etc. for UI appearance - ANTON
scrsz=get(0,'ScreenSize');
button_text = [0 0 0.6];
button_bkgnd = [0.9,0.9,0.9];
button_fontSize = 18;
button_fontWt = 'bold';

textFont = 'Menlo';
textFontSize = 12;
textAlignment = 'left';
textColour = [0 0 0];
textWeight = 'normal';
editAlignment = 'right';

headerFontSize = 24;
headerFont = 'Avenir Condensed';
headerWeight = 'normal';

patchColour = [0.5 0.85 0.9];

octImagePosition = [0.75 0.05 0.2 0.9]; % this is the position in the UI corresponding with the image preview

%% Creating the UI - ANTON
% All "uicontrol" objects are created using approximately 3 lines of code
% You can see which uicontrol object corresponds to which feature/button by looking at the argument following "string". 
OCTMENU=figure('Name', 'OCT - Main Menu', 'Position', [(scrsz(3)-1400)/2 (scrsz(4)-700)/2 1400 700],... 
            'menubar','none','numbertitle','off', 'Color','white', 'CloseRequestFcn',@QUIT_CALLBACK);

movegui(OCTMENU, 'center');

% create placeholder for the OCT image preview (should look like a grey
% rectangle on the right-hand side)
subplot(1,4,4);
imagesc(0.7*(ones(1000, 500, 3)));   
    
% Create a listbox for multi-selection of datasets (ctrl-click)
    DS_LISTBOX=uicontrol('Style','Listbox','enable','off','Units','Normalized','Position',...
    [0.05 0.77 0.22 0.15],'String',ds_filename,'HorizontalAlignment','Center','BackgroundColor','White',...
    'FontName',textFont,'FontSize',textFontSize,'Max',10000, 'Callback',@DS_LISTBOX_CALLBACK);    

% workspace buttons
    SET_WORKSPACE_BUTTON=uicontrol('Style','PushButton','enable','on','FontSize',10,'Units','Normalized','Position',...
    [0.05 0.73 0.1 0.034],'String','Change Dir','HorizontalAlignment','Left',...
    'foregroundcolor','blue','Callback',@WORKSPACE_CALLBACK);
    
    SET_SAVE_LOCATION_BUTTON=uicontrol('Style','PushButton','enable','on','FontSize',10,'Units','Normalized','Position',...
    [0.15 0.73 0.1 0.034],'String','Set Save Location','HorizontalAlignment','Left',...
    'foregroundcolor','blue','Callback',@SAVE_LOCATION_CALLBACK);

% Visible text that indicates the current selected dataset
    csvFileLabel=uicontrol('style','text','units','normalized','position',...
        [0.05 0.955 0.35 0.03],'String','OCT file:','HorizontalAlignment','left',...
        'FontName',textFont,'fontsize',textFontSize,'fontweight','bold','BackgroundColor','white');
    csvFileText=uicontrol('style','text','units','normalized','position',...
        [0.10 0.955 0.8 0.03],'String','No dataset selected','HorizontalAlignment','left',...
        'FontName',textFont,'fontsize',textFontSize,'BackgroundColor','white');

% Visible text that indicates your current working directory and the
% specified save location directory
   currPathLabel=uicontrol('style','text','units','normalized','position',...
        [0.05 0.93 0.35 0.03],'String','Current Folder:','HorizontalAlignment','left',...
        'FontName',textFont,'fontsize',textFontSize,'fontweight','bold','BackgroundColor','white');
    currPathText=uicontrol('style','text','units','normalized','position',...
        [0.13 0.93 0.4 0.03],'String',currDirectory,'HorizontalAlignment','left',...
        'FontName',textFont,'fontsize',textFontSize,'BackgroundColor','white');
    savePathText=uicontrol('style','text','units','normalized','position',...
        [0.26 0.73 0.4 0.03],'String',saveDirectory,'HorizontalAlignment','left',...
        'FontName',textFont,'fontsize',textFontSize,'BackgroundColor','white');

% UNUSED features
%     CURVE_FITTING=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
%             [0.05 0.1 0.15 0.05],'String','Curve Fitting','HorizontalAlignment','Center',...
%             'ForegroundColor',button_text,'Callback',@CURVE_FITTING_CALLBACK);

%     DEPTH_RESOLVE=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
%             [0.25 0.1 0.15 0.05],'String','Depth Resolve','HorizontalAlignment','Center',...
%             'ForegroundColor',button_text,'Callback',@DEPTH_RESOLVE_CALLBACK);

%     QUIT_MENU=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
%             [0.1 0.3 0.15 0.05],'String','Quit','HorizontalAlignment','Center',...
%             'ForegroundColor',button_text,'Callback',@QUIT_CALLBACK);

%% This function is called whenever a new dataset in the Listbox is selected
% The end result of this is the cell array I1

% If file organization is in the form of nested directories with multiple
% .csv files inside every directory, then this function is producing a nested cell
% array, {{1_1.csv, 1_2.csv, 1_3.csv}, {2_1.csv, 2_2.csv, 2_3.csv},...{n_1.csv, n_2.csv, n_3.csv}}

% For every .csv file, we are storing the matrix of intensity data. In the
% above example, there are 3 intensity matrices per patient.

    function DS_LISTBOX_CALLBACK(src, evt)
        selectedDatasets = get(src,'value'); % selectedDatasets stores the indices of highlighted datasets in the listbox.
        ds_foldernames = get(src,'string'); % stores the filenames of all datasets in the listbox
        I1 = {}; % this cell array will eventually store the matrices of the highlighted datasets
        selectedDatasets_names = {}; % this cell array will eventually store filenames of just highlighted datasets
        
        % the following for-loop iterates through all the selected datasets
        for i = selectedDatasets
            ds_foldername=char(ds_foldernames(i,:));
            selectedDatasets_names{i} = ds_foldername;
            
            % Only extract information from .csv files
            curr_path = strcat(currDirectory,'/',ds_foldername);
            csv_files = dir(strcat(curr_path,'/*.csv')); % need to generalise to read any data type
            csv_filenames = {csv_files.name};
            
            % Extract all OCT images (matrices) from a single selected folder/patient
            I1_cell = {};
            for j = 1:length(csv_filenames)
                [I1_cell{j}, path] = readCSVdata(curr_path, csv_filenames{j}); 
            end
            I1{i} = I1_cell;            
        
        end
             
        numPxlVertical = size(I1{end}{end},1);
        pxlLength_mm = imageLength_mm/numPxlVertical;
        numPxlHorizontal = size(I1{end}{end},2);
        pxlWidth_mm = imageWidth_mm/numPxlHorizontal;
        
        [row , column] = size(I1{end}{end});
        z = (1:row);
                
        subplot('Position', octImagePosition);
        dispfig1(I1{end}{end}, pxlLength_mm, pxlWidth_mm);   
        
        set(csvFileText,'string',path); 
    end

%% Functions for changing your current working directory or your save location directory
% When "Change Dir" is clicked, you may change your current working directory
    function WORKSPACE_CALLBACK(src,evt)
        tempDirectory = uigetdir;
        
        if tempDirectory ~= 0
            currDirectory = tempDirectory;
            set(currPathText,'string',currDirectory);        
            setWorkSpace(DS_LISTBOX, currDirectory);
            cd(currDirectory);
            fprintf('setting current working directory to %s\n',currDirectory);
        end
    end

% When "Set Save Location" is clicked, you may change the location where results will be saved
    function SAVE_LOCATION_CALLBACK(src,evt)
        tempDirectory = uigetdir;
        
        if tempDirectory ~= 0
            saveDirectory = tempDirectory;
            set(savePathText,'string',saveDirectory);    
            fprintf('setting save location to %s\n',saveDirectory);
        end
    end

%% When you exit out of a window, you will be prompted to confirm whether you want to close all windows or not.
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

%% - UNUSED
    function CURVE_FITTING_CALLBACK(src,evt)
        if ~isempty(I1) 
            Curvefittingfn(I1,z);
        
        else
            menu('No dataset was selected', 'Ok');
        end
    end

%% - UNUSED
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
editPosition_gloParams = [0.23 1 0.05 0.025];

text_array = {'Top limit (mm):', 'Bottom limit (mm):', 'Block height (y pixels):', 'Block width (x pixels):', 'Total depth of image (mm):', 'Total width of image (mm):', 'Refractive index of tissue:', 'A-scan of interest (x-coord):', 'mu range:'};
edit_array = [topLimit*pxlLength_mm,bottomLimit*pxlLength_mm,blockHeight,blockWidth,imageLength_mm,imageWidth_mm,n,columnVectorCoords,murange];

HEADER_GLOBALPARAMETERS=uicontrol('Style','Text','Units','Normalized','Position',...
        [1 0.66 1 1].*headerPosition_gloParams,'String','Enter Paramaters:','HorizontalAlignment',textAlignment,...
        'FontName',headerFont,'Fontsize',headerFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);  

% creating the text descriptions for paramater inputs in the UI
for k=1:length(text_array)
    PARAMETERS_TEXT(k) = uicontrol('Style','Text','Units','Normalized','Position',...
        [1.1 0.68-(0.0375*k) 1 1].*textPosition_gloParams,'String',text_array(k),...
        'HorizontalAlignment',textAlignment,'FontName',textFont,...
        'Fontsize',textFontSize,'Fontweight',headerWeight,...
        'ForegroundColor',textColour,'BackgroundColor',patchColour);   
end
% creating the edit boxes for variable parameter inputs
for k=1:length(edit_array)
    PARAMETERS_EDIT(k) = uicontrol('Style','Edit','Units','Normalized','Position',...
        [1 0.68-(0.0375*k) 1 1].*editPosition_gloParams,'String',edit_array(k),...
        'HorizontalAlignment',editAlignment,'FontName',textFont,...
        'Fontsize',textFontSize,'Fontweight',headerWeight,...
        'ForegroundColor',textColour,'Callback',{@INPUTGLOPARAMS_CALLBACK,k});   
end

% The following are all related to how the results will be saved
INSTRUCTIONS_SAVEFILES=uicontrol('Style','Text','Units','Normalized','Position',...
        [1 0.27 1 2].*textPosition_gloParams,'String','Select files to save to your current folder:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour); 

save_labels = {'Fitted curve',...
            'Att. image (masked)',...
            'Att. image (unmasked)'};
% by default, only the unmasked image is selected
% Back in September/October 2021 when I was working with intralipid images, I had included an option to mask part of
% the image by zeroing everything above the top limit or below the bottom
% limit (both horizontal lines). There was also an option to save the intensity-decay curve. Both functionalities were no longer useful
% for me once I began working with non-uniform patient samples, so I did
% not continue to update it along with the rest of my additions in 2022. 

% As a result, it probably does not work anymore. All of my analysis could
% be completed with just leaving the default "unmasked" option selected.

checklist_selection = [0 0 1];

for k=1:3
    CHECKBOXES(k) = uicontrol('Style','checkbox','Units','Normalized','Position',...
        [1.1 0.27-(0.03*k) 1 1].*textPosition_gloParams,'String',save_labels(k),...
        'Value',checklist_selection(k),'HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,...
        'BackgroundColor',patchColour,'Callback',{@SAVE_CHECKBOX_CALLBACK,k}); 
end

% creates an edit box for the user to specify a save filename for saved results.
text_FILENAME=uicontrol('Style','Text','Units','Normalized','Position',...
        [1 0.13 1 1].*textPosition_gloParams,'String','Save files as:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour); 
edit_FILENAME=uicontrol('Style','Edit','Units','Normalized','Position',...
        [1 0.10 1.4 1.2].*textPosition_gloParams,'HorizontalAlignment',textAlignment,...
        'FontName',textFont,'FontSize',textFontSize,'FontWeight',textWeight,...
        'String',attimage_filename,'ForegroundColor',textColour,'Callback',@FILENAME_CALLBACK);

% The following is for readability. Creates a box to outline the "section" for the 
% Global parameters section in the UI.
subplot('Position', [0.035 0.075 0.27 0.64]);
axis off;
r = rectangle('Position', [0 0 1 1],...
    'FaceColor', patchColour,...
    'EdgeColor', [1 1 1]);
    
%% SIMPLE BEER LAMBERT LAW

% Attenuated image, alternative method - divide into blocks, regression
% line for each block
SIMPLEBEER_BUTTON=uicontrol('Style','PushButton','Units','Normalized','Position',...
        [0.33 0.445 0.15 0.05],'String','Generate Image','HorizontalAlignment','Center',...
        'FontName',headerFont,'FontSize',button_fontSize,'FontWeight',button_fontWt,...
        'ForegroundColor',button_text,'Callback',@SIMPLEBEER_CALLBACK);

SIMPLEBEER_HEADER=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.33 0.66 0.15 0.05],'String','Simple Beer','HorizontalAlignment','center',...
        'FontName',headerFont,'Fontsize',headerFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);  

subplot('Position', [0.32 0.415 0.17 0.3]);
axis off;
r = rectangle('Position', [0 0 1 1],...
    'FaceColor', patchColour,...
    'EdgeColor', [1 1 1]);

%% MODIFIED BEER LAMBERT

% NEW - parameters for zCF and zR
text_ZCF=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.33 0.25 0.15 0.025],'String','Confocal distance:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour); 
edit_ZCF=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.45 0.25 0.03 0.025],'HorizontalAlignment',editAlignment,...
        'FontSize',textFontSize,'FontWeight',headerWeight,...
        'String',zcf,'ForegroundColor',textColour,'Callback',@ZCF_CALLBACK);

text_ZR=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.33 0.20 0.15 0.025],'String','Rayleigh length:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour); 
edit_ZR=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.45 0.20 0.03 0.025],'HorizontalAlignment',editAlignment,...
        'FontSize',textFontSize,'FontWeight',headerWeight,...
        'String',zr,'ForegroundColor',textColour,'Callback',@ZR_CALLBACK);

MODIFIEDBEER_BUTTON=uicontrol('Style','PushButton','Units','Normalized','Position',...
        [0.33 0.1 0.15 0.05],'String','Generate Image','HorizontalAlignment','Center',...
        'FontName',headerFont,'FontSize',button_fontSize,'FontWeight',button_fontWt,...
        'ForegroundColor',button_text,'Callback',@MODIFIEDBEER_CALLBACK);

MODIFIEDBEER_HEADER=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.33 0.315 0.15 0.05],'String','Modified Beer','HorizontalAlignment','center',...
        'FontName',headerFont,'Fontsize',headerFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);    

% The following is for readability. Creates a box to outline the "section" for the 
% attenuated image options in the UI.
subplot('Position', [0.32 0.070 0.17 0.3]);
axis off;
r = rectangle('Position', [0 0 1 1],...
    'FaceColor', patchColour,...
    'EdgeColor', [1 1 1]);

%% CALLBACK FUNCTIONS

% The following are used in simple beer, modified beer
function INPUTGLOPARAMS_CALLBACK(src,evt,k)
    if k == 1
        topLimit = ceil(str2double(get(src,'string'))/pxlLength_mm);
        subplot('Position', octImagePosition);
        topRange = yline(topLimit,'Color','Red');

    elseif k == 2
        bottomLimit = floor(str2double(get(src,'string'))/pxlLength_mm);
        subplot('Position', octImagePosition);
        bottomRange = yline(bottomLimit,'Color','Red');
        
    elseif k == 3
        blockHeight = str2double(get(src,'string'));
    elseif k == 4
        blockWidth = str2double(get(src,'string'));
    elseif k == 5
        imageLength_mm = str2double(get(src,'string'));
    elseif k == 6
        imageWidth_mm = str2double(get(src,'string'));
    elseif k == 7
        n = str2double(get(src,'string'));
    elseif k == 8
        columnVectorCoords = str2double(get(src,'string'));
    elseif k == 9
        murange = str2double(get(src,'string'));
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

% callbacks to separate scripts (beermatrix and attenuationImages)
% Beermatrix performs the calculations for attenuation coefficients using either simple or modified beer (user selection)
% Attenuation images handles generating the attenuation maps, saving images, computing results, etc.
function SIMPLEBEER_CALLBACK(src,evt)
%     confirmed = 0;
%     confirmed = menu('Run Simple Beer with these settings?','No','Yes')-1;
%     if confirmed
        if ~isempty(I1)
            newDirectory = fullfile(saveDirectory, attimage_filename);
            mkdir(newDirectory)

            for i = 1:length(I1) % allow the ability to iterate through multiple datasets, if more than 1 are selected
                for j = 1:length(I1{i})
                    I2{i}{j} = I1{i}{j} * n; % multiplying by refractive index
        %             I2{i}(1:topLimit,:) = NaN; % masking top
        %             I2{i}(bottomLimit:length(I2{i}),:) = NaN; % masking bottom
                    [blockedI] = beerMatrix('simpleBeer', I2{i}{j}, pxlLength_mm, topLimit, bottomLimit, blockWidth, blockHeight,z,zcf,zr);

                    attenuationImages('simpleBeer',...
                        I1{i}{j}, blockedI,...
                        topLimit, bottomLimit,...
                        blockWidth, blockHeight,...
                        murange,...
                        attimage_filename,...
                        strcat(selectedDatasets_names{i},'_',num2str(j)),...
                        newDirectory,...
                        checklist_selection,...
                        pxlLength_mm,...
                        pxlWidth_mm,...
                        n,...
                        columnVectorCoords);
                end
            end
            attimage_params_filepath = fullfile(newDirectory, 'attimage_params.csv');
            attimage_params_table = table(blockWidth,blockHeight,imageLength_mm,imageWidth_mm,n,zr,zcf,murange);
            writetable(attimage_params_table,attimage_params_filepath);
            
        else
            menu('No dataset was selected', 'Ok');    
        end
%     end
end

function MODIFIEDBEER_CALLBACK(src,evt)
%     confirmed = 0;
%     confirmed = menu('Run Modified Beer with these settings?','No','Yes')-1;
%     if confirmed
        if ~isempty(I1)
            newDirectory = fullfile(saveDirectory, attimage_filename);
            mkdir(newDirectory)

            for i = 1:length(I1) % allow the ability to iterate through multiple datasets, if more than 1 are selected
                for j = 1:length(I1{i})
                    I2{i}{j} = I1{i}{j} * n; % multiplying by refractive index
    %                 I2{i}(1:topLimit,:) = NaN; % masking top
    %                 I2{i}(bottomLimit:length(I2{i}),:) = NaN; % masking bottom
                    blockedI = beerMatrix('modifiedBeer', I2{i}{j}, pxlLength_mm, topLimit, bottomLimit, blockWidth, blockHeight,z,zcf,zr);
                    attenuationImages('modifiedBeer',...
                                I1{i}{j}, blockedI,...
                                topLimit, bottomLimit,...
                                blockWidth, blockHeight,...
                                murange,...
                                attimage_filename,...
                                strcat(selectedDatasets_names{i},'_',num2str(j)),...
                                newDirectory,...
                                checklist_selection,...
                                pxlLength_mm,...
                                pxlWidth_mm,...
                                n,...
                                columnVectorCoords);
                end
            end
            attimage_params_filepath = fullfile(newDirectory, 'attimage_params.csv');
            attimage_params_table = table(blockWidth,blockHeight,imageLength_mm,imageWidth_mm,n,zr,zcf,murange);
            writetable(attimage_params_table,attimage_params_filepath);
            
        else
            menu('No dataset was selected', 'Ok');    
        end
%     end
end

%% This is needed to set the initial workspace. If omitted, the listbox will begin empty.
setWorkSpace(DS_LISTBOX, currDirectory);

end