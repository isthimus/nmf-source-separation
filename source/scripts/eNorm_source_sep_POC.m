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
[audio_vec, Fs] = audioread(fullfile(DEV_DATA_PATH, 'TRIOS_vln_Db6_B6.wav'));

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
% bad old set
stft_wlen_bad = ceil(Fs/50); 
stft_hop_bad = ceil(3*stft_wlen_bad / 4); 
stft_nfft_bad = 1024;
stft_analwin_bad = blackmanharris(stft_wlen_bad, 'periodic'); 
stft_synthwin_bad = hamming(stft_wlen_bad, 'periodic');

% good new set
stft_wlen_good = 1024; 
stft_hop_good = 1024/8; 
stft_nfft_good = 1024*4;
stft_analwin_good = blackmanharris(stft_wlen, 'periodic'); 
stft_synthwin_good = hamming(stft_wlen, 'periodic');


% build spectrum and reconstruction functions
p_spect_bad = @(x) ...
    stft(x, stft_analwin_bad, stft_hop_bad, stft_nfft_bad, Fs);
p_reconstruct_bad = @(audio_spect, W, H) ...
    nmf_reconstruct_keepPhase (audio_spect, W, H, stft_analwin_bad, ...
                               stft_synthwin_bad, stft_hop_bad, stft_nfft_bad, Fs);

p_spect_good = @(x) ...
    stft(x, stft_analwin_good, stft_hop_good, stft_nfft_good, Fs);
p_reconstruct_good = @(audio_spect, W, H) ...
    nmf_reconstruct_keepPhase (audio_spect, W, H, stft_analwin_good, ...
                               stft_synthwin_good, stft_hop_good, stft_nfft_good, Fs);

% perform source separation with max plotting level 
sources_out = nmf_separate_sources(p_nmf, p_init, p_spect_bad, p_reconstruct_bad, audio_vec, 99);
sources_out = nmf_separate_sources(p_nmf, p_init, p_spect_good, p_reconstruct_good, audio_vec, 99);
close all