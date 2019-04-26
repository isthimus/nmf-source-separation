function out = block_normalise (in, blockSize, dropout_dB, removeMean, rectify)
    % applies block_normalise to the rows of a matrix

    % !!! theres still some differences between block and row normalise 
    % that never got bottomed out. test like billy-o before removing this
    freakout

    % default args
    if nargin <= 2
        dropout_dB = -3;
    end
    if nargin <= 3
        removeMean = true;
    end
    if nargin <= 4
        rectify = true;
    end

    out = zeros(size(in));

    for i = 1:size(out,1)
        out(i,:) = block_normalise(in(i,:), blockSize, dropout_dB, removeMean, rectify);
    end
end