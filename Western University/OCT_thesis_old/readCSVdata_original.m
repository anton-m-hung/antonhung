function [I0,path] = readCSVdata
[files,path] = uigetfile('*.csv');    %File selection
I0 = readtable(files);
% I0 = I0(12:999,:);
I0=table2array(I0);                   %table to array
% I1 =I0;
%----Resizing values (you end up with verticalxhorizontal matrix from the array)-------------------%
% vertical=678;                                     %vertical pixel size according to csv table (1 pixel per mm with vertical=678)        
% horizontal=1400;                                  %arbitraty horizontal size (adjust it accordingly, this is just horizontal pixel length)
% I1 = imresize(I0,[vertical horizontal]);          %resize to 6.78x5.00 mm image
% I1=I1-min(min(I1));                               %image adjustment to eliminate negative values from the image, could also do abs(I1). 
%                                                   %It's really just to avoid negative
                                                  %values from the graphs

end

