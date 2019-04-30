function [W_mask, H_mask, trackVec] = aln_makeMasks_midi (notes, spectInfo)
    % given a midi representation of the notes in a piece of audio, builds masks for W and H
    % to allow score - aware initialisation.
    % audio_len_samp can be optionally derived from the midi information - leave as []
    % NB if there is silence at the end of the audio then audio_len_samp MUST be provided

    % supress silly matlab warnings about semicolons
    %#ok<*NOSEL>

    % unpack spectInfo
    wlen = spectInfo.wlen;
    hop = spectInfo.hop;
    audio_len_samp = spectInfo.audio_len_samp;
    fs = spectInfo.fs;

    % precondition checks
    % make sure wlen is a multiple of hop - this allows all time bins to line up exactly with a midi "pixel"
    assert(mod(wlen, hop) == 0, "wlen must be a whole number multiple of hop!");

    % make sure there are no midi events after the end of the audio
    endTimes = notes(:, 6);
    lastEndTime_samp = ceil(fs * max(endTimes(:)));
    assert (lastEndTime_samp <= audio_len_samp, "midi events occur after stated end of audio!")

    % figure out the max track value and initialise W_mask and H_mask
    tracks = notes(:,1);
    maxTrack = max(tracks);
    W_mask = []; H_mask = []; trackVec = [];

    % iterate over all tracks in the midi file
    for track_i = 0:maxTrack

        % extract all the notes on this track
        % continue to next iteration if current track is empty
        notes_thisTrack = notes(tracks == track_i, :);
        if isempty (notes_thisTrack); continue; end;

        % build a "piano roll" matrix
        % pianoRoll_tb(n) gives the fft time bin corresponding to pianoRoll(:, n).
        % derived using pianoRoll_t which gives the time in seconds for pianoRoll(:, n).
        [pianoRoll, pianoRoll_t, pianoRoll_nn] = piano_roll(notes_thisTrack, 0, hop/fs);
        pianoRoll_tb = aln_secs2TimeBin(pianoRoll_t, spectInfo);

        % build masks for W and H based on this track
        [W_mask_curr, H_mask_curr] = mask_from_pRoll (pianoRoll, pianoRoll_nn, pianoRoll_tb, spectInfo);
        trackVec_curr = ones(size(H_mask_curr,1),1) * track_i;

        % concatenate the new masks with those obtained from other tracks
        % !!! BIG OL' PREALLOCATION PROBLEM HERE. but can't see a neat way round it :(
        % lots of arithmetic at start to decide exactly the size of W_mask, H_mask maybe?2
        W_mask = [W_mask, W_mask_curr]; % horizontal cat
        H_mask = [H_mask; H_mask_curr]; % vertical cat
        trackVec = [trackVec; trackVec_curr];
    end

    assert(iscolumn(trackVec), "internal: trackVec should be a column vector");

end

function [W_mask, H_mask] = mask_from_pRoll (pianoRoll, pianoRoll_nn, pianoRoll_tb, spectInfo)

    % unpack spectInfo
    nfft = spectInfo.nfft;
    num_freq_bins = spectInfo.num_freq_bins;
    num_time_bins = spectInfo.num_time_bins;
    fs = spectInfo.fs;

    % figure out how many note nums actually used, for preallocation.
    num_notes_used = size(pianoRoll,1);
    for i = 1:size(pianoRoll,1)
        % iterate over note numbers in piano roll and check if unused
        if all(pianoRoll(i,:) == 0)
            num_notes_used = num_notes_used - 1;
        end
    end

    % preallocate W, H
    W_mask = zeros(num_freq_bins, num_notes_used);
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
        bins = aln_freq2FreqBin(harmonics, spectInfo);
        bins = bins (bins <= num_freq_bins);

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