function freqBins = align_freq2FreqBin (f, nfft, fs)
	% check preconditions
	assert ( all(f <= fs/2), "at least one frequency given for conversion is above the nyquist limit!");

	% convert and return
	freqBins = round(nfft .* f ./ fs) + 1; % + 1 is for matlab indexing 
end