function notes_aligned = aln_align_dtw_onset (...
    notes, ...
    audio, ...
    spect, ... 
    spectInfo, ...
    onset_func, ...
    chroma_onset_ratio, ...
    use_vel, ...
    midiOnset_useRoot ...
)
    
    % default args
    if nargin < 6
        chroma_onset_ratio = 0.5; % 1 => all chroma, 0 => all onset.
    end
    if nargin < 7
        use_vel = true;
    end
    if nargin < 8
        midiOnset_useRoot = false;
    end
    assert (0 < chroma_onset_ratio && chroma_onset_ratio < 1, "chroma_onset_ratio should be between 0 and 1!")

    % extract chroma from midi and audio. normalise audio
    chroma_midi = aln_getChroma_midi (notes, spectInfo, use_vel);
    chroma_midi = mat_normalise(chroma_midi, 1);

    chroma_audio = aln_getChroma_audio (audio, spectInfo);
    chroma_audio = mat_normalise(chroma_audio, 1);

    % get the chroma-based dtw cost matrix
    C_chroma = aln_dtw_buildCostMatrix(chroma_midi, chroma_audio);

    % extract onsets from midi and audio (at timeBin-rate)
    onset_midi  = aln_getOnset_midi(notes, spectInfo);
    onset_audio = onset_func(spect, spectInfo);

    % get the onset-based dtw cost matrix
    C_onset = aln_dtw_buildCostMatrix (onset_midi, onset_audio);

    % make the final cost matrix using a weighted sum of the two
    C_final = chroma_onset_ratio*C_chroma + (1-chroma_onset_ratio)*C_onset;
    
    % traceback to find warping path
    % make sure IM, IA are column vectors first
    [~, IM, IA] = aln_dtw_traceback(C_final);
    if isrow(IM); IM = IM'; end
    if isrow(IA); IA = IA'; end
    IM = aln_resolveWarpingPath(IM, IA);

    % warp the midi and return
    notes_aligned = aln_midiPathWarp (notes, IM, spectInfo);
end