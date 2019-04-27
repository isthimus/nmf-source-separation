% opens the midi files given in varargin, stacks them all up as separate tracks and
% writes them to filename_out.

% eventually lel

function midi_stack (filename_out, varargin)    

    maxTrackNum = 0;
    notes_out = [];
    for i = 1:length(varargin);
        % get the notes array
        notes = midiInfo(readmidi(varargin{i}), 0);

        % pull out the track numbers and channel numbers
        tracks_thisArg = unique(notes(:, 1));
        chans_thisArg  = unique(notes(:, 2));

        % not dealing with channels here
        assert(all(chans_thisArg) == 0, "eek, channels!");

        % decide on some new track numbers
        newTrackNums = (1:length(tracks_thisArg)) + maxTrackNum;
        maxTrackNum = max(newTrackNums);

        % write the new track numbers into the existing notes array
        t = notes(:, 1);
        for i = 1:length(tracks_thisArg)
            t(t == tracks_thisArg(i)) = newTrackNums(i);
            notes(:, 1) = t;
        end

        % append notes array to notes_out
        notes_out = [notes_out; notes];
    end

    % make sure each message has a unique number
    % nb - does not ensure correct ordering of message numbers.
    notes_out(:,7) = 0;
    notes_out(:,8) = 0;

    % write back to file
    r = readmidi(varargin{1});
    ticks_per_quarter = r.ticks_per_quarter_note;
    writemidi(matrix2midi(notes_out, ticks_per_quarter), filename_out);
end