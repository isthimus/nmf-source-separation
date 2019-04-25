% script to take an onset function, apply it to a given piece of audio and plot it.
% ONSET FUNCTION INTERFACE: onset_func(audio, spectInfo)

clear

PLOT = true; % plot results to screen
WRITE_TMP = false; % save results to a file in tmp

% cd to the folder this script is in
script_path = mfilename('fullpath');
if ispc
    script_path = script_path(1: find(script_path == '\', 1, 'last'));
elseif isunix
    script_path = script_path(1: find(script_path == '/', 1, 'last'));
end
cd(script_path)

% setup matlab path and pick up some useful path strings
PROJECT_PATH = fullfile('../../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
PHENICX_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/PHENICX');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');
run(fullfile(PROJECT_PATH, 'source/scripts/setpaths.m'));

% audio to plot
audio_paths = { ...
    fullfile(TRIOS_DATA_PATH, "mozart/piano.wav"), ... % piano with clear onsets - easy
    % fullfile(TRIOS_DATA_PATH, "mozart/clarinet.wav"), ... % clarinet - harder
    % fullfile(TRIOS_DATA_PATH, "schubert/violin.wav"), ... % violin - much harder i suspect
    % fullfile(TRIOS_DATA_PATH, "schubert/mix.wav"), ... % simplest mix i could find - hard but no need for perfection. 
    % fullfile(TRIOS_DATA_PATH, "schubert/cello.wav"), ... % "hey look, low pitched instruments are difficult without multires"
};

% functions to plot
test_funcs = { ...
    @(a, si) align_onset_energyFirstDiff(a, si, 10) ...
    @(a, si) align_onset_energyFirstDiff(a, si, 20) ...
    @(a, si) align_onset_energyFirstDiff(a, si, 30) ...
    @(a, si) align_onset_energyFirstDiff(a, si, 40) ...
};

% for each test function...
for i = 1:length(test_funcs)
    % ...and each piece of audio
    for j = 1:length(audio_paths)
        
        % open audio path and get name
        audio_path = audio_paths{j};
        [audio, fs] = audioread(audio_path);
        [~, audioName, ~] = fileparts(audio_path);

        % clear and rebuild spectInfo
        spectInfo = struct();
        spectInfo.fs = fs;

        % apply func
        test_func = test_funcs{i};
        onsets = test_func(audio, spectInfo);

        % make sure test_func is giving the right kind of result
        assert (all(size(onsets) == size(audio)), "audio size does not match onset vector size");
        
        % plot, if told to do so
        if PLOT
            figure(1);
             subplot(2,1,1);
             plot(audio);
             title(strcat("audio - ", audioName))
             subplot(2,1,2);
             plot(onsets);
             title(strcat("test function #", num2str(i)));
            
            % wait for return key 
            wait_returnKey();
            close all;
        end

        if WRITE_TMP
            % write onset to file as a wav
            onsets_norm = onsets / max(onsets);
            onset_filename = fullfile("./tmp", strcat(audioName,"_func#",num2str(i),".wav"));
            audiowrite(onset_filename, onsets_norm, fs);
        end

    end
end