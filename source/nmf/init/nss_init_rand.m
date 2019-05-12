function [W_out, H_out] = nss_init_rand (spectInfo, k, avg)
% NSS_INIT_RAND - initialise W,H matrices randomly ready for NMF
%
%   arguments:       
%       spectInfo - a struct containing the following parameters
%           num_freq_bins - number of frequency bins in the spectrogram
%           num_time_bins - number of time bins in the spectrogram
%       k - the width of W and height of H
%       avg - the mean value to initialise to
%
%   return values:
%       W_out - a randomised initial value for W with the required size
%       H_out - a randomised initial value for H with the required size
%
%   description:
%       given a number of time bins, a number of frequency bins, the width of 
%       W/height of H, and the mean value to initialise to, generates starting 
%       values for W, H by simply picking a nonzero value for each element

    % default args
    if nargin < 3
        avg = 10;
    end

    % unpack spectInfo
    num_time_bins = spectInfo.num_time_bins;
    num_freq_bins = spectInfo.num_freq_bins;

    % make sure the "avg" argument is right
    if size(avg) == [1,1]
        avg = [avg, avg];
    elseif ~isequal(size(avg),[1,2])
        ME = MException ("nss_init_rand:bad_input", "avg should be a scalar or a 2 element vector");
        throw(ME)
    end
    
    if any(avg(:) <= 0)
        ME = MException ("nss_init_rand:bad_input", "avg should be all positive");
        throw(ME)
    end
    
   % build random matrices od the required size and avg
    W_out = (rand(num_freq_bins, k)+ 0.5) * avg(1);
    H_out = (rand(k, num_time_bins) + 0.5) * avg(2);
end
