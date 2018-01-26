clc,clear;
%% 创建图像及投影
M=256;
P = phantom(M); % 创建一个 shepp-logan 模型，原图像
theta=1:180; %角度
[R,xp] = radon(P,(theta*180)/pi);%利用radon变换获得不同方向上的投影
xp_offset = abs(min(xp) + 1);

%% 傅立叶变换
size(R,1);%367
width = 2^nextpow2(size(R,1)); %傅立叶变换的宽度
proj_fft = fft(R, width);

filter = 2*[0:(width/2-1), width/2:-1:1]'/width;
plot(filter)

proj_filtered = zeros(width,180);
for i = 1:180
    proj_filtered(:,i) = proj_fft(:,i).*filter;
end
%% 逆傅里叶变换并反投影
proj_ifft = real(ifft(proj_filtered)); 
fbp = zeros(M); 
for i = 1:180
    rad = theta(i);
    for x = (-M/2+1):M/2
        for y = (-M/2+1):M/2
            t = round(x*cos(rad+pi/2)-y*sin(rad+pi/2)+xp_offset);
            fbp(x+M/2,y+M/2)=fbp(x+M/2,y+M/2)+proj_ifft(t ,i);
        end
    end
end
fbp =(fbp*pi)/180;%256x256 

%% 显示结果
subplot(1, 2, 1), imshow(P), title('Original')
subplot(1, 2, 2), imshow(fbp), title('FBP')
