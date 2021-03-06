function [Angle,T] = poseCalcOI(X,Y,M,epsilon,maxIteration)
%poseCalc - Description
%
% Syntax:[R,t] = poseCalc(X,Y,camera)
%
% Pose Calculation Algorithm
% Input:
% X - 3 x n world coordinates of n targets 
% Y - 3 x n focus unified image coordinates of n projections of targets 
% Output:
% R - 3 x 3 rotation matrix
% t - 3 x 1 translation vector

Y = (Y - repmat(M(:,3),1,size(X,2)))./M(1,1);
Y(3,:) = 1;

n = size(X,2);  % Numer of targets

A = X';
x = Y(1,:)';
y = Y(2,:)';

I0hap = pinv(A'*A)*A'*x;
J0hap = pinv(A'*A)*A'*y; 

I0 = I0hap(1:3,:);
J0 = J0hap(1:3,:);

x0 = I0hap(4,1);
y0 = J0hap(4,1);

a = x0*y0/(1+x0*x0);
b = x0*y0/(1+y0*y0);
c = I0'*J0;
d = norm(I0,2)^2;
e = norm(J0,2)^2;
g = (1+x0*x0)/(1+y0*y0);

AA = a^2 - g;
B = 2*a^2*d - g*d + e - 2*a*c;
C = a^2*d^2 + c^2 -2*a*c*d;

AAA = b^2 - 1/g;
BB = 2*b^2*e - e/g + d - 2*d*c;
CC = b^2*e^2 + c^2 - 2*b*c*e;

delta = B^2 - 4*AA*C;
delta2 = BB^2 - 4*AAA*CC;
lambda = [sqrt((-B+sign(AA)*sqrt(delta))/(2*AA)),-sqrt((-B+sign(AA)*sqrt(delta))/(2*AA))]';
miu = [sqrt((-BB+sign(AAA)*sqrt(delta2))/(2*AAA)),-sqrt((-BB+sign(AAA)*sqrt(delta2))/(2*AAA))]';
err1 = c*ones(2,2) + lambda*miu' - a*(d*ones(2,2)+2*(repmat(lambda,1,2)).^2);
err2 = c*ones(2,2) + lambda*miu' - b*(e*ones(2,2)+2*(repmat(miu,1,2)').^2);
err = abs(err1) + abs(err2);
[minR,minC] = find(err==min(min(err)));

R = zeros(3,3,2);
t = zeros(3,1,2);
err = zeros(2,1);

for ii=1:2
  Ip = I0 + lambda(minR(ii))*[0,0,1]';
  Jp = J0 + miu(minC(ii))*[0,0,1]';
  tz = sqrt(sqrt(1+x0*x0)/norm(Ip,2)*sqrt(1+y0*y0)/norm(Jp,2));
  k = inv(eye(3,3) - tz*y0*crossMatrix(Ip) + tz*x0*crossMatrix(Jp))*tz^2*(cross(Ip,Jp));
  i = tz*Ip + x0*k;
  j = tz*Jp + y0*k;
  R(:,:,ii) = [i,j,k]';
  [R(:,:,ii),t(:,:,ii),err(ii)] = orthogonalIteration(X,Y,R(:,:,ii),epsilon,maxIteration);
end

if(err(1)<err(2))
   ii = 1; 
end

phi = atan(R(2,1,ii)/R(2,2,ii))/pi*180;
alpha = -asin(R(2,3,ii))/pi*180;
gamma = atan(R(1,3,ii)/R(3,3,ii))/pi*180;

Angle = [alpha;phi;gamma];
T = t(:,ii);
end