function notes_aligned = align_dtw_onset (notes, audio, spectInfo, onset_func, use_vel, chroma_onset_ratio)
    
    % default args
    if nargin < 5
        use_vel = true;
    end
    if nargin < 6
        chroma_onset_ratio = 0.5 % 1 => all chroma, 0 => all onset.
    end
    assert (0 < chroma_onset_ratio && chroma_onset_ratio < 1, "chroma_onset_ratio should be between 0 and 1!")

    % extract chroma from midi and audio. normalise audio
    chroma_midi = align_getChroma_midi (notes, spectInfo, use_vel);
    chroma_audio = align_getChroma_audio (audio_vec, spectInfo);
    chroma_audio = mat_normalise(chroma_audio, 1);

    % get the chroma-based dtw cost matrix
    C_chroma = dtw_buildCostMatrix(chroma_midi, chroma_audio);

    % extract onsets from midi and audio (at timeBin-rate)
    onset_midi = align_getOnset_midi(notes, spectInfo, use_root);
    onset_audio = onset_func(audio, spectInfo);

    % get the onset-based dtw cost matrix
    C_onset = dtw_buildCostMatrix (onset_midi, onset_audio);

    % !!! should normalise?
    % make the final cost matrix using a weighted sum of the two
    C_final = chroma_onset_ratio*C_chroma + (1-chroma_onset_ratio)*C_onset;

    % traceback to find warping path
    [~, IM, IA] = dtw_traceback(C_final)
    IM = align_resolveWarpingPath(IM, IA);

    % warp the midi and return
    notes_aligned = align_midiPathWarp (notes, IM, spectInfo);
end