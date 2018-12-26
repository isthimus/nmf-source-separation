% benchmark of various stft window choices, assessing quality of reconstruction. 

% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('../setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

% make some windows
blackmanharris_1024_p = blackmanharris(1024, 'periodic');
hamming_1024_p = hamming (1024, 'periodic');
rect_1024_selfInverse = ones(1024,1) * (1 / sqrt(2))
rect_1024_unity   = ones(1024,1)

% list some filenames. 
file_paths = {
    fullfile(DEV_DATA_PATH, 'rand.wav');
    fullfile(DEV_DATA_PATH, 'chirp.wav');
    fullfile(DEV_DATA_PATH, 'TRIOS_hn_6note.wav');
}



% make some stft param lists in a cell array
rng(0);
param_lists = { 
%     name                          anal_win           synth_win             hop    nfft
    "default",               blackmanharris_1024_p, hamming_1024_p,        1024/8, 1024*4;
    "rect_1024_selfInverse", rect_1024_selfInverse, rect_1024_selfInverse, 1024/2, 1024*4;
    "rect_1024_unity",       rect_1024_unity,       rect_1024_unity,       1024/2, 1024*4;

};


%--

% for each arg list in list:
    % print name

    % for each filename in list

        % get audio vector, sample rate, ?bitdepth

        % take stft and inverse stft 

        % graph original against recovered signal

        % print and accumulate MSE against filename (normalise?)

    % end

    % print avg MSE 

