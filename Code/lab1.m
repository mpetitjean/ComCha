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
vmoy = (time(end)-time(1))/(dist(end)-dist(1));
% figure;
% plot(dist,power);
% % Remark : shadow area
power = power(dist > 209)';
dist = dist(dist > 209);
% figure
% plot(dist,power)

% Path loss model
p = polyfit(log10(dist),power,1);
figure;
plot(log10(dist),power);
hold on
plot(log10(dist),p(1)*log10(dist)+p(2), 'linewidth', 3)

pathLossExponent = - p(1)/10
% A RELIER AVEC UN MODELE
% depend du cut shadow area
cellRadius = 10^((-102 - p(2))/p(1))

% Shadowing

power = power- (p(1)*log10(dist)+p(2));
lambda = 3*1e8/925.4/1e6;

%Moving Average
windowSize = 40; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;

shadowing = filter(b,a,power);
figure
plot(log10(dist),shadowing)
createFit(shadowing);

% Autocorr & rc
autocor = xcorr(shadowing,'coeff');
autocor = autocor(find(autocor == 1):end);
ind = find(autocor < 0.37);

rc = dist(ind(1))-dist(1)

% Cell radius 90% edge
figure
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
figure
fplot(Fu, [0 10000])
hold on;
line([0 10000], [0.95 0.95], 'linestyle',':')
cellRadius95 = 2324


% 4.4 Shitty model
corShad = corShadowing(length(shadowing),vmoy,std(shadowing),rc);
figure
plot(corShad.')