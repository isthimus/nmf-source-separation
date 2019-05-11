% bringing up SASS
clear

% setup
% cd to the folder this script is in
script_path = mfilename('fullpath');
if ispc
    script_path = script_path(1: find(script_path == '\', 1, 'last'));
elseif isunix
    script_path = script_path(1: find(script_path == '/', 1, 'last'));
end
cd(script_path)

% setup matlab path and pick up some useful path strings
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
PHENICX_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/PHENICX');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');
run(fullfile(PROJECT_PATH, 'source/scripts/setpaths.m'));

% get some midi and some audio
notes = midiInfo(readmidi("./tmp/triosLussierMix.mid"), 0);
[audio, fs] = audioread(fullfile(TRIOS_DATA_PATH, "lussier/mix.wav"));

% build a spectInfo
spectInfo = struct( ... 
    "wlen"         , 4096, ... 
    "nfft"         , 4096 * 4, ...
    "hop"          , 4096 / 8, ...
    "analwin"      , blackmanharris(4096, 'periodic'), ...
    "synthwin"     , hamming(4096, 'periodic'), ...
    "fs"           , fs, ... 
    "max_freq_bins", 1000 ...
);
    
% choose partials
run('../../source/user/gen_tuned_funcs');
spect_func = @nss_stft;
tol_func = @(Wm, Hm, si)aln_tol_lin(Wm,1, Hm, 10);
nmf_func = @nss_nmf_euclidian;
recons_func = @nss_reconstruct_fromTracks;

% do it
[sources_out, trackVec] = sepSources_scoreAware_plot ( ...
    notes,  ...
    audio,  ...
    spectInfo, ...
    spect_func,  ...
    alignOnset_tuned,  ...
    tol_func,  ...
    nmf_func,  ...
    recons_func ...
);

stem(trackVec);
wait_returnKey();
close all;
