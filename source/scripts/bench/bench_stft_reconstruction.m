% benchmark of various stft window choices, assessing quality of reconstruction. 

PLOT_FIGS = 0; % zero for just logs

% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('../setpaths.m')
PROJECT_PATH = fullfile('../../..');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

% make some windows
blackmanharris_3072 = blackmanharris(3072, 'symmetric');
blackmanharris_3072_p = blackmanharris(3072, 'periodic');
hamming_3072 = hamming (3072, 'symmetric');
hamming_3072_p = hamming (3072, 'periodic');
rect_3072_selfInverse = ones(3072,1) * (1 / sqrt(2));
rect_3072_unity   = ones(3072,1);

N = 3072;
n = (0:N-1).';
shiftedSin_3072 = sin ( (pi/N) * (n + 0.5));

% list some audio filenames
file_paths = {
    fullfile(DEV_DATA_PATH, 'doorbell.wav');
    fullfile(DEV_DATA_PATH, 'rand.wav');
    fullfile(DEV_DATA_PATH, 'chirp.wav');
    fullfile(DEV_DATA_PATH, 'TRIOS_hn_6note.wav');
};

% make some stft param lists in a cell array
% i theorise that nfft doesnt matter (in this case) as long as nfft > max window length. 

% !!! add the first one i used:
%    wlen = ceil(Fs/50); hop = ceil(3*wlen / 4); nfft = 1024; minThresh_dB = -110;
%    anal_win = blackmanharris(wlen, 'periodic'); synth_win = hamming(wlen, 'periodic');

rng(0);
param_lists = { 
%     name                        anal_win             synth_win              hop              nfft
    "default",                blackmanharris_3072_p, hamming_3072_p,        3072/8,           3072*4;
    "first-attempt",          blackmanharris_3072_p, hamming_3072_p,        ceil(3*3072 / 4), 3072*4;
    "bh-hamming-symmetric",   blackmanharris_3072,   hamming_3072,          3072/8,           3072*4;
    "bh-hamming-noPR",        blackmanharris_3072_p, hamming_3072_p,        3072/2,           3072*4;
    "rect-3072-selfInverse",  rect_3072_selfInverse, rect_3072_selfInverse, 3072/2,           3072*4;
    "rect-3072-unity",        rect_3072_unity,       rect_3072_unity,       3072/2,           3072*4;
    "shift-sin-hop50%",       shiftedSin_3072,       shiftedSin_3072,       3072/2,           3072*4;
    "shift-sin-hop25%",       shiftedSin_3072,       shiftedSin_3072,       3072/4,           3072*4;
    "shift-sin-hop33%",       shiftedSin_3072,       shiftedSin_3072,       3072/3,           3072*4;

    "nfft-pad-1x-PR",         shiftedSin_3072,       shiftedSin_3072,       3072/2,           3072*1;
    "nfft-pad-2x-PR",         shiftedSin_3072,       shiftedSin_3072,       3072/2,           3072*2;
    "nfft-pad-4x-PR",         shiftedSin_3072,       shiftedSin_3072,       3072/2,           3072*4;
    "nfft-pad-8x-PR",         shiftedSin_3072,       shiftedSin_3072,       3072/2,           3072*8;
   
    "nfft-pad-1x-noPR",       blackmanharris_3072_p, hamming_3072_p,        3072/3,           3072*1;
    "nfft-pad-2x-noPR",       blackmanharris_3072_p, hamming_3072_p,        3072/3,           3072*2;
    "nfft-pad-4x-noPR",       blackmanharris_3072_p, hamming_3072_p,        3072/3,           3072*4;
    "nfft-pad-8x-noPR",       blackmanharris_3072_p, hamming_3072_p,        3072/3,           3072*8;
};


fprintf('########################################\n')
fprintf('TEST TYPE - %s\n', mfilename())
fprintf('########################################\n')


% go through all param lists
results = cell(size(param_lists, 1), 3);
for i = 1:size(param_lists, 1)
    
    % get param_list 
    param_list = param_lists(i, :);

    % store params in named variables
    test_name = param_list{1};
    anal_win  = param_list{2};
    synth_win = param_list{3};
    hop       = param_list{4};
    nfft      = param_list{5};

    % could do some clever stuff on the audio truncation code to support differing window lengths
    % out of scope at this stage
    % !!! "Hitherto shalt thou come, but no further; and here shall thy proud waves be stayed?" Job 38:11
    assert(isequal(length(synth_win), length(anal_win)), "synth and analysis window different lengths");
    wlen = length(anal_win);
    
    % logging
    fprintf('----------------------------------------\n')
    fprintf('Test Name: %s\n', test_name)
    fprintf('----------------------------------------\n')
    fprintf('Params: hop       = %d\n', hop);
    fprintf('        nfft      = %d\n\n', nfft);

    fprintf('        anal_win length  = %d\n', length(anal_win));
    fprintf('        synth_win length = %d\n', length(synth_win));
    fprintf('----------------------------------------\n')
    
    MSEs = [];
    central_MSEs = [];
    for j = 1:size(file_paths, 1)
        % bit depth accounted for - all 16

        % get audio filename for display
        [~, curr_filename, ~] = fileparts(file_paths{j});

        % get audio as vector, truncate so it's an exact number of hops, make sure it's mono
        [audio_orig, Fs] = audioread(file_paths{j});
        audio_len = floor_to_multiple (length(audio_orig) - wlen, hop) + wlen;
        audio_orig = audio_orig(1:audio_len, 1);
        t_orig = (0:audio_len-1)/Fs;

        % perform stft and reconstruction
        [STFT, ~, ~] = stft(audio_orig, anal_win, hop, nfft, Fs);
        [audio_recon, t_recon] = istft(STFT, anal_win, synth_win, hop, nfft, Fs);
        
        % !!! enable this assert and figure out missing samples at end of
        % stft_recon
        % assert(isequal(t_orig, t_recon), "internal error - time base should not change due to stft/istft")
        
        timebase_len = min (length(t_orig), length(t_recon));
        audio_orig = audio_orig(1:timebase_len);
        audio_recon = audio_recon(1:timebase_len).';
        t_orig = t_orig(1:timebase_len);
        t_recon = t_recon(1:timebase_len);
        
        % find and accumulate MSE value
        MSE = immse(audio_orig, audio_recon);
        MSEs = [MSEs MSE]; %#ok<AGROW>

        central_MSE = immse(audio_orig(2*wlen:end - 2* wlen), audio_recon(2*wlen:end - 2* wlen));
        central_MSEs = [central_MSEs central_MSE];

        % logging
        fprintf('###%s###\n', curr_filename)
        fprintf('        MSE: %d\n', MSE)
        fprintf('central_MSE: %d\n', central_MSE)

        % plotting
        if PLOT_FIGS
            % ITT: making things look a certain way in 99999 lines or fewer

            figure(1)
            
            subplot(2,1,1)
            plot(t_orig, audio_orig, 'b')
            grid on
            xlim([0 max(t_orig)])
            set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
            xlabel('Time, s')
            ylabel('Signal amplitude')
            title( [test_name, curr_filename], 'Interpreter', 'none')
            hold on
            plot(t_recon,audio_recon, '-.r')
            legend('Original signal', 'Reconstructed signal')
            hold off

            subplot(2,1,2)
            plot(t_orig, audio_orig - audio_recon)
            xlim([0 max(t_orig)])
            xlabel('Time, s')
            ylabel('Error amplitude')
            title('Difference')

            wait_returnKey
        end 

    end

    % logging
    fprintf('############\n\n')
    fprintf('        avg MSE: %d\n', mean(MSEs))
    fprintf('avg central_MSE: %d\n', mean(central_MSEs))
    results(i, :) = {test_name, mean(MSEs), mean(central_MSEs)};

end

fprintf('----------------------------------------\n')
fprintf('results\n')
fprintf('----------------------------------------\n')
disp(results)