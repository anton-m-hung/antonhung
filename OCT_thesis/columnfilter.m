function [X,Y] = columnfilter(X,Y)
%This program just converts any vector input into a column vector.
    s1=size(X);
    s2=size(Y);                 
    if s1(2)>s1(1)
        X=X';
    end
    if s2(2)>s2(1)
        Y=Y';
    end
end