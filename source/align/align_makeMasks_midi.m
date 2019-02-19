function [W_mask, H_mask] = align_makeMasks_midi (midi, audio_len_samp, fs, wlen, hop, nfft)
    % given a midi representation of the notes in a piece of audio, builds masks for W and H
    % to allow score - aware initialisation.

    % precondition checks
    % make sure wlen is a multiple of hop - this allows all time bins to line up exactly with a midi "pixel"
    assert( mod(wlen, hop) == 0, "wlen must be a whole number multiple of hop!");

    % extract the notes array and build a "piano roll" matrix where rows are midi note numbers
    % pianoRoll_tb(n) gives the fft time bin corresponding to pianoRoll(:, n).
    % derived using pianoRoll_t which gives the time in seconds for pianoRoll(:, n).
    notes = midiInfo(midi, 0);
    [pianoRoll, pianoRoll_t, pianoRoll_nn] = piano_roll(notes, 0, hop/fs);
    pianoRoll_tb = align_secs2TimeBin(pianoRoll_t, fs, wlen, hop);

    % figure out how many note nums actually used, for preallocation.
    num_notes_used = size(pianoRoll,1);
    for i = 1:size(pianoRoll,1) % iterate over note numbers in piano roll
        if all(pianoRoll(i,:) == 0) 
            num_notes_used = num_notes_used - 1;
        end;
    end

    % preallocate W, H
    num_time_bins = align_samps2TimeBin(audio_len_samp, wlen, hop);
    W_mask = zeros(nfft, num_notes_used);
    H_mask = zeros(num_notes_used, num_time_bins); 

    % iterate over piano roll and fill out W_mask, H_mask
    WH_i = 1;                       % WH_i  is which row/col of W/H we're on.
    for PR_i = 1:size(pianoRoll,1)  % PR_i  is the current row of the piano roll matrix

        % skip empty rows
        % this case increments PR_i but not WH_i, hence the two iterators
        if all(pianoRoll(i,:) == 0) continue; end; 

        % this PR row is not empty - so this note number will have a column in W

        % get note number of fundamental
        % also get nyquist limit "as a note number" (fractional)
        ny_nn = align_freq2nn_fractional(fs/2);
        fund_nn = pianoRoll_nn(PR_i);
        curr_nn = fund_nn;
        while (curr_nn < ny_nn)
            
            % write into all the harmonics of the fundamental for this column of W.
            % Since multiple NNs can end up in the same freq bin, its better
            % to multiply the nn and convert to a freq bin each time, rather than
            % finding one freq bin and multiplying that. This is why 
            % we needed nyquist limit "as an NN"
            W_mask(align_noteNum2FreqBin(curr_nn,nfft,fs), WH_i) = 1;
            curr_nn = curr_nn + fund_nn;
        end

        % fill in corresponding row of H_mask
        for PR_j = 1:size(pianoRoll, 2)
            if pianoRoll(PR_i, PR_j) ~= 0
                H_mask(WH_i, pianoRoll_tb(PR_j)) = 1;
            end
        end 

        % we've filled in a row/col - increment WH_i
        WH_i = WH_i + 1;

    end

end