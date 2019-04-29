function freqBins = aln_nn2FreqBin (nn, spectInfo)
	% converts a midi note number (nn, as an integer) to an fft frequency bin.
	% vectorised
	% since nn might not correspond exactly to frequency, this function rounds DOWN to the nearest freq bin
	% so [freqBin, freqBin+1] are the two nearest bins

	% unpack spectInfo
	nfft = spectInfo.nfft;
	fs = spectInfo.fs;

	f_midi = midi2freq(nn);

	assert (                       ...
		all(f_midi <= fs/2),       ...
		"at least one note number given in nn is above the nyquist frequency for given nfft and fs" ...
	);

	freqBins = floor(nfft .* f_midi ./ fs) + 1; % "+ 1" is for matlab indexing
end