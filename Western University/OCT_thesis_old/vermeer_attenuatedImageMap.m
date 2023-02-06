function [mu_matrix_vermmer] = Vermeer_Attenuatedimage_map(I,row,column,pxlLength_mm)
 %figure(5)
%             M=zeros(size(I));
%             prompt = {'Enter the approximate top region of data in 100um:',
%                 'Enter the approximate bottom region of data in 100um:'};
%             dlgtitle = 'Define Mask region';
%             dims = [1 50];
%             userinput = inputdlg(prompt,dlgtitle,dims);
%             numzerosTop = str2double(userinput{1});
%             numzerosBot = str2double(userinput{2});
%             for j=1:column
%                  M(:,j)=mask2top(I(:,j),(1:row),0.09,numzerosTop);
%             end
%             for j=1:column
%                  M(:,j)=mask2bot(I(:,j),(1:row),numzerosBot);
%             end
            mu_matrix_vermmer =zeros(size(I));             
            for q=1:column
                [~,mu_matrix_vermmer(:,q)]=vermeer(pxlLength_mm,I(:,q));
            end
            %M(1:end-1,:);   
            %ac_grapher(M.*mu_matrix,I,8)
            save('Workspace_ScatteringMatrix_Vermmer')
           
end

