% script to take an spec diff function, apply it to a given piece of audio and plot it.
% SPEC DIFF INTERFACE: specDiff_func(spect, `spectInfo)
clear

PLOT = false; % plot results to screen
WRITE_TMP = true; % save results to a file in tmp
WRITE_TMP_12D = true; % more detailed treatment of 12D measures - write out to 12 individual files

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

% audio to plot
audio_paths = { ...
    fullfile(TRIOS_DATA_PATH, "mozart/piano.wav"), ... % piano with clear onsets - easy
%    fullfile(TRIOS_DATA_PATH, "mozart/clarinet.wav"), ... % clarinet - harder
%    fullfile(TRIOS_DATA_PATH, "mozart/viola.wav"), ... % viola with long notes - much harder i suspect
%    fullfile(TRIOS_DATA_PATH, "schubert/mix.wav"), ... % simplest mix i could find - hard but no need for perfection. 
%    fullfile(TRIOS_DATA_PATH, "take_five/mix.wav"), ... % suspect onset will be v good for drums
%    fullfile(TRIOS_DATA_PATH, "schubert/cello.wav"), ... % "hey look, low pitched instruments are difficult without multires!!1!"
};

% functions to plot
test_funcs = { ...
%    @align_onsUtil_specDiff_taxi
%    @align_onsUtil_specDiff_rectL2, ...
%    @(s,si)block_normalise(align_onsUtil_specDiff_taxi(s,si),100,-99)
    @(s,si)block_normalise(align_onsUtil_specDiff_taxi(s,si),100,0) % best 1D atm
    @(s,si)align_onsUtil_leadingEdge(block_normalise(align_onsUtil_specDiff_taxi(s,si),100,0))
%    @(s,si)block_normalise(align_onsUtil_specDiff_taxi(s,si),100,10) 
%   @(s,si)block_normalise(align_onsUtil_specDiff_rectL2(s,si),100,0)
%    @(s,si)block_normalise(align_onsUtil_specDiff_rectL2(s,si),100,-3)
%    @(s, si)block_normalise(align_onsUtil_specDiff_rectL2(s,si),100), ...
%   @(s,si)align_onsUtil_bandSplit(s,si,@align_onsUtil_specDiff_taxi) 
%    @(s,si)align_onsUtil_bandSplit(s,si,@align_onsUtil_specDiff_rectL2)
%   @(s,si)row_normalise(align_onsUtil_bandSplit(s,si,@align_onsUtil_specDiff_taxi),100) ...
%    @(s,si)row_normalise(align_onsUtil_bandSplit(s,si,@align_onsUtil_specDiff_rectL2), 100), ...
};

% create spectInfo
spectInfo = struct ( ...
    'wlen', 1024, ... 
    'nfft', 4*1024, ... 
    'hop', 1024/4 ... 
);
spectInfo.analwin = blackmanharris(spectInfo.wlen, 'periodic'); 
spectInfo.synthwin = hamming(spectInfo.wlen, 'periodic');

% array relating chroma bins to letter names
chromaToLetter = ["A", "Bb", "B", "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab"];

% for each test function...
for i = 1:length(test_funcs)
    % ...and each piece of audio
    for j = 1:length(audio_paths)       
        disp('.');

        % open audio path and get name
        audio_path = audio_paths{j};
        [audio, fs] = audioread(audio_path);
        [~, audioName, ~] = fileparts(audio_path);

        % take spect
        spectInfo.audio_len_samp = length(audio);
        spectInfo.fs = fs;
        spect = stft(audio, spectInfo.analwin, spectInfo.hop, spectInfo.nfft, spectInfo.fs);
        
        % update spectInfo
        spectInfo.num_freq_bins = size(spect, 1);
        spectInfo.num_time_bins = size(spect, 2);
        assert(checkSpectInfo(spectInfo), "bad spectInfo");

        % apply func
        test_func = test_funcs{i};
        onsets = test_func(spect, spectInfo);

        % make sure test_func is giving the right kind of result
        if iscolumn(onsets)
            % 1D measure
            assert(size(onsets,1) == size(spect, 2), "bad length output from 1D onset measure");
        else
            % only other allowable measure is 12D chroma based
            assert(isequal(size(onsets), [12,size(spect,2)]), "bad length output from 12D onset measure");
        end
       
        % plot, if told to do so
        if PLOT
            figure(1);
             subplot(2,1,1);
             imagesc(abs(spect(1:100, :)));
             title(strcat("audio - ", audioName))
             subplot(2,1,2);
             if iscolumn(onsets); 
                plot(onsets);
             else;           
                imagesc(onsets); 
             end
             title(strcat("test function #", num2str(i)));
            
            % wait for return key 
            wait_returnKey();
            close all;
        end

        if WRITE_TMP
            % write standard set of wavs to file
            filename = fullfile("./tmp", strcat(num2str(j), "_", audioName,"_func#",num2str(i),".wav"));
            write_to_wavFile(onsets, audio, spectInfo, filename);
        end

        if WRITE_TMP_12D && ~iscolumn(onsets)
            % write 12D measures in more detail if the flag is set
            for k = 1:12
                filename = strcat(num2str(j), "_", audioName,"_func#", num2str(i),"_", chromaToLetter(k),".wav");
                filename = fullfile("./tmp", filename);
                write_to_wavFile(onsets(k, :).', audio, spectInfo, filename);
            end
        end
    end
end
