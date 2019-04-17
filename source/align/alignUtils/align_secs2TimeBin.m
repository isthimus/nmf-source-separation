function timeBins = align_secs2TimeBin (t, spectInfo, use_audio_len)
    % if use_audio_len is not provided, default to true
    % if it is true, the differences in window pattern at the far end of the signal will be taken into account
    % if it is false, the calculation will be done as if with an infinite length signal
    if nargin < 3
    	use_audio_len = true;

    % unpack spectinfo
    fs = spectInfo.fs

    % get nearest sample indices to t and find first window centre
    samps = round(t .* fs);

    % defer to the samps2TimeBin function
    if use_audio_len
    	timeBins = align_samps2TimeBin(samps, wlen, hop, audio_len_samp);
    else
    	timeBins = align_samps2TimeBin(samps, wlen, hop);
    end

    % implicitly return timebins
end