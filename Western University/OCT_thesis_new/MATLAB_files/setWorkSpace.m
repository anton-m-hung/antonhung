function setWorkSpace(DS_LISTBOX, dataDir)
    
    if isempty(dataDir)
        return;
    end

    workspace1=dataDir;

   %exclude Mac metadata files begining with ._
    Workspace=dir(workspace1);
    dirFlags = [Workspace.isdir];
    subFolders = Workspace(dirFlags);
    subFolderNames = {subFolders(3:end).name};
%     
%     numfiles=size(WorkSpace,2);
%     count=1;
%     DSworkspace={};
%     for k=1:numfiles
%        s = WorkSpace(1,k);
%        str = char(s);
% %        idx = strfind(str,'.csv');
% %        idx2 = strfind(str,'.');
% %        if ~isempty(idx)
% %            if idx2 ~= 1
% %                DSworkspace(1,count)={str};
% %                count = count+1;
% %            end
% %        end   
%     end
   
    % might need to reset the controls each time?...
%     DS_LISTBOX=uicontrol('Style','Listbox','enable','off','Units','Normalized','Position',...
%         [0.1 0.77 0.32 0.15],'String',ds_filename,'HorizontalAlignment','Center','BackgroundColor',...
%         'White','min',1,'max',10000,'Callback',@DS_LISTBOX_CALLBACK);
    set(DS_LISTBOX,'enable','on','String',subFolderNames)

    tstr = sprintf('Data Directory: (%s%s)', workspace1, filesep);