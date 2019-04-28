% full benchmark for onsets
tic
clear

% switches for this testbench
CALC = true;
BENCH = true;
PLOT = false;

% switches for gen_tables
table_switches = struct();
table_switches.TESTVECS_SOLO = true;
table_switches.TESTVECS_MIX = true;
table_switches.TESTDEFS_MAIN = true;
table_switches.TESTDEFS_NORMLEN = true;
table_switches.TESTDEFS_SPECTINFO = true;
table_switches.TESTDEFS_AGRESSION = true;

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

% generate testvector and test definition tables
[testVectors, testDefs] = gen_tables(table_switches);

% CALC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if CALC
    % for each testDef ...
    for td_i = 1:length(testDefs)
        testDef = testDefs{td_i};

        % ... and each testvector
        for tv_i = 1:length(testVectors)
            testVec = testVectors{tv_i};

            % open audio path
            [audio, fs] = audioread(testVec.audioPath);

            % take spect
            spectInfo = testDef.spectInfo;
            spectInfo.audio_len_samp = length(audio);
            spectInfo.fs = fs;
            spect = stft(audio, spectInfo.analwin, spectInfo.hop, spectInfo.nfft, spectInfo.fs);
            
            % update spectInfo
            spectInfo.num_freq_bins = size(spect, 1);
            spectInfo.num_time_bins = size(spect, 2);
            assert(checkSpectInfo(spectInfo), "bad spectInfo");
            
            % apply function
            onsets = testDef.testFunc(spect, spectInfo);
            assert(iscolumn(onsets), "bad output from a test func");

            % write onset values to a wav file at audio rate
            filename = test2FilePath(testDef, testVec);      
            write_to_wavFile (onsets, audio, spectInfo, filename);

            disp('.');
        end
        disp('#')
    end
end

% BENCH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if BENCH
    % ------------------------------------
    % overall results
    % ------------------------------------

    % make a cellarray to hold the outputs
    bench_results = { ...
        "filename", ...
        "false_pos_time_percent", ...
        "false_pos_rate_percent", ...
        "false_neg_rate_percent", ...
        "avg_response_time", ...
        "avg_level_onset", ...
        "avg_level_nonset" ...
    };
    currResRow = 2; % current row of results to write to

    % for each testDef ...
    for td_i = 1:length(testDefs)
        testDef = testDefs{td_i};

        % ... and each testvector
        for tv_i = 1:length(testVectors)
            testVec = testVectors{tv_i};

            % get onset back from file. pick up testName  while we're at it
            testName = strcat(testDef.name,"_",testVec.name);
            onset_path = test2FilePath(testDef, testVec);        
            [onsets, fs] = audioread(onset_path);

            % get the midi ground truth file, perform onset bench
            notes = midiInfo(readmidi(testVec.midiPath), 0);
            [falsePos_time, nFalsePos, nFalseNeg, nOnsets, resTime, avg_on, avg_non] = bMark_onset(notes, onsets, fs);
            falseNeg_rate = nFalseNeg/nOnsets * 100;
            falsePos_rate = nFalsePos/nOnsets * 100;

            % write to results
            bench_results(currResRow, :) = {testName, falsePos_time, falsePos_rate, falseNeg_rate, resTime, avg_on, avg_non};
            currResRow = currResRow + 1;
        end
    end

    % ------------------------------------
    % averaged results
    % ------------------------------------

    % declare avg_results array
    avg_results = cell(length(testDefs) + 1, size(bench_results, 2));
    avg_results(1, :) = bench_results(1,:);
    avg_results{1, 1} = "testName";

    % go through bench_results and take averages
    numTestVecs = length(testVectors);
    for td_i = 1:length(testDefs)
        testDef = testDefs{td_i};

        % figure out which rows to average over
        % rowsToAvg is shifted by one because of "title row"
        currRowOffset = (td_i - 1) * numTestVecs;
        rowsToAvg = currRowOffset + 2 : currRowOffset + numTestVecs + 1; 

        % take the means
        means = mean(cell2mat(bench_results(rowsToAvg, 2:end)));
        assert(isrow(means), "whoops!");
        
        % write into avg_results
        avg_results(td_i + 1, 2:end) = num2cell(means);
        avg_results{td_i + 1, 1} = testDef.name;
    end

    % add a "level ratio" column to the far right of the table
    avg_results{1, end+1} = "level ratio";
    avg_results(2:end, end) = num2cell( ...
        cell2mat(avg_results(2:end, end-2)) ./ cell2mat(avg_results(2:end, end-1)) ...
    );

    save('./results/bench_results.mat', 'bench_results');
    save('./results/avg_results.mat', 'avg_results');
end

% PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~BENCH
    % load results tables
    load('./results/bench_results.mat');
    load('./results/avg_results.mat');
end

if PLOT
    % get all testNames in avg_results as a string array
    testNames = string(avg_results(:,1)); % keeping 1st elem for convenience

    % -----------------------------------------------
    % xy aggression plot
    % -----------------------------------------------
    if table_switches.TESTDEFS_AGRESSION

        % find the tests in the "ATaxiTol1DropXXX" series, put in s1
        s1_indices = startsWith(testNames, "ATaxiTol1Drop");
        s1 = avg_results(s1_indices, [2,4]) ;% cols 2 and 4 are false pos and false neg
        s1 = cell2mat(s1); 

        % find the tests in the "ATaxiTol10DropXXX" series, put in s2
        s2_indices = startsWith(testNames, "ATaxiTol10Drop");
        s2 = avg_results(s2_indices, [2,4]) ;% cols 2 and 4 are false pos and false neg
        s2 = cell2mat(s2); 

        % find the tests in the "ARectTol1DropXXX" series, put in s3
        s3_indices = startsWith(testNames, "ARectTol1Drop");
        s3 = avg_results(s3_indices, [2,4]) ;% cols 2 and 4 are false pos and false neg
        s3 = cell2mat(s3); 

        % find the tests in the "ARectTol10DropXXX" series, put in s4
        s4_indices = startsWith(testNames, "ARectTol10Drop");
        s4 = avg_results(s4_indices, [2,4]) ;% cols 2 and 4 are false pos and false neg
        s4 = cell2mat(s4); 

        % plot them all against each other
        scatter(s1(:,2), s1(:,1));
        hold on;
        scatter(s2(:,2), s2(:,1));
        scatter(s3(:,2), s3(:,1));
        scatter(s4(:,2), s4(:,1));
        legend('Taxi - Tol 1', 'Taxi Tol - 10', 'Rect - Tol1', 'Rect - Tol10');
        title("agression levels");
        xlabel("false negative rate");
        ylabel("false positive rate");
        wait_returnKey();  
    end

    % -----------------------------------------------
    % subplot showing start-to-finish performance on 
    % particular pieces of audio
    % -----------------------------------------------
    if table_switches.TESTDEFS_MAIN
        % mozart viola = difficult to avoid false pos
        % lussier mix = difficult to avoid false neg

        % get audio and midi
        [viola_audio, fs_V] = audioread(fullfile(TRIOS_DATA_PATH, "mozart/viola.wav"));
        viola_notes = midiInfo(readmidi(fullfile(TRIOS_DATA_PATH, "mozart/viola.mid")), 0);
        [viola_pRoll, vtt] = piano_roll(viola_notes);

        [mix_audio, fs] = audioread(fullfile(TRIOS_DATA_PATH, "lussier/mix.wav"));
        mix_notes = midiInfo(readmidi("./tmp/triosLussierMix.mid"), 0);
        [mix_pRoll, mtt] = piano_roll(mix_notes);

        % get audio files of the various methods used to detect onset
        methods_to_plot = {
            "MStandardTaxi"
            "MTaxiNormNoDroput"
            "MTaxiNormLowDropout"
            "MTaxiNormHighDropout"
            "MTaxiAgressLeadingEdge1"
            "MTaxiAgressLeadingEdge1Smooth"
        };
        numMethods = length(methods_to_plot);

        % get wav files for each method
        % viola
        method_wavs_viola = cell(size(methods_to_plot));
        for i = 1:length(methods_to_plot)
            audioPath = strcat("./results/", methods_to_plot{i}, "_triosMozartViola.wav");
            [method_wavs_viola{i}, fs_Me] = audioread(audioPath);
        end

        % mix
        method_wavs_mix = cell(size(methods_to_plot));
        for i = 1:length(methods_to_plot)
            audioPath = strcat("./results/", methods_to_plot{i}, "_triosLussierMix.wav");
            method_wavs_mix{i} = audioread(audioPath);
        end

        % ---- viola plotting ---- % 

        % choose a 10 sec chunk of the audio to compare
        sound_start_sec = viola_notes(1,5); % first note onset time , in seconds
        chunk = [floor(sound_start_sec*fs)+1, floor(sound_start_sec*fs+440000)+1];

        % find the corresponding endpoint in the midi file
        first_pRoll_index = find( vtt > (sound_start_sec) ,1);
        last_pRoll_index = find( vtt < (sound_start_sec+10) ,1 , 'last');

        % plot
        figure(1);
        subplot(numMethods + 2, 1, 1);
         plot(viola_audio(chunk(1):chunk(2)));
        subplot(numMethods + 2, 1, 2);
         imagesc(viola_pRoll(:, first_pRoll_index:last_pRoll_index));
        for i = 1:numMethods
            subplot(numMethods + 2, 1, i + 2);
             thisWav = method_wavs_viola{i};
             plot(thisWav(chunk(1):chunk(2)));
        end

        % ---- mix plotting ---- %

        % choose a chunk of audio to look at
        chunk = [1, 220000];

        % find the corresponding endpoint in the midi file
        first_pRoll_index = find( mtt >= 0,1);
        last_pRoll_index = find( mtt < 5,1 , 'last');

        % plot
        figure(2);
        subplot(numMethods + 2, 1, 1);
         plot(mix_audio(chunk(1):chunk(2)));
        subplot(numMethods + 2, 1, 2);
         imagesc(mix_pRoll(:, first_pRoll_index:last_pRoll_index));
        for i = 1:numMethods
            subplot(numMethods + 2, 1, i + 2);
             thisWav = method_wavs_mix{i};
             plot(thisWav(chunk(1):chunk(2)));
        end

        % ------------------------- %
        wait_returnKey();
        close all;
    end
end
toc

% HELPER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function path = test2FilePath (testDef, testVec)
    path = fullfile("./results", strcat(testDef.name,"_",testVec.name,".wav"));
end