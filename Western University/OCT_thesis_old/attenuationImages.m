function attenuationImages(whichModel,...
                            I, blockedI, I_error,...
                            topLimit, bottomLimit,...
                            blockWidth, blockHeight,...
                            murange,...
                            attimage_filename,...
                            selectedDatasets_name,...
                            currDirectory,...
                            checklist_selection,...
                            pxlLength_mm,...
                            n,...
                            columnVectorCoords,...
                            hz)
                        
        % adding parameter information to the attimage_params structure
        % which will be saved as a .mat file when the user clicks "Generate
        % images"
        attimage_params.topLimit = topLimit;
        attimage_params.bottomLimit = bottomLimit;
        attimage_params.numcolforBlocking = blockWidth;
        attimage_params.numrowforBlocking = blockHeight;
        attimage_params.murange = murange;
        attimage_params.saveFilename = attimage_filename;
                
%                 [M,AverageI] = MaskZerosAverage(I1{i},topLimit,bottomLimit,numrowforAveraging,numcolforAveraging); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% only change things in this box 
%                 I2 = M.*AverageI; % mask - everything outside the region of interest becomes zero 
%                 numcolumns = size(AverageI,2);
                maxDepth = size(I,1);
                numcolumns = size(I,2);
                
                ds_filename = erase(char(selectedDatasets_name),'.csv');
                attimage_filename_prefixed = strcat(ds_filename,'_',attimage_filename);
                attimage_params.saveFilename = attimage_filename_prefixed;
                % Anton - creating directories to save workspace and image data
                saveDirectory = fullfile(currDirectory, attimage_filename_prefixed);

                mkdir(saveDirectory)           

%     %            [mu_matrix_vermeer] = Vermeer_Attenuatedimage_map(I2,row,column2,pxlLength_mm);
%                 if selectedToSave_array(2)
%                     path = {saveDirectory, strcat(attimage_filename_prefixed,'_masked')};
% 
%                     [mu_matrix_logSimpleBeer] = logSimpleBeer_attenuatedImage(z,I2,numcolumns,pxlLength_mm,path);                
%                     ac_grapher_full_onlysimpleBeer(mu_matrix_logSimpleBeer,I2,murange,path);
%                     mu_struct_logSimpleBeer.mu_matrix_logSimpleBeer_masked = mu_matrix_logSimpleBeer;
%                 end
% 
                if checklist_selection(3)
                    path = {saveDirectory, strcat(attimage_filename_prefixed,'_unmasked')};

%                     [mu_matrix_logSimpleBeer] = logSimpleBeer_attenuatedImage(z,AverageI,numcolumns,pxlLength_mm,path);         
                    ac_grapher_full_onlysimpleBeer(blockedI,I,pxlLength_mm,murange,path); 
                    mu_struct_logSimpleBeer.mu_matrix_logSimpleBeer_unmasked = blockedI;
                    mu_struct_logSimpleBeer.error_matrix_logSimpleBeer_unmasked = I_error;
                end

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
                        
                        mu_struct_logSimpleBeer.mean = AverageI_overall;
                        mu_struct_logSimpleBeer.std = stdI;
                        
%                         
%                         intensityPlot_max = max(I3(ceil(topLimit):ceil(bottomLimit)));
                        intensity_intercept = I3(ceil(topLimit));
%                         regressionline3 = AverageI_overall*(-40*log10(exp(1)))*(x - min(x)) + intensityPlot_max; %y = m(x-x1) +y1
                        
                        if isequal(whichModel,'simpleBeer')
                            regressionline3 = AverageI_overall/n*(-40*log10(exp(1)))*(x - topLimit*pxlLength_mm) + intensity_intercept; %y = m(x-x1) +y1
                        elseif isequal(whichModel,'modifiedBeer')
                            regressionline3 = AverageI_overall/n/hz*(-40*log10(exp(1)))*(x - topLimit*pxlLength_mm) + intensity_intercept; %y = m(x-x1) +y1
                        end
                            
                        fittedCurve = plot(x,regressionline3,'Color',[1 0 0 0.5],'LineWidth',6);
                        hold off;

                        legend('Intensity decay curve', 'Fitted attenuation curve')
                        
                        curve_fitting_text = "Attenuation coefficient" + newline + "Mean: " + num2str(AverageI_overall) + newline + "std: " + num2str(stdI);
                        text(maxDepth*pxlLength_mm*0.6,max(I3)*0.85, curve_fitting_text, 'Fontweight', 'Bold', 'Fontsize', 14);
                        
                        path{2} = strcat('fittedCurve_',attimage_filename_prefixed);
                        path = fullfile(path{1},path{2});
                        saveas(figure(2),path, 'png');
% 
                    end 

                    
                end
            
            
%             saving 2 structures: 
%             one containing the scattering matrices,
%             one containing the parameters used for the calculations.
                mu_filepath = strcat(saveDirectory,'/mu_logSimpleBeer_',attimage_filename_prefixed);
                save(mu_filepath, '-struct', 'mu_struct_logSimpleBeer');

                params_filepath = strcat(saveDirectory, '/attenuated_image_params');
                save(params_filepath, '-struct', 'attimage_params');
            end
            
