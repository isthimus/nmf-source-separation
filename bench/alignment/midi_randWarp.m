function notes_warped = midi_randWarp(notes, maxWarp, numSegments)
    % split notes array into numSegments parts, 
    % linearly stretch or compress by up to maxWarp (factor is randomly chosen)
    % seed rng before using this if you want it to be repeatable!
    % return in notes_warped.
    
    % default args
    if nargin < 2
        maxWarp = 0.5;
    end
    if nargin < 3
        numSegments = 20;
    end
    assert(maxWarp < 1 && maxWarp > 0, "bad maxWarp argument")

    % figure out the different segments
    numNotes = size(notes,1);
    segHop = numNotes ./ numSegments; % the "exact" size of a segment. may be fractional
    seg_indices = floor(0:segHop:numNotes) + 1 % the segment boundaries
                                                % includes both 1 and numNotes + 1
                                                
    assert(length(seg_indices) == numSegments + 1);

    % iterate over each segment
    for i = 1:numSegments

        % get note delta times
        thisSeg = seg_indices(i):seg_indices(i+1)-1;
        theseNotes = notes(thisSeg, 5:6);
        firstStart = min(theseNotes(:,1)');
        noteDeltas = theseNotes - firstStart;

        % warp this seg
        warpFactor = (rand(1)-0.5) * 2 * maxWarp;
        noteDeltas = noteDeltas .* (1 + warpFactor);

        % write back into notes
        theseNotes = noteDeltas + firstStart;
        notes(thisSeg, 5:6) = theseNotes;

        
        % if we're not on the last segment... 
        if i < numSegments
            % ...get the first note onset of next seg, 
            % and warp by warpFactor to find start time of next seg.
            nextSegStart = notes(seg_indices(i+1), 5);
            nextSegDelta = nextSegStart - firstStart;
            nextSegDelta = nextSegDelta * (1+warpFactor);
            nextSegStart_new = firstStart + nextSegDelta;

            % realign the whole notes array based on the new start time
            segShift = nextSegStart_new - nextSegStart;
            notes(seg_indices(i+1):end, 5:6) = notes(seg_indices(i+1):end, 5:6) + segShift;
        end
        
    end 

    notes_warped = notes;
end