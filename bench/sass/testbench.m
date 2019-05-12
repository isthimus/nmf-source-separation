% full benchmark for alignment
clear

% switches for this testbench
CALC = false;
BENCH = true;
PLOT = true;
CALC_RETHROW = false;
CALC_SKIP_EXISTING = true;

% switches for testdefs
table_switches = struct();
table_switches.TESTVECS_TRIOS = true;
table_switches.TESTVECS_TAKEFIVE = false;
table_switches.TESTDEFS_HASS = true;
table_switches.TESTDEFS_HAM = true;
table_switches.TESTDEFS_SASS = true;
table_switches.TESTDEFS_LONGWLEN = true;

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
USER_FUNCS_PATH = fullfile(PROJECT_PATH, '/source/user');
run(fullfile(PROJECT_PATH, 'source/scripts/setpaths.m'));

% generate testvector and test definition tables
[testVectors, testDefs] = gen_tables(table_switches);

% generate tuned functions
run(fullfile(USER_FUNCS_PATH, "gen_tuned_funcs"));

% CALC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if CALC

    % start a metadata list
    if CALC_SKIP_EXISTING && isfile("./results/calc_metadata.mat")
        load("./results/calc_metadata.mat");
    else
        metadata = cell(0,0);
    end

    % for each testDef ...
    for td_i = 1:length(testDefs)
        testDef = testDefs{td_i};
        fprintf("%s\n", testDef.name);

        % ... and each testvector
        for tv_i = 1:length(testVectors)
            testVec = testVectors{tv_i};
            fprintf("\t%s", testVec.name);

            % if the test we're about to run already happened, skip this iteration
            if CALC_SKIP_EXISTING && ~isempty(metadata)
                if ~isempty(find(strcat(string(metadata(:,1)),string(metadata(:,2))) == strcat(testDef.name, testVec.name)))
                    fprintf('\n');
                    continue
                end
            end
            
            % seed domness using current testvec index
            % this ensures its the same for each func being tested
            rng(tv_i * 9999);

            % open midi file, warp if flag is set
            notes_ground = midiInfo(readmidi(testVec.midiPath), 0);
            if testDef.warpMidi
                notes_test = midi_randWarp(notes_ground);
            else
                notes_test = notes_ground;
            end

            % open mixture audio file
            [audio, fs] = audioread(testVec.audioPath);

            % get spectInfo, update with fs
            spectInfo = testDef.spectInfo;
            spectInfo.fs = fs;

            % attempt source separation, catch errors
            try
                %clear metadata
                meta=struct();
                
                tic()
                sources = sepSources_scoreAware ( ...
                    notes_test, ...
                    audio, ...
                    spectInfo, ...
                    testDef.spect_func, ...
                    testDef.align_func, ...
                    testDef.tol_func, ...
                    testDef.nmf_func, ...
                    testDef.recons_func ... 
                );
                meta.testTime = toc();
                fprintf(" %d\n", meta.testTime);
                meta.ranToCompletion = true;

                % write sources to file
                assert(size(sources,1) < size(sources, 2), "source array probably transposed incorrectly")
                for i = 1:size(sources, 1)
                    filepath = test2FilePath(testDef,testVec,i);
                    audiowrite(filepath, sources(i, :),  fs);
                end
            catch exception
                % if theres an exception, just record it and move on
                meta.testTime = Inf;
                meta.ranToCompletion = false;
                meta.exception = exception;

                if CALC_RETHROW
                    rethrow(exception);
                end
            end

            % write metadata to file
            metadata(end+1, 1:3) = {testDef.name, testVec.name, meta};
            save("./results/calc_metadata.mat", 'metadata');
        end
    end
end % if CALC

% BENCH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if BENCH

    disp('benching...');

    % pick up metadata from calc run if not done already
    if ~CALC
        load("./results/calc_metadata.mat");
    end

    % ----------------------------
    % master results array, ran to completion, and byTest
    % ----------------------------
    num_td = length(testDefs);
    num_tv = length(testVectors);

    % make a cellarray to hold the results
    % +1 for "header rows" giving names of testdefs/vecs
    results_master = cell(num_tv+1, num_td+1);  
    results_master{1,1} = ":)";

    results_ranToCompletion = {"testName", "ranToCompletion"};
    results_byTest = {"testName", "runtime", "avg SDR", "avg SIR", "avg SAR"};

    % for each testVector
    for tv_i = 1:num_tv
        testVec = testVectors{tv_i};

        % write the name of this testVec in the first column of master results
        results_master{tv_i+1,1} = testVec.name;

        % load the ground truth sources
        sources_ground = [];
        for src_i = 1:length(testVec.sourcePaths)
            sourcePath = testVec.sourcePaths(src_i);
            sources_ground = [sources_ground; audioread(sourcePath).'];
        end
        assert (size(sources_ground, 1) == 3, "bad shape for ground truth sources matrix");

        % for each testDef
        for td_i = 1:num_td
            testDef = testDefs{td_i};

            % pick up a combined "test name"
            testName = sprintf("%s_%s", testDef.name, testVec.name);

            % write the name of this test in the first row
            % will do it loads of times but whatever
            results_master{1, td_i+1} = testDef.name;

            % get the metadata struct for this test
            thisMetaRow = find(string(metadata(:,1)) == testDef.name & string(metadata(:, 2)) == testVec.name);
            if isempty(thisMetaRow)
                error(sprintf("failed to find test %s_%s in metadata table", testDef.name, testVec.name));
            end;
            meta = metadata{thisMetaRow, 3};

            % store ranToCompletion results in cell array
            % if this test did not run to completion, dont run BSS_eval
            results_ranToCompletion(end+1,:) = {testName, meta.ranToCompletion};
            if ~meta.ranToCompletion
                results = struct();
                results.ranToCompletion = false;
                results_master{tv_i+1, td_i+1} = results;
                continue;
            end

            % load the reconstructed sources
            sources_recons = [];
            for src_i = 1:length(testVec.sourcePaths)
                sourcePath = test2FilePath(testDef,testVec,src_i);
                sources_recons = [sources_recons; audioread(sourcePath).'];
            end
            assert (size(sources_recons, 1) == 3, "bad shape for reconstructed sources matrix");

            % run bss_eval, write results to results_master
            results = struct();
            results.ranToCompletion = true; % already checked this
            [results.SDRs, results.SIRs, results.SARs] = ...
                bss_eval_sources(sources_recons, sources_ground);
            results.testTime = meta.testTime;
            results_master{tv_i+1, td_i+1} = results;

            % put an averaged set of results for this test into results_byTest
            results_byTest(end+1, :) = ... 
                {testName, results.testTime, mean(results.SDRs), mean(results.SIRs), mean(results.SARs)};

            fprintf('.');
        end
        fprintf('#\n');
    end

    % ---------------------------------
    % measure source difficulty
    % ---------------------------------

    % find out which sources were hard, and which easy
    results_sourceDifficulty = {"source", "avg SDR"};
    for tv_i = 1:num_tv
        
        % get the current testVec struct, 
        % and pull out the results for this vector from master
        testVec = testVectors{tv_i};
        results_thisVec = results_master(tv_i+1, 1:end);

        % for each source in this testdef
        for i = 1:length(testVec.sourcePaths)

            % get a name for the current source
            sourceName = sprintf("%s_%d", testVec.name, i);

            % get a vector of SDRS for this vec and this source
            SDRs = zeros(size(results_thisVec));
            for j = 1:length(results_thisVec)
                res = results_thisVec{j};
                if isfield(res, SDRs)
                    SDRs(j) = results_thisVec{j}.SDRs(i);
                end
            end

            % take the average SDR, write into results_sourceDifficulty
            meanSDR = mean(SDRs(SDRs~=0));
            assert(isequal(size(meanSDR), [1,1]), "mean is the wrong size");
            results_sourceDifficulty(end+1, :) = {sourceName, meanSDR};
         end
    end

    % save everything to file
    save("./results/results_master.mat", "results_master");
    save("./results/results_ranToCompletion.mat", "results_ranToCompletion");
    save("./results/results_byTest.mat", "results_byTest");
    save("./results/results_sourceDifficulty.mat", "results_sourceDifficulty");

end

% PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
    fprintf("nice\n"); % nice.
end

function path = test2FilePath (testDef, testVec, id)
    assert(nargin >= 3, "too few args - called by old code perhaps?");

    if id < 0
        idStr = "meta";
        ext = "mat";
    else 
        idStr = num2str(id);
        ext = "wav";
    end

    filename = sprintf("%s_%s_%s.%s", testDef.name, testVec.name, idStr, ext);
    path = fullfile("./results", filename);
end



