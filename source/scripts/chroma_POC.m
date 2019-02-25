% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('./setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

% get audio and midi from file
[audio_vec, Fs] = audioread(fullfile(TRIOS_DATA_PATH, 'brahms/horn.wav'));
midi = readmidi(fullfile(TRIOS_DATA_PATH, 'brahms/horn.mid'));
notes = midiInfo(midi, 0);

% take chromagram of signal
% frame advance is Fft_len divided by 4 - ie timebase is cfftlen/(4*Fs)
cfftlen = 2048;
C = chromagram_IF(audio_vec, Fs, cfftlen);
tt = [1:size(C,2)] * cfftlen/(4*Fs);

% get piano roll
[pianoRoll, pianoRoll_t] = piano_roll(notes, 0);
pianoRoll = [ zeros(size(pianoRoll,1),pianoRoll_t(1)*Fs) , pianoRoll];

% calc and display regular ol' spectrogram
subplot(3,1,1);
sfftlen = 512;
spectrogram(audio_vec,[],[], sfftlen, Fs, 'yaxis');

% clamp colormap to 60dB range, set spect axes to bottom 4kHz only
caxis(max(caxis) + [-60,0])
axis([0, length(audio_vec)/Fs, 0, 4000])
title('Spectrogram')

% now display chromagram
subplot(3,1,2);
C_dB = 20*log10(C+eps);
imagesc(tt, [1:12], C_dB)
axis xy
caxis(max(caxis) + [-60,0]) % clamp colormap again
title('Chromagram');

%{
subplot(3,1,3);
imagesc(pianoRoll);
title ('Piano Roll matrix');
%}