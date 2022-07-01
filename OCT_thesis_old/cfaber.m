function [u,x1,y1]=cfaber(x,y,range)
[x,y]=columnfilter(x,y);
a=x>=range(1);
b=x<=range(2);
in=a.*b;          %Range selector for the x interval
x=x.*in;
y(x==0)=[];
x(x==0)=[];
x1=x;
y1=log(y); %Linearization function
p=polyfit(x1,y1,1); %Fitter
u=[-p(1)/2, p(1), exp(p(2))]; %Coefficient array
y1=exp(p(2)).*exp(p(1).*x1);  %Fitted curve 
end
