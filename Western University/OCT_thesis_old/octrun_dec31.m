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
VerticalnumberPx = 0;
imageLength_mm = 0.00;
pxlLength_mm = 0.00; %pixel length conversion 
z = [];                  %Depth Vector (mm)(divide by 100 to um->mm )%Displays the clean image for referencing later on

n=1.353;                      %Index of refraction. Set to 1 to use it with the new rayleigh length of 1.1mm (I determined the 1.1 using n=1)
centerlambda =1310*10^-6;     %central wavelength in mm
zmax= 6.78;                   %maximum ranging depth in mm
n1=1;                         %index of refraction 
DELTAlambda=centerlambda^2/(4*n1*zmax); %DELTA lambda in mm
zr = 1000;                    %rayleigh length in microns 
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

% Attenuated image floating parameters
topLimit = 0;
bottomLimit = 1000; 
numcolforBlocking = 5;
numrowforBlocking = 5;
murange = 10;
attimage_filename = '';

attimage_params = [];
params_filepath = '';

mu_struct_logSimpleBeer = [];
mu_filepath = '';

%%
    OCTMENU=figure('Name', 'OCT - Main Menu', 'Position', [(scrsz(3)-1400)/2 (scrsz(4)-700)/2 1400 700],... 
                'menubar','none','numbertitle','off', 'Color','white', 'CloseRequestFcn',@QUIT_CALLBACK);
    
    movegui(OCTMENU, 'center');
    
    subplot(1,4,4);
    imagesc(0.7*(ones(1000, 500, 3)));   
    
    CURVE_FITTING=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
            [0.05 0.1 0.15 0.05],'String','Curve Fitting','HorizontalAlignment','Center',...
            'ForegroundColor',button_text,'Callback',@CURVE_FITTING_CALLBACK);

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
        
        subplot('Position', [0.75 0.05 0.2 0.9]);
        
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


%% GENERAL PARAMETERS (Necessary imput for all three models)


%% SIMPLE BEER LAMBERT LAW

% Attenuated image, alternative method - divide into blocks, regression
% line for each block

SIMPLEBEER_BUTTON=uicontrol('Style','PushButton','Units','Normalized','Position',...
        [0.25 0.1 0.15 0.05],'String','Generate Image','HorizontalAlignment','Center',...
        'FontName',headerFont,'FontSize',button_fontSize,'FontWeight',button_fontWt,...
        'ForegroundColor',button_text,'Callback',@SIMPLEBEER_CALLBACK);

SIMPLEBEER_HEADER=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.24 0.62 0.17 0.05],'String','Simple Beer','HorizontalAlignment',textAlignment,...
        'FontName',headerFont,'Fontsize',headerFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);    
SIMPLEBEER_INSTRUCTIONS=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.24 0.55 0.17 0.05],'String','Parameters:','HorizontalAlignment',textAlignment,...
        'FontName',headerFont,'Fontsize',textFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);    
    
SIMPLEBEER_text_TOP=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.24 0.55 0.15 0.025],'String','Top Region (mm):','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour);    
SIMPLEBEER_edit_TOP=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.38 0.55 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',topLimit,'ForegroundColor',textColour,'Callback',@TOP_CALLBACK);


SIMPLEBEER_text_BOTTOM=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.24 0.50 0.15 0.025],'String','Bottom Region (mm):','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour);
SIMPLEBEER_edit_BOTTOM=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.38 0.50 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',bottomLimit,'ForegroundColor',textColour,'Callback',@BOTTOM_CALLBACK);

    
SIMPLEBEER_text_BLOCKHEIGHT=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.24 0.45 0.15 0.025],'String','Block height (y):','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour);    
SIMPLEBEER_edit_BLOCKHEIGHT=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.38 0.45 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',numrowforBlocking,'ForegroundColor',textColour,'Callback',@BLOCKHEIGHT_CALLBACK);       


SIMPLEBEER_text_BLOCKWIDTH=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.24 0.40 0.15 0.025],'String','Block width (x):','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour); 
SIMPLEBEER_edit_BLOCKWIDTH=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.38 0.40 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',numcolforBlocking,'ForegroundColor',textColour,'Callback',@BLOCKWIDTH_CALLBACK);
 

SIMPLEBEER_text_FILENAME=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.24 0.35 0.1 0.025],'String','Save Filename:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour); 
SIMPLEBEER_edit_FILENAME=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.32 0.35 0.09 0.03],'HorizontalAlignment',textAlignment,...
        'FontName',textFont,'FontSize',textFontSize,'FontWeight',textWeight,...
        'String',attimage_filename,'ForegroundColor',textColour,'Callback',@FILENAME_CALLBACK);

    
% The following is for readability. Creates a box to outline the "section" for the 
% simple beer options in the UI.
subplot('Position', [0.225 0.075 0.2 0.6]);
axis off;
r = rectangle('Position', [0 0 1 1],...
    'FaceColor', patchColour,...
    'EdgeColor', [1 1 1],...
    'Curvature', [0.15 0.1]);

save_labels = {'Curve fitting',...
            'Att. image (masked)',...
            'Att. image (unmasked)'};

selectedToSave_array = [0 0 1];

savefiles_header=uicontrol('Style','text','Units','Normalized','Position',...
        [0.24 0.28 0.18 0.05],'String','Select files to save to your current folder:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour); 

for k=1:3; 
    cbh(k) = uicontrol('Style','checkbox','Units','Normalized','Position',...
        [0.25 0.28-(0.03*k) 0.15 0.025],'String',save_labels(k),...
        'Value',selectedToSave_array(k),'HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,...
        'BackgroundColor',patchColour,'Callback',{@save_checkbox_CALLBACK,k}); 
end

%% MODIFIED BEER LAMBERT

% NEW - parameters for zCF and zR
att_text_ZCF=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.65 0.15 0.025],'String','zCF:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour); 
att_edit_ZCF=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.58 0.65 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',zcf,'ForegroundColor',textColour,'Callback',@ZCF_CALLBACK);


att_text_ZR=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.60 0.15 0.025],'String','Rayleigh length:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour); 
att_edit_ZR=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.58 0.60 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',zr,'ForegroundColor',textColour,'Callback',@ZR_CALLBACK);

topLimit = 0;
bottomLimit = 1000; 
numcolforBlocking = 5;
numrowforBlocking = 5;
murange = 10;
attimage_filename = '';

attimage_params = [];
params_filepath = '';

mu_struct_logSimpleBeer = [];
mu_filepath = '';

ATTENUATED_IMAGE_BUTTON=uicontrol('Style','PushButton','Units','Normalized','Position',...
        [0.45 0.1 0.15 0.05],'String','Generate Image','HorizontalAlignment','Center',...
        'FontName',headerFont,'FontSize',button_fontSize,'FontWeight',button_fontWt,...
        'ForegroundColor',button_text,'Callback',@V2_ATTENUATED_IMAGE_CALLBACK);

ATTENUATED_IMAGE_HEADER=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.72 0.17 0.05],'String','Modified Beer','HorizontalAlignment',textAlignment,...
        'FontName',headerFont,'Fontsize',headerFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);    
ATTENUATED_IMAGE_INSTRUCTIONS=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.69 0.17 0.05],'String','Parameters:','HorizontalAlignment',textAlignment,...
        'FontName',headerFont,'Fontsize',textFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);    
    
att_text_TOP=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.55 0.15 0.025],'String','Top Region (mm):','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour);    
att_edit_TOP=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.58 0.55 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',topLimit,'ForegroundColor',textColour,'Callback',@TOP_CALLBACK);


att_text_BOTTOM=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.50 0.15 0.025],'String','Bottom Region (mm):','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour);
att_edit_BOTTOM=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.58 0.50 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',bottomLimit,'ForegroundColor',textColour,'Callback',@BOTTOM_CALLBACK);

    
att_text_BLOCKHEIGHT=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.45 0.15 0.025],'String','Block height (y):','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour);    
att_edit_BLOCKHEIGHT=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.58 0.45 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',numrowforBlocking,'ForegroundColor',textColour,'Callback',@BLOCKHEIGHT_CALLBACK);       


att_text_BLOCKWIDTH=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.40 0.15 0.025],'String','Block width (x):','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour); 
att_edit_BLOCKWIDTH=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.58 0.40 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',numcolforBlocking,'ForegroundColor',textColour,'Callback',@BLOCKWIDTH_CALLBACK);


att_text_FILENAME=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.35 0.1 0.025],'String','Save Filename:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour); 
att_edit_FILENAME=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.52 0.35 0.09 0.03],'HorizontalAlignment',textAlignment,...
        'FontName',textFont,'FontSize',textFontSize,'FontWeight',textWeight,...
        'String',attimage_filename,'ForegroundColor',textColour,'Callback',@FILENAME_CALLBACK);

    
% The following is for readability. Creates a box to outline the "section" for the 
% attenuated image options in the UI.
subplot('Position', [0.425 0.075 0.2 0.7]);
axis off;
r = rectangle('Position', [0 0 1 1],...
    'FaceColor', patchColour,...
    'EdgeColor', [1 1 1],...
    'Curvature', [0.15 0.1]);

save_labels = {'Curve fitting',...
            'Att. image (masked)',...
            'Att. image (unmasked)'};

selectedToSave_array = [0 0 1];

savefiles_header=uicontrol('Style','text','Units','Normalized','Position',...
        [0.44 0.28 0.18 0.05],'String','Select files to save to your current folder:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour); 

for k=1:3; 
    cbh(k) = uicontrol('Style','checkbox','Units','Normalized','Position',...
        [0.45 0.28-(0.03*k) 0.15 0.025],'String',save_labels(k),...
        'Value',selectedToSave_array(k),'HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,...
        'BackgroundColor',patchColour,'Callback',{@save_checkbox_CALLBACK,k}); 
end

%% CALLBACK FUNCTIONS

% The following are used in simple beer, modified beer
function TOP_CALLBACK(src,evt)
    topLimit = str2double(get(src,'string'))/pxlLength_mm;
end 
function BOTTOM_CALLBACK(src,evt)
    bottomLimit = str2double(get(src,'string'))/pxlLength_mm;
end 
function BLOCKHEIGHT_CALLBACK(src,evt)
    numrowforBlocking = str2double(get(src,'string'));
end 
function BLOCKWIDTH_CALLBACK(src,evt)
    numcolforBlocking = str2double(get(src,'string'));
end   
function FILENAME_CALLBACK(src,evt)
    attimage_filename = get(src,'String');
end    
function save_checkbox_CALLBACK(src,evt,checkboxID)
    enabled_disabled = get(src,'Value');
    selectedToSave_array(checkboxID) = enabled_disabled;
end

% the following are used in modified beer
function ZCF_CALLBACK(src,evt)
    zcf = str2double(get(src,'string'));
end
function ZR_CALLBACK(src,evt)
    zr = str2double(get(src,'string'));
end

%%
    function V2_ATTENUATED_IMAGE_CALLBACK(src,evt)
        % adding parameter information to the attimage_params structure
        % which will be saved as a .mat file when the user clicks "Generate
        % images"
        attimage_params.topLimit = topLimit;
        attimage_params.bottomLimit = bottomLimit;
        attimage_params.numcolforBlocking = numcolforBlocking;
        attimage_params.numrowforBlocking = numrowforBlocking;
        attimage_params.murange = murange;
        attimage_params.saveFilename = attimage_filename;

        if ~isempty(I1) 
            for i = 1:length(I1) % allow the ability to iterate through multiple datasets, if more than 1 are selected
                
%                 [M,AverageI] = MaskZerosAverage(I1{i},topLimit,bottomLimit,numrowforAveraging,numcolforAveraging); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% only change things in this box 
%                 I2 = M.*AverageI; % mask - everything outside the region of interest becomes zero 
%                 numcolumns = size(AverageI,2);
                [blockedI,standard_error] = MaskZerosBlocked(I1{i}, pxlLength_mm, topLimit, bottomLimit, numcolforBlocking, numrowforBlocking, murange);
                maxDepth = size(I1{i},1);
                numcolumns = size(I1{i},2);
                
                ds_filename = erase(char(selectedDatasets_names{i}),'.csv');
                attimage_filename_prefixed = strcat(ds_filename,'_',attimage_filename);
                attimage_params.saveFilename = attimage_filename_prefixed;
                % Anton - creating directories to save workspace and image data
                saveDirectory = fullfile(currDirectory, attimage_filename_prefixed);

                mkdir(saveDirectory)           

%     %            [mu_matrix_vermeer] = Vermeer_Attenuatedimage_map(I2,row,column2,pxlLength_mm);
%                 if selectedToSave_array(2)
%                     path = {saveDirectory, strcat(attimage_filename_prefixed,'_masked')};
% 
%                     [mu_matrix_logSimpleBeer] = logSimpleBeer_attenuatedImage(z,I2,numcolumns,pxlLength_mm,path);                
%                     ac_grapher_full_onlysimpleBeer(mu_matrix_logSimpleBeer,I2,murange,path);
%                     mu_struct_logSimpleBeer.mu_matrix_logSimpleBeer_masked = mu_matrix_logSimpleBeer;
%                 end
% 
                if selectedToSave_array(3)
                    path = {saveDirectory, strcat(attimage_filename_prefixed,'_unmasked')};

%                     [mu_matrix_logSimpleBeer] = logSimpleBeer_attenuatedImage(z,AverageI,numcolumns,pxlLength_mm,path);         
                    ac_grapher_full_onlysimpleBeer(blockedI,I1{i},pxlLength_mm,murange,path); 
                    mu_struct_logSimpleBeer.mu_matrix_logSimpleBeer_unmasked = blockedI;
                    mu_struct_logSimpleBeer.error_matrix_logSimpleBeer_unmasked = standard_error;
                end

                if selectedToSave_array(1)
                    I3 = mean(I1{i},2);
%                     I3 = (I1{i}(:,ceil(numcolumns/2)));

                    x = linspace(1,maxDepth,maxDepth)*pxlLength_mm;
                    figure(2);
                    plot(x,I3,'.b','LineWidth',2);

                    xlabel('Depth (mm)');
                    ylabel('Intensity');
                    
                    % set the y minimum to 0
                    yLim = get(gca,'ylim');
                    set(gca,'ylim', [0 yLim(2)]);
                    xlim([0 maxDepth*pxlLength_mm]);
                    
                    title(strcat('fittedCurve_',attimage_filename_prefixed),'Interpreter','none');

                    if selectedToSave_array(2) || selectedToSave_array(3)
                        hold on;
                        
                        %temporary fix for unit conversion

                        x = linspace(topLimit*pxlLength_mm,bottomLimit*pxlLength_mm,bottomLimit-topLimit+1);

                        AverageI_column = mean(blockedI,2);
                        AverageI_overall = mean(AverageI_column(ceil(topLimit/numrowforBlocking):floor(bottomLimit/numrowforBlocking)-1));
                        % This is the average attenuation coefficient for
                        % the data range within the top and bottom limit
                        
                        stdI = std(blockedI(ceil(topLimit/numrowforBlocking):floor(bottomLimit/numrowforBlocking),:),0,'all');
                        
                        mu_struct_logSimpleBeer.mean = AverageI_overall;
                        mu_struct_logSimpleBeer.std = stdI;
                        
%                         pcoefs1 = polyfit(x,AverageI_column(321:500),1);
% 
%                         regressionline1 = polyval(pcoefs1,x);
%                         multiplicationFactor = median(I3(321:500))/median(AverageI_column);
%                         regressionline2 = regressionline1 * multiplicationFactor;
%                         
%                         intensityPlot_max = max(I3(ceil(topLimit):ceil(bottomLimit)));
                        intensity_intercept = I3(ceil(topLimit));
%                         regressionline3 = AverageI_overall*(-40*log10(exp(1)))*(x - min(x)) + intensityPlot_max; %y = m(x-x1) +y1
                        regressionline3 = AverageI_overall/1.353*(-40*log10(exp(1)))*(x - topLimit*pxlLength_mm) + intensity_intercept; %y = m(x-x1) +y1

                        fittedCurve = plot(x,regressionline3,'Color',[1 0 0 0.5],'LineWidth',6);
                        hold off;

                        legend('Intensity decay curve', 'Fitted attenuation curve')
                        
                        curve_fitting_text = "Attenuation coefficient" + newline + "Mean: " + num2str(AverageI_overall) + newline + "std: " + num2str(stdI);
                        text(maxDepth*pxlLength_mm*0.6,max(I3)*0.85, curve_fitting_text, 'Fontweight', 'Bold', 'Fontsize', 14);
                        
                        path{2} = strcat('fittedCurve_',attimage_filename_prefixed);
                        path = fullfile(path{1},path{2});
                        saveas(figure(2),path, 'png');
% 
                    end 

                    
                end
            
            
%             saving 2 structures: 
%             one containing the scattering matrices,
%             one containing the parameters used for the calculations.
                mu_filepath = strcat(saveDirectory,'/mu_logSimpleBeer_',attimage_filename_prefixed);
                save(mu_filepath, '-struct', 'mu_struct_logSimpleBeer');

                params_filepath = strcat(saveDirectory, '/attenuated_image_params');
                save(params_filepath, '-struct', 'attimage_params');
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