% lil plotting function to test aln_align_dtw_onset 
% and generally get stuff ready for benching
clear
rng(0);

PLOT = false;
WRITE_TMP = true;
WRITE_TMP_UNALIGNED = true;

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
% interface: test_func(notes, audio, spect, spectInfo)
Ons_agress = @(s,si)aln_onsUtil_smooth(aln_onsUtil_leadingEdge(block_normalise(aln_onsUtil_specDiff_taxi(s,si),100,0),1),15);
Ons_cons   = @(s,si)aln_onsUtil_smooth(aln_onsUtil_leadingEdge(block_normalise(aln_onsUtil_specDiff_taxi(s,si),100,7),1), 15);
test_funcs = { ... 
    @(n,a,s,si)aln_align_dtw(n,a,si)
    @(n,a,s,si)aln_align_dtw_onset(n,a,s,si,Ons_agress)
    @(n,a,s,si)aln_align_dtw_onset(n,a,s,si,Ons_cons)
    @(n,a,s,si)aln_align_dtw_onset(n,a,s,si,Ons_agress, 0.8)
    @(n,a,s,si)aln_align_dtw_onset(n,a,s,si,Ons_cons, 0.8)
    @(n,a,s,si)aln_align_dtw_onset(n,a,s,si,Ons_agress, 0.3)
    @(n,a,s,si)aln_align_dtw_onset(n,a,s,si,Ons_cons, 0.3)
};

midi_stack( ...
            "./tmp/triosMozartMix.mid", ...
            fullfile(TRIOS_DATA_PATH, "mozart/piano.mid"), ...
            fullfile(TRIOS_DATA_PATH, "mozart/clarinet.mid"), ...
            fullfile(TRIOS_DATA_PATH, "mozart/viola.mid") ...
);
% midi files
midi_paths = {
    % fullfile(TRIOS_DATA_PATH, "mozart/clarinet.mid");
    "./tmp/triosMozartMix.mid"
};

% audio files
audio_paths = {
    % fullfile(TRIOS_DATA_PATH, "mozart/clarinet.wav");
    fullfile(TRIOS_DATA_PATH, "mozart/mix.wav");
};

assert(length(audio_paths) == length(midi_paths), "audio_paths and midi_paths are different lengths");


% build a spectInfo
spectInfo_proto = struct( ... 
    "wlen"         , 1024, ... 
    "nfft"         , 1024 * 4, ...
    "hop"          , 1024 / 4, ...
    "analwin"      , blackmanharris(1024, 'periodic'), ...
    "synthwin"     , hamming(1024, 'periodic'), ...
    "max_freq_bins", 300 ... 
);

% for each piece of audio/midi ...
for vec_i = 1:length(audio_paths)       
    % and each test function...
    for func_i = 1:length(test_funcs)
        % seed randomness so its the same for each func
        rng(vec_i * 9999);

        % open midi file
        notes_ground = midiInfo(readmidi(midi_paths{vec_i}), 0);
        notes_warped = midi_randWarp(notes_ground);

        % open audio file and get name
        audio_path = audio_paths{vec_i};
        [audio, fs] = audioread(audio_path);
        [~, audioName, ~] = fileparts(audio_path);

        % get spectInfo, take spect
        spectInfo = spectInfo_proto;
        spectInfo.fs = fs;
        [spect, spectInfo] = nss_stft(audio, spectInfo);
        assert(checkSpectInfo(spectInfo), "bad spectInfo");

        % apply func
        test_func = test_funcs{func_i};
        notes_aligned = test_func(notes_warped,  audio, spect, spectInfo);
        
        % save to file if flag is set
        if WRITE_TMP
            % store the aligned version
            filename = strcat("./tmp/" ,num2str(vec_i), "_", audioName,"_func#",num2str(func_i),".mid");
            writemidi(matrix2midi(notes_aligned), filename);
        end

        if WRITE_TMP_UNALIGNED 
            % store the prewarped midi
            filename = strcat("./tmp/" ,num2str(vec_i), "_", audioName,"_func#",num2str(func_i),"_orig.mid");
            writemidi(matrix2midi(notes_warped), filename);
        end

        % plot if flag is set
        if PLOT 
            % take piano rolls
            pRoll_ground = piano_roll(notes_ground);
            pRoll_warped = piano_roll(notes_warped);
            pRoll_aligned = piano_roll(notes_aligned);

            % plot pRoll against audio
            figure(1);
            subplot(2,1,1);
            imagesc(abs(spect));
            title(strcat("#", num2str(func_i) ," spectrogram"));
            subplot(2,1,2);
            imagesc(pRoll_aligned);
            title("realigned midi");

            % get piano roll lengths
            len_ground = size(pRoll_ground, 2);
            len_warped = size(pRoll_warped, 2);
            len_aligned = size(pRoll_aligned, 2);
            maxLen = max([len_warped, len_aligned, len_ground]); 

            % make all piano rolls the same size
            pRoll_ground = ...
                [pRoll_ground, zeros(size(pRoll_ground,1), maxLen - len_ground)];
            pRoll_warped = ...
                [pRoll_warped, zeros(size(pRoll_warped,1), maxLen - len_warped)];
            pRoll_aligned = ...
                [pRoll_aligned, zeros(size(pRoll_aligned,1), maxLen - len_aligned)];

            % plot pRolls against each other
            figure(2);
            subplot(3,1,1);
             imagesc(pRoll_warped);
             title(strcat("#", num2str(func_i) ," warped"));
            subplot(3,1,2);
             imagesc(pRoll_aligned);
             title("realigned");
            subplot(3,1,3);
             imagesc(pRoll_ground);
             title("ground");


            wait_returnKey()
            close all;

        end
        [mn, mdn, sd] = midi_avg_distance(notes_ground, notes_aligned);
        fprintf("func#%i : %.2f %.2f %.2f\n", func_i, mn, mdn, sd);
    end
    disp('#');
end

