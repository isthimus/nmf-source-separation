function notes_aligned = alignOnset_tuned(n,a,s,si)
    onset_tuned = @(s,si)aln_onset_specDiffR(s,si,1,0);
    notes_aligned = aln_align_dtw_onset(n,a,s,si,onset_tuned, 0.3, true);
end