function [x,t] = nss_istft (spect, spectInfo)
    % performs istft on spect using the information from spectInfo
    % supports spect elision

    % unpack spectInfo
    synthwin = spectInfo.synthwin;
    analwin = spectInfo.analwin;
    hop = spectInfo.hop;
    nfft = spectInfo.nfft;
    fs = spectInfo.fs;
    num_freq_bins = spectInfo.num_freq_bins;

    % if spect has a max_freq_bins field, zero-fill back to its original shape
    if isfield(spectInfo, "max_freq_bins") && num_freq_bins < ceil((1+nfft)/2)
        num_zeros = ceil((1+nfft)/2) - num_freq_bins;
        spect = [spect; zeros(num_zeros, size(spect,2));
    end

    % take the istft
    [x,t] = istft(stft, analwin, synthwin, hop, nfft, fs);

end

