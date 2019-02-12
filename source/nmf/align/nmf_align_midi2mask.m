function [W_mask, H_mask] = nmf_align_midi2mask (midi, audio_spect, fs, wlen,hop)
    % given a midi representation of the notes in a piece of audio, builds masks for W and H
    % to allow score - aware initialisation. !!! might be able to get away with passing in 
    % nfft, hop, audio_len over audio_spect. better?? less data but more brittle.
    % fs is needed because midi times are in seconds.
    % !!! does nfft == num_freq_bins?
    % !!! ensure that piano roll "pixel size" smaller than an stft frame (i think smaller than hop)
    % this is to make sure that rows of H are continuous

    % extract the notes array and build a "piano roll" matrix where rows are midi note numbers
    % pianoRoll_tb(n) gives the fft time bin corresponding to pianoRoll(:, n).
    % derived using pianoRoll_t which gives the time in seconds for pianoRoll(:, n).
    notes = midiInfo(midi, 0);
    [pianoRoll, pianoRoll_t, pianoRoll_nn] = piano_roll(notes);
    pianoRoll_tb = arrayfun (                          ...
        @(t) secs2timeBin(t,fs,wlen,hop) ,             ...
        pianoRoll_t                                   ...
    );

    % figure out how many note nums actually used, for preallocation.
    num_notes_used = size(pianoRoll,1)
    for i = 1:size(pianoRoll,1) % iterate over note numbers in piano roll
        if all(pianoRoll(i,:) == 0) 
            num_notes_used = num_notes_used - 1;
        end;
    end

    % preallocate W, H
    [num_freq_bins, num_time_bins] = size (audio_spect);
    W_mask = zeros(num_freq_bins, num_notes_used);
    H_mask = zeros(num_notes_used, num_time_bins); 

    % iterate over piano roll and fill out W_mask, H_mask
    WH_i = 1;                       % WH_i  is which row/col of W/H we're on.
    for PR_i = 1:size(pianoRoll,1)  % PR_i  is the current row of the piano roll matrix

        % skip empty rows
        % this case increments PR_i but not WH_i, hence the two iterators
        if all(pianoRoll(i,:) == 0) continue; end; 

        % this PR row is not empty - so this note number will have a column in W
        % so init this column of W_mask
        freq_index = notenum2freqbin (pianoRoll_nn(PR_i), num_freq_bins, fs) % !!! i really hope num_freq_bins == nfft in all cases...........
        while (freq_index < num_freq_bins)
            % if freq_index is too high for the fft this loop is never entered. leaves an empty col of W
            % kind of convenient behaviour but !!! should it warn/error??
            W_mask(freq_index, WH_i) = 1;
            freq_index = freq_index * 2;
        end

        % fill in corresponding row of H_mask
        for PR_j = 1:size(pianoRoll, 2)
            if pianoRoll(PR_i, PR_j) ~= 0
                H_mask(WH_i, pianoRoll_tb(PR_j)) = 1; % NB: relies on |pianoRoll_tb(n+1) - pianoRoll_tb(n)| <= 1. see triple pling in header comment
            end
        end 

        % we've filled in a row/col - increment WH_i
        WH_i = WH_i + 1;0;

    end

end