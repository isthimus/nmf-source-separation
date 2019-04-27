function notes_aligned = align_dtw (notes, audio_vec, spectInfo, use_vel)
    % extract chroma from midi and audio. normalise audio
    chroma_midi = align_getChroma_midi (notes, spectInfo, use_vel);
    chroma_audio = align_getChroma_audio (audio_vec, spectInfo);
    chroma_audio = mat_normalise(chroma_audio, 1);

    assert (all (size(chroma_midi) == size(chroma_audio)), "bad chroma matrix sizes");

    % perform dtw to find warping path between chroma
    [~, IM, IA] = dtw (chroma_midi, chroma_audio);
    IM = align_resolveWarpingPath (IM, IA);

    % warp midi using midiPathWarp and return
    notes_aligned = align_midiPathWarp (notes, IM, spectInfo);
end

