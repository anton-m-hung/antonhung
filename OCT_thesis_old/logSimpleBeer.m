function [logSimpleBeer_mu_vector] = LogSimpleBeer(z,I,pxlLength_mm)
    % Log Simple Beer takes x=oct depth and y=oct signal as input
    % Outputs mu=attenuation coefficient arrays and new x=depth array since
    % they're short one element from the original x and y.
    
    [z,I] = columnfilter(z,I); %makes any input a column vector
    
%     delta=1/(2*(x(2)-x(1)));  %Pixel length
    
    dim=length(I);
    logSimpleBeer_mu_vector=zeros(dim,1);
    
    % this is using 10log10 data need to double check this
    
    for i=2:length(I)-1
         logSimpleBeer_mu_vector(i) = (I(i)-(I(i-1)))./(-40*pxlLength_mm*log10(exp(1)));   
    % model can be edited on the right without approximation
    end
    
%     for i=2:5:length(I)-1
%          logSimpleBeer_mu_vector(i) = (I(i)-(I(i-1))/(-20*5*log10(exp(1))));   
%     % model can be edited on the right in px without approximation
%     end
    
    z(end)=[];    %Last element corrector for depth
%     Nz = 1;       % Number Of Zeros To Pad
    logSimpleBeer_mu_vector = [logSimpleBeer_mu_vector]; %zeros(Nz,1)]; 
end

