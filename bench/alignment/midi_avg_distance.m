function [mean_out,median_out,sd_out] = midi_avg_distance (notesA, notesB)
    % finds the average and sd of the difference in onset/offset times between two midi files

    % pick up onset and offset times
    onsets_A  = notesA(:, 5);
    offsets_A = notesA(:, 6);
    onsets_B  = notesB(:, 5);
    offsets_B = notesB(:, 6);

    % take the difference between notes A and B
    diff_onsets  = abs(onsets_A - onsets_B);
    diff_offsets = abs(offsets_A - offsets_B);

    % compute mean, median and sd and retur
    mean_out   = mean([diff_offsets; diff_onsets], 1);
    median_out = median([diff_offsets; diff_onsets], 1);
    sd_out     = std([diff_offsets; diff_onsets],0 , 1);
end