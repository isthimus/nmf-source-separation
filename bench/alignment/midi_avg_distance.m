function [mean_on,sd_on, mean_off, sd_off] = midi_avg_distance (notesA, notesB)
    % finds the average and sd of the difference in onset/offset times between two midi files

    onsets_A  = notesA(:, 5);
    offsets_A = notesA(:, 6);

    onsets_B  = notesB(:, 5);
    offsets_B = notesB(:, 6);

    diff_onsets = abs(onsets_A - onsets_B);
    diff_offsets = abs(offsets_A - offsets_B);

    mean_on = mean(diff_offsets);
    mean_off = mean(diff_offsets);

    sd_on = std(diff_onsets);
    sd_off = std(diff_offsets);
end