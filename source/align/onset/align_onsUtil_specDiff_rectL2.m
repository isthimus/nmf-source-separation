function out = align_onset_spectDiff_rectL2 (spect, spectInfo)
    % onset detecting function based on the rectified euclidian distance between sucessive stft frames
    % no chroma separation

    % compute rolling distance using rectified L2 norm
    % see helper function below
    distances = rectL2_distance (abs(spect(:, 1:end-1)), abs(spect(:, 2:end)));
    out = [distances.'; 0];

end

function d = rectL2_distance (A, B)
    % finds the difference vector between A and B, clamps it to 0 from below (halfwave rectifies)
    % and takes its L2 (euclidian squared) norm. the clamping has the effect that only onsets (not offsets)
    % show up in the onset function output
    % if A, B are matrices, treats them in parralel as a series of column vectors 

    % get difference and rectify
    diffs = A - B;
    diffs(diffs < 0) = 0;

    % take L2 norm
    d = sum(diffs.*diffs);
end