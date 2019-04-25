function secs = align_timeBin2Secs (tb, spectInfo)
	% unpack spectInfo
	fs = spectInfo.fs;

	assert(mod(wlen,2) == 0, "window length should be even");

	% find timebin values in terms of samples
	samps = align_timeBin2Samps (tb, spectInfo);

	% get the same values in continuous time
	secs = samps ./ fs; 
end