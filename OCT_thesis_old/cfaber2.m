function [u,x1,y1,mus,r]=cfaber2(x,y,range)
%Fits x,y to the model y=A*exp(mu*x). 
[x,y]=columnfilter(x,y);            %Makes all the vectors x,y column vectors
[x1,y]=rangecutter(x,y,range);      %Cuts x and y to the range specified in x, meaning only indices for some range in x [xinitial xfinal] will be counted for x and y 
lm=fitlm(x1,log(y));                %Linearlization and fitting model meaning log(y)=log(A)+mu*x whihc is linear and can be fitted nicely.
u=[-lm.Coefficients{2,'Estimate'}/2 lm.Coefficients{2,'Estimate'} lm.Coefficients{1,'Estimate'}]; %Coefficient table of the form: [-mu/2 mu Amplitude A]
y1=exp(u(3)).*exp(u(2).*x1);        %Fitted curve 
mus=lm.Coefficients{2,'SE'};        %Standard error with the mu coefficient
r=lm.Rsquared.Ordinary;             %Goodness of fit (Rsquared)
end
