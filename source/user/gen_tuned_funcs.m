% declares tuned partial functions for each of the source separation stages.
align_tuned = @(n,a,s,si)aln_align_dtw(n,a,si,false);
onset_tuned = @(s,si)aln_onset_specDiffR(s,si,1,0);
alignOnset_tuned = @(n,a,s,si)aln_align_dtw_onset(n,a,s,si,onset_tuned, 0.3, true);
recons_tuned = @nss_reconstruct_keepPhase;
