function onsets_out = aln_onset_specDiffR (spect, spectInfo, leadingEdge_tol, norm_dropout)
    % detects onsets using spectral difference with a rectL2 distance measure
    % (hence "DiffR")
    % then performs block normaliseation, leading edge dtetction, and smoothing 

    onsets = aln_onsUtil_specDiff_rectL2(spect,spectInfo);
    onsets_norm = block_normalise(onsets, 100, norm_dropout);
    onsets_leadingEdge = aln_onsUtil_leadingEdge(onsets_norm, leadingEdge_tol);
    onsets_out = aln_onsUtil_smooth(onsets_leadingEdge);
end
