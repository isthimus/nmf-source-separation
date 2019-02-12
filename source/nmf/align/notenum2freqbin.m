function freqBin = notenum2freqBin (nn, nfft, fs)
	% converts a midi note number (nn, as an integer) to an fft frequency bin
	% since nn may not correspond exactly to frequency, this function rounds DOWN to the nearest freq bin
	% so [freqBin, freqBin+1] are the two nearest bins

	f_midi = midi2freq(nn);
	freqBin = floor(nfft * f_midi / fs) + 1; % matlab indexes from 1, hence the "+ 1" 
end