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

figure;
plot(dist,power);
% Remark : shadow area
xlim([210 max(dist)]);