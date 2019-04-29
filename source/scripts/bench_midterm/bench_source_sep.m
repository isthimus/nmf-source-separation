% benchmark the whole source separation procedure with a wide range of parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% zero for just logs and no plotting, 1 to follow preference in testdefs
PLOT_FIGS = 0;

% if truthy, bench will not stop at an nmf exception, but will skip to the next test
SUPRESS_NMF_EXCEPTIONS = false;  

% set to a string and results array will be saved to a .mat file at that path
RESULTS_SAVE_PATH = 'bench_source_sep_results.mat';
                                                            
% constrain PLOT_FIGS to 0 or 1
if PLOT_FIGS ~= 0
    PLOT_FIGS = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCRIPT SETUP                                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('../setpaths.m')
PROJECT_PATH = fullfile('../../..');
BENCH_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/bench');

rng(27011996); % seed randomness 

% log to terminal. last fprintf statement til DISPLAY RESULTS stage.
fprintf('########################################\n')
fprintf('TEST TYPE - %s\n', mfilename())
fprintf('########################################\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TABLES                                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% paths to both mixture audio and ground truth
% first item in a row is a path to the mixture (mono, for now)
% rest of row is taken up with ground truth source paths. 
% leave empty spaces where necessary.
audio_filepaths = {

    %{    
    % vln 2 note
    fullfile(BENCH_DATA_PATH, 'TRIOS_vln2Note_M.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_vln2Note_S1.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_vln2Note_S2.wav'), ...
        [],[],[],[],[],[],[],[],[],[],[];
    
    % doorbell
    fullfile(BENCH_DATA_PATH, 'doorbell_M.wav'), ...
        fullfile(BENCH_DATA_PATH, 'doorbell_S1.wav'), ...
        fullfile(BENCH_DATA_PATH, 'doorbell_S2.wav'), ...
        [],[],[],[],[],[],[],[],[],[],[];

    % basoon solo
    fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bassoon_M.wav'), ...   
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bassoon_S1.wav'), ...  
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bassoon_S2.wav'), ...  
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bassoon_S3.wav'), ...  
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bassoon_S4.wav'), ...  
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bassoon_S5.wav'), ...  
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bassoon_S6.wav'), ...  
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bassoon_S7.wav'), ...  
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bassoon_S8.wav'), ...  
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bassoon_S9.wav'), ...
        [],[],[],[];
%}

%{
    % bassoon with trumpet long notes
    fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_M.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S1.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S2.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S3.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S4.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S5.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S6.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S7.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S8.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S9.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S10.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S11.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S12.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnTpt_S13.wav');

    % basson with sin wave
    fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnSin_M.wav'), ...    
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnSin_S1.wav'), ...   
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnSin_S2.wav'), ...   
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnSin_S3.wav'), ...   
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnSin_S4.wav'), ...   
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnSin_S5.wav'), ...   
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnSin_S6.wav'), ...   
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnSin_S7.wav'), ...   
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnSin_S8.wav'), ...   
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnSin_S9.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_lussier_bsnSin_S10.wav'), ...
        [],[],[];
%}
    % take five intro (drums and piano)
    fullfile(BENCH_DATA_PATH, 'TRIOS_takeFive_M.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_takeFive_S1.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_takeFive_S2.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_takeFive_S3.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_takeFive_S4.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_takeFive_S5.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_takeFive_S6.wav'), ...
        fullfile(BENCH_DATA_PATH, 'TRIOS_takeFive_S7.wav');
};


% create audio_vectors with same dimension as audio_filepaths, plus 2 extra columns
% one for name and one for Fs
audio_vectors = cell (size(audio_filepaths, 1), size(audio_filepaths,2) + 2);

% populate audio_vectors
% iterate over rows of audio_filepaths
for i = 1:size(audio_filepaths,1)
    Fs = [];

    % get each file
    for j = 1:size(audio_filepaths,2)
        if ~isempty(audio_filepaths{i,j})
            [audio_vectors{i,j+2}, Fs] = audioread(audio_filepaths{i,j});
        end
    end

    % fill in name and Fs in 1st and 2nd col respectively
    [~, audio_name, ~] = fileparts(audio_filepaths{i, 1});
    audio_vectors{i,1} = audio_name;
    audio_vectors{i,2} = Fs;
end

analwin_dflt_1024  = blackmanharris(1024, 'periodic'); 
synthwin_dflt_1024 = hamming(1024, 'periodic');
hop_dflt_1024 = 1024/8;

hop_dflt_256 = 256/8;
analwin_dflt_256  = blackmanharris(256, 'periodic'); 
synthwin_dflt_256 = hamming(256, 'periodic');

analwin_dflt_32  = blackmanharris(32, 'periodic'); 
synthwin_dflt_32 = hamming(32, 'periodic');
hop_dflt_32 = 32/8;

analwin_kaiserNoPR_1024 = kaiser(1024);
synthwin_kaiserNoPR_1024 = kaiser(1024);
hop_kaiserNoPR_1024 = 1024/4;

analwin_bhHamNoPR_1024  = blackmanharris(1024, 'periodic'); 
synthwin_bhHamNoPR_1024 = hamming(1024, 'periodic');
hop_bhHamNoPR_1024      = 1024/2;

% format:
% name, nmf_init_func, nmf_func, spect_func, recons_func, plot_level;
%   nmf_init_func prototype: (freqBins, timeBins, K) -> (W_init, H_init)
%   nmf_func prototype (V,W,H) -> (W_out, H_out, final_err, iterations)
%   spect_func prototype: (audio_vec, Fs) -> (spectrogram)
%   recons_func prototype: (orig_spect, W, H, Fs) -> (nsrc x nsamples array of sources)
testdefs = {
% Reconstruction
    "reconstruction:keepPhases_PR",                                                       ...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;

    "reconstruction:keepPhases_noPR_kaiser",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_kaiserNoPR_1024, hop_kaiserNoPR_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_kaiserNoPR_1024, synthwin_kaiserNoPR_1024, hop_kaiserNoPR_1024, 1024*8, Fs),            ...
        99;

    "reconstruction:keepPhases_noPR_bhHam",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_bhHamNoPr_1024, hop_bhHamNoPr_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_bhHamNoPr_1024, synthwin_bhHamNoPr_1024, hop_bhHamNoPr_1024, 1024*8, Fs),            ...
        99;

    "reconstruction:noPhases_PR",                                                       ...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_noPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;

    "reconstruction:noPhases_noPR_kaiser",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_kaiserNoPR_1024, hop_kaiserNoPR_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_noPhase(orig_spect, W, H,                            ...
            analwin_kaiserNoPR_1024, synthwin_kaiserNoPR_1024, hop_kaiserNoPR_1024, 1024*8, Fs),            ...
        99;

    "reconstruction:noPhases_noPR_bhHam",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_bhHamNoPr_1024, hop_bhHamNoPr_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_noPhase(orig_spect, W, H,                            ...
            analwin_bhHamNoPr_1024, synthwin_bhHamNoPr_1024, hop_bhHamNoPr_1024, 1024*8, Fs),            ...
        99;

% original POC - canary
    "eNorm_source_sep_orig",                                                                           ...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_euclidian_norm(V,W,H, 0.001, 100000, 0),                                          ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*1, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*1, Fs),            ...
        99;

% convergence % tests
    "convergence_thresh:0.01%",                                                                ...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_euclidian(V,W,H, 0.0001, 100000, 0),                                              ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;

    "convergence_thresh:0.1%",                                                                ...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_euclidian(V,W,H, 0.001, 100000, 0),                                              ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;

    "convergence_thresh:1%",                                                                ...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_euclidian(V,W,H, 0.01, 100000, 0),                                              ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;

    "convergence_thresh:5%",                                                                ...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_euclidian(V,W,H, 0.05, 100000, 0),                                              ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;

% different NMF update steps 
    "NMF_update_steps:euclidian",                                                                ...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_euclidian(V,W,H, 0.001, 100000, 0),                                              ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;


    "NMF_update_steps:euclidian_norm",                                                           ...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_euclidian_norm(V,W,H, 0.01, 100000, 0),                                         ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;


    "NMF_update_steps:IS_divergence",                                                            ...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;

    "NMF_update_steps:KL_divergence",                                                            ...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_kl(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;

% different fft padding ratio
    "fft_zeropadding:pad_1x_wlen_1024",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*1, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;

    "fft_zeropadding:pad_2x_wlen_1024",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*2, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;

    "fft_zeropadding:pad_8x_wlen_1024",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_1024, synthwin_dflt_1024, hop_dflt_1024, 1024*8, Fs),            ...
        99;

    "fft_zeropadding:pad_1x_wlen_256",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_256, hop_dflt_256, 256*1, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_256, synthwin_dflt_256, hop_dflt_256, 256*8, Fs),            ...
        99;


    "fft_zeropadding:pad_8x_wlen_256",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_256, hop_dflt_256, 256*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_256, synthwin_dflt_256, hop_dflt_256, 256*8, Fs),            ...
        99;

    "fft_zeropadding:pad_16x_wlen_256",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_256, hop_dflt_256, 256*16, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_256, synthwin_dflt_256, hop_dflt_256, 256*8, Fs),            ...
        99;

    "fft_zeropadding:pad_1x_wlen_32",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_32, hop_dflt_32, 32*1, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_32, synthwin_dflt_32, hop_dflt_32, 32*8, Fs),            ...
        99;

    "fft_zeropadding:pad_2x_wlen_32",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_32, hop_dflt_32, 32*2, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_32, synthwin_dflt_32, hop_dflt_32, 32*8, Fs),            ...
        99;

    "fft_zeropadding:pad_8x_wlen_32",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_32, hop_dflt_32, 32*8, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_32, synthwin_dflt_32, hop_dflt_32, 32*8, Fs),            ...
        99;

    "fft_zeropadding:pad_16x_wlen_32",...
        @(freqBins, timeBins, K) nss_init_rand(freqBins, timeBins, K, 10),                             ...
        @(V,W,H) nss_nmf_is(V,W,H, 0.01, 100000, 0),                                                     ...
        @(audio_vec, Fs) stft(audio_vec, analwin_dflt_32, hop_dflt_32, 32*16, Fs),   ...
        @(orig_spect, W, H, Fs) nss_reconstruct_keepPhase(orig_spect, W, H,                            ...
            analwin_dflt_32, synthwin_dflt_32, hop_dflt_32, 32*8, Fs),            ...
        99;
};

% list of benchmark functions 
% NB would like to only include estimated and ground truth sources
% can use other benchmarks to test final_err etc

% format:
% name, bench_func

% bench_func prototype - (se, s) -> any number of scalers
% where se is a nsrc x nsamples array of estimated sources
%       s  is a nsrc x nsamples array of ground truths
% the output will be captured in a cell array using nargout()
% thus benchmark funcs must not use varargout
benchmarks = {
    "avg_bss_eval", @avg_bss_eval;
%    "dummy_bench", @dummy_bench;
%   "PEASS", @PEASS;
%   "MSE",   @MSE;
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN BENCHMARKS                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% run every benchmark on every test with every audio vector
% and collate in results array
% results array one larger in "benchmarks" dimension to store a "ran-to-completion" flag
results = cell(size(testdefs,1), size(audio_vectors,1), size(benchmarks,1) + 1);
for test_i = 1:size(testdefs,1)
    for audio_i = 1:size(audio_vectors,1)

        % print something each test to show aliveness
        if audio_i == 1; fprintf('\n'); end
        fprintf('.')
        
        % get all the values from the testdef
        % if PLOT_FIGS=0 plot_level will be forced to 0
        init_func   = testdefs{test_i, 2};
        nmf_func    = testdefs{test_i, 3};
        spect_func  = testdefs{test_i, 4};
        recons_func = testdefs{test_i, 5};
        plot_level  = testdefs{test_i, 6} * PLOT_FIGS; 

        % get the mixture, the original sources, and Fs
        Fs = audio_vectors{audio_i, 2};
        audio_mixture = audio_vectors{audio_i, 3};
        am_L = length(audio_mixture);

        audio_groundtruth = audio_vectors(audio_i, 4:end);        
        audio_groundtruth = [audio_groundtruth{:}].'; % unpack cellArr to matrix
        % include Fs in spect/recons funcs and K in init func now that we know them
        % couldnt include in testdef because they differ between audio vectors
        % init_func is free to ignore K if benching SASS, testing wrong K-val, etc. 
        K = size(audio_groundtruth,1);
        init_func_k = @(freqBins, timeBins) init_func(freqBins, timeBins, K);
        spect_func_fs =  @(audio_vec) spect_func(audio_vec, Fs);
        recons_func_fs = @(original_spect, W,H) recons_func(original_spect, W,H, Fs);

        try
            % attempt source separation
            tic()
            sources_out = nss_separate_sources(     ...
                nmf_func,                           ... 
                init_func_k,                        ...
                spect_func_fs,                      ...
                recons_func_fs,                     ...
                audio_mixture,                      ...
                plot_level                          ...
            );
            separationTime= toc();
            audio_groundtruth = audio_groundtruth(:, 1:size(sources_out, 2)); 

            % separation ran to completion - store completion time in "ran to completion" field
            results{test_i,audio_i,1} = {separationTime + eps};
            skip_bench = false;

        catch ME
            % separation did not run to completion - store 0 in ran-to-completion field
            results{test_i,audio_i,1} = {0};
            skip_bench = true;                   
            
            % rethrow, or just continue benchmarking if SUPPRESS_NMF_EXCEPTIONS is true
            if ~SUPRESS_NMF_EXCEPTIONS
                rethrow(ME);
            end
        end

        % no point running benchmarks if test didnt complete - continue to next test
        if skip_bench; continue; end

        % iterate over benchmarks
        for benchmark_i = 1:size(benchmarks,1)

            % get bench func, perform bench, store results
            bench_func = benchmarks{benchmark_i, 2};
            bench_result = cell(1, nargout(bench_func));
            [bench_result{:}] = bench_func(sources_out, audio_groundtruth);
            results{test_i, audio_i, benchmark_i + 1} = bench_result;
            
            % if a save location for result is given, save to there
            if ~isempty (RESULTS_SAVE_PATH)
                save(RESULTS_SAVE_PATH, 'results')
            end
        end

    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DISPLAY RESULTS                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NB: BENCHMARK DSPLAY MUST BE NULL-AWARE
[T, A, B] = size(results);

for b = 1:B

    if b == 1
        bench_name = 'ran to completion';
    else
        bench_name = benchmarks{b-1,1};
    end

    fprintf('----------------------------------------\n')
    fprintf('Benchmark Name: %s\n', bench_name)
    fprintf('----------------------------------------\n')

    for a = 1:A
        fprintf('%s:\n', audio_vectors{a,1})

        for t = 1:T
            fprintf('\t%s ', testdefs{t,1});
        
            result = results{t, a, b};
            for i = 1:size(result,2)
                if ~isempty(result{i})
                    assert(isequal(size(result{i}), [1,1]), ...
                        "benchmarks should give lists of scalars as output!");
                    fprintf ('%d ', result{i})
                else
                    fprintf('%d ', 0 + 2*eps);
                end
            end

        fprintf('\n');
        end
    end
end

[T, A, B] = size(results);
r1 = cell(size(results));
r2 = cell(size(results));
r3 = cell(size(results));

for b = 1:B

    for a = 1:A

        for t = 1:T
        
            result = results{t, a, b};
            r1 {t,a,b} = result{1}
            r2 {t,a,b} = result{2}
            r3 {t,a,b} = result{3}

            for i = 1:size(result,2)
                if ~isempty(result{i})
                    assert(isequal(size(result{i}), [1,1]), ...
                        "benchmarks should give lists of scalars as output!");
                    fprintf ('%d ', result{i})
                else
                    fprintf('%d ', 0 + 2*eps);
                end
            end

        fprintf('\n');
        end
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END OF SCRIPT    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SDR_avg, SIR_avg, SAR_avg] = avg_bss_eval (se, s)
    % average the SDR, SIR and SAR scores from bss_eval
    % makes the resuts viewable as a single number

    fprintf('|')
    [SDR, SIR, SAR, ~] = bss_eval_sources(se, s);
    SDR_avg = mean(SDR);
    SIR_avg = mean(SIR);
    SAR_avg = mean(SAR);
end

function out = dummy_bench (se,S)
    out = 1;
end

function out = vec_same_length(L, vec)
    if length(vec) < L
        out = [vec; zeros(L - length(vec), 1)];
    else
        out = vec(1:L)
    end
end