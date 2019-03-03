function [W_mask, H_mask] = align_makeMasks_midi (midi, audio_len_samp, fs, wlen, hop, nfft)
    % given a midi representation of the notes in a piece of audio, builds masks for W and H
    % to allow score - aware initialisation.
    % audio_len_samp can be optionally derived from the midi information - leave as []
    % NB if there is silence at the end of the audio then audio_len_samp MUST be provided

    % precondition checks
    % make sure wlen is a multiple of hop - this allows all time bins to line up exactly with a midi "pixel"
    assert( mod(wlen, hop) == 0, "wlen must be a whole number multiple of hop!");

    % extract the notes array and build a "piano roll" matrix where rows are midi note numbers
    % pianoRoll_tb(n) gives the fft time bin corresponding to pianoRoll(:, n).
    % derived using pianoRoll_t which gives the time in seconds for pianoRoll(:, n).
    notes = midiInfo(midi, 0);
    [pianoRoll, pianoRoll_t, pianoRoll_nn] = piano_roll(notes, 0, hop/fs);
    pianoRoll_tb = align_secs2TimeBin(pianoRoll_t, fs, wlen, hop);

    % pick up audio_len_samp if its not provided
    if isempty(audio_len_samp)
        endTimes = notes(:, 6);
        audio_len_samp = ceil(fs * max(endTimes(:)));
    end

    % figure out how many note nums actually used, for preallocation.
    num_notes_used = size(pianoRoll,1);
    for i = 1:size(pianoRoll,1) % iterate over note numbers in piano roll
        if all(pianoRoll(i,:) == 0) 
            num_notes_used = num_notes_used - 1;
        end
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
        if all(pianoRoll(PR_i,:) == 0) 
            continue; 
        end

        % this PR row is not empty - so this note number will have a column in W
        % build that column ...
        fund_freq = midi2freq(pianoRoll_nn(PR_i));
        nyquist_freq = fs/2;
        harmonics = fund_freq : fund_freq : nyquist_freq;
        bins = align_freq2FreqBin(harmonics, nfft, fs);
        
        % ... and write it into W
        W_mask(bins, WH_i) = 1;

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