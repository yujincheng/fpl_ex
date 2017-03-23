function [ Y ] = winograd( kn,B,d,A )
%WINOGRAD 此处显示有关此函数的摘要
%   此处显示详细说明
    fe=B'*d*B;
    Y=A'*(kn.*fe)*A;

end

