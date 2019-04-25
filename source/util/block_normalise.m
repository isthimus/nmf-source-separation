function out = block_normalise (in, blockSize, dropout_dB, removeMean, rectify)
    % normalises a signal such that each block of size blockSize is in the range [-1, 1]
    % if removeMean is true (or not given), also removes DC in each block. 
    % dropout_dB is the threshold below which values are clamped to zero
    % its a dB ratio relative to the GLOBAL mean (NOT LOCAL MEAN)

    % uses linear indexing - so treats rows, cols, and whole matrices as a single long vector

    % default args
    if nargin <= 2
        dropout_dB = -99;
    end
    if nargin <= 3
        removeMean = true;
    end
    if nargin <= 4
        rectify = true;
    end

    % preconditions
    % assert(dropout_dB <= 0, "dB dropout threshold should be negative");

    % figure out dropout level and zero those indices
    dropout_abs = db2mag(dropout_dB) * mean(in(:));
    in(in<dropout_abs) = 0;

    % preallocate out
    out = zeros(size(in)); 

    % iterate block by block
    currIndex = 1;
    while(currIndex <= length(in(:)))
        % figure out upper limit of this block
        upperLim = min(currIndex + blockSize - 1, length(in(:)));

        % extract a block, normalise and put into out
        thisBlock = in(currIndex:upperLim);
        if removeMean
            block_mean = mean(thisBlock);
            thisBlock = thisBlock - block_mean;
        end
        if rectify
            thisBlock(thisBlock < 0) = 0;
        end

        block_max = max(abs(thisBlock));
        if block_max == 0
            thisBlock(:) = 0;
        else
            thisBlock = thisBlock./max(abs(thisBlock));
        end
        out(currIndex:upperLim) = thisBlock;

        % get starting index of next block
        % when this goes off the end we fall out of the while loop
        currIndex = upperLim + 1; 
    end

end