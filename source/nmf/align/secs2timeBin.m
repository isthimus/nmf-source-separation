function timeBin = secs2timeBin (t, fs, wlen, hop)
    % get neareet sample index to t
    samp = round(t * fs) 

    % find the time bin - 
    % first figure out where the fist window centre is,
    % then find how many hops along from there to reach samp
    window_centre = ceil (wlen/2)
    if samp <= window_centre
        timeBin = 1;
    else
        timeBin = round ((samp - window_centre) / hop) + 1 ;
    end

end