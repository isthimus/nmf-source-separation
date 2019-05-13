function sources_out = sepSources_blind_plot ( ...
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
    % this is the same as nmf_sepSources_blind, except it plots each intermediate stage
    %
    % "audio" is a vector containing the audio to be worked on.
    % k is the expected totl number of distinct notes across all instruments
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
    % nmf_en_partial = @(V, W, H) nss_nmf_euclidian_norm(V, W, H, myThreshold, myMaxIter)
    % nss_separate_sources(nmf_en_partial, <some>, <other>, <args>, ...)
    
    % default args
    % supply [] to skip an arg
    if nargin < 4 || isempty(spect_func)
        spect_func = @nss_stft;
    end
    if nargin < 5 || isempty(nmf_init_func)
        nmf_init_func = @nmf_init_tuned;
    end
    if nargin < 6 || isempty(nmf_func)
        nmf_func = @nmf_tuned;
    end
    if nargin < 7 || isempty(reconstruct_func)
        reconstruct_func = @recons_tuned_BSS;
    end

    
    % take spect and initialise
    [spect, spectInfo] = spect_func(audio, spectInfo);
    assert(checkSpectInfo(spectInfo), "missing values in return value for spectInfo!");

    [W_init, H_init] = nmf_init_func(spectInfo, k);
    assert(isequal( size(W_init),[spectInfo.num_freq_bins,k] ), "W_init is the wrong size");
    assert(isequal( size(H_init),[k,spectInfo.num_freq_bins] ), "H_init is the wrong size");

    % plot spectrogram
    figure(1)
    imagesc(abs(spect));
    title("audio spectrogram");
    axis xy;
    colorbar;

    wait_returnKey()
    close all;

    % do nmf
    spect_mag = abs(spect);
    [W_out,H_out] = nmf_func(spect_mag, W_init, H_init);
    assert(isequal(size(W_init), size(W_out)), "W_out is the wrong size");
    assert(isequal(size(H_init), size(H_out)), "H_out is the wrong size");

    % plot W_out
    figure(1)
    imagesc(W_out);
    title("W\_out");
    axis xy;
    colorbar;

    % plot H_out
    figure(2)
    imagesc(H_out);
    title("H\_out");
    axis xy;
    colorbar;

    wait_returnKey()
    close all;

    % reconstruct sources
    sources_out = reconstruct_func (spect, W_out, H_out, spectInfo);
    assert(size(sources_out, 1) == k, "wrong number of sources in output");

    % plot sources in time domain
    for i = 1:size(sources_out, 1)
        source_vec = sources_out(i, :);
        plot(source_vec)
        title('source time domain')
        wait_returnKey
    end
    close all;

    % implicitly return sources_out
end

