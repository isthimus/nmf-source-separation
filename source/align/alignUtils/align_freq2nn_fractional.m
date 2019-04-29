function nn_fract = aln_freq2nn_fractional(f)
	nn_fract = 12 * log2(32 .* f ./ 440) + 9;
end