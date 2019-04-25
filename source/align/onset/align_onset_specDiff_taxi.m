function out = align_onset_specDiff_taxi (audio, spectInfo)
	% onset detecting function based on the taxicab distance between sucessive stft frames
	% no chroma separation

	% unpack spectInfo
	wlen = spectInfo.wlen;
    nfft = spectInfo.nfft;
    hop = spectInfo.hop;
    fs = spectInfo.fs;
    analwin = spectInfo.analwin;
    synthwin = spectInfo.synthwin;

    % take audio spectrogram
    spect = stft(audio, analwin, hop, nfft, fs);
    spectInfo.num_freq_bins = size(spect, 1);
    spectInfo.num_time_bins = size(spect, 2);

    % compute rolling taxicab distance 
    distances = taxicab_distance(abs(spect(:, 1:end-1)), abs(spect(:, 2:end)));
    out = [0; distances.'];
end

function d = taxicab_distance (A, B)
	% finds the taxi distance between two column vectors
	% if A, B are matrices, treat as a set of column vectors
	diffs = A - B;
	d = sum(abs(diffs));
end