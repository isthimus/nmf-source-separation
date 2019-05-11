function sources_out = sepSources_scoreAware ( ... 
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

    % take spect, update spectInfo
    [spect, spectInfo] = spect_func(audio, spectInfo);
    assert(checkSpectInfo(spectInfo), "missing values in return value for spectInfo!")

    % align midi
    notes_aligned = align_func(notes, audio, spect, spectInfo);

    % build W and H masks
    [W_mask, H_mask, trackVec] = aln_makeMasks_midi(notes_aligned, spectInfo);
    
    % apply tolerance to W and H
    [W_mask, H_mask] = tol_func(W_mask, H_mask, spectInfo);

    % initialise nmf matrices and mask them with W_mask, H_mask
    assert(size(W_mask,2) == size(H_mask,1), "W_mask and H_mask not multipliable");
    k = size(W_mask,2);
    [W_init, H_init] = nss_init_rand(spectInfo, k, 10);
    assert(all(size(W_mask) == size(W_init)), "size of W mask does not match W_init!");
    assert(all(size(H_mask) == size(H_init)), "size of H mask does not match H_init!");
    W_masked = W_init .* W_mask;
    H_masked = H_init .* H_mask;

    % perform nmf
    spect_mag = abs(spect);
    [W_out, H_out] = nmf_func (spect_mag, W_masked, H_masked);
    assert(isequal(size(W_init), size(W_out)), "W_out is the wrong size");
    assert(isequal(size(H_init), size(H_out)), "H_out is the wrong size");

    % reconstruct original sources
    sources_out = recons_func (spect, W_out, H_out, spectInfo, trackVec);
end