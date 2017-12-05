function [alpha,T] = measure(I,similarity)
%myFun - Description
%
% Syntax: output = myFun(input)
%
% Long description
f=12.5;

%%figure; imshow(I);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[mH, nL]=size(I);

% level=graythresh(I)
% bw=im2bw(I,level);
% se = strel('disk',32);

bw=(I)>50;
%%figure,imshow(bw);
% bw=~bw;

% bw=bwfill(bw,'holes');
% for j=1:mH
%     for i=1:nL
%         if(i<641) ||(j>884)
%             bw(j,i)=0;
%         end;
%     end;
% end;



se = strel('disk',5);
openbw=imopen(bw,se);

% se = strel('disk',16);
% openbw=imdilate(bw,se);

openbw=~openbw;
figure,imshow(openbw);

stats=regionprops(openbw,'basic');%�õ������������Ͻǵ�ͼ��λ�úͷ�������Ĵ�С
[T_H,T_L]=size(stats);

T_g=zeros(T_H,4);


for i=1:T_H
	aa1=stats(i).BoundingBox(1,1); %�з������
    if(fix(aa1)==0)
       aa1=1;  
    else
       aa1=fix(aa1); 
    end;

    aa2=stats(i).BoundingBox(1,1) + stats(i).BoundingBox(1,3); %�з����յ�
    aa2=fix(aa2)+1;

    aa3=stats(i).BoundingBox(1,2);%�з������
    aa3=fix(aa3);

    if(fix(aa3)==0)
       aa3=1;  
    else
       aa3=fix(aa3); 
    end;
    
    aa4=stats(i).BoundingBox(1,2) + stats(i).BoundingBox(1,4);%�з����յ�
    aa4=fix(aa4)+1;

    if(aa2 > nL) || (aa4 > mH)
        T_g(i,1)=1;
        T_g(i,2)=1;
        T_g(i,3)=1;
        T_g(i,4)=1;
    else
        T_g(i,:)=[aa3,aa4,aa1,aa2];
    end;
end;

%%�ж�Բ��%%%
ss=zeros(T_H,3);
[B,L] = bwboundaries(openbw,'noholes');
stats=regionprops(openbw,'basic');
%%figure;imshow(L);
ff=length(B);
for i=1:T_H
    aa=openbw(T_g(i,1):T_g(i,2),T_g(i,3):T_g(i,4));
    sum_aa=sum(sum(aa));
    boundary=B{i};
    delta_sq = diff(boundary).^2;
    sum_aa_edge = sum(sqrt(sum(delta_sq,2)));
%     aa_edge=bwboundaries
%     sum_aa_edge=sum(sum(aa_edge));
    ss(i,1)=4*pi*sum_aa/sum_aa_edge^2;
end
% for i=1:T_H
%     aa=openbw(T_g(i,1):T_g(i,2),T_g(i,3):T_g(i,4));
%     sum_aa=sum(sum(aa));
%     se=[0 1 0;1 1 1;0 1 0];
%     aa_erode=imerode(aa,se);
% %     aa_edge=edge(aa,'canny');
%     aa_edge=aa-aa_erode;
%     sum_aa_edge=sum(sum(aa_edge));
%     ss(i,1)=4*pi*sum_aa/sum_aa_edge^2;
% end

%%������ͨ�������%%%
x_sum=0;
y_sum=0;


for i=1:T_H
    for m=T_g(i,1):T_g(i,2)
        for n=T_g(i,3):T_g(i,4)
            if openbw(m,n)==1
                x_sum=n+x_sum;
                y_sum=m+y_sum;
            end;    
        end;
    end;
    aa_i=openbw(T_g(i,1):T_g(i,2),T_g(i,3):T_g(i,4));
    sum_aa_i=sum(sum(aa_i));
    ss(i,2)= x_sum/sum_aa_i;
    ss(i,3)= y_sum/sum_aa_i;
    
    x_sum=0;
    y_sum=0;
end;


dian_index=zeros(1,T_H);
for i=1:T_H
    if ss(i,1)<1&&(ss(i,1)-similarity)>0
        dian_index(1,i)=1; 
    end;
end

% %%%%%%%%��÷�����������ĵ�---����%%%%%%%%%%%%%%%%%%%%
% stats2=regionprops(openbw,'centroid');
% centroids = cat(1, stats2.Centroid);
% % plot(centroids(:,1), centroids(:,2), 'b*');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%imshow(openbw);

for i=1:T_H
    if dian_index(1,i)==1
        rectangle('position',[stats(i).BoundingBox], 'LineWidth',2,'LineStyle','--','EdgeColor','r');
        hold on
        %%plot(ss(i,2), ss(i,3), 'b*')%%%%���ĵ�ͼ������
        hold off
    end;
end

%%%%%%���ĵ��ͼ����������ά�������ƥ��%%%%%%%%%%%%%%%%%%%
zhixin_position=[0 0];
for i=1:T_H
    if dian_index(1,i)==1
        zhixin_position =[zhixin_position;ss(i,2:3)];
    end;
end
zhixin_position=zhixin_position(2:end,:);%%%%����ͼ������


zhixin_2=zeros(size(zhixin_position));
dian_index=zeros(4,1);
%%%%�� 0 150 0 ��ά�����ƥ���ͼ������%%%%%%%%%%%
[d_h,d_l]=size(zhixin_position);

%%%������1��ͼ�������������������ĵ�б�� ȷ������ͬһ��ֱ���ϵĵ�
K2=(zhixin_position(2,2)-zhixin_position(1,2))/(zhixin_position(2,1)-zhixin_position(1,1));
K3=(zhixin_position(3,2)-zhixin_position(1,2))/(zhixin_position(3,1)-zhixin_position(1,1));
K4=(zhixin_position(4,2)-zhixin_position(1,2))/(zhixin_position(4,1)-zhixin_position(1,1));

a=atan(K2)*180/pi;
 b=atan(K3)*180/pi;
 c=atan(K4)*180/pi;

if(abs(K2-K3) < 0.02) %%���Զ�λλ��������һ�ߵĵ����������
    zhixin_2(3,:) =[zhixin_position(4,1),zhixin_position(4,2)];
    dian_index(3,1)=4; %4�ŵ�
    dian_index(1,1)=1;
    dian_index(2,1)=2;
    dian_index(4,1)=3;
elseif(abs(K2-K4) < 0.02)
    zhixin_2(3,:) =[zhixin_position(3,1),zhixin_position(3,2)];
    dian_index(3,1)=3; %3�ŵ�
    dian_index(1,1)=1;
    dian_index(2,1)=2;
    dian_index(4,1)=4; 
elseif(abs(K3-K4) < 0.02)
    zhixin_2(3,:) =[zhixin_position(2,1),zhixin_position(2,2)];
    dian_index(3,1)=2; %2�ŵ�
    dian_index(1,1)=1;
    dian_index(2,1)=3;
    dian_index(4,1)=4;
else
    zhixin_2(3,:) =[zhixin_position(1,1),zhixin_position(1,2)];
    dian_index(3,1)=1; %1�ŵ�
    dian_index(1,1)=2;
    dian_index(2,1)=3;
    dian_index(4,1)=4;
end;
%%%��ʣ�������������ͼ���������������������ƥ��%%%%%%%
dis12=((zhixin_position(dian_index(1,1),1)-zhixin_position(dian_index(2,1),1))^2+(zhixin_position(dian_index(1,1),2)-zhixin_position(dian_index(2,1),2))^2)^0.5;
dis14=((zhixin_position(dian_index(1,1),1)-zhixin_position(dian_index(4,1),1))^2+(zhixin_position(dian_index(1,1),2)-zhixin_position(dian_index(4,1),2))^2)^0.5;
dis24=((zhixin_position(dian_index(2,1),1)-zhixin_position(dian_index(4,1),1))^2+(zhixin_position(dian_index(2,1),2)-zhixin_position(dian_index(4,1),2))^2)^0.5;

dis13=((zhixin_position(dian_index(1,1),1)-zhixin_position(dian_index(3,1),1))^2+(zhixin_position(dian_index(1,1),2)-zhixin_position(dian_index(3,1),2))^2)^0.5;
dis23=((zhixin_position(dian_index(2,1),1)-zhixin_position(dian_index(3,1),1))^2+(zhixin_position(dian_index(2,1),2)-zhixin_position(dian_index(3,1),2))^2)^0.5;
dis43=((zhixin_position(dian_index(4,1),1)-zhixin_position(dian_index(3,1),1))^2+(zhixin_position(dian_index(4,1),2)-zhixin_position(dian_index(3,1),2))^2)^0.5;

if(dis12>dis14) && (dis12>dis24)
    zhixin_2(4,:) =[zhixin_position(dian_index(4,1),1),zhixin_position(dian_index(4,1),2)];  %%4�ŵ�
    if(dis13>dis23)
       zhixin_2(1,:) =[zhixin_position(dian_index(1,1),1),zhixin_position(dian_index(1,1),2)];  %%1�ŵ�
       zhixin_2(2,:) =[zhixin_position(dian_index(2,1),1),zhixin_position(dian_index(2,1),2)];  %%2�ŵ�
    else   
       zhixin_2(1,:) =[zhixin_position(dian_index(2,1),1),zhixin_position(dian_index(2,1),2)];  %%2�ŵ�
       zhixin_2(2,:) =[zhixin_position(dian_index(1,1),1),zhixin_position(dian_index(1,1),2)];  %%1�ŵ�
    end;
elseif(dis14>dis12) && (dis14>dis24)
    zhixin_2(4,:) =[zhixin_position(dian_index(2,1),1),zhixin_position(dian_index(2,1),2)];  %%2�ŵ�
    if(dis13>dis43)
       zhixin_2(1,:) =[zhixin_position(dian_index(1,1),1),zhixin_position(dian_index(1,1),2)];  %%1�ŵ�
       zhixin_2(2,:) =[zhixin_position(dian_index(4,1),1),zhixin_position(dian_index(4,1),2)];  %%4�ŵ�
    else   
       zhixin_2(1,:) =[zhixin_position(dian_index(4,1),1),zhixin_position(dian_index(4,1),2)];  %%4�ŵ�
       zhixin_2(2,:) =[zhixin_position(dian_index(1,1),1),zhixin_position(dian_index(1,1),2)];  %%1�ŵ�
    end; 
elseif(dis24>dis12) && (dis24>dis14)    
    zhixin_2(4,:) =[zhixin_position(dian_index(1,1),1),zhixin_position(dian_index(1,1),2)];  %%1�ŵ�
    if(dis23>dis43)
       zhixin_2(1,:) =[zhixin_position(dian_index(2,1),1),zhixin_position(dian_index(2,1),2)];  %%2�ŵ�
       zhixin_2(2,:) =[zhixin_position(dian_index(4,1),1),zhixin_position(dian_index(4,1),2)];  %%4�ŵ�
    else   
       zhixin_2(1,:) =[zhixin_position(dian_index(4,1),1),zhixin_position(dian_index(4,1),2)];  %%4�ŵ�
       zhixin_2(2,:) =[zhixin_position(dian_index(2,1),1),zhixin_position(dian_index(2,1),2)];  %%2�ŵ�
    end;  
end;

% Camera_M=[12.5*10^3/5.5,      0,            nL/2;...
%            0,            12.5*10^3/5.5,      mH/2;...
%           0,                  0,               1];


Camera_M=[2294.35,0,1172.41;...
          0,2310.24,885.828;...
          0,0,1];

% Camera_M=[2299.23,0,1166.11;...
%           0,2287.08,946.431;...
%           0,0,1];

XYZ1=[200,0,1;0,0,1;0,75,1;90,0,1]';%% m

zhixin1(1:4,1)=zhixin_2(1:4,1);%%%  M
zhixin1(1:4,2)=zhixin_2(1:4,2);
zhixin1(:,3)=1;
zhixin1=zhixin1';


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x1=XYZ1;
x2=zhixin1;


M=x1;
m=x2;

%[x1, T1] = normalise2dpts(x1);
%[x2, T2] = normalise2dpts(x2);

% Npts = length(x1);
% A = ones(2*Npts,9);    
% O = [0 0 0];
% for n = 1:Npts
% 	X = x1(:,n)';
% 	x = x2(1,n); y = x2(2,n); w = x2(3,n);
% 	%A(3*n-2,:) = [  O  -w*X  y*X];
% 	A(2*n-1,:) = [  X  O  -x*X];
% 	A(2*n  ,:) = [  O  X  -y*X];
% end   
% [U,D,V] = svd(A);
% % Extract homography
% H = reshape(V(:,9),3,3)';
% Denormalise
%H = T2\H*T1; 

%H=H/H(3,3);

H=x2/x1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Maximun likelihood estimation for the H
% using the function(10), P7
options = optimset('LargeScale','off');
x = lsqnonlin( @simon_H, reshape(H,1,9) , [],[],options,m, M);
H=reshape(x,3,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r1=(inv(Camera_M))*H;
ZZc=1/sqrt(r1(1,1)^2+r1(2,1)^2+r1(3,1)^2);
ZZc2=1/sqrt(r1(1,2)^2+r1(2,2)^2+r1(3,2)^2);

a=sqrt(ZZc*ZZc2);
r11=a*r1;

C_r0=[r11(1,1);r11(2,1);r11(3,1)];
C_r1=[r11(1,2);r11(2,2);r11(3,2)];

C_r2=cross(C_r0,C_r1);

Aa=asin((-1)*C_r1(3,1))*57.3;
Ab=atan((-1)*C_r0(3,1)/C_r2(3,1))*57.3; %%Ay
Ac=atan(C_r1(1,1)/C_r1(2,1))*57.3;  



%%  Euler angles
Euler_Aa=atan(C_r1(3,1)/C_r2(3,1))*57.3;
Euler_Ab=asin((-1)*C_r0(3,1))*57.3;                    %%Ay
Euler_Ac=atan(C_r0(2,1)/C_r0(1,1))*57.3;

alpha = [Euler_Aa;Euler_Ab;Euler_Ac];
T = [r11(1,3);r11(2,3);r11(3,3)];

end
