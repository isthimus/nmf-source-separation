function [spect, spectInfo_out] = num_stft(audio, spectInfo)
    % unpack spectInfo
    wlen = spectInfo.wlen;
    hop = spectInfo.hop;
    nfft = spectInfo.nfft;
    fs = spectInfo.fs;
    analwin = spectInfo.analwin;

    % take spectrum
    spect = stft(audio,analwin,hop,nfft,fs);

    % if spect has a max_freq_bins field, clamp the size of the spectrum to that value
    if isfield(spectInfo, "max_freq_bins") && size(spect,1) > spectInfo.max_freq_bins
        spect = spect(1:spectInfo.max_freq_bins,:);
    end

    % pack up spectInfo_out
    spectInfo_out = spectInfo;
    spectInfo_out.audio_len_samp = length(audio);
    [spectInfo_out.num_freq_bins, spectInfo_out.num_time_bins] = size(spect);
end