function samps = align_timeBin2Samps (tb, spectInfo)
	% extract values from spectInfo
	wlen = spectInfo.wlen;
	hop = spectInfo.hop;
	fs = spectInfo.fs;

	% find timebin center values in terms of samples
	samps = (tb - 1) .* hop + (wlen / 2);
end