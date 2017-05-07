clear;
close all;

load('../Measurements/data.mat');
%power_map(power,coordinates)

% Coordinates of base station 
% LAT: 50.812114 N
% LON:  4.384941 E

lat_base = deg2rad(50.812114);
long_base = deg2rad(4.384941);
coordinates = deg2rad(coordinates);


% coord: lat, long
R = 6.471e6;
dist = 2*R*asin(sqrt(sin((coordinates(:,1)-lat_base)./2).^2 + ...
    cos(coordinates(:,1)).*cos(lat_base).* sin((coordinates(:,2)-long_base)./2).^2));
% figure;
% plot(dist,power);
% % Remark : shadow area
power = power(dist > 209)';
time = time(dist > 209);
dist = dist(dist > 209);
power = power(1:20272);
dist = dist(1:20272);
time = time(1:20272);
vmoy = (dist(end)-dist(1))/(time(end)-time(1));
dmoy = dist(2)-dist(1);

% figure
% plot(dist,power)

% Path loss model
p = polyfit(log10(dist),power,1);
figure('name','Path Loss','NumberTitle','off');
plot(log10(dist),power);
hold on
plot(log10(dist),p(1)*log10(dist)+p(2), 'linewidth', 3)
title('Path Loss')

pathLossExponent = - p(1)/10
% A RELIER AVEC UN MODELE
% depend du cut shadow area
cellRadius = 10^((-102 - p(2))/p(1))

% Shadowing

shadowing = power- (p(1)*log10(dist)+p(2));
lambda = 3*1e8/925.4/1e6;

%Moving Average
windowSize = 40; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;

shadowing = filter(b,a,shadowing);
shadowing = [shadowing(round(windowSize/2):end) ; zeros(round(windowSize/2)-1,1)];
figure('name','Shadowing','NumberTitle','off');
plot(log10(dist),shadowing)
createFit(shadowing);

% Autocorr & rc
autocor = xcorr(shadowing,'coeff');
autocor = autocor(find(autocor == 1):end);
ind = find(autocor <= 0.37);

rc = dist(ind(1))-dist(1)

% Cell radius 90% edge
figure('name','find Gamma','NumberTitle','off')
findGamma = @(x) erfc(x/std(shadowing)/sqrt(2))/2;
fplot(findGamma,[0 50]);
hold on;
line([0 50], [0.1 0.1], 'linestyle',':')
grid on;

gamma = 6.12
cellRadius90 = 10^((-102+gamma - p(2))/p(1))

% Cell radius 95% w29.2hole
a = @(R) (102 + (p(1).*log10(R)+p(2)))./(std(shadowing) .* sqrt(2));
b = 10.*pathLossExponent.*log10(exp(1))./(std(shadowing).*sqrt(2));
Fu = @(R) 1-erfc(a(R))./2 + exp(2.*a(R)./b+1./(b.^2))*erfc(a(R)+1./b)./2;
figure('name','Find Cell Radius 95%','NumberTitle','off')
fplot(Fu, [0 10000])
hold on;
line([0 10000], [0.95 0.95], 'linestyle',':')
cellRadius95 = 2371


% 4.4 Shitty model
corShad = corShadowing(length(shadowing)*10,vmoy,std(shadowing),rc,time(2)-time(1));
figure('name','Shadowing','NumberTitle','off')
subplot(1,2,1)
plot(log10(dist),shadowing)
title('Shadowing')
subplot(1,2,2)
plot(corShad)
title('Iterative Model')

% 5.1 Fast Fading clc

ffading = power - (p(1)*log10(dist)+p(2)) - shadowing;
figure('name','Fast Fading','NumberTitle','off');
plot(log10(dist), ffading);


ffadinglin = abs(db2mag(ffading*2));
ffading1 = ffadinglin(2000:2000+round(lambda*30/dmoy));
%createFitff1
s1 = 0.00997919;
sigma1 = 0.99883;
k1 = s1^2/2/sigma1^2;

ffading2 = ffadinglin(11000:11000+round(lambda*30/dmoy));
s2 = 0.137395;
sigma2 = 0.921529;
k2 = s2^2/2/sigma2^2;

ffading3 = ffadinglin(10:10+round(lambda*26/dmoy));
s3 = 0.975906;
sigma3 = 0.416635;
k3 = s3^2/2/sigma3^2;

% coherence time
cotime = lambda/vmoy/2;

%LCR
threshold = -20:0.5:10;
ffading3db = db(ffading2,'power');
[LCR,~] = lcr(ffading3db,threshold);
figure('name','LCR','NumberTitle','off');
plot(threshold,LCR);
% fm = 1/2/cotime;
% rho = db2mag(threshold*2)./rms(ffading2);
% LCRt = sqrt(2*pi).*fm.*rho.*exp(-rho.^2);
% hold on;
% plot(threshold,LCRt);
AFD = afd(ffading3db,threshold,time(2)-time(1));
figure('name','AFD','NumberTitle','off');
plot(threshold,AFD);
