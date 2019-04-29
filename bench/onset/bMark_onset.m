function [false_pos_percent, num_false_pos, num_false_neg, num_total_onsets, mean_response_time, avg_lvl_on, avg_lvl_non] = bMark_onset(notes, onsets, fs, tol_sec, print_ans)
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
    assert(max(noteOnsets) < length(onsets), "last midi event is after end of onsets argument!")

    % convert tolerance to samps
    tol_samp = floor(tol_sec * fs);

    % preallocate ground truth vector
    % true =  samp is in an "onset period"
    % false = silence or a held note
    groundTruth = false(length(onsets), 1);
    onset_vec_tst = zeros(length(onsets), 1); % !!! can remove me later

    % iterate through noteOnsets
    for i = 1:length(noteOnsets)
        % figure out the samples this onset relates to
        thisOnset = noteOnsets(i);
        onsetPeriod = thisOnset: min(thisOnset+tol_samp, length(groundTruth));

        % write into groundTruth
        groundTruth(onsetPeriod) = true;
        onset_vec_tst(thisOnset) = 1; % !!! remove me
    end

    % measure false pos time as a percentage
    good = 0; bad = 0;
    for i = 1:length(onsets)
        % only look at samples where theres no onset
        if ~groundTruth(i)
            if onsets(i) == 0; good = good + 1;
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

        if all(onsets(onsetPeriod) == 0)
            % if the onset was missed, add to num_false_neg
            num_false_neg = num_false_neg+1;
        else
            % if the onset was caught, figure out how long the response time was
            response_times(end+1) = (find(onsets(onsetPeriod),1) - 1) / fs;
        end
    end
    mean_response_time = mean(response_times);

    % get false pos count
    i = 1;
    num_false_pos = 0;
    LE_skip = false; % whether to skip non-zero samples because of leading-edge detect
    while(i < length(groundTruth))
        if groundTruth(i)
            % if we're in an onset region, fast-forward to the next non-onset region
            i = i + find(~groundTruth(i:end), 1) - 1;
            LE_skip = true;
            if isempty(i)
                % if theres no more non onset regions, we're done - break out
                break
            end
        else
            % we're in a non-onset region - look for false positives
            if LE_skip
                % skip nonzeros because we've counted this onset already
                % (or because we just came out of an onset region and its a tail)
                LE_skip = false;
                while onsets(i) ~= 0
                    i = i+1;
                    if i > length(onsets); break; end;
                end
            else
                if onsets(i) ~= 0
                    num_false_pos = num_false_pos + 1;
                    LE_skip = true;
                end
                i = i+1;
            end                
        end
    end

    % get avg_lvl_on and avg_lvl_non
    % useful for less accurate measures when the other figures are nonsensical 
    avg_lvl_on  = mean(onsets(groundTruth == true));
    avg_lvl_non = mean(onsets(groundTruth == false));

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
        plot(onsets);
        wait_returnKey()
        close all;
        
        plot((2*groundTruth - 1).*(onsets))
        wait_returnKey()
        close all;

        plot(10*groundTruth - onsets);
        wait_returnKey();
        close all;
    end
    
    % implicit return of a bunch of things
end