function out = align_onset_energyFirstDiff(audio, spectInfo, f_cutoff)
    % detects onsets in a signal by taking the local energy (squaring each sample),
    % lowpass filtering, and taking the first difference of the result. this has the
    % effect of creating short spikes when there is a sudden rise in the low-frequency energy.
    % hopefuly that represents an onset!

    % f_cutoff is an optional argument specifying where the cutoff of the LPF
    % should be, in Hz. if not specified a default value of 2k will be used
    % band ratio gives sharpness of filter. 1 = "perfect", larger = smoother.

    % !!! p sure my terminology is wrong here... will ask mark


    % default args
    if nargin <= 2
        f_cutoff = 400; % centre of transition band
    end
    band_ratio = 1.5;

    % unpack spectInfo
    fs = spectInfo.fs;

    % precondition check
    assert(f_cutoff * band_ratio < fs, "use a lower f_cutoff");
    assert(band_ratio > 1, "band ratio should be > 1")

    % build lowpass filter
    Fst = f_cutoff * band_ratio;
    Fp  = f_cutoff / band_ratio;
    d = fdesign.lowpass('fp,fst,ap,ast' , Fp, Fst, 0.5, 40, fs);
    disp("filter spec:");
    disp(d);
    LPF = design(d, 'equiripple');
    disp("filter:");
    disp(LPF);

    % find the local energy and filter it using the LPF
    localEnergy = filter(LPF, audio .* audio);

    % find the first difference and return()
    % need to cat a 0 on the start since diff() gives a vector one shorter than original
    out = [0; diff(localEnergy)]; 
end