% proof of concept to source separate and play audio
% when i have all the bits working i'll generic-ify

% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('./setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

% get audio from file
[audio_vec, Fs] = audioread(fullfile(TRIOS_DATA_PATH, 'lussier/bassoon.wav'));

% build nmf function
nmf_statPoint_thresh = 0.00001; % detect stationary point at 0.001% per 1000 iterations
nmf_max_iter = 1000000;         % max iterations 1'000'000
nmf_done_thresh = 0;            % use only stationary point detection 
p_nmf = @(V,W,H) ...
    nmf_euclidian_norm(V, W, H, nmf_statPoint_thresh, nmf_max_iter, nmf_done_thresh);

% build init function
init_K = 2; init_avg = 10;
p_init = @(freqBins, timeBins) ...
    nmf_init_rand(freqBins, timeBins, init_K, init_avg);

% define the stft analysis and synthesis parameters
stft_wlen = 1024; 
stft_hop = 1024/8; 
stft_nfft = 1024*4;
stft_analwin = blackmanharris(stft_wlen, 'periodic'); 
stft_synthwin = hamming(stft_wlen, 'periodic');

% build spectrum and reconstruction functions
p_spect = @(x) ...
    stft(x, stft_analwin, stft_hop, stft_nfft, Fs);
p_reconstruct = @(audio_spect, W, H) ...
    nmf_reconstruct_keepPhase (audio_spect, W, H, stft_analwin, ...
                               stft_synthwin, stft_hop, stft_nfft, Fs);

% perform source separation with max plotting level 
sources_out = nmf_separate_sources(p_nmf, p_init, p_spect, p_reconstruct, audio_vec, 99);
