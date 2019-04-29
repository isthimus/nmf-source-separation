function out = aln_onsUtil_specDiff_taxi_pesky0 (spect, spectInfo)
    % NB SAME AS SPECDIFF_TAXI BUT WITH THE 0 IN LINE 9 SWAPPED
    % will shift some times around I think. 

    % onset detecting function based on the taxicab distance between sucessive stft frames
    % no chroma separation

    % compute rolling taxicab distance 
    distances = taxicab_distance(abs(spect(:, 1:end-1)), abs(spect(:, 2:end)));
    out = [0 ;distances.'];
end

function d = taxicab_distance (A, B)
    % finds the taxi distance between two column vectors
    % if A, B are matrices, treat as a set of column vectors
    diffs = A - B;
    d = sum(abs(diffs));
end