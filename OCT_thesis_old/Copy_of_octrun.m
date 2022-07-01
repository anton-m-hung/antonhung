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
    scrnsizes=get(0,'MonitorPosition');
    button_text = [0 0.4470 0.7410];
    button_bkgnd = [0.9,0.9,0.9];
    button_fontSize = 18;
    button_fontWt = 'bold';
    textFontSize = 12;

    OCTMENU=figure('Name', 'OCT - Main Menu', 'Units','normalized','Position',[0.4 0.4 0.25 0.30],... % D.C. decreased size a bit...
                'menubar','none','numbertitle','off', 'Color','white', 'CloseRequestFcn',@QUIT_CALLBACK);
    
    movegui(OCTMENU, 'center');
    
    
    CURVE_FITTING=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
            [0.1 0.50 0.8 0.14],'String','Curve Fitting','HorizontalAlignment','Center',...
            'ForegroundColor',button_text,'Callback',@CURVE_FITTING_CALLBACK);

    DEPTH_RESOLVE=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
            [0.1 0.35 0.8 0.14],'String','Depth Resolve','HorizontalAlignment','Center',...
            'ForegroundColor',button_text,'Callback',@DEPTH_RESOLVE_CALLBACK);

    ATTENUATED_IMAGE=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
            [0.1 0.20 0.8 0.14],'String','Attenuated Image','HorizontalAlignment','Center',...
            'ForegroundColor',button_text,'Callback',@ATTENUATED_IMAGE_CALLBACK);

    QUIT_MENU=uicontrol('Style','PushButton','FontSize',button_fontSize,'FontWeight',button_fontWt,'Units','Normalized','Position',...
            [0.1 0.05 0.8 0.14],'String','Quit','HorizontalAlignment','Center',...
            'ForegroundColor',button_text,'Callback',@QUIT_CALLBACK);

    FILE_MENU=uimenu('Label','File');
    uimenu(FILE_MENU,'label','Open csv file','Callback',@OPEN_CSV_CALLBACK);
    uimenu(FILE_MENU,'label','Change save directory','separator','on','Callback',@SAVE_DIRECTORY_CALLBACK);

% Callback functions

    csvFileLabel=uicontrol('style','text','units','normalized','position',[0.05 0.80 0.25 0.15],...
        'String','csv file:','HorizontalAlignment','left','fontsize',textFontSize,'fontweight','bold','BackgroundColor','white');
    csvFileText=uicontrol('style','text','units','normalized','position',[0.19 0.80 0.65 0.15],...
        'String','No dataset selected','HorizontalAlignment','left','fontsize',textFontSize,'BackgroundColor','white');

    function OPEN_CSV_CALLBACK(src, evt)
        [I1, path]=readCSVdata;           %reads folders and outputs the clean Bscan and the Bscan with an averaging filter (I1-original, I1-filtered)
        
        if ~isempty(I1) 
            set(csvFileText,'string',path);
        
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

    savePathLabel=uicontrol('style','text','units','normalized','position',[0.05 0.65 0.25 0.15],...
        'String','Save Directory:','HorizontalAlignment','left','fontsize',textFontSize,'fontweight','bold','BackgroundColor','white');
    savePathText=uicontrol('style','text','units','normalized','position',[0.31 0.65 0.65 0.15],...
        'String',saveDirectory,'HorizontalAlignment','left','fontsize',textFontSize,'BackgroundColor','white');
    
    function SAVE_DIRECTORY_CALLBACK(src,evt)
        saveDirectory = uigetdir;
        if saveDirectory ~= 0
            savePath = saveDirectory;
            set(savePathText,'string',savePath);
        end
    end


    function QUIT_CALLBACK(src,evt)   

           if size(get(0,'children'),1) > 1
               response = menu('Warning: Close all current windows?','Yes','No');
               if response == 1           
                   delete(OCTMENU);
                   close all
                   disp('exiting OCT...')
               end       
           else
               delete(OCTMENU);
               disp('exiting OCT...')
           end           
    end

    function CURVE_FITTING_CALLBACK(src,evt)
        Curvefittingfn(I1,z);
    end

    function DEPTH_RESOLVE_CALLBACK(src,evt)
        Depthresolved_mu(I1,z,zr,z0);
    end

    function ATTENUATED_IMAGE_CALLBACK(src,evt)
        [M,AverageI,murange,filename] = MaskZerosAverage(I1); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% only change things in this box 
        I2 = M.*AverageI; % mask - everything outside the region of interest becomes zero 
        figure(5)
        numcolumns = size(AverageI,2);

        % Anton - creating directories to save workspace and image data
        saveDirectory = fullfile(currDirectory, filename);
        path = {saveDirectory, filename};

        mkdir(saveDirectory);            

       % [mu_matrix_vermmer] = Vermeer_Attenuatedimage_map(I2,row,column2,pxlLength_mm);
        [mu_matrix_logSimpleBeer] = logSimpleBeer_attenuatedImage(z,I2,numcolumns,pxlLength_mm, path);
        %ac_grapher_full(mu_matrix_vermmer,mu_matrix_logSimpleBeer,I2,30) % mu range is the last number here adjust accordingly 
        ac_grapher_full_onlysimpleBeer(mu_matrix_logSimpleBeer,I1,murange, path);    
    end

end