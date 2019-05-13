function [sources_out, trackVec] = sepSources_scoreAware_plot ( ...
    notes,  ...
    audio,  ...
    spectInfo, ...
    spect_func,  ...
    align_func,  ...
    tol_func,  ...
    nmf_func,  ...
    recons_func ...
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
    [W_mask, H_mask, trackVec] = aln_makeMasks_midi(notes_aligned, spectInfo);
	
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
    assert(size(W_mask,2) == size(H_mask,1), "error in tol_func: W_mask and H_mask not multipliable");
    k = size(W_mask,2);
    [W_init, H_init] = nss_init_rand(spectInfo, k, 10);
    assert(all(size(W_mask) == size(W_init)), "error in nmf_init_func: size of W mask does not match W_init!");
    assert(all(size(H_mask) == size(H_init)), "error in nmf_init_func: size of H mask does not match H_init!");
    W_masked = W_init .* W_mask;
    H_masked = H_init .* H_mask;

    % perform nmf
    spect_mag = abs(spect);
    [W_out, H_out] = nmf_func (spect_mag, W_masked, H_masked);
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
    % note-by-note
    sources_note = recons_func (spect, W_out, H_out, spectInfo);
    % summed to one source per midi track
    sources_out = aln_recoverFromMasks(sources_note, trackVec);  
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