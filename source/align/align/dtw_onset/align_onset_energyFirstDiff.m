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

    % find the first difference and return()
    % need to cat a 0 on the start since diff() gives a vector one shorter than original
    out = [0; diffs]; 
end