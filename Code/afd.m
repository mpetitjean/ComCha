function [lcf] = afd(sig, thr,time)
    if size(thr,1) ~= 1
        error('thr must be row vector')
    end
    if size(sig,2) ~=1
        error('sig must be column vector')
    end
    
    lcf= sum((sig > thr) == 0).*time;