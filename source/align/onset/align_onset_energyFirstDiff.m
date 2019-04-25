function out = align_onset_energyFirstDiff(audio, spectInfo, f_3db, N)
    % detects onsets in a signal by taking the local energy (squaring each sample),
    % lowpass filtering, and taking the first difference of the result. this has the
    % effect of creating short spikes when there is a sudden rise in the low-frequency energy.
    % hopefuly that represents an onset!

    % f_3db is an optional argument specifying where the cutoff of the LPF
    % should be, in Hz. if not specified a default value of 400 will be used
    % N is filter order

    % !!! p sure my terminology is wrong here... will ask mark


    % default args
    if nargin <= 2
        f_3db = 400; % centre of transition band
    end
    if nargin <= 3
        N = 300;
    end

    % unpack spectInfo
    fs = spectInfo.fs;
    num_time_bins = spectInfo.num_time_bins;

    % build lowpass filter
    d = fdesign.lowpass('N,F3db' , N, f_3db, fs);
    disp("filter spec:");
    disp(d);
    LPF = design(d, 'butter');
    disp("filter:");
    disp(LPF);

    % find the local energy and filter it using the LPF
    localEnergy = filter(LPF, audio .* audio);

    % find running difference and half wave rectify
    diffs = diff(localEnergy);
    diffs(diffs < 0) = 0;
    % need to cat a 0 on the start since diff() gives a vector one shorter than original
    diffs = [0; diffs]; 

    % need the output to be one value per timeBin rather than one value per audio sample
    % no need to conserve any freq-domain properties - just take the max of each bin.

    % preallocate return val
    out = zeros(num_time_bins, 1);

    % get center times of all timebins
    center_samps = align_timeBin2Samps(1:num_time_bins);

    %iterate over timeBins
    for i = 1:num_time_bins 
        % take max of [center +- hop/2], put in out(i)
        % account for asymmetrical endpoints
        % NB this actually ignores some samples at the start and end 
        %    because the bins are unevenly spaced. but the total time
        %    ignored is ~1/88th of a sec, and independent of audio_len_samp.
        %    so no worries.
        out (i) = max(audio(center_samps(i)+hop/2:center_times(i)+1-hop/2));
    end

    % implicitly return out
end