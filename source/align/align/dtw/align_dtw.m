function notes_aligned = align_dtw (notes, audio, spectInfo, use_vel)
    % extract chroma from midi and audio. normalise audio
    chroma_midi = align_getChroma_midi (notes, spectInfo, use_vel);
    chroma_audio = align_getChroma_audio (audio, spectInfo);
    chroma_audio = mat_normalise(chroma_audio, 1);

    assert (all (size(chroma_midi) == size(chroma_audio)), "bad chroma matrix sizes");

    % perform dtw to find warping path between chroma
    % make sure IM, IA are column vectors first - dtw() transposes in some situations 
    [~, IM, IA] = dtw (chroma_midi, chroma_audio);
    if isrow(IM); IM = IM'; end
    if isrow(IA); IA = IA'; end

    % warp midi using midiPathWarp and return
    IM = align_resolveWarpingPath (IM, IA);
    notes_aligned = align_midiPathWarp (notes, IM, spectInfo);
end

