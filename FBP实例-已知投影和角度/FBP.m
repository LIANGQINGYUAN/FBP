clc,clear;
%% 各个参数信息
%重建后图片像素个数
M=512;%建议先和接收传感器的个数一样

%旋转的角度 180次旋转
theta=xlsread('angles_180.xlsx','Sheet1','a2:a181');

%投影为512行，180列的数据，列的数据对应每一次旋转，512行表示有512个接收传感器
R=xlsread('projection.xls','附件3');

%由投影进行反变换
size(R,1);%512

% 设置快速傅里叶变换的宽度
width = 2^nextpow2(size(R,1));  

%% 对投影做快速傅里叶变换并滤波
%傅立叶变换
proj_fft = fft(R, width);

% filter 滤波
% R-L是一种基础的滤波算法
filter = 2*[0:(width/2-1), width/2:-1:1]'/width;

% 滤波后结果 proj_filtered
proj_filtered = zeros(width,180);
for i = 1:180
    proj_filtered(:,i) = proj_fft(:,i).*filter;
end
figure
subplot(1,2,1),imshow(proj_fft),title('傅立叶变换')
subplot(1,2,2),imshow(proj_filtered),title('傅立叶变换+滤波')

%% 逆快速傅里叶变换并反投影
% 逆快速傅里叶变换 proj_ifft
proj_ifft = real(ifft(proj_filtered)); 
figure,imshow(proj_ifft),title('逆傅立叶变换')

%反投影到x轴，y轴
fbp = zeros(M); % 假设初值为0
for i = 1:180
    rad = theta(i);%弧度， %这个rad 是投影角，不是投影线与x轴夹角，他们之间相差 pi/2
    for x = 1:M
        for y = 1:M
            %{
            %最近邻插值法
            t = round((x-M/2)*cos(rad)-(y-M/2)*sin(rad));%将每个元素舍X入到最接近的整数。
            if t<size(R,1)/2 && t>-size(R,1)/2
                fbp(x,y)=fbp(x,y)+proj_ifft(round(t+size(R,1)/2),i);
            end
            %}
            t_temp = (x-M/2) * cos(rad) - (y-M/2) * sin(rad)+M/2  ;
             %最近邻插值法
            t = round(t_temp) ;
            if t>0 && t<=M
                fbp(x,y)=fbp(x,y)+proj_ifft(t,i);
            end
        end
    end
end
fbp = (fbp*pi)/180;%512x512 原图像每个像素位置的密度

%% 显示结果
xlswrite('rebuild_info.xlsx',fbp,'Sheet1');%将得到的重建后的图像数据写入

figure,imshow(fbp),title('反投影变换后的图像')
