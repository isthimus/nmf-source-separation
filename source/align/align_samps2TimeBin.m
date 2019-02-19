function timeBins = align_samps2TimeBin (samps, wlen, hop)
    % find first window centre
    window_centre = ceil (wlen/2);

    % find the time bins,
    % making sure that samples before the first window centre get an index of 1.
    timeBins = round ((samps - window_centre) ./ hop) + 1;
    timeBins(samps < window_centre) = 1;
end