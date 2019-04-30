function sources_out = nss_sepSources_scoreAware_plot (
    midiNotes,  ...
    audio,  ...
    spectInfo, ...
    spect_func,  ...
    align_func,  ...
    makeMask_func,  ...
    tol_func,  ...
    nmf_init_func,  ...
    nmf_func,  ...
    recons_func, ...
)
    % a many-argumented beast which performs the whole SASS pipeline based on 7 partial functions
    % !!! much more commenting/ explanation to come here...
    % !!! good defaults will make a big difference here

    % this is the same as nss_sepSources_scoreAware 
    % except it plots intermediate values at every stage

    % take spect, update spectInfo
    [spect, spectInfo] = spect_func(audio, spectInfo);
    assert(checkSpectInfo(spect), "missing values in return value for spectInfo!")

    % plot spectrogram
    figure(1)
    imagesc(abs(spect));
    title("audio spectrogram");
    axis xy;
    colorbar;

    wait_returnKey()
    close all;

    % align midi
    midiNotes_aligned = align_func(midiNotes, audio, spect, spectInfo);

    % plot aligned vs unaligned MIDI
    figure(1)
    title("unaligned MIDI")
    subplot(2,1,1)
    imagesc(abs(spect));
    axis xy;
    colorbar;
    subplot(2,1,2)
    imagesc(piano_roll(midiNotes));
    
    figure(2)
    title("aligned MIDI")
    subplot(2,1,1)
    imagesc(abs(spect));
    axis xy;
    colorbar;
    subplot(2,1,2)
    imagesc(piano_roll(midiNotes_aligned));

    wait_returnKey()
    close all;

    % build W and H masks, plot
    [W_mask, H_mask] = makeMask_func(midiNotes_aligned, spectInfo);
    figure(1); 
    imagesc(W_mask);
    title("W\_mask - pre tolerance");
    axis xy;
    colorbar;
    figure(2)
    imagesc(H_mask);
    title("H\_mask - pre tolerance");
    axis xy;
    colorbar;

    % apply tolerance to W and H, plot
    [W_mask, H_mask] = tol_func(W_mask, H_mask, spectInfo);
    figure(3); 
    imagesc(W_mask);
    title("W\_mask - post tolerance");
    axis xy;
    colorbar;
    figure(4)
    imagesc(H_mask);
    title("H\_mask - post tolerance");
    axis xy;
    colorbar;

    wait_returnKey()
    close all;

    % initialise nmf matrices and mask them with W_mask, H_mask
    [W_init, H_init] = nmf_init_func(spectInfo);
    assert(all(size(W_mask) == size(W_init)), "size of W mask does not match W_init!");
    assert(all(size(H_mask) == size(H_init)), "size of H mask does not match H_init!");
    W_masked = W_init .* W_mask;
    H_masked = H_init .* H_mask;

    % perform nmf
    spect_mag = abs(spect);
    [W_out, H_out] = nmf_func (spect_mag, W_masked, H_masked, spectInfo);
    figure(1); 
    imagesc(W_out);
    title("W\_out");
    axis xy;
    colorbar;
    figure(2)
    imagesc(H_out);
    title("H\_out");
    axis xy;
    colorbar;

    % reconstruct original sources
    sources_out = recons_func (spect, W_out, H_out, spectInfo);

    % plot sources in time domain
    for i = 1:size(sources_out, 1)
        source_vec = sources_out(i, :);
        plot(source_vec)
        title('source time domain')
        wait_returnKey
    end
end