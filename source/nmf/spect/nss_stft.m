function [spect, spectInfo_out] = nss_stft(audio, spectInfo)
% NSS_STFT - take the Short-Time fourier transform of an audio vector
%
%   arguments:
%       audio - the audio to be transformed
%       spectInfo - a struct containing the following parameters for the STFT
%           wlen - window length
%           hop - hop size
%           nfft - fft length
%           fs - sampling frequency
%           analwin - analysis window
%           max_freq_bins (optional) - remove frequency bins above this point
%
%   return values:
%       spect - the STFT spectrogram. 
%       spectInfo_out - the struct given in "spectInfo" with the following fields added:
%           num_time_bins - number of time bins (columns) in the STFT 
%           num_freq_bins - number of frequency bins (rows) in the STFT 
%
%   description:
%       spectInfo-aware wrapper function for the third-party Zhivomirov stft function.
%       unpacks the necessary values from the spectInfo, performs the stft, and returns
%       an updated spectInfo.
%
%       also supports spectrum elision through the optional "max_freq_bins" parameter - 
%       if the resultant stft matrix has more than "max_freq_bins" rows, the extra rows 
%       are removed before returning. during reconstruction a matching istft function 
%       (eg. nss_istft) should zero-pad the matrix to its correct size before taking the 
%       istft.

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