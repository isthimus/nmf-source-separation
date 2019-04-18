function [W_out, H_out] = nmf_init_zeroMask (W_mask, H_mask, spectInfo)

	% unpack spectInfo
	num_freq_bins = spectInfo.num_freq_bins;
	num_time_bins = spectInfo.num_time_bins;

	% precondition checks
	assert (size(W_mask,1) == num_freq_bins, "shape of W_mask does not match value given for num_freq_bins");
	assert (size(H_mask,2) == num_time_bins, "shape of h_mask does not match value given for num_time_bins");

	% find K (ie number of independent notes)
	K = size(W_mask, 2);

	% randomly initialise W and H using nmf_init_rand
	[W_out, H_out] = nmf_init_rand(num_freq_bins, num_time_bins, K, 10);

	% mask W,H and return
	W_out = W_out .* W_mask;
	H_out = H_out .* H_mask;
end