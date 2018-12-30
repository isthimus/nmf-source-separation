% benchmark the whole source separation procedure with a wide range of parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCRIPT SETUP                                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('../setpaths.m')
PROJECT_PATH = fullfile('../../..');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

% log to terminal. last fprintf statement til logging stage at bottom.
fprintf('########################################\n')
fprintf('TEST TYPE - %s\n', mfilename())
fprintf('########################################\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST DEFINITIONS                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
audio_filepaths = {
    fullfile(DEV_DATA_PATH, 'TRIOS_vln_Db6_B6.wav'),       ...
        fullfile(DEV_DATA_PATH, 'TRIOS_vln_Db6_B6_1.wav'), ...
        fullfile(DEV_DATA_PATH, 'TRIOS_vln_Db6_B6_2.wav');
%{
    fullfile(DEV_DATA_PATH, 'TRIOS_vln_Db6_B6.wav'),       ...
        fullfile(DEV_DATA_PATH, 'TRIOS_vln_Db6_B6_1.wav'), ...
        fullfile(DEV_DATA_PATH, 'TRIOS_vln_Db6_B6_2.wav');
%}
};
% !!!
assert (~isempty(audio_filepaths), "matt you suuuuuuuck")

% create audio_vectors with same dimension as audio_filepaths, plus 2 extra columns
% one for name and one for Fs
audio_vectors = cell (size(audio_filepaths, 1), size(audio_filepaths,2) + 2);

% populate audio_vectors
% iterate over rows of audio_filepaths
for i = 1:size(audio_filepaths,1)
    Fs = [];

    % get each source
    for j = 1:size(audio_filepaths,2)
        if ~isempty(audio_filepaths{i,j})
            [audio_vectors{i,j+2}, Fs] = audioread(audio_filepaths{i,j});
        end
    end

    % fill in name and Fs in 1st and 2nd col respectively
    [~, audio_name, ~] = fileparts(audio_filepaths{i, 1});
    audio_vectors{i,1} = audio_name;
    audio_vectors{i,2} = Fs;
end

% !!! tidy up these window definitions
% maybe even functionify and pass in from another script??
stft_wlen = 1024;
stft_analwin  = blackmanharris(stft_wlen, 'periodic'); 
stft_synthwin = hamming(stft_wlen, 'periodic');

% format:
% name, nmf_init_func, nmf_func, spect_func, recons_func;
% nmf_init_func prototype: (freqBins, timeBins) -> (W_init, H_init)
% nmf_func prototype (V,W,H) -> (W_out, H_out, final_err, iterations)
% spect_func prototype: (audio_vec, Fs) -> (spectrogram)
% recons_func prototype: (orig_spect, W, H, Fs) -> (nsrc x nsamples array of sources)
testdefs = { ...
    "eNorm_source_sep_orig",                                                          ...
        @(freqBins, timeBins) nmf_init_rand(freqBins, timeBins, 2, 10),               ...
        @(V,W,H) nmf_euclidian_norm(V,W,H, 0.001, 1000000, 0),                      ...
        @(audio_vec, Fs) stft(audio_vec, stft_analwin, stft_wlen/8, stft_wlen*1, Fs), ...
        @(orig_spect, W, H, Fs) nmf_reconstruct_keepPhase(orig_spect, W, H,           ...
            stft_analwin, stft_synthwin, stft_wlen/8, stft_wlen/4, Fs);

    "eNorm_source_sep_statPoint1%",                                                                      ...
        @(freqBins, timeBins) nmf_init_rand(freqBins, timeBins, 2, 10),               ...
        @(V,W,H) nmf_euclidian_norm(V,W,H, 0.01, 1000000, 0),                      ...
        @(audio_vec, Fs) stft(audio_vec, stft_analwin, stft_wlen/8, stft_wlen*1, Fs), ...
        @(orig_spect, W, H, Fs) nmf_reconstruct_keepPhase(orig_spect, W, H,           ...
            stft_analwin, stft_synthwin, stft_wlen/8, stft_wlen/4, Fs);

};

% list of benchmark functions 
% NB would like to only include estimated and ground truth sources
% can use other benchmarks for eg final_err etc

% prototype - (se, s) -> anything
% where se is a nsrc x nsamples array of estimated sources
%       s  is a nsrc x nsamples array of ground truths
% the "anything" will be captured in a cell array using nargout()
% thus benchmark funcs must not use varargout
benchmarks = {
    "avg_bss_eval", @avg_bss_eval;
%   "subjective_source_eval", @subjective_source_eval; 
%   "PEASS", @PEASS;
%   "MSE",   @MSE;
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN BENCHMARKS                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% run every benchmark on every test with every audio vector
% and collate in results array
% results array one larger in "benchmarks" dimension to store a "ran-to-completion" flag
results = cell(size(testdefs,1), size(audio_vectors,1), size(benchmarks,1) + 1);
for test_i = 1:size(testdefs,1)
    for audio_i = 1:size(audio_vectors,1)
        
        % get the functions for init, nmf, spect and reconstruct
        init_func   = testdefs{test_i, 2};
        nmf_func    = testdefs{test_i, 3};
        spect_func  = testdefs{test_i, 4};
        recons_func = testdefs{test_i, 5};

        % get the mixture, the original sources, and Fs
        Fs = audio_vectors{audio_i, 2};
        audio_mixture = audio_vectors{audio_i, 3};
        audio_groundtruth = audio_vectors(audio_i, 4:end);
        audio_groundtruth = [audio_groundtruth{:}].'; % unpack cellArr to matrix

        % include Fs in spect and recons funcs now that we know it
        % couldnt include it in testdef because it might differ between audio vectors
        spect_func_fs =  @(audio_vec) spect_func(audio_vec, Fs);
        recons_func_fs = @(original_spect, W,H) recons_func(original_spect, W,H, Fs);

        try
            % attempt source separation
            sources_out = nmf_separate_sources(nmf_func, init_func, spect_func_fs, recons_func_fs, audio_mixture, 0);
            audio_groundtruth = audio_groundtruth(:, 1:size(sources_out, 2));

            % separation ran to completion - store true in "ran to completion" field
            results{test_i,audio_i,1} = {true};
            skip_bench = false;
        catch ME
            
            % separation did not run to completion - store false in ran-to-completion field
            results{test_i,audio_i,1} = {false}; %#ok<NASGU>
            skip_bench = true;                   %#ok<NASGU>
            rethrow(ME); % can comment this for large batches
        end

        % no point running benchmarks if test didnt complete - continue to next test
        if skip_bench; continue; end

        % iterate over benchmarks
        for benchmark_i = 1:size(benchmarks,1)

            % get bench func, perform bench, store results
            bench_func = benchmarks{benchmark_i, 2};
            bench_result = cell(1, nargout(bench_func));
            [bench_result{:}] = bench_func(sources_out, audio_groundtruth);
            results{test_i, audio_i, benchmark_i + 1} = bench_result;
        end

        % print something each test to show aliveness
        if audio_i == 1; fprintf('\n'); end;
        fprintf('.')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DISPLAY RESULTS                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BENCHMARK DSPLAY MUST BE NULL-AWARE
[T, A, B] = size(results);

for b = 1:B

    if b == 1
        bench_name = 'ran to completion';
    else
        bench_name = benchmarks{b-1,1};
    end

    fprintf('----------------------------------------\n')
    fprintf('Benchmark Name: %s\n', bench_name)
    fprintf('----------------------------------------\n')

    for a = 1:A
        fprintf('%s:\n', audio_vectors{a,1})

        for t = 1:T
            fprintf('\t%s ', testdefs{t,1});
        

            result = results{t, a, b};
            for i = 1:size(result,2)
                if ~isempty(result{i})
                    assert(isequal(size(result{i}), [1,1]), ...
                        "benchmarks should give lists of scalars as output!");
                    fprintf ('%d ', result{i})
                else
                    fprintf('%d ', 0 + 2*eps);
                end
            end
        fprintf('\n');
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SDR_avg, SIR_avg, SAR_avg] = avg_bss_eval (se, s)
    % average the SDR, SIR and SAR scores from bss_eval

    [SDR, SIR, SAR, ~] = bss_eval_sources(se, s);
    SDR_avg = mean(SDR);
    SIR_avg = mean(SIR);
    SAR_avg = mean(SAR);
end