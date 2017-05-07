function [ lcf, thr ] = lcr( sig, thr )
% LCR calculates Level Crossing Rate, that is a number
%   of crossings (in the positive direction) of an input 
%   vector through a given threshold vector.
%       [ x, t ] = lcr( sig, thr );
%
%   The crossings are calculated for all the values of 
%   the input threshold vector. The input signal has to
%   be a vector.
% 
%   Example:
%       n = randn( 1, 1000 );
%       [ x, t ] = lcr( n, -5:0.1:5 );
%       plot( t, x );

%% (c) Adrian Bohdanowicz
%% $Id: lcr.m,v 1.2 2002/12/05 08:44:52 adrian Exp $

% COMMENTS:
% The algorithm usues the Matlab matrix function
% instead of algorithm mased on definition of
% LCR. 
% This algorithm is about 30 times faster than
% traditional (Matlab implementation).

    % check errors:
    if( (nargin~=2) || (~ismatrix(sig)) )
        error( 'Wrong input parameters!' );
    end
    if size(thr,1) ~= 1
        error('thr must be row vector')
    end
    if size(sig,2) ~=1
        error('sig must be column vector')
    end
    
    % calculate lcf for each threshold:
    lcf = sum(diff(sig > thr) == 1);
    
return;    