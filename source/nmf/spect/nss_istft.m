function [x,t] = nss_istft (spect, spectInfo)
% NSS_ISTFT - take the Inverse Short Time Fourier Transform of a spectrogram
%
%   arguments:
%       spect - the spectrogram to be transformed
%       spectInfo - a struct containing the following parameters
%           synthwin - synthesis window   
%           analwin - analysis window
%           hop - hop size
%           nfft - fft length
%           fs - sampling frequency
%           num_freq_bins - number of frequency bins in the spectrogram
%           audio_len_samp - lenght of the original audio
%           max_freq_bins (optional) - remove frequency bins above this point
%
%   return values:
%       x - time domain signal
%       t - time vector, in seconds
%
%   description:
%       takes the ISTFT of a spectrogram and returns the time-domain audio it
%       corresopnds to. This is a spectInfo-aware wrapper function for the third-party
%       Zhivomirov istft function.
%    
%       this function supports spectrum elision, through the optional "max_freq_bins" 
%       parameter. if this parameter is in the spectInfo, it is assumed that the corresponding
%       stft used spectrum elision, and the spectrogram is zero-padded to the right size
%       before the istft is taken.  

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

