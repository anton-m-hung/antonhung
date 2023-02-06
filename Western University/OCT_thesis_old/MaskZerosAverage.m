function [M,AverageI] = MaskZerosAverage(I, numzerosTop, numzerosBot, movAvgX, movAvgY)

%             prompt = {'Enter the approximate top region of data in 100um:',
%                 'Enter the approximate bottom region of data in 100um:',
%                 'Enter the number of columns to average (X):',
%                 'Enter the number of cells for moving Average (Y):',
%                 'Enter the maximum range of scattering coefficent 0-n:',
%                 'Enter filename for data storage:'};
%             dlgtitle = 'Define Mask region and Average resolution';
%             dims = [1 50];
%             userinput = inputdlg(prompt,dlgtitle,dims);
%             numzerosTop = str2double(userinput{1});
%             numzerosBot = str2double(userinput{2});
            
%             murange = str2double(userinput{5});
%             filename = userinput{6};

    AverageI = MovingAverageIntensity(I,movAvgX,movAvgY);
    
    numcol = size(AverageI,2);
    numrow  = size(AverageI,1);
    M=ones(numrow,numcol);
    
    for i = 1:numrow
        if i < numzerosTop
            M(i,:) = 0;
        elseif i > numzerosBot
            M(i,:) = 0
        end
    end
        
%     for j=1:numcol
%         for i = 1:numrow
% 
%             if i > numzerosBot 
%             M(i,j) = 0; 
%             end
%             if i < numzerosTop 
%             M(i,j) = 0; 
%             end          
%          end
%     end
%                  M(:,j)=mask2top(I(:,j),(1:row),numzerosTop);
%             end
%             for j= 1:column
%                  M(:,j)=mask2bot(I(:,j),(1:row),numzerosBot);
%             end
end

