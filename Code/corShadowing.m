function res = corShadowing(samples,v, sigma, rc)

gaussian = randn(1, samples);
T = 0;
res = zeros(1,samples);
for i =1:samples
    a = exp(-v*T/rc);
    b = a * T;
    T = b + gaussian(i);
    res(i) = T * sigma * sqrt(1-a^2);
end
    