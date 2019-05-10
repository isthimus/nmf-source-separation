function [x,t] = nss_nmf_istft (spect, spectInfo)
    % performs istft on spect using the information from spectInfo
    % supports spect elision

    % unpack spectInfo
    synthwin = spectInfo.synthwin;
    analwin = spectInfo.analwin;
    hop = spectInfo.hop;
    nfft = spectInfo.nfft;
    fs = spectInfo.fs;
    num_freq_bins = spectInfo.num_freq_bins;
    audio_len_samp = spectInfo.audio_len_samp;

    % if spect has a max_freq_bins field, zero-fill back to its original shape
    if isfield(spectInfo, "max_freq_bins") && num_freq_bins < ceil((1+nfft)/2)
        num_zeros = ceil((1+nfft)/2) - num_freq_bins;
        spect = [spect; zeros(num_zeros, size(spect,2))];
    end

    % take the istft
    [x,t] = istft(spect, analwin, synthwin, hop, nfft, fs);

    % zero pad x to match the audio_len_samp
    if isrow(x)
        x = [x, zeros(1, audio_len_samp - length(x))];
    else
        x = [x; zeros(audio_len_samp - length(x), 1)];
    end

end

