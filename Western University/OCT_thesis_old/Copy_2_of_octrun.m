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
    
    I1 = [];
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

patchColour = [1.0 0.8 0.675];

checkboxFontsize = 10;


    OCTMENU=figure('Name', 'OCT - Main Menu', 'Position', [(scrsz(3)-1400)/2 (scrsz(4)-700)/2 1400 700],... % D.C. decreased size a bit...
                'menubar','none','numbertitle','off', 'Color','white', 'CloseRequestFcn',@QUIT_CALLBACK);
    
    movegui(OCTMENU, 'center');
    
    subplot(1,4,4);
    imagesc(0.7*(ones(1000, 500, 3)));   
    
    CURVE_FITTING=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
            [0.05 0.1 0.15 0.05],'String','Curve Fitting','HorizontalAlignment','Center',...
            'ForegroundColor',button_text,'Callback',@CURVE_FITTING_CALLBACK);

    DEPTH_RESOLVE=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
            [0.25 0.1 0.15 0.05],'String','Depth Resolve','HorizontalAlignment','Center',...
            'ForegroundColor',button_text,'Callback',@DEPTH_RESOLVE_CALLBACK);


%     QUIT_MENU=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
%             [0.1 0.3 0.15 0.05],'String','Quit','HorizontalAlignment','Center',...
%             'ForegroundColor',button_text,'Callback',@QUIT_CALLBACK);

    
    FILE_MENU=uimenu('Label','File');
    uimenu(FILE_MENU,'label','Open csv file','Callback',@OPEN_CSV_CALLBACK);
    uimenu(FILE_MENU,'label','Change save directory','separator','on','Callback',@SAVE_DIRECTORY_CALLBACK);
    
    DS_LISTBOX=uicontrol('Style','Listbox','enable','off','Units','Normalized','Position',...
    [0.05 0.77 0.22 0.15],'String',ds_filename,'HorizontalAlignment','Center','BackgroundColor','White',...
    'FontName',textFont,'FontSize',textFontSize,'min',1,'max',1,'Callback',@DS_LISTBOX_CALLBACK);    
    
    SET_WORKSPACE_BUTTON=uicontrol('Style','PushButton','enable','on','FontSize',10,'Units','Normalized','Position',...
    [0.05 0.73 0.1 0.034],'String','Change Dir','HorizontalAlignment','Left',...
    'foregroundcolor','blue','Callback',@SAVE_DIRECTORY_CALLBACK);

% Callback functions

    csvFileLabel=uicontrol('style','text','units','normalized','position',...
        [0.05 0.955 0.35 0.03],'String','OCT file:','HorizontalAlignment','left',...
        'FontName',textFont,'fontsize',textFontSize,'fontweight','bold','BackgroundColor','white');
    csvFileText=uicontrol('style','text','units','normalized','position',...
        [0.10 0.955 0.30 0.03],'String','No dataset selected','HorizontalAlignment','left',...
        'FontName',textFont,'fontsize',textFontSize,'BackgroundColor','white');

    
    function OPEN_CSV_CALLBACK(src, evt)
        [I0, path]=readCSVdata;           %reads folders and outputs the clean Bscan and the Bscan with an averaging filter (I1-original, I1-filtered)
        
      
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

    function DS_LISTBOX_CALLBACK(src, evt)
        selectedDatasets = get(src,'value');
        ds_idx = selectedDatasets(1);
        ds_filenames = get(src,'string');
        ds_filename=char(ds_filenames(ds_idx,:));
        [I0, path] = readCSVdata(workspace1,ds_filename);           %reads folders and outputs the clean Bscan and the Bscan with an averaging filter (I1-original, I1-filtered)        
      
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

    function CURVE_FITTING_CALLBACK(src,evt)
        if ~isempty(I1) 
            Curvefittingfn(I1,z);
        
        else
            menu('No dataset was selected', 'Ok');
        end
    end

    function DEPTH_RESOLVE_CALLBACK(src,evt)
        if ~isempty(I1) 
            Depthresolved_mu(I1,z,zr,z0);
        
        else
            menu('No dataset was selected', 'Ok');
        end
    end

%{
Attenuated Image
The following creates the UI interface for generating the Attenuated Image.
It creates the edit boxes used to input analysis parameters
- edit boxes with parameters
- button to generate plot
%}

topLimit = 0;
bottomLimit = 1000; 
numcolforAveraging = 10;
numrowforAveraging = 10;
murange = 10;
attimage_filename = '';

attimage_params = [];
params_filepath = '';

mu_struct_logSimpleBeer = [];
mu_filepath = '';

ATTENUATED_IMAGE_BUTTON=uicontrol('Style','PushButton','Units','Normalized','Position',...
        [0.45 0.1 0.15 0.05],'String','Generate Image','HorizontalAlignment','Center',...
        'FontName',headerFont,'FontSize',button_fontSize,'FontWeight',button_fontWt,...
        'ForegroundColor',button_text,'Callback',@ATTENUATED_IMAGE_CALLBACK);

ATTENUATED_IMAGE_HEADER=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.62 0.17 0.05],'String','Attenuated Image','HorizontalAlignment',textAlignment,...
        'FontName',headerFont,'Fontsize',headerFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);    
ATTENUATED_IMAGE_INSTRUCTIONS=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.55 0.17 0.05],'String','Parameters:','HorizontalAlignment',textAlignment,...
        'FontName',headerFont,'Fontsize',textFontSize,'Fontweight',headerWeight,'ForegroundColor',button_text,'BackgroundColor',patchColour);    
    
att_text_TOP=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.55 0.15 0.025],'String','Top Region (μm):','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour);    
att_edit_TOP=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.58 0.55 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',topLimit,'ForegroundColor',textColour,'Callback',@TOP_CALLBACK);
function TOP_CALLBACK(src,evt)
    topLimit = str2double(get(src,'string'))
end 

att_text_BOTTOM=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.50 0.15 0.025],'String','Bottom Region (μm):','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour);
att_edit_BOTTOM=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.58 0.50 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',bottomLimit,'ForegroundColor',textColour,'Callback',@BOTTOM_CALLBACK);
function BOTTOM_CALLBACK(src,evt)
    bottomLimit = str2double(get(src,'string'))
end 
    
att_text_COLUMNS=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.45 0.15 0.025],'String','# of columns to avg (x):','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour);    
att_edit_COLUMNS=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.58 0.45 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',numrowforAveraging,'ForegroundColor',textColour,'Callback',@avgCOLUMNS_CALLBACK);       
function avgCOLUMNS_CALLBACK(src,evt)
    numrowforAveraging = str2double(get(src,'string'))
end 

att_text_ROWS=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.40 0.15 0.025],'String','# of rows to avg (y):','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour); 
att_edit_ROWS=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.58 0.40 0.03 0.025],'HorizontalAlignment',textAlignment,...
        'FontSize',textFontSize,'FontWeight',button_fontWt,...
        'String',numcolforAveraging,'ForegroundColor',textColour,'Callback',@avgROWS_CALLBACK);
function avgROWS_CALLBACK(src,evt)
    numcolforAveraging = str2double(get(src,'string'))
end    

att_text_FILENAME=uicontrol('Style','Text','Units','Normalized','Position',...
        [0.44 0.35 0.1 0.025],'String','Save Filename:','HorizontalAlignment',textAlignment,...
        'FontName',textFont,'Fontsize',textFontSize,'Fontweight',textWeight,'BackgroundColor',patchColour); 
att_edit_FILENAME=uicontrol('Style','Edit','Units','Normalized','Position',...
        [0.520 0.35 0.09 0.03],'HorizontalAlignment',textAlignment,...
        'FontName',textFont,'FontSize',textFontSize,'FontWeight',textWeight,...
        'String',attimage_filename,'ForegroundColor',textColour,'Callback',@FILENAME_CALLBACK);
function FILENAME_CALLBACK(src,evt)
    attimage_filename = get(src,'String');
end    
    
% The following is for readability. Creates a box to outline the "section" for the 
% attenuated image options in the UI.
subplot('Position', [0.425 0.075 0.2 0.6]);
axis off;
r = rectangle('Position', [0 0 1 1],...
    'FaceColor', patchColour,...
    'EdgeColor', [1 1 1],...
    'Curvature', [0.15 0.1]);

%%%%% Give the user options to select what gets saved
% initialise astructure to hold 0 (don't save) or 1 (save) for the five following options:
% [OCT image, masked_image, unmasked_image, masked_mu, unmasked_mu]
% masked options enabled by default.

save_labels = {'OCT image',...
            'Att. image (masked)',...
            'Att. image (unmasked)'};
selectedToSave_array = [0 1 0];

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
function save_checkbox_CALLBACK(src,evt,checkboxID)
    enabled_disabled = get(src,'Value');
    selectedToSave_array(checkboxID) = enabled_disabled;
end
    
    function ATTENUATED_IMAGE_CALLBACK(src,evt)
        % adding parameter information to the attimage_params structure
        % which will be saved as a .mat file when the user clicks "Generate
        % images"
        attimage_params.topLimit = topLimit;
        attimage_params.bottomLimit = bottomLimit;
        attimage_params.numcolforAveraging = numcolforAveraging;
        attimage_params.numrowforAveraging = numrowforAveraging;
        attimage_params.murange = murange;
        attimage_params.saveFilename = attimage_filename;

        if ~isempty(I1) 
            [M,AverageI] = MaskZerosAverage(I1,topLimit,bottomLimit,numrowforAveraging,numcolforAveraging); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% only change things in this box 
            I2 = M.*AverageI; % mask - everything outside the region of interest becomes zero 
            numcolumns = size(AverageI,2);

            % Anton - creating directories to save workspace and image data
            saveDirectory = fullfile(currDirectory, attimage_filename);
            
            mkdir(saveDirectory)           

%            [mu_matrix_vermeer] = Vermeer_Attenuatedimage_map(I2,row,column2,pxlLength_mm);
            if selectedToSave_array(2)
                path = {saveDirectory, strcat(attimage_filename,'_masked')};

                [mu_matrix_logSimpleBeer] = logSimpleBeer_attenuatedImage(z,I2,numcolumns,pxlLength_mm,path);                
                ac_grapher_full_onlysimpleBeer(mu_matrix_logSimpleBeer,I2,murange,path);
                mu_struct_logSimpleBeer.mu_matrix_logSimpleBeer_masked = mu_matrix_logSimpleBeer;
            end
            
            if selectedToSave_array(3)
                path = {saveDirectory, strcat(attimage_filename,'_unmasked')};

                [mu_matrix_logSimpleBeer] = logSimpleBeer_attenuatedImage(z,AverageI,numcolumns,pxlLength_mm,path);         
                ac_grapher_full_onlysimpleBeer(mu_matrix_logSimpleBeer,AverageI,murange,path); 
                mu_struct_logSimpleBeer.mu_matrix_logSimpleBeer_unmasked = mu_matrix_logSimpleBeer;
            end
            
            if selectedToSave_array(1)
                I3 = mean(I1');
                x = linspace(1,1000,1000);
                figure(2);
                plot(x,I3,'-b','LineWidth',2);
                
                xlabel('Depth');
                ylabel('Intensity');
                title('Curve Fitting');
                
                if selectedToSave_array(2) || selectedToSave_array(3)
                    hold on;
                    
                    x = linspace(321,500,180);
                    
                    AverageI_column = mean(AverageI');
                    pcoefs1 = polyfit(x,AverageI_column(321:500),1);
                    
                    regressionline1 = polyval(pcoefs1,x);
                    fittedCurve = plot(x,regressionline1,'Color',[1 0 0 0.5],'LineWidth',6);
                    hold off;
                    
                    path{2} = strcat('fittedCurve_',attimage_filename);
                    path = fullfile(path{1},path{2});
                    saveas(figure(2),path, 'png')

                end 

                    
            end
            % saving 2 structures: 
            % one containing the scattering matrices,
            % one containing the parameters used for the calculations.
            mu_filepath = strcat(saveDirectory,'/mu_logSimpleBeer_',attimage_filename);
            save(mu_filepath, '-struct', 'mu_struct_logSimpleBeer');
            
            params_filepath = strcat(saveDirectory, '/attenuated_image_params');
            save(params_filepath, '-struct', 'attimage_params');
        else
            menu('No dataset was selected', 'Ok');
        end
    end

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