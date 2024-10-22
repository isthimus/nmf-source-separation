function chroma = aln_getChroma_midi(notes, spectInfo, use_vel)
    % extracts a chroma estimate from an unaligned midi score, for alignmment

    % if use_vel is not given, default to false
    if nargin < 3
        use_vel = false;
    end

    % unpack spectInfo
    hop = spectInfo.hop;
    fs = spectInfo.fs;

    % build a "piano roll" matrix
    % pianoRoll_tb(n) gives the time bin corresponding to pianoRoll(:, n).
    % derived using pianoRoll_t which gives the time in seconds for pianoRoll(:, n).
    [pianoRoll, pianoRoll_t, pianoRoll_nn] = piano_roll(notes, 1, hop/fs);
    pianoRoll_tb = aln_secs2TimeBin(pianoRoll_t, spectInfo, false);

    % tidy up the edges of the pianoRoll so its prefectly aligned with timebin indices
    chroma_len = pianoRoll_tb(end);
    pianoRoll_tbAligned = zeros(size(pianoRoll, 1), chroma_len);
    for i = 1:length(pianoRoll_tb)
        pianoRoll_tbAligned(:, pianoRoll_tb(i)) = pianoRoll_tbAligned(:, pianoRoll_tb(i)) + pianoRoll(:, i);
    end

    % build chromagram from tidied up pianoRoll
    chroma = zeros(12, chroma_len);
    for i = 1:12
        % indices_thisChroma is a vector of indices for 
        % all the rows in pianoRoll which map to row i in "chroma" 
        indices_thisChroma = ...
            aln_nn2ChromaBin(pianoRoll_nn) == i;
        % sum up the values in the pianoRoll rows, put in chromagram 
        chroma(i, :) = sum(pianoRoll_tbAligned(indices_thisChroma,:), 1); 
    end

    % if we arent using vel, just set all nonzero elements of chromagram to 1
    if ~use_vel
        % the "1 *" makes it into a real array not a logical array
        chroma = 1 * (chroma ~= 0);
    end
end