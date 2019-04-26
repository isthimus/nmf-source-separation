clear

% cd to the folder this script is in
script_path = mfilename('fullpath');
if ispc
    script_path = script_path(1: find(script_path == '\', 1, 'last'));
elseif isunix
    script_path = script_path(1: find(script_path == '/', 1, 'last'));
end
cd(script_path)

% setup matlab path and pick up some useful path strings
run('./setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

%{
spectInfo.wlen = 16;
spectInfo.hop = 8;
spectInfo.nfft = 16;
spectInfo.audio_len_samp =64;

analwin = blackmanharris(spectInfo.wlen, 'periodic');
synthwin = hamming(spectInfo.wlen, 'periodic');

% build spectrogram function
p_spect = @(x) ...
    stft(x, analwin, spectInfo.hop, spectInfo.nfft, spectInfo.fs);

audio = sin( 0.1 * pi * (1:spectInfo.audio_len_samp));
audio(6) = 99;
stem(audio);

spect = p_spect(audio);
spectInfo.num_freq_bins = size(spect, 1); 
spectInfo.num_time_bins = size(spect, 2);
disp(size(spect));

chroma = chromagram_IF(audio, spectInfo.fs, 4 * spectInfo.hop);
disp(spectInfo.audio_len_samp/spectInfo.hop);
disp(size(chroma));
%}

i = 10;

cnfft = 1024;
c_hop = cnfft/4; 
audio_len_samp = i * c_hop;

% the below sets A440 to be 8 samps/cycle, or 1/8 cycles/samp, or w = 2pi/8 
fs = 3520; 

% ranges from 2 cycles per 32 samp window, to 4 cycles per 32 samp window
note_freqs_c = 220 * 2.^((1/12) * (0:11));
note_freqs_dw = 2 .* pi .* note_freqs_c ./ fs;

base = 1:c_hop;
audio = [];
for j = 1:length(note_freqs_dw)   
    audio = [audio, sin(note_freqs_dw(j).*base)]; %#ok<AGROW>
end

% nice...
audio = zeros(1,(c_hop*12));
audio = [audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio audio ];
audio = audio(1:audio_len_samp);
audio((floor(audio_len_samp/c_hop)-1)* c_hop) = 99;

% audio = ones(2 * fs, 1);
% audio = audio(:);

% at this point we have all 12 notes, changing once every c_hop samples, 0
% based
% disp(size(audio));
chroma = chromagram_P(audio, fs, cnfft);
% assert(size(chroma, 2) + 1 == i);
disp([i, size(chroma,2)]);
%disp(i - size(chroma, 2));
%disp('---');
imagesc(chroma);
axis xy
colorbar;
wait_returnKey();
close all;

disp("done");