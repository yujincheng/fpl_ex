function [ Y ] = winograd( kn,B,d,A )
%WINOGRAD �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    fe=B'*d*B;
    Y=A'*(kn.*fe)*A;

end

