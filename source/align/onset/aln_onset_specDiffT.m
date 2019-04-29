function onsets_out = aln_onset_specDiffT (spect, spectInfo, leadingEdge_tol, norm_dropout)
    % detects onsets using spectral difference with a taxicab distance measure
    % (hence "DiffT")
    % then performs block normaliseation, leading edge dtetction, and smoothing 

    onsets = aln_onsUtil_specDiff_taxi(s,si);
    onsets_norm = block_normalise(onsets, 100, norm_dropout);
    onsets_leadingEdge = aln_onsUtil_leadingEdge(onsets_norm, leadingEdge_tol);
    onsets_out = aln_onsUtil_smooth(onsets_leadingEdge);
end
