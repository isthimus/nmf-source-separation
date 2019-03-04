function timeBins = align_secs2TimeBin (t, fs, wlen, hop, audio_len_samp)
    % get nearest sample indices to t and find first window centre
    samps = round(t .* fs);

    if nargin >= 5
    	timeBins = align_samps2TimeBin(samps, wlen, hop, audio_len_samp);
    else
    	timeBins = align_samps2TimeBin(samps, wlen, hop);
    end
end