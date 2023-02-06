function oct_mainmenu
%%% This function was created with the idea of enabling cutomizability with
%%% how your datasets are organized. Basically it lets the user select
%%% whether their .csv files are all found in the same folder, or if
%%% individual patients are separated into different folders.

%%% The idea was that depending on your selection, the rest of the scripts
%%% will process your datasets differently (octrun, attenuation images,
%%% etc.). However, I realized that it is likely the case that patients'
%%% files will always be in separate folders and this function will have
%%% little use.

%%% This function is complete for the most part, however, octrun,
%%% attenuation images, etc. have not been updated to accomodate this
%%% function, and it serves no use currently. May 3, 2022.

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
    
    
    OCT_MAINMENU=figure('Name', 'OCT - Main Menu', 'Position', [(scrsz(3)-300)/2 (scrsz(4)-500)/2 300 500],... 
                'menubar','none','numbertitle','off', 'Color','white', 'CloseRequestFcn',@QUIT_CALLBACK);
    
    movegui(OCT_MAINMENU, 'center');
    
    % Select this button if your oct files are organized in separate
    % folders (eg. patient tissues (three scans per tissue) were organized
    % in separate folders (P001, P002, etc.))
    ATTENUATED_IMAGE_BUTTON=uicontrol('Style','PushButton','Units','Normalized','Position',...
        [0.05 0.6 0.9 0.2],'String','Patient folders','HorizontalAlignment','Center',...
        'FontName',headerFont,'FontSize',button_fontSize,'FontWeight',button_fontWt,...
        'ForegroundColor',button_text,'Callback',@FOLDER_ORGANIZATION_CALLBACK);
    
    % Select this button if your oct files are simply individual csv files
    % all in the same folder.
    ATTENUATED_IMAGE_BUTTON=uicontrol('Style','PushButton','Units','Normalized','Position',...
        [0.05 0.3 0.9 0.2],'String','Individual csv files','HorizontalAlignment','Center',...
        'FontName',headerFont,'FontSize',button_fontSize,'FontWeight',button_fontWt,...
        'ForegroundColor',button_text,'Callback',@FILE_ORGANIZATION_CALLBACK);
    
    
    function FILE_ORGANIZATION_CALLBACK(src,evt)
        octrun('individualFiles')
    end

    function FOLDER_ORGANIZATION_CALLBACK(src,evt)
        octrun('folders')
    end
    
    function QUIT_CALLBACK(src,evt)   

           if size(get(0,'children'),1) > 1
               response = menu('Warning: Close all current windows?','Yes','No');
               if response == 1           
                   delete(OCT_MAINMENU);
                   close all
                   disp('exiting OCT...')
               else
                   delete(OCT_MAINMENU);
                   disp('exiting OCT...')
               end       
           else
               delete(OCT_MAINMENU);
               disp('exiting OCT...')
           end           
    end
end