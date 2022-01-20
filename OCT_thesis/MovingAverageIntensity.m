function [averageI] = MoveingAverageIntensity(I,numColForAverage,numRowForAverage)

%  DIM1 = 1; % dimension to average 2 implies column 
%  blockAverageI1 =  filter(ones(1,numRowsforAverage)/numRowsforAverage,1,I,[],DIM1);  
%  AverageI = blockAverageI1(numRowsforAverage:numRowsforAverage:end,:);
%  
%  DIM2 = 2; % dimension to average 2 implies column 
%  blockAverageI2 =  filter(ones(1,numColforAverage)/numColforAverage,1,I,[],DIM2);  
%  AverageI2 = blockAverageI2(:,numColforAverage:numColforAverage:end);

    numRows = size(I,1);
    numColumns = size(I,2);

    averageI = zeros([numRows numColumns]);
    
    % Moving window average in both dimenstions 
    for i = 1:numRows % iterate through 1:I_numrows
        averageI(i,:) = movmean(I(i,:),numColForAverage);
    end
    for j = 1:numColumns % iterate through 1:I_numcolumns
        averageI(:,j) = movmean(averageI(:,j),numRowForAverage);     
    end

end

