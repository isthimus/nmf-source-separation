% figure out the best hop sizes for a chroma extraction
clear % sigh...

% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('../setpaths.m')
PROJECT_PATH = fullfile('../../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

% empty spectInfo
spectInfo = struct();
tic
% getsome audio
[audio, fs] = audioread(fullfile(TRIOS_DATA_PATH, "/brahms/violin.wav"));
spectInfo.audio_len_samp = length(audio);

results = cell(1, 1);
for i = 0:2

    % build a spectInfo
    % using some params from eNorm_source_sep_POC
    spectInfo.wlen = 2048;
    spectInfo.nfft = spectInfo.wlen * 4;
    assert(spectInfo.wlen/(2^i * 4) > 32);
    spectInfo.hop = spectInfo.wlen/(2^i * 4);
    spectInfo.fs = fs;

    disp(spectInfo.hop);
    assert (mod(spectInfo.hop, 1) == 0, "DAMMIT JACK");

    % analysis and synth windows
    % !!! should be in spectInfo?
    analwin = blackmanharris(spectInfo.wlen, 'periodic');
    synthwin = hamming(spectInfo.wlen, 'periodic');

    % build spectrogram function, take spect
    p_spect = @(x) ...
        stft(x, analwin, spectInfo.hop, spectInfo.nfft, spectInfo.fs);
    spect = p_spect(audio);

    % pick up num_time_bins/num_freq_bins
    spectInfo.num_freq_bins = size(spect, 1);
    spectInfo.num_time_bins = size(spect, 2);

    % extract chroma from audio
    chroma_audio = align_getChroma_audio (audio, spectInfo);

    results{i + 1} = chroma_audio;
end
toc

% save results
save(fullfile('results', mfilename()), 'results', 'spectInfo');
