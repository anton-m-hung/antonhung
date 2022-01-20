function [x, mu] = vermeer(x,y)
    % Vermeer method, takes x=oct depth and y=oct signal as input
    % Outpus mu=attenuation coefficient arrays and new x=depth array since
    % they're short one element from the original x and y.
    [x,y] = columnfilter(x,y); %makes any input a column vector
%     delta=1/(2*(x(2)-x(1)));  %Pixel length
    
    dim=length(y);
    mu=zeros(dim-1,1);

%      for i=1:dim-1
%          mu(i,1)=x*y(i)/(sum(y(i+1:end)));   %Integral or sum over I's (approximation)
%      end
    % For a more "precise" version, expect 1-0.1 ms delays for 7000~ elements
%      delta=x(2)-x(1);
    % this is using 10log10 data 
    
    for i=1:length(y)-1
        mu(i)= (5*log10(1+y(i)/(sum(y(i+1:end))))/x);   
    % model can be edited on the right without approximation
    end
    
    x(end)=[];    %Last element corrector for depth
    Nz = 1;       % Number Of Zeros To Pad
    mu = [mu; zeros(Nz,1)]; 
end
