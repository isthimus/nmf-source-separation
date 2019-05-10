function sources_out = sepSources_blind ( ...
    audio, ...
    spectInfo, ...
    k, ...
    spect_func, ...
    nmf_init_func, ...
    nmf_func, ...
    reconstruct_func ...
)
    % performs source separation using one of a range of nmf functions.
    % returns a matrix where each row is one separated out source.
    %
    % "audio" is a vector containing the audio to be worked on.
    % k is the expected totl number of distinct notes across all instruments
    % all other inputs are function handles with prototypes as below
    % use partial application to make them match if necessary
    %
    % !!! add the partial function interfaces
    %
    % !!! new partial function example
    
    % take spect
    [spect, spectInfo] = spect_func(audio, spectInfo);
    assert(checkSpectInfo(spectInfo), "missing values in return value for spectInfo!");

    % initialise NMF function
    [W_init, H_init] = nmf_init_func(spectInfo, k);
    assert(isequal( size(W_init),[spectInfo.num_freq_bins,k] ), "W_init is the wrong size");
    assert(isequal( size(H_init),[k,spectInfo.num_freq_bins] ), "H_init is the wrong size");

    % do nmf
    spect_mag = abs(spect);
    [W_out,H_out] = nmf_func(spect_mag, W_init, H_init);
    assert(isequal(size(W_init), size(W_out)), "W_out is the wrong size");
    assert(isequal(size(H_init), size(H_out)), "H_out is the wrong size");

    % reconstruct sources
    sources_out = reconstruct_func (spect, W_out, H_out, spectInfo);
    assert(size(sources_out, 1) == k, "wrong number of sources in output");

    % implicitly return sources_out
end
