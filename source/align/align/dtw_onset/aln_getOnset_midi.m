function onsets = aln_getOnset_midi(notes, spectInfo, smoothing, smooth_ksize, smooth_use_root)
    % extract a 1D onset measure at timeBin rate from the midi file in notes
    % along with an audio onset detecting function and an alignment function,
    % can be used to align midi to audio

    % default args
    if nargin < 3
        smoothing = true;
    end
    if nargin < 4
        smooth_ksize = 5; 
    end
    if nargin < 5
        smooth_use_root = true; % true for root, false for geometric.
    end

    % preallocate onset
    % chroma_len is set by finding the last note off in the midi file
    % and converting to timebins
    chroma_len = aln_secs2TimeBin(max(notes(:, 6)), spectInfo, false);
    onsets = zeros(chroma_len, 1);

    % pull out midi startTimes, convert to timeBin indices
    startTimes = notes(:, 5);
    startBins = aln_secs2TimeBin(startTimes, spectInfo, false);

    % put a 1 in onsets for every onset in startBins
    for i = 1:length(startBins)
        onsets(startBins(i)) = 1;
    end

    % smoothing if smoothing flag is set
    if smoothing
        onsets = aln_onsUtil_smooth(onsets, smooth_ksize, smooth_use_root);
    end

end