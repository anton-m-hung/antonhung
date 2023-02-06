function [xnew,yFitted,u]=cf21(X,Y,beta,range)
[X,Y] = columnfilter(X,Y); %makes any input a column vector
in=find(X>=range(1));
in1=find(X<=range(2));
X=X(in(1):in1(end));
Y=Y(in(1):in1(end));
beta0=[Y(end) Y(find(abs(X-range(1))==min(abs(X-range(1))))) beta];
%[shift    amplitude    lamda]  %Reference array for best guess
tbl = table(X, Y); %Table must be vertical
modelfun = @(b,x) b(1) + b(2) * exp(-b(3)*x(:, 1)); %Sample function
mdl = fitnlm(tbl, modelfun, beta0);  %Function fitter
coefficients = mdl.Coefficients{:, 'Estimate'}; %Coefficient extractor
u=coefficients(3); %Extracting the exponent 
yFitted = coefficients(1) + coefficients(2) * exp(-coefficients(3)*X);
xnew=X;
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]); %Image full-size and bring to the front
% set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 
end