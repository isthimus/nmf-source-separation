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

% get audio from file, along with midi score information
[audio_vec, fs] = audioread(fullfile(TRIOS_DATA_PATH, 'lussier/bassoon.wav'));
%[audio_vec, fs] = audioread(fullfile(DEV_DATA_PATH, 'TRIOS_vln_Db6_B6.wav'));
midi = readmidi (fullfile(TRIOS_DATA_PATH, 'lussier/bassoon.mid'));
notes = midiInfo(midi, 0);
endTimes = notes (:, 6);
audio_len_samp = length(audio_vec);
%sound(audio_vec, fs);


% build nmf function
nmf_statPoint_thresh = 0.001; % detect stationary point at xxx per 1000 iterations
nmf_max_iter = 1000000;         % max iterations 1'000'000
nmf_done_thresh = 0;            % use only stationary point detection
p_nmf = @(V,W,H) ...
    nmf_is(V, W, H, nmf_statPoint_thresh, nmf_max_iter, nmf_done_thresh);
%{
p_nmf = @(V,W,H) deal(W,H);
%}

% define the stft analysis and synthesis parameters
spectInfo.fs = fs;
spectInfo.audio_len_samp = audio_len_samp;

wlen = 1024;
spectInfo.wlen = wlen;

hop = wlen/8;
spectInfo.hop = hop;

nfft = wlen;
spectInfo.nfft = nfft;

num_freq_bins = nfft/2 + 1;
spectInfo.num_freq_bins = num_freq_bins;

analwin = blackmanharris(wlen, 'periodic');
spectInfo.analwin = analwin;

synthwin = hamming(wlen, 'periodic');
spectInfo.synthwin = synthwin;

num_time_bins = align_samps2TimeBin(audio_len_samp, spectInfo);
spectInfo.num_time_bins = num_time_bins;
% build spectrum and reconstruction functions
p_spect = @(x) ...
    stft(x, spectInfo.analwin, spectInfo.hop, spectInfo.nfft, spectInfo.fs);
p_reconstruct = @(audio_spect, W, H) ...
    nmf_reconstruct_keepPhase (audio_spect, W, H, spectInfo.analwin, ...
                               spectInfo.synthwin, spectInfo.hop, spectInfo.nfft, spectInfo.fs);

% below will be superceded when we have a proper sep_sources_aligned pipeline
% make W,H masks from midi
[W_mask, H_mask] = align_makeMasks_midi (notes, spectInfo);
disp('W_mask');
disp(size(W_mask));
disp('H_mask');
disp(size(H_mask));

% build init function
p_init = @(freqBins, timeBins) ...
    nmf_init_zeroMask(W_mask, H_mask, struct('num_freq_bins',spectInfo.num_freq_bins,'num_time_bins', spectInfo.num_time_bins));

% perform source separation with max plotting level
sources_out = nmf_separate_sources(p_nmf, p_init, p_spect, p_reconstruct, audio_vec, 99);
