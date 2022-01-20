function [X,yFitted,u,ue,r]=cf222f(X1,Y,beta,range,zcf,zr,n,centerlambda,zmax,resolution)
%Fits a nonlinear curve of the form Y=A*exp(-uX)*h(X)*f(X) where beta is an
%approximation of this exponent, h is the confocal function and f is the Sensitivity Rolloff function.
[X1,Y] = columnfilter(X1,Y);         %Makes any input a column vector
[X,Y]=rangecutter(X1,Y,range);       %Cuts x and y to the range specified in x, meaning only indices for some range in x [xinitial xfinal] will be counted for x and y 
DELTAlambda=centerlambda^2/(4*zmax); %DELTA lambda in mm

%beta0=[Y(find(abs(X-range(1))==min(abs(X-range(1))))) beta];   %Uses the
beta0=[0.01 beta];                        %Initial guesses for the amplitude-coefficient                         
%[amplitude    lamda]  %Reference array for best guess
modelfun = @(b,X)b(1)*exp(-b(2)*X).*(sinc(pi*X/(2*zmax)).^2).*exp(-(resolution*X*pi/(2*zmax*DELTAlambda)).^2/(2*log(2)))./((X-zcf).^2/(2*n*zr)^2+1); %Sample function

opts=statset('fitnlm');
opts.MaxIter=10000;
opts.TolFun=1e-9;
opts.TolX=1e-9;

mdl = fitnlm(X,Y, modelfun, beta0,'Options',opts);  %Function fitter

coefficients = mdl.Coefficients{:, 'Estimate'}; %Coefficient extractor
u=coefficients(2);                 %Extracting the exponent
yFitted = coefficients(1) *exp(-u*X).*(sinc(pi*X/(2*zmax)).^2).*exp(-(resolution*X*pi/(2*zmax*DELTAlambda)).^2/(2*log(2)))./((X-zcf).^2/(2*n*zr)^2+1);
ue=mdl.Coefficients{2,'SE'};        %Standard error with the u coefficient
r=mdl.Rsquared.Ordinary;            %Goodness of fit (Rsquared)