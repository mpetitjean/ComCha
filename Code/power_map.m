function power_map(power, coordinates)

figure;
scatter(coordinates(:,2), coordinates(:,1), 10, power(:), 'filled');
colorbar;
colormap jet;
colormap('default');
plot_google_map('maptype', 'hybrid', 'APIKey', 'AIzaSyCIMKDsk_O_W3MyvexlR4GD4bTyetR2yBg');

end