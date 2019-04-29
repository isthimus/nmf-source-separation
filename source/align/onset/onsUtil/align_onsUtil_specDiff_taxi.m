function out = align_onsUtil_specDiff_taxi (spect, spectInfo)
    % onset detecting function based on the taxicab distance between sucessive stft frames
    % no chroma separation

    % compute rolling taxicab distance 
    distances = taxicab_distance(abs(spect(:, 1:end-1)), abs(spect(:, 2:end)));
    out = [distances.'; 0];
end

function d = taxicab_distance (A, B)
    % finds the taxi distance between two column vectors
    % if A, B are matrices, treat as a set of column vectors
    diffs = A - B;
    d = sum(abs(diffs));
end