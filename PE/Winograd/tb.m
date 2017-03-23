clear;
weight_bit=8;
feature_bit=8;
mesh_x=4;
mesh_y=4;
mesh_n=16;


weight=randi(2^weight_bit,[3,3,mesh_n])-2^(weight_bit-1)-1;
feature_map=randi(2^feature_bit,[mesh_y,mesh_x,mesh_n])-2^(feature_bit-1)-1;

B=[1,0,0,0;0,1,-1,1;-1,1,1,0;0,0,0,-1];
G=2*[1,0,0;1/2,1/2,1/2;1/2,-1/2,1/2;0,0,1];
A=[1,0;1,1;1,-1;0,-1];
wino_tb=[0,0;0,0];
wino=wino_tb;
for i=1:mesh_n
    g=weight(:,:,i);
    d=feature_map(:,:,i);
    kn(:,:,i)=G*g*G';
    wino_temp(:,:,i)=winograd(kn(:,:,i),B,d,A)/4;
    wino=wino+wino_temp(:,:,i);
    wino_tb_temp(:,:,i)=xcorr2(d,g);
    wino_tb=wino_tb+wino_tb_temp(3:4,3:4,i);
end


write_hex_file( 'feature.txt',permute(feature_map,[2,1,3]),2);
write_hex_file( 'weight_ori.txt',permute(weight,[2,1,3]),3);
write_hex_file( 'weight.txt',permute(kn,[2,1,3]),3);
write_hex_file( 'result.txt',wino_tb',6);