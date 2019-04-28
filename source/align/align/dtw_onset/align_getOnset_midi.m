function onset = align_getOnset_midi(notes, spectInfo, smooth, smooth_ksize, smooth_use_root)
    % extract a 1D onset measure at timeBin rate from the midi file in notes
    % along with an audio onset detecting function and an alignment function,
    % can be used to align midi to audio

    % unpack spectInfo
    num_time_bins = spectInfo.num_time_bins;

    % default args
    if nargin < 3
        smooth = true;
    end
    if nargin < 4
        smooth_ksize = 5; 
    end
    if nargin < 5
        smooth_use_root = true; % true for root, false for geometric.
    end

    % pull out midi startTimes, convert to timeBin indices
    startTimes = notes(:, 5);
    startBins = align_secs2TimeBin(startTimes, spectInfo);

    % preallocate onset
    onset = zeros(num_time_bins, 1);

    % put a 1 in onsets for every onset in startBins
    for i = 1:length(startBins)
        onset(startBins(i)) = 1;
    end

    % smooth if smoothing flag is set
    if smooth
        align_onsetSmooth(onset, smooth_ksize, smooth_use_root);
    end

end