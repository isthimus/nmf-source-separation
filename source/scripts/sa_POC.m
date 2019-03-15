% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('./setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

% go find some midi
midi = readmidi (fullfile(DEV_DATA_PATH, 'TRIOS_brahms_2bar.mid'));

% create a spectInfo (partially made up for this test script)
spectInfo.wlen = 1024;
spectInfo.nfft = spectInfo.wlen * 4;
spectInfo.num_freq_bins = spectInfo.nfft / 2 + 1;
spectInfo.hop = 1024/8;
spectInfo.fs = 44000; 

% build piano roll
notes = midiInfo(midi, 0);
% this is a slightly silly test script so we're just gonna make up spectInfo.audio_len_samp
% something something, "smoke test", something mumble something
% the "+44000" is just adding a second of silence on the end. other functions need to be able to handle it.
endTimes = notes (:, 6);

spectInfo.audio_len_samp = ceil(max(endTimes(:)) * spectInfo.fs) + 44000;
spectInfo.num_time_bins = align_samps2TimeBin(... 
	spectInfo.audio_len_samp, ... 
	spectInfo.wlen, ... 
	spectInfo.hop, ... 
	spectInfo.audio_len_samp ... 
);

[pianoRoll, pianoRoll_t, pianoRoll_nn] = piano_roll(notes, 0, spectInfo.hop/spectInfo.fs);
pianoRoll_tb = align_secs2TimeBin (pianoRoll_t, spectInfo.fs, spectInfo.wlen, spectInfo.hop, spectInfo.audio_len_samp);

% create a chromagram on the same timebase
chromagram = align_getChroma_midi(notes, spectInfo, 0);

disp(size(chromagram))
disp(size(pianoRoll))

i = 1;
while i * 12 <= size(pianoRoll)
	pianoRoll(i * 12,:) = 0.5
	i = i + 1;
end

figure (1)
imagesc(chromagram)
title('chromagram')

figure (2)
imagesc(pianoRoll)
title('pianoRoll')

%plot them both as subplots and make sure they line up