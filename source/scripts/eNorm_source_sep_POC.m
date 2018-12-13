% proof of concept to source separate and play audio
% when i have all the bits working i'll generic-ify

% make sure the matab path is correct, and pick up some useful path strings
run('./setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

% get audio from file
[audio_vec, Fs] = audioread(fullfile(DEV_DATA_PATH, 'TRIOS_vln_Db6_B6.wav'));

% build nmf function
nmf_threshold = 0.0001;
p_nmf = @(V,W,H) nmf_euclidian_norm(V, W, H, nmf_threshold);

% build init function
init_K = 2; init_avg = 10;
p_init = @(freqBins, timeBins) ...
    nmf_init_rand(freqBins, timeBins, init_K, init_avg);

% define the stft analysis and synthesis parameters
stft_wlen = ceil(Fs/50); 
stft_hop = ceil(3*stft_wlen / 4); 
stft_nfft = 1024;
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
close all

