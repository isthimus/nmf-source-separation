% lil plotting function to test align_dtw_onset 
% and generally get stuff ready for benching
clear
rng(0);

PLOT = true;

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

% functions to test
% interface: test_func(notes, audio, spectInfo)
test_funcs = { ... 
    freakout
};

% midi files
midi_paths = {
    freakout
};

% audio files
audio_paths = {
    freakout
};

assert(length(audio_paths) == length(midi_paths), "audio_paths and midi_paths are different lengths");


% build a spectInfo
spectInfo_proto = struct( ... 
    "wlen"         , 1024, ... 
    "nfft"         , 1024 * 4, ...
    "hop"          , 1024 / 4, ...
    "analwin"      , blackmanharris(1024, 'periodic'), ...
    "synthwin"     , hamming(1024, 'periodic'), ...
    "fs"           , fs, ... 
);

% for each test function...
for i = 1:length(test_funcs)
    % ...and each piece of audio/midi
    for j = 1:length(audio_paths)       
        disp('.');

        % open midi file
        notes_ground = midiInfo(readmidi(audio_paths{j}), 0);
        notes_warped = midi_randWarp(notes);

        % open audio file and get name
        audio_path = audio_paths{j};
        [audio, fs] = audioread(audio_path);
        [~, audioName, ~] = fileparts(audio_path);

        % get spectInfo, take spect
        spectInfo = spectInfo_proto;
        spectInfo.fs = fs;
        [spect, spectInfo] = nmf_spect(audio, spectInfo);
        assert(checkSpectInfo(spectInfo), "bad spectInfo");

        % apply func
        test_func = test_funcs{i};
        notes_aligned = test_func(notes,  audio, spectInfo);

        if PLOT 
            % take piano rolls, make them the same size
            pRoll_warped = piano_roll(notes_warped);
            pRoll_aligned = piano_roll(notes_aligned);

            len_warped = size(pRoll_warped, 2);
            len_aligned = size(pRoll_aligned, 2);

            if len_warped > len_aligned
                pRoll_aligned = ...
                    [pRoll_aligned, zeros(size(pRoll_aligned,1), len_warped-len_aligned)];
            else
                pRoll_warped = ...
                    [pRoll_warped, zeros(size(pRoll_warped,1), len_aligned-len_warped)];
            end

            % do some plotting shit who knows
            % im gonna get off my computer and go call my mum now kthx
            
        end

        


    end
end

