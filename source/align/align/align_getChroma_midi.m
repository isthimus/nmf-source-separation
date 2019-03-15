function chroma = align_getChroma_midi(notes, spectInfo, use_vel)
    % extracts a chroma estimate from an unaligned midi score, for alignmment

    % if use_vel is not given, default to false
    if nargin < 3
        use_vel = false;
    end

    % get the right bits out of spectInfo
    hop = spectInfo.hop;
    fs = spectInfo.fs;
    wlen = spectInfo.wlen;
    audio_len_samp = spectInfo.audio_len_samp;
    num_time_bins = spectInfo.num_time_bins;

    % build a "piano roll" matrix
    % pianoRoll_tb(n) gives the time bin corresponding to pianoRoll(:, n).
    % derived using pianoRoll_t which gives the time in seconds for pianoRoll(:, n).
    [pianoRoll, pianoRoll_t, pianoRoll_nn] = piano_roll(notes_thisChan, 1, hop/fs);
    pianoRoll_tb = align_secs2TimeBin(pianoRoll_t, fs, wlen, hop, audio_len_samp);

    % tidy up the edges of the pianoRoll so its prefectly aligned with timebin indices
    pianoRoll_tbAligned = zeros(size(pianoRoll, 1), num_time_bins)
    for i = 1:length(pianoRoll_tb)
        pianoRoll_tbAligned(:, pianoRoll_tb(i)) = pianoRoll_tbAligned(:, pianoRoll_tb(i)) + pianoRoll(:, i);
    end

    % build chromagram from tidied up pianoRoll
    chroma = zeros(12, num_time_bins)
    for i = 1:12
        % indices_thisChroma is a vector of indices for 
        % all the rows in pianoRoll which map to row i in "chroma" 
        indices_thisChroma = mod(pianoRoll_nn, 12) + 1 == i

        % sum up the values in the pianoRoll rows, put in chromagram 
        chroma(i, :) = sum(pianoRoll(indices_thisChroma,:))
    end

    % if we arent using vel, just set all nonzero elements of chromagram to 1
    if ~ use_vel
        % the "1 *" makes it into a real array not a logical array
        chroma = 1 * (chroma ~= 0)
    end
end

%{
    % preallocate chroma array
    chroma = zeros(12, spectInfo.num_time_bins);

    % get chroma val, start, end, and (vel)
    nns = notes(:, 3);
    vels = notes(:, 4) ./ 127; % normalise vels to 1
    start_sec = notes(:, 5);
    end_sec = notes(:, 6);

    chroma_vals = mod (nns, 12) + 1; % +1 for matlab indexing. sigh
    
    start_bins = align_secs2TimeBin( ...
        start_sec, ...
        spectInfo.fs, ...
        spectInfo.wlen, ...
        spectInfo.hop, ...
        spectInfo.audio_len_samp ...
    );

    end_bins = align_secs2TimeBin( ...
        end_sec, ...
        spectInfo.fs, ...
        spectInfo.wlen, ...
        spectInfo.hop, ...
        spectInfo.audio_len_samp ...
    );        

    % paint chroma according to values (norm vel to 1 for noo)
    if use_vel
        for i = 1:size(notes,1)
            chroma(chroma_vals(i), start_bins(i) : end_bins(i)) = vels(i);
        end
    else
        for i = 1:size(notes,1)
            chroma(chroma_vals(i), start_bins(i) : end_bins(i)) = 1;
        end
    end
%}