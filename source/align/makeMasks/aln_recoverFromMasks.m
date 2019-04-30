function sources_out = aln_recoverFromMasks(sources_note, trackVec)
    % recover original sources given the isolated notes,given the trackVec
    % which was calculated in the aln_makeMasks_midi function


    % figure out number of tracks and preallocate sources out
    numTracks = max(trackVec);
    sources_out = zeros(numTracks, size(sources_note,2));

    % go through trackVec and sum sources
    for i = 1:numTracks
        sources_out(i, :) = sum(sources_note(trackVec == i, :));
    end 
end