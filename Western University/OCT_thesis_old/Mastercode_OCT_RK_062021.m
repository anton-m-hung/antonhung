function Mastercode_OCT_RK_062021

% MasterCode
% Code for the extraction of the scattering coefficient. 
% cf222 is simple beer
% This code is specfically desgined to analyse data from the SANTEC OCT
% All calculations are done as microns and converted to mm at the end for display 
% This code only uses the simple beer law for comparison and torubleshooting 

% clear all;
% close all;
currDirectory = pwd;

[I1]=readCSVdata;            %reads folders and outputs the clean Bscan and the Bscan with an averaging filter (I1-original, I1-filtered)
dispfig1(I1)    
VerticalnumberPx = length(I1);
imageLength_mm = 6.78;
pxlLength_mm = imageLength_mm/VerticalnumberPx; %pixel length conversion 
[row , column] = size(I1);
z = (1:row);                  %Depth Vector (mm)(divide by 100 to um->mm )%Displays the clean image for referencing later on
n=1.353;                      %Index of refraction. Set to 1 to use it with the new rayleigh length of 1.1mm (I determined the 1.1 using n=1)
centerlambda =1310*10^-6;     %central wavelength in mm
zmax= 6.78;                   %maximum ranging depth in mm
n1=1;                         %index of refraction 
DELTAlambda=centerlambda^2/(4*n1*zmax); %DELTA lambda in mm
zr = 1000;                    %rayleigh length in microns 
z0 = 300;

%%

response=menu('Actions:','Curve Fitting','Depth Resolved','Attenuated Image/Map','Close');

while response ~= 0 || response ~= 4 
%     if response == 0
%         close all
%         break
%     end
    
    if response==1  %CURVE FITTING
        Curvefittingfn(I1,z);
        response=menu('Actions:','Continue','Exit'); 
        if response==2
            close all
            break
        end

    elseif response==2 %DEPTH RESOLVED
        Depthresolved_mu(I1,z,zr,z0);
        response=menu('Actions:','Continue','Exit'); 
        if response==2
            close all
            break
        end
        
    elseif response==3 %Attenuated Image/Map%
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
            
            
%     elseif response==4
%         close all
%         break     
            
    end
    
    close all;
    break;
end
