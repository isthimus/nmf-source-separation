function [false_pos_percent, num_false_neg, num_total_onsets, mean_response_time] = bMark_onset(notes, onset, fs, tol_sec, print_ans)
    % measures false positive percentage and number of missed onsets for a given onset measure and midi file
    % bit primitive but itll do the job
    % might need a slightly different approach for leading-edge shenanigans
    % onset MUST be at sample rate not timebin rate! read from a wav file and make your life easy :)

    PLOT = false;

    if nargin < 4
        tol_sec = 0.05; % single sided!
    end 
    if nargin < 5
        print_ans = false;
    end

    % get a vector of note onset times, convert to samples
    noteOnsets = notes(:, 5);
    noteOnsets = floor(noteOnsets * fs) + 1;
    assert(max(noteOnsets) < length(onset), "last midi event is after end of onset argument!")

    % convert tolerance to samps
    tol_samp = floor(tol_sec * fs);

    % preallocate ground truth vector
    % true =  samp is in an "onset period"
    % false = silence or a held note
    groundTruth = false(length(onset), 1);
    onset_vec_tst = zeros(length(onset), 1); % !!! can remove me later

    % iterate through noteOnsets
    for i = 1:length(noteOnsets)
        % figure out the samples this onset relates to
        thisOnset = noteOnsets(i);
        onsetPeriod = thisOnset: min(thisOnset+tol_samp, length(groundTruth));

        % write into groundTruth
        groundTruth(onsetPeriod) = true;
        onset_vec_tst(thisOnset) = 1; % !!! remove me
    end

    % measure false pos percentage
    good = 0; bad = 0;
    for i = 1:length(onset)
        % only look at samples where theres no onset
        if ~groundTruth(i)
            if onset(i) == 0; good = good + 1;
            else; bad = bad + 1; end
        end
    end
    false_pos_percent = (bad/(bad+good)) * 100;

    % count missed onsets and record avg. response time
    response_times = [];
    num_false_neg = 0;
    for i = 1:length(noteOnsets)
        thisOnset = noteOnsets(i);
        onsetPeriod = max(thisOnset-tol_samp, 1) : min(thisOnset+tol_samp, length(groundTruth));

        if all(onset(onsetPeriod) == 0)
            % if the onset was missed, add to num_false_neg
            num_false_neg = num_false_neg+1;
        else
            % if the onset was caught, figure out how long the response time was
            response_times(end+1) = (find(onset(onsetPeriod),1) - 1) / fs;
        end
    end
    mean_response_time = mean(response_times);

    num_total_onsets = length(noteOnsets);
    if print_ans
        fprintf("---\nfalse pos percent: %.1f\n", false_pos_percent)
        fprintf("num missed onsets: %d/%d\n", num_false_neg, num_total_onsets)
        fprintf("missrate (%%): %.1f\n", (num_false_neg./num_total_onsets) * 100)
        fprintf("avg. response time (s): %.4f\n---\n", mean_response_time)
    end

    if PLOT
        figure (1)
        subplot(2,1,1)
        stem(1 * groundTruth);
        subplot(2,1,2)
        plot(onset);
        wait_returnKey()
        close all;
        
        plot((2*groundTruth - 1).*(onset))
        wait_returnKey()
        close all;

        plot(10*groundTruth - onset);
        wait_returnKey();
        close all;
    end
    
    % implicit return of num_false_neg, false_pos_percent, num_total_onsets
end