function secs = align_timeBin2Secs (tb, spectInfo)
	% extract values from spectInfo
	wlen = spectInfo.wlen;
	hop = spectInfo.hop;
	fs = spectInfo.fs;


	% find timebin values in terms of samples
	samps = (tb - 1) .* hop + (wlen / 2);

	% get the same values in continuous time
	secs = samps ./ fs; 
end