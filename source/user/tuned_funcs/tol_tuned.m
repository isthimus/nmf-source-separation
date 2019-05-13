function [W_mask_out, H_mask_out] = tol_tuned (W_mask, W_tol, H_mask, H_tol)
    % best performing tolerance function found during testing

    % it was found that linear tolerance did not improve nmf performance.
    % using no tolerance at all was better
    % it is possible the results might be different for a multiresolution spectrogram
    W_mask_out = W_mask;
    H_mask_out = H_mask;
end