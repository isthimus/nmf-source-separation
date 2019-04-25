function out = align_onset_bandSplit(audio, spectInfo,  onset_func, lowest_nn, highest_nn)
	% splits a signal into chroma, calls onset_func on each band, and recombines

    % unpack spectInfo
    wlen = spectInfo.wlen;
    nfft = spectInfo.nfft;
    hop = spectInfo.hop;
    fs = spectInfo.fs;
    analwin = spectInfo.analwin;
    synthwin = spectInfo.synthwin;

    % default args
    if nargin <= 3
        lowest_nn = 48; % C3
    end
    if nargin <= 4
        highest_nn = floor(align_freq2nn_fractional(fs/2)); % nearest nn below nyquist
    end

    % preconditions
    assert(midi2freq(lowest_nn) < fs/2,  "lowest_nn has a frequency above the nyquist limit");
    assert(midi2freq(highest_nn) < fs/2, "highest_nn has a frequency above the nyquist limit");

    % take spectrogram
    spect = stft(audio, analwin, spectInfo.hop, spectInfo.nfft, spectInfo.fs);

    % preallocate return val
    out = zeros(12, size(spect, 2));

    % iterate over the 12 chroma and fill "out"
    % NB not iterating in ascending order - chroma bin for first iteration will be
    % whatever bin corresponds to lowest_nn
    for i = 0:11
        % list all nns in this chroma index
        nns = lowest_nn+i : 12 : highest_nn;
        freqBins = align_nn2FreqBin(nns, spectInfo);

        % find out what chroma index this is
        thisChromaIndex = mod (nns(1) + 3, 12) + 1; 

        % find the onset func for this band
        % onset funcs work on column vectors, so transpose, calculate, transpose back.
        disp(size(spect(freqBins, :)));
        out(thisChromaIndex,:) = onset_func(spect(freqBins, :), spectInfo);
    end    

    % implicitly return out
end