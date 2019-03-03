% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('./setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

% get audio from file, along with midi score information
[audio_vec, fs] = audioread(fullfile(TRIOS_DATA_PATH, 'lussier/bassoon.wav'));
sound(audio_vec, fs);
wait_returnKey
midi = readmidi (fullfile(TRIOS_DATA_PATH, 'lussier/bassoon.mid'));

% build nmf function
nmf_statPoint_thresh = 0.00001; % detect stationary point at 0.001% per 1000 iterations
nmf_max_iter = 1000000;         % max iterations 1'000'000
nmf_done_thresh = 0;            % use only stationary point detection 
p_nmf = @(V,W,H) ...
    nmf_is(V, W, H, nmf_statPoint_thresh, nmf_max_iter, nmf_done_thresh);

% define the stft analysis and synthesis parameters
wlen = 1024; 
hop = 1024/8; 
nfft = 1024*4;
analwin = blackmanharris(wlen, 'periodic'); 
synthwin = hamming(wlen, 'periodic');

% build spectrum and reconstruction functions
p_spect = @(x) ...
    stft(x, analwin, hop, nfft, fs);
p_reconstruct = @(audio_spect, W, H) ...
    nmf_reconstruct_keepPhase (audio_spect, W, H, analwin, ...
                               synthwin, hop, nfft, fs);

% below will be superceded when we have a proper sep_sources_aligned pipeline
% make W,H masks from midi
[W_mask, H_mask] = align_makeMasks_midi (midi, length(audio_vec), fs, wlen, hop, nfft, 0);
% build init function
p_init = @(freqBins, timeBins) ...
    nmf_init_zeroMask(freqBins, timeBins, W_mask, H_mask);

% perform source separation with max plotting level 
sources_out = nmf_separate_sources(p_nmf, p_init, p_spect, p_reconstruct, audio_vec, 99);