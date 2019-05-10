% random test file lol
clear;

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

% get some MIDI and audio
notes = midiInfo(readmidi("../alignment/tmp/triosLussierMix.mid"), 0);
[audio, fs] = audioread(fullfile(TRIOS_DATA_PATH, "lussier/mix.wav"));

% proportional hop
if 0
    for i = 0:5
        tic()
        fact = 2 ^ i;
        % build a spectInfo, update using nss_stft
        spectInfo = struct( ... 
            "wlen"         , fact * 1024, ... 
            "nfft"         , fact * 1024 * 4, ...
            "hop"          , fact * 1024 / 4, ...
            "analwin"      , blackmanharris(fact * 1024, 'periodic'), ...
            "synthwin"     , hamming(fact * 1024, 'periodic'), ...
            "fs"           , fs ... 
        );
        spectInfo.max_freq_bins = 400 * fact;  
        [spect, spectInfo] = nss_stft(audio, spectInfo);
        toc();
        imagesc(abs(spect));
        axis xy;  
        title(sprintf("proportional hop. wlen = %d", spectInfo.wlen));
        wait_returnKey();
        close all;
    end
end

% fixed hop
if 0
    for i = 0:5

        tic();
        fact = 2 ^ i;
        % build a spectInfo, update using nss_stft
        spectInfo = struct( ... 
            "wlen"         , fact * 1024, ... 
            "nfft"         , fact * 1024 * 4, ...
            "hop"          , 512, ...
            "analwin"      , blackmanharris(fact * 1024, 'periodic'), ...
            "synthwin"     , hamming(fact * 1024, 'periodic'), ...
            "fs"           , fs ... 
        );
        spectInfo.max_freq_bins = 400 * fact;  
        [spect, spectInfo] = nss_stft(audio, spectInfo);
        toc();
        imagesc(abs(spect));
        axis xy;  
        title(sprintf("constant hop. wlen = %d", spectInfo.wlen));
        wait_returnKey();
        close all;
    end
end

% effect of hop in detail
if 1 
    for i = 0:3

        tic();
        fact = 2 ^ i;
        % build a spectInfo, update using nss_stft
        spectInfo = struct( ... 
            "wlen"         , 4096, ... 
            "nfft"         , 4096 * 4, ...
            "hop"          , 128 * fact, ...
            "analwin"      , blackmanharris(4096, 'periodic'), ...
            "synthwin"     , hamming(4096, 'periodic'), ...
            "fs"           , fs ... 
        );
        spectInfo.max_freq_bins = 1600;  
        [spect, spectInfo] = nss_stft(audio, spectInfo);
        figure(i+1);
        imagesc(abs(spect));
        axis xy;  
        title(sprintf("hop = %d", spectInfo.hop));
        toc();
    end
    wait_returnKey();
    close all;
end

