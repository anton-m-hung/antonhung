function [mu_matrix_logSimpleBeer] = logSimpleBeer_attenuatedImage(z,I,numcolumns,pxlLength_mm,path)
    
    mu_matrix_logSimpleBeer =zeros(size(I));    
    
    for q=1:numcolumns
        [mu_matrix_logSimpleBeer(:,q)] = logSimpleBeer(z,I(:,q),pxlLength_mm); % data is connverted from px to mm 
    end
    
    % - Anton
%     name = strcat(string(path{2}),'_Workspace_ScatteringMatrix_LogSimpleBeer');
%     
%     path = fullfile(path{1},name);
%     save(path);
end

