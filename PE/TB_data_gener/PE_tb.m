clear;
weight_bit=8;
feature_bit=8;
weight=randi(2^weight_bit,[3,3,64])-2^(weight_bit-1)-1;
feature_map=randi(2^feature_bit,[10,10,64])-2^(feature_bit-1)-1;
result=zeros(8,8);

for x=1:8
    for y=1:8
        temp=weight.*feature_map(y:y+2,x:x+2,:);
        result(y,x)=sum(temp(:));
    end
end

write_hex_file( 'feature.txt',feature_map,2);
write_hex_file( 'weight.txt',weight,2);
write_hex_file( 'result.txt',result,2);
