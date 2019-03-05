function notes_aligned = align_dtw (notes, audio_vec, spectInfo, use_vel)
    % extract chroma from midi and audio
    chroma_midi = align_getChroma_midi (notes, spectInfo, use_vel);
    chroma_audio = align_getChroma_audio (audio_vec, spectInfo);

    assert (all (size(chroma_midi) == size(chroma_audio)), "bad chroma matrix sizes");

    % perform dtw to find warping path between chroma
    [~, IM, IA] = dtw (chroma_midi, chroma_audio)
    IM = align_resolveWarpingPath (IM, IA);

    % get all midi event times in notes, as timebin indexes
    %% < vector full of indices, V(i) represents time of event in notes(i, :), as a timebin>
    startTimes_bins = align_secs2TimeBin(notes(:, 5), spectInfo.fs, spectInfo.wlen, spectInfo.hop, spectInfo.audio_len_samp)
    endTimes_bins   = align_secs2TimeBin(notes(:, 6), spectInfo.fs, spectInfo.wlen, spectInfo.hop, spectInfo.audio_len_samp)

    % warp midi event times using IM warping path
    %% replace each num in V with the index of the first instance of >= that num in IM
    %% !!! or poss "middle instance"?

    % this is the sad painters algorithm, so seemingly inefficient
    % but we can't do it efficiently because ORDEREDNESS of *Times_bins is NOT GUARANTEED
    for i = 1:length(startTimes_bins)
        startTimes_bins(i) = find(IM >= startTimes_bins(i), 1);
    end
    for i = 1:length(endTimes_bins)
        endTimes_bins(i) = find(IM >= endTimes_bins(i), 1);
    end
 
    % transform the notes array using this information, return
    
    freakout % align_timeBin2Secs not written yet!!
    startTimes_secs = align_timeBin2Secs(startTimes_bins, XXXX);
    endTimes_secs = align_timeBin2Secs(endTimes_bins, XXXX);

    notes_aligned = notes;
    notes_aligned (:, 5) = startTimes_secs;
    notes_aligned (:, 6) = endTimes_secs;

end