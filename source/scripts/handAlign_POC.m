% learning how the midi library works and doing some
% basic testing of my helper functions

% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('./setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

% make and view a piano roll
midi = readmidi ('jesu.mid');
wlen = 1024;
nfft = wlen * 4;
hop = 1024/8;
fs = 44000;

% build piano roll. same code as align_makeMasks_midi. keep it that way.
notes = midiInfo(midi, 0);
[pianoRoll, pianoRoll_t, pianoRoll_nn] = piano_roll(notes, 0, hop/fs);
pianoRoll_tb = align_secs2TimeBin (pianoRoll_t, fs, wlen, hop);

% this is a slightly silly test script so we're just gonna make up audio_len_samp
% something something, "smoke test", something mumble something
% the "+44000" is just adding a second of silence on the end. makeMasks needs to be able to handle it.
endTimes = notes (:, 6);
audio_len_samp = ceil(max(endTimes(:)) * fs) + 44000;

% plot pianoRoll_t and pianoRoll_tb to make sure they correspond
%{
imagesc (pianoRoll_t, pianoRoll_nn, pianoRoll);
wait_returnKey();
stem (pianoRoll_t, pianoRoll_tb);
wait_returnKey();
pianoRoll_ts = pianoRoll_t * fs;
stem (pianoRoll_ts, pianoRoll_tb);
%}

% plot midi note number against linear-scale frequency.
% houston, do we have a problem here?
%{
figure;hold on
p1 = stem (align_noteNum2FreqBin([0:127], nfft/2, fs));
p2 = stem (align_noteNum2FreqBin([0:127], nfft, fs));
p3 = stem (align_noteNum2FreqBin([0:127], nfft*2, fs));
legend ([p1,p2,p3],'nfft = 2048', 'nfft = 4096', 'nfft = 8192')
title ("midi note num against freq bin for a linear frequency scale, fs =  44k");
xlabel ("midi note number");
ylabel ("freq bin");
%}

% run align_makeMasks_midi and plot along with piano roll for comparison
[W_mask, H_mask] = align_makeMasks_midi(midi, audio_len_samp, fs, wlen, hop, nfft);

figure (1);
imagesc(W_mask);
title("W\_mask");

figure (2);
imagesc(H_mask);
title("H\_mask");

figure (3);
imagesc(pianoRoll);
title("pianoRoll");

wait_returnKey
close all;