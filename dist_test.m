dist = [40,80,120,230,340,450,540,710,920];
for i = 1:9
I  = imread([getenv('MONO_DATA_PATH'),'\',num2str(dist(i)),'\360.bmp']);
X  = dist'.*10;
[alpha,T] = measure(I,0.05);
Y(i,1)=T(3,1);
disp(i);
end
figure;
plot(X,Y,'LineWidth',1,'Marker','*');
hold on;
plot(X,X,'--','LineWidth',0.5);
hold off;
set(gca,'xlim',[0,10000]);
set(gca,'ylim',[0,10000]);
xlabel('Z_w /mm');
ylabel('����ֵ Z_w /mm');
grid(gca,'on');
grid(gca,'minor');
legend({'����ֵ','��ʵֵ'},'Location','northwest');
print('C:\Users\Victo\OneDrive\��Ŀ\��Ŀ�Ӿ�\Z_Z.png','-dpng','-r1200');

E = Y-X;

figure;
plot(E,'LineWidth',1,'Marker','*');
hold on;
plot(repmat(mean(E),size(E,1),1),'--','LineWidth',0.5);
hold off;
xlabel('���Ե� i');
ylabel('Z_W������� E_i /mm');
grid(gca,'on');
grid(gca,'minor');
legend({'����ֵ','ƽ��ֵ'},'Location','northwest');
print('C:\Users\Victo\OneDrive\��Ŀ\��Ŀ�Ӿ�\Z_error.png','-dpng','-r1200');


disp(sqrt(mean((X-Y).^2)));
disp(sqrt(mean((E-repmat(mean(E),size(E,1),1)).^2)));