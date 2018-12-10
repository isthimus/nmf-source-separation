% proof of concept source separate and play audio
% when i have all the bits working i'll generic-ify

% make sure the matab path is correct
run('./setpaths.m')

% pick up some paths to useful places
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

[audio_vec, Fs] = audioread(fullfile(DEV_DATA_PATH, 'TRIOS_vln_Db6_B6.wav'));

nmf_threshold = 0.0001;
p_nmf = @(V,W,H) (nmf_euclidian_norm(V, W, H, nmf_threshold));

init_K = 2; init_avg = 20;
p_init = @(freqBins, timeBins) (nmf_init_rand(freqBins, timeBins, init_K, init_avg));

% ---- below code straight from zhivomirov example. needs tweaking -------
% define the analysis and synthesis parameters
stft_wlen = 1024;
stft_hop = stft_wlen/8;
stft_nfft = 4*stft_wlen;
% generate analysis and synthesis windows
stft_anal_win = blackmanharris(stft_wlen, 'periodic');
stft_synth_win = hamming(stft_wlen, 'periodic');
% ------------------------------------------------------------------------

p_spect = @(x) stft(x, stft_anal_win, stft_hop, stft_nfft, Fs);
p_reconstruct = @(audio_spect, W, H) ...
    nmf_reconstruct_keepPhase (audio_spect, W, H, stft_anal_win, stft_synth_win, stft_hop, stft_nfft, Fs);

nmf_separate_sources(p_nmf, p_init, p_spect, p_reconstruct, audio_vec, 99);

