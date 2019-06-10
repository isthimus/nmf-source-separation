function [W_out, H_out] = nmf_init_tuned (spectInfo, k, avg)
% NMF_INIT_TUNED - calls the best performing NMF initialisation function
% with the best performing set of parameters, as discovered during testing
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

    [W_out, H_out] = nss_init_rand (spectInfo, k, avg)
end
