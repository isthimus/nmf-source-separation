% full benchmark for onsets
clear

CALC = false;
BENCH = true;
PLOT = true;

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
[testVectors, testDefs] = gen_tables();

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
			filename = fullfile("./results", strcat(testVec.name,"_",testDef.name,".wav"));      
			write_to_wavFile (onsets, audio, spectInfo, filename);

			disp('.');
		end
		disp('#')
	end
end
% BENCH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if BENCH
	% make a cellarray for results
	results = {"filename", "false_pos_time_percent", "false_neg_rate_percent", "avg_response_time"};
	currResRow = 2; % current row of results to write to

	% for each testDef ...
	for td_i = 1:length(testDefs)
		testDef = testDefs{td_i};

		% ... and each testvector
		for tv_i = 1:length(testVectors)
			testVec = testVectors{tv_i};

			% get onset back from file. pick up testName  while we're at it
			testName = strcat(testVec.name,"_",testDef.name);
			onset_path = fullfile("./results", strcat(testVec.name,"_",testDef.name,".wav"));        
			[onsets, fs] = audioread(onset_path);

			% get the midi ground truth file, perform onset bench
			notes = midiInfo(readmidi(testVec.midiPath), 0);
			[falsePos, nFalseNeg, nOnsets, resTime] = bMark_onset(notes, onsets, fs);
			falseNeg = nFalseNeg/nOnsets * 100;

			% write to results
			results(currResRow, :) = {testName, falsePos, falseNeg, resTime};
			currResRow = currResRow + 1;
		end
	end

	save('./results/bench_results.mat', 'results');
end
% PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT
	disp(results) % nice
end