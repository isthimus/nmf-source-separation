function [W_out,H_out] = nmf_tuned (V, W, H)
    % best performing nmf function found during testing
    [W_out,H_out] = nss_nmf_euclidian(V,W,H);
end 