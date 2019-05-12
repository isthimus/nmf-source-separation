function [W_out, H_out] = nss_init_zeroMask (W_mask, H_mask, spectInfo)
% NSS_INIT_ZEROMASK - initialise constrained W,H matrices ready for NMF
%
%   arguments:       
%       W_mask - a matrix the same size as W, with 0's where W should be zero initialised and 1's elsewhere
%       H_mask - a matrix the same size as H, with 0's where H should be zero initialised and 1's elsewhere
%       spectInfo - a struct containing the following parameters
%           num_freq_bins - number of frequency bins in the spectrogram
%           num_time_bins - number of time bins in the spectrogram
%
%   return values:
%       W_out - a randomised initial value for W with the required size
%       H_out - a randomised initial value for H with the required size
%
%   description:
%       given a pair of masks and a spectInfo, randomly initialise W and H such that
%       all values where the masks are 0 are 0, and alvalues where the masks are 1 are randomised.

    % unpack spectInfo
    num_freq_bins = spectInfo.num_freq_bins;
    num_time_bins = spectInfo.num_time_bins;

    % precondition checks
    assert (size(W_mask,1) == num_freq_bins, "shape of W_mask does not match value given for num_freq_bins");
    assert (size(H_mask,2) == num_time_bins, "shape of h_mask does not match value given for num_time_bins");
    assert(size(W_mask,2) == size(H_mask,1), "W_mask and H_mask not multipliable");

    % find K (ie number of independent notes)
    K = size(W_mask, 2);

    % randomly initialise W and H using nss_init_rand
    [W_out, H_out] = nss_init_rand(spectInfo, K, 10);

    % mask W,H and return
    W_out = W_out .* W_mask;
    H_out = H_out .* H_mask;
end