% full benchmark for alignment
clear

% switches for this testbench
CALC = true;
BENCH = false;
PLOT = true;
CALC_RETHROW = true;

% switches for testdefs
table_switches = struct();
table_switches.TESTVECS_TRIOS = false;
table_switches.TESTVECS_TAKEFIVE = true;
table_switches.TESTDEFS_HASS = false;
table_switches.TESTDEFS_HAM = true;
table_switches.TESTDEFS_SASS = true;

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
    metadata = cell(0,0);

    % for each testDef ...
    for td_i = 1:length(testDefs)
        testDef = testDefs{td_i};

        % ... and each testvector
        for tv_i = 1:length(testVectors)
            testVec = testVectors{tv_i};

            % seed randomness using current testvec index
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

                if CALC_RETHROW
                    rethrow(exception);
                end
            end

            % write metadata to file
            metadata(end+1, 1:3) = {testDef.name, testVec.name, meta};
            save("./results/calc_metadata.mat", 'meta');

            fprintf(".")
        end
        fprintf("#\n")
    end
end % if CALC

% BENCH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NB must check metadata before anything else.


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



