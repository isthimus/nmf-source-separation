% full benchmark for alignment
tic 
clear

% switches for this testbench
CALC = true;
BENCH = true;
PLOT = true;

% switches for gen_tables
table_switches = struct();
table_switches.TESTVECS_SOLO = true;
table_switches.TESTVECS_MIX  = true;
table_switches.TESTDEFS_VANILLA = true;
table_switches.TESTDEFS_ONSET = true;

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

% CALC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if CALC
    % for each testDef ...
    for td_i = 1:length(testDefs)
        testDef = testDefs{td_i};

        % ... and each testvector
        for tv_i = 1:length(testVectors)
            testVec = testVectors{tv_i};

            % seed randomness using current testvec index
            % this ensures its the same for each func being tested
            rng(tv_i * 9999);

            % open midi file and warp
            notes_ground = midiInfo(readmidi(testVec.midiPath), 0);
            notes_warped = midi_randWarp(notes_ground);

            % open audio file
            [audio, fs] = audioread(testVec.audioPath);

            % get spectInfo, take spect
            spectInfo = testDef.spectInfo;
            spectInfo.fs = fs;
            [spect, spectInfo] = nmf_spect(audio, spectInfo);
            assert(checkSpectInfo(spectInfo), "bad spectInfo");

            % apply func
            test_func = testDef.testFunc;
            notes_aligned = test_func(notes_warped,  audio, spect, spectInfo);

            % write result to file
            filename = test2FilePath (testDef, testVec);
            writemidi(matrix2midi(notes_aligned), filename);

            disp('.');
        end
        
        disp('#');
    end
end

% BENCH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if BENCH
    %----------------------------------------
    % overalll results
    % ---------------------------------------

    % make a cellArray to hold the outputs
    bench_results = { ...
        "filename", ...
        "mean", ...
        "median", ...
        "sd" ...
    };
    currResRow = 2; % current row of results to write to

    % for each testDef ...
    for td_i = 1:length(testDefs)
        testDef = testDefs{td_i};

        % ... and each testvector
        for tv_i = 1:length(testVectors)
            testVec = testVectors{tv_i};

            % get midi back from file
            testName = strcat(testDef.name,"_",testVec.name);
            filepath = test2FilePath(testDef, testVec);
            notes_aligned = midiInfo(readmidi(filepath), 0);

            % get the midi ground truth file
            notes_ground = midiInfo(readmidi(testVec.midiPath), 0);
            [mn, mdn, sd] = midi_avg_distance(notes_aligned, notes_ground);

            % write to results
            bench_results(currResRow, :) = ...
                {testName, mn, mdn, sd};
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

    % save results to file
    % THIS FILE IS GITIGNORED, NEED TO BE COMMITTED MANUALLY
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
    disp("nice") % bench results
end

toc
% HELPER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function path = test2FilePath (testDef, testVec)
    path = fullfile("./results", strcat(testDef.name,"_",testVec.name,".mid"));
end