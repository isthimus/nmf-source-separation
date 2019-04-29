function notes_warped = aln_midiPathWarp (notes, path, spectInfo)
    % get all midi event times in notes, as timebin indexes
    startTimes_bins = aln_secs2TimeBin(notes(:, 5), spectInfo, false);
    endTimes_bins   = aln_secs2TimeBin(notes(:, 6), spectInfo, false);

    % warp midi event times using "path" as warping path
    % ie replace each num in V with the index of the first instance in path which is >= that num
    % using find like this is the "sad painters algorithm" - seemingly inefficient
    % but we can't do it "properly" because ORDEREDNESS of *Times_bins is NOT GUARANTEED
    for i = 1:length(startTimes_bins)
        startTimes_bins(i) = find(path >= startTimes_bins(i), 1);
    end
    for i = 1:length(endTimes_bins)
        endTimes_bins(i) = find(path >= endTimes_bins(i), 1);
    end

    % get start and end times in seconds
    startTimes_secs = aln_timeBin2Secs(startTimes_bins, spectInfo);
    endTimes_secs = aln_timeBin2Secs(endTimes_bins, spectInfo);

    % build the realigned notes array, return
    notes_warped = notes;
    notes_warped(:, 5) = startTimes_secs;
    notes_warped(:, 6) = endTimes_secs;
end