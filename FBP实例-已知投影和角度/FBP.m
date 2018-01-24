clc,clear;
%% ����������Ϣ
%�ؽ���ͼƬ���ظ���
M=512;%�����Ⱥͽ��մ������ĸ���һ��

%��ת�ĽǶ� 180����ת
theta=xlsread('angles_180.xlsx','Sheet1','a2:a181');

%ͶӰΪ512�У�180�е����ݣ��е����ݶ�Ӧÿһ����ת��512�б�ʾ��512�����մ�����
R=xlsread('projection.xls','����3');

%��ͶӰ���з��任
size(R,1);%512

% ���ÿ��ٸ���Ҷ�任�Ŀ��
width = 2^nextpow2(size(R,1));  

%% ��ͶӰ�����ٸ���Ҷ�任���˲�
%����Ҷ�任
proj_fft = fft(R, width);

% filter �˲�
% R-L��һ�ֻ������˲��㷨
filter = 2*[0:(width/2-1), width/2:-1:1]'/width;

% �˲����� proj_filtered
proj_filtered = zeros(width,180);
for i = 1:180
    proj_filtered(:,i) = proj_fft(:,i).*filter;
end
figure
subplot(1,2,1),imshow(proj_fft),title('����Ҷ�任')
subplot(1,2,2),imshow(proj_filtered),title('����Ҷ�任+�˲�')

%% ����ٸ���Ҷ�任����ͶӰ
% ����ٸ���Ҷ�任 proj_ifft
proj_ifft = real(ifft(proj_filtered)); 
figure,imshow(proj_ifft),title('�渵��Ҷ�任')

%��ͶӰ��x�ᣬy��
fbp = zeros(M); % �����ֵΪ0
for i = 1:180
    rad = theta(i);%���ȣ� %���rad ��ͶӰ�ǣ�����ͶӰ����x��нǣ�����֮����� pi/2
    for x = 1:M
        for y = 1:M
            %{
            %����ڲ�ֵ��
            t = round((x-M/2)*cos(rad)-(y-M/2)*sin(rad));%��ÿ��Ԫ����X�뵽��ӽ���������
            if t<size(R,1)/2 && t>-size(R,1)/2
                fbp(x,y)=fbp(x,y)+proj_ifft(round(t+size(R,1)/2),i);
            end
            %}
            t_temp = (x-M/2) * cos(rad) - (y-M/2) * sin(rad)+M/2  ;
             %����ڲ�ֵ��
            t = round(t_temp) ;
            if t>0 && t<=512
                fbp(x,y)=fbp(x,y)+proj_ifft(t,i);
            end
        end
    end
end
fbp = (fbp*pi)/180;%512x512 ԭͼ��ÿ������λ�õ��ܶ�

%% ��ʾ���
xlswrite('rebuild_info.xlsx',fbp,'Sheet1');%���õ����ؽ����ͼ������д��

figure,imshow(fbp),title('��ͶӰ�任���ͼ��')
