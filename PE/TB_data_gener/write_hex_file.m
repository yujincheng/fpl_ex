function [ ] = write_hex_file( file_name,data,width)
%WRITE_HEX_FILE 此处显示有关此函数的摘要
%   此处显示详细说明

file=fopen(file_name,'w');
hex_data=dec2hex(mod(data+16^width,16^width),width);
fprintf(file,'%c',[hex_data,32*ones(length(hex_data),1)]');
fclose(file);

end

