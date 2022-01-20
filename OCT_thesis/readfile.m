function [I0,I1]=readfile
%Function to read tif files, it outputs two double format images. I0 has an
%averaging filter applied while I0 doesn't and I0 is the 'original' image.
    [files,path1] = uigetfile('*.tif','Multiselect', 'on');
    if length(files)>1
    I0 = (imread(strcat(path1,'/',(files{1}))));
    sumImage = double(I0);
    for i=2:length(files)
        OCT_Image = imread(strcat(path1,'/',(files{i})));
        sumImage = sumImage +(double(OCT_Image));
    end
    I1 = sumImage/(length(files));
    elseif length(files)==1
    [files,path1] = uigetfile('*.tif');
    I0 = (imread(strcat(path1,'/',(files))));
    I1 = double(I0);
    end
I1=I1/65535; %Conversion factor
I0=I1;       %Setting an extra clear image aside for various reasons;
%Average filter below:
I2 = transpose(I1);
I3 = filter2(fspecial('average', 12),I2);
I1=transpose(I3);
end