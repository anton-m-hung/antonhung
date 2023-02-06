function [blockedI,blockedI_error] = beerMatrix(I, pxlLength_mm, numzerosTop, numzerosBot, blockWidth, blockHeight)

%     I = max(I,0);
    
    numcol = size(I,2);
    numrow  = size(I,1);

    % calculate how many columns and rows need to be added such that the
    % block size leaves no remainders
    numcolNan = blockWidth - mod(numcol,blockWidth);
    numrowNan = blockHeight - mod(numrow,blockHeight);

    if numcolNan == blockWidth
        numcolNan = 0;
    end
    if numrowNan == blockHeight
        numrowNan = 0;
    end

    I_nan_appended = I;

    % append columns of nans, increasing the matrix width
    if numcolNan ~= 0
        I_nan_appended(:,end+1:end+numcolNan) = nan;
        numcol = size(I_nan_appended,2);
    end

    % append rows of nans, increasing the matrix height
    if numrowNan ~= 0
        I_nan_appended(end+1:end+numrowNan,:) = nan;
        numrow = size(I_nan_appended,1);
    end

    % average every block across the x-direction
    averagedI = zeros(numrow,numcol/blockWidth);
    blockTmp = zeros(1,blockWidth);

    rowCounter = 1;
    colCounter = 1;

    for i = 1:numrow
        for j=1:numcol

            blockTmp(colCounter) = I_nan_appended(i,j);
            if mod(colCounter,blockWidth) == 0
                averagedI(i,j/blockWidth) = mean(blockTmp,'omitnan');
                colCounter = 1;
            else
                colCounter = colCounter + 1;
            end

        end
        if mod(rowCounter,blockHeight) == 0
            rowCounter = 1;
        else
            rowCounter = rowCounter + 1;
        end
    end

    % create a line of best fit through every blocked column vector

    numcol = numcol/blockWidth;
    blockedI = zeros(numrow/blockHeight,numcol);
    blockedI_error = zeros(numrow/blockHeight,numcol);
%     blockedI_error = zeros(numrow,numcol);

    blockAvgVector = zeros(1,blockHeight);
    x = linspace(1,blockHeight,blockHeight);
    x = x*pxlLength_mm;
    
%     averagedI = MovingAverageIntensity(averagedI,1,blockHeight);
    
    % iterate through columns
    for j=1:numcol
        % iterate through rows
        for i = 1:numrow
            blockAvgVector(rowCounter) = averagedI(i,j);

            if mod(rowCounter,blockHeight) == 0
                [pcoefs,S] = polyfit(x,blockAvgVector,1);
                pcoefs(1) = pcoefs(1)/(-40*log10(exp(1)));
                [y,std_error] = polyval(pcoefs,x,S);

                blockedI(i/blockHeight,j) = pcoefs(1);
                
%                 sumerror = sum((y - blockAvgVector).^2); % adding the sums of the squared differences of each point from its expected value
%                 meanerror = (sumerror/blockHeight); % dividing by number of datapoints, blockHeight.
%                 blockedI_error(i-blockHeight+1:i,j) = std_error';
                blockedI_error(i/blockHeight,j) = mean(std_error);
%                 blockedI_error(i/blockHeight,j) = meanerror;

                rowCounter = 1;
            else
                rowCounter = rowCounter + 1;
            end
        end
    end
%     params = strcat('blockHeight_',string(blockHeight),'_blockWidth_',string(blockWidth));
%     ac_grapher_full_onlysimpleBeer(blockedI,I,murange,{'/Users/anton/Desktop/McCord_MermutLab/project_code/datasets/Intralipids',params})
end  