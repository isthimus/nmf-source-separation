function timeBins = align_secs2TimeBin (t, fs, wlen, hop)
    % get nearest sample indices to t and find first window centre
    samps = round(t .* fs);
    window_centre = ceil (wlen/2);

    % find the time bins,
    % making sure that samples before the first window centre get an index of 1.
    timeBins = round ((samps - window_centre) ./ hop) + 1;
    timeBins(samps < window_centre) = 1;
end