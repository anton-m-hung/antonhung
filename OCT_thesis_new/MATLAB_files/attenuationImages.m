function attenuationImages(whichModel,...
                    I, blockedI,...
                    topLimit, bottomLimit,...
                    blockWidth, blockHeight,...
                    murange,...
                    attimage_filename,...
                    selectedDatasets_name,...
                    saveDirectory,...
                    checklist_selection,...
                    pxlLength_mm,...
                    pxlWidth_mm,...
                    n,...
                    columnVectorCoords)
%% 1.
%   [M,AverageI] = MaskZerosAverage(I1{i},topLimit,bottomLimit,numrowforAveraging,numcolforAveraging); 
%   I2 = M.*AverageI; % mask - everything outside the region of interest becomes zero 
    maxDepth = size(I,1);
    ds_filename = erase(char(selectedDatasets_name),'.csv');

    % the following is not really in-use currently
    attimage_filename_prefixed = strcat(ds_filename,'_',attimage_filename);

% If we selected for the unmasked image to be saved
    if checklist_selection(3)
        path = strcat(saveDirectory,'/', ds_filename);
        ginput_ac_grapher_full_onlysimpleBeer(whichModel,blockedI,I,pxlLength_mm,pxlWidth_mm,murange,path,blockWidth,blockHeight); 
        mu_struct.mu_matrix_logSimpleBeer_unmasked = blockedI;
    end
    
%% 2. The following code block has not been maintained since December 2021 (up-to-date code resumes in block 3.)
% If we selected for the masked image to be saved
    if checklist_selection(1)
        I3 = (I(:,columnVectorCoords));

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

        if checklist_selection(2) || checklist_selection(3)
            hold on;

            %temporary fix for unit conversion

            x = linspace(topLimit*pxlLength_mm,bottomLimit*pxlLength_mm,bottomLimit-topLimit+1);

            AverageI_column = blockedI(:,columnVectorCoords); %mean(blockedI,2);
            AverageI_overall = mean(AverageI_column(ceil(topLimit/blockHeight):floor(bottomLimit/blockHeight)-1),'omitnan');
            % This is the average attenuation coefficient for
            % the data range within the top and bottom limit

            stdI = std(blockedI(ceil(topLimit/blockHeight):floor(bottomLimit/blockHeight),:),0,'all','omitnan');

            mu_struct.mean = AverageI_overall;
            mu_struct.std = stdI;

%                         
%                         intensityPlot_max = max(I3(ceil(topLimit):ceil(bottomLimit)));
            intensity_intercept = I3(ceil(topLimit));
%                         regressionline3 = AverageI_overall*(-40*log10(exp(1)))*(x - min(x)) + intensityPlot_max; %y = m(x-x1) +y1

            if isequal(whichModel,'simpleBeer')
                regressionline3 = AverageI_overall/n*(-40*log10(exp(1)))*(x - topLimit*pxlLength_mm) + intensity_intercept; %y = m(x-x1) +y1
            elseif isequal(whichModel,'modifiedBeer')
                regressionline3 = AverageI_overall/n*(-40*log10(exp(1)))*(x - topLimit*pxlLength_mm) + intensity_intercept; %y = m(x-x1) +y1
            end

            fittedCurve = plot(x,regressionline3,'Color',[1 0 0 0.5],'LineWidth',6);
            hold off;

            legend('Intensity decay curve', 'Fitted attenuation curve')

            curve_fitting_text = "Attenuation coefficient" + newline + "Mean: " + num2str(AverageI_overall) + newline + "std: " + num2str(stdI);
            text(maxDepth*pxlLength_mm*0.6,max(I3)*0.85, curve_fitting_text, 'Fontweight', 'Bold', 'Fontsize', 14);

            path{2} = strcat('fittedCurve_',attimage_filename_prefixed);
            path = fullfile(path{1},path{2});
            saveas(figure(2),path, 'png');
        end 
    end
    
%% 3. Saving all the attenuation map matrices in a subfolder called "matrices". Saved as .mat files.
    matrix_filepath = fullfile(saveDirectory,'matrices');
    mkdir(matrix_filepath);
    matrix_filepath_filename = fullfile(matrix_filepath,strcat(whichModel,'_',ds_filename));
    save(matrix_filepath_filename, '-struct', 'mu_struct');
    
end

