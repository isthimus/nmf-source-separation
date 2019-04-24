function out = midiAudioClick(notes, audio, spectInfo)
	% audible test of midi alignment. creates a stereo track with the 
	% audio on one side and a click on the other side whenever theres a midi note
	% use with sound(midiAudioClick(myAudio, myMidiNotes))
	% nb the matlab audio functions produce column vectors by default

	% unpack spectInfo
	fs = spectInfo.fs;

	% preconditions
	assert (size(audio, 2) == 1, "stereo tracks and row vectors not supported!");

	% preallocate return value
	out = zeros(size(audio, 1), 2);
	out (:, 1) = audio;

	startTimes = notes (:, 5); % in s
	startTimes = floor((startTimes * fs)) + 1; % now in samples. +1 for matlab indexing#

	% put a click around the note start time
	for i = 1:length(startTimes)
		out(startTimes(i), 2) = 1;
		if startTimes(i) > 1
			out(startTimes(i) - 1, 2) = 0.5;
		end
		if startTimes(i) < length(startTimes)
			out(startTimes(i) + 1, 2) = 0.5;
		end
	end

	% implicitly return out
end