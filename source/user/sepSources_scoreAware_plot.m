function [sources_out, trackVec] = sepSources_scoreAware_plot ( ...
    notes,  ...
    audio,  ...
    spectInfo, ...
    spect_func,  ...
    align_func,  ...
    tol_func,  ...
    nmf_func,  ...
    recons_func, ...
    makeMasks_func, ...
    nmf_saInit_func ...
)
    % a many-argumented beast which performs the whole SASS pipeline based on 7 partial functions
    % !!! much more commenting/ explanation to come here...
    % !!! good defaults will make a big difference 
    % !!! clean up mask-making and recovery

    % this is the same as nss_sepSources_scoreAware 
    % except it plots intermediate values at every stage

    % default args. supply [] to skip an argument.
    if nargin < 3 || isempty(spectInfo)
        spectInfo = spectInfo_tuned();
    end
    if nargin < 4 || isempty (spect_func)
        spect_func = @nss_stft;
    end
    if nargin < 5 || isempty (align_func)
        align_func = @alignOnset_tuned;
    end
    if nargin < 6 || isempty (tol_func)
        tol_func = @tol_tuned;
    end
    if nargin < 7 || isempty (nmf_func)
        nmf_func = @nmf_tuned;
    end
    if nargin < 8 || isempty (recons_func)
        recons_func = @recons_tuned_SASS;
    end
    if nargin < 9 || isempty (makeMasks_func)
        makeMasks_func = @aln_makeMasks_midi;
    end    
    if nargin < 10 || isempty (nmf_saInit_func)
        nmf_saInit_func = @nss_init_zeroMask;    
    end


    % take spect, update spectInfo
    [spect, spectInfo] = spect_func(audio, spectInfo);
    assert(checkSpectInfo(spectInfo), "error in spect_func: missing values in return value for spectInfo!")

    % plot spectrogram
    figure(1)
    imagesc(abs(spect));
    title("audio spectrogram");
    axis xy;
    colorbar;

    wait_returnKey()
    close all;

    % align midi
    notes_aligned = align_func(notes, audio, spect, spectInfo);

    % plot aligned vs unaligned MIDI
    figure(1)
    title("unaligned MIDI")
    subplot(2,1,1)
    imagesc(abs(spect));
    axis xy;
    colorbar;
    subplot(2,1,2)
    imagesc(piano_roll(notes));
    
    figure(2)
    title("aligned MIDI")
    subplot(2,1,1)
    imagesc(abs(spect));
    axis xy;
    colorbar;
    subplot(2,1,2)
    imagesc(piano_roll(notes_aligned));

    wait_returnKey()
    close all;

    % build W and H masks, plot
    [W_mask, H_mask, trackVec] = makeMasks_func(notes_aligned, spectInfo);
	
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

    % initialise nmf matrices using masking information
    [W_init, H_init] = nmf_saInit_func(W_mask, H_mask, spectInfo);
    assert(all(size(W_mask) == size(W_init)), "error in nmf_saInit_func: size of W mask does not match W_init!");
    assert(all(size(H_mask) == size(H_init)), "error in nmf_saInit_func: size of H mask does not match H_init!");

    % perform nmf
    spect_mag = abs(spect);
    [W_out, H_out] = nmf_func (spect_mag, W_init, H_init);
    assert(isequal(size(W_init), size(W_out)), "error in nmf_func: W_out is the wrong size");
    assert(isequal(size(H_init), size(H_out)), "error in nmf_func: H_out is the wrong size");
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

    wait_returnKey()
    close all;

    % reconstruct original sources
    sources_out = recons_func (spect, W_out, H_out, spectInfo, trackVec);

    % uncomment to plot each source
    %{
    % plot sources in time domain
    for i = 1:size(sources_out, 1)
        source_vec = sources_out(i, :);
        plot(source_vec)
        title('source time domain')
        wait_returnKey
    end
    close all;
    %}
end