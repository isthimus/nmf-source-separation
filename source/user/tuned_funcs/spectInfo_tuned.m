function si = spectInfo_tuned
    % returns the best-performing spectInfo found during testing
    % note - parameter specific to a given audio file, like Fs and audio_len_samp, are not provided

    wlen = 1024;
    si = struct( ... 
        "wlen"         , wlen, ... 
        "nfft"         , wlen * 4, ...
        "hop"          , 256, ... 
        "analwin"      , blackmanharris(wlen, 'periodic'), ...
        "synthwin"     , hamming(wlen, 'periodic'), ...
        "max_freq_bins", floor(400 * wlen/1024) ...
    );
end