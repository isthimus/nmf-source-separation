function timeBins = aln_samps2TimeBin (samps, spectInfo, use_audio_len)
    % unpack spectinfo
    wlen = spectInfo.wlen;
    hop = spectInfo.hop;
    audio_len_samp = spectInfo.audio_len_samp;

    % if use_audio_len is not provided, default to true
    if nargin < 3
        use_audio_len = true;
    end

    if use_audio_len
        % if using audio len, check that no samples are out of
        % range, and also work out the audio length in bins
        assert (all(samps <= audio_len_samp), "there are out of range samples in samps!")
        audio_len_bins = 1 + fix ((audio_len_samp - wlen) / hop);
    end

    % find first window centre
    window_centre = ceil (wlen/2);

    % find the time bins,
    % making sure that samples before the first window centre get an index of 1.
    timeBins = round ((samps - window_centre) ./ hop) + 1;
    timeBins(samps < window_centre) = 1;

    if use_audio_len
        % the calculation above finds the "closest" window for each element
        % in samps, assuming that the windows will go on forever. this
        % means that in the last window it might overestimate the timeBin
        % value.

        % however, since we've already verified that there are no out of
        % range indices in samps, we can just clamp any timeBins which are
        % too big downwards.
        timeBins(timeBins > audio_len_bins) = audio_len_bins;
    end
end