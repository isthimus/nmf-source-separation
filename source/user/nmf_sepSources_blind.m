function sources_out = nmf_sepSources_blind ( ...
    audio, ...
    spectInfo ...
    k, ...
    spect_func, ...
    nmf_init_func, ...
    nmf_func, ...
    reconstruct_func, ...
)
    % performs source separation using one of a range of nmf functions.
    % returns a matrix where each column is one separated out source.
    %
    % "audio" is a vector containing the audio to be worked on.
    % k is the expected total number of distinct notes across all instruments
    % all other inputs are function handles with prototypes as below
    % use partial application to make them match if necessary
    %
    % [W_out, H_out] = nmf_func(V, W, H)
    % [W_init, H_init] = nmf_init_func(num_freq_bins, num_time_bins)
    % spectrogram = spectrogram_func(vector)
    % sources_out = reconstruction_func(orig_audio_spectrogram, W, H)
    %   NB! reconstruction func to return a matrix whose rows are the sources
    %
    % eg - to make nss_nmf_euclidian_norm match nmf_func:
    % myThreshold = 10; myMaxIter = 10000;
    % nmf_func = @(V, W, H) nss_nmf_euclidian_norm(V, W, H, myThreshold, myMaxIter)
    % nss_separate_sources(nmf_func, <some>, <other>, <args>, ...)
    
    % take spect and initialise
    [spect, spectInfo] = spect_func(audio, spectInfo);
    [W_init, H_init] = nmf_init_func(spectInfo, k);

    % do nmf
    spect_mag = abs(spect);
    [w_out,H_out] = nmf_func(spect_mag, W_init, H_init);

    % reconstruct and return sources
    sources_out = reconstruct_func (spect, W_out, H_out);
end

