function res = corShadowing(samples,v, sigma, rc,time)

gaussian = randn(1, samples);
a = exp(-v*time/rc);
res = zeros(1,samples);
res(1)=gaussian(1);
for i =2:samples
    res(i) = a * res(i-1) + gaussian(i);
end
res = res.*sigma*sqrt(1-a^2);

