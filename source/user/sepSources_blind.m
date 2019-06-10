function sources_out = sepSources_blind ( ...
    audio, ...
    spectInfo, ...
    k, ...
    spect_func, ...
    nmf_init_func, ...
    nmf_func, ...
    reconstruct_func ...
)
% SEPSOURCES_BLIND - performs the whole blind source separation pipeline, based on a 
% single mixture audio file. Function handles may be provided for the 
% numerical blocks - otherwise the funtion will use the pretuned functions in user/tuned funcs.
%
%   arguments:
%      audio - the mixture audio, as a 1D vector
%
%      spectInfo - a struct containing the following parameters
%               synthwin - synthesis window   
%               analwin - analysis window
%               hop - hop size
%               nfft - fft length
%               fs - sampling frequency
%               num_freq_bins - number of frequency bins in the spectrogram
%               num_time_bins - number of time bins in the spectrogram
%               audio_len_samp - length of the original audio
%
%      k - the expected number of distinct note-instrument pairs in the audio
%          this parameter sets the number of columns in W and number of rows in H
%
%       spect_func (optional - omit or supply [] to skip)
%               The function with which to take the spectrogram
%               interface: [spect, spectInfo] = spect_func(audio, spectInfo);
%
%       nmf_Init_func (optional - omit or supply [] to skip)
%               The function with which to initialise the W and H matrices before NMF
%               interface: [W_init, H_init] = nmf_init_func(spectInfo, k);
%
%       nmf_func (optional - omit or supply [] to skip)
%               The function with which to perform NMF 
%               interface: [W_out,H_out] = nmf_func(spect_mag, W_init, H_init);
%
%       recons_func (optional - omit or supply [] to skip)
%               The reconstruction function to find time-domain sources from W and H
%               after convergence                
%               interface: sources_out = recons_func (spect, W_out, H_out, spectInfo);
%
%       return values:
%               sources_out - a matrix in which each row is one separated out source    

    % default args
    % supply [] to skip an arg
    if nargin < 4 || isempty(spect_func)
        spect_func = @nss_stft;
    end
    if nargin < 5 || isempty(nmf_init_func)
        nmf_init_func = @nmf_init_tuned;
    end
    if nargin < 6 || isempty(nmf_func)
        nmf_func = @nmf_tuned;
    end
    if nargin < 7 || isempty(reconstruct_func)
        reconstruct_func = @recons_tuned_BSS;
    end

    % take spect
    [spect, spectInfo] = spect_func(audio, spectInfo);
    assert(checkSpectInfo(spectInfo), "missing values in return value for spectInfo!");

    % initialise NMF function
    [W_init, H_init] = nmf_init_func(spectInfo, k);
    assert(isequal( size(W_init),[spectInfo.num_freq_bins,k] ), "W_init is the wrong size");
    assert(isequal( size(H_init),[k,spectInfo.num_freq_bins] ), "H_init is the wrong size");

    % do nmf
    spect_mag = abs(spect);
    [W_out,H_out] = nmf_func(spect_mag, W_init, H_init);
    assert(isequal(size(W_init), size(W_out)), "W_out is the wrong size");
    assert(isequal(size(H_init), size(H_out)), "H_out is the wrong size");

    % reconstruct sources
    sources_out = reconstruct_func (spect, W_out, H_out, spectInfo);
    assert(size(sources_out, 1) == k, "wrong number of sources in output");

    % implicitly return sources_out
end
