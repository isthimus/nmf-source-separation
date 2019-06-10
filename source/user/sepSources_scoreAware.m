function sources_out = sepSources_scoreAware ( ... 
    notes,  ...
    audio,  ...
    spectInfo, ...
    spect_func,  ...
    align_func,  ...
    tol_func,  ...
    nmf_func,  ...
    recons_func, ...
    makeMasks_func, ...
    nmf_saInit_func ...
)
% SEPSOURCES_SCOREAWARE - performs the whole score-aware source separation pipeline
% on an audio mixture file and corresponding MIDI score. Function handles can be 
% provided for the numerical blocks - otherwise the function will use the pre-tuned
% functions in user/tuned_funcs.
% 
%   arguments:
%       notes - the (unaligned) MIDI representation of the musical score,
%               in the format produced by midiInfo(readmidi(...))  
%
%       audio - the mixture audio, as a 1D vector
%
%       spectInfo - a struct containing the following parameters
%               synthwin - synthesis window   
%               analwin - analysis window
%               hop - hop size
%               nfft - fft length
%               fs - sampling frequency
%               num_freq_bins - number of frequency bins in the spectrogram
%               num_time_bins - number of time bins in the spectrogram
%               audio_len_samp - length of the original audio
%
%       spect_func (optional - omit or supply [] to skip)
%               The function with which to take the spectrogram
%               interface: [spect, spectInfo] = spect_func(audio, spectInfo);
%
%       align_func (optional - omit or supply [] to skip)
%               The function with which to perform score alignment
%               interface: notes_aligned = align_func(notes, audio, spect, spectInfo);
%
%       tol_func (optional - omit or supply [] to skip)
%               The function with which to add tolerance to the W and H matrices after masking
%               interface: [W_mask, H_mask] = tol_func(W_mask, H_mask, spectInfo);
%
%       nmf_func (optional - omit or supply [] to skip)
%               The function with which to perform NMF 
%               interface: [W_out, H_out] = nmf_func (spect_mag, W_init, H_init);
%
%       recons_func (optional - omit or supply [] to skip)
%               The reconstruction function to find time-domain sources from W and H
%               after convergence                
%               interface: sources_out = recons_func (spect, W_out, H_out, spectInfo, trackVec);
%
%       makeMasks_func (optional - omit or supply [] to skip)
%               The function with which to make W and H masks from aligned MIDI
%               interface: [W_mask, H_mask, trackVec] = makeMasks_func(notes_aligned, spectInfo);
%
%       nmf_saInit_func (optional - omit or supply [] to skip)
%               The function with which to initialise the W and H matrices before NMF
%               based on W and H masks.
%               interface: [W_init, H_init] = nmf_saInit_func(W_mask, H_mask, spectInfo);
%
%       return values:
%               sources_out - a matrix in which each row is one separated out source    


    % default args. supply [] to skip an argument
    if nargin < 3 || isempty(spectInfo)
        spectInfo = spectInfo_tuned();
    end
    if nargin < 4 || isempty (spect_func)
        spect_func = @nss_stft;
    end
    if nargin < 5 || isempty (align_func)
        align_func = @alignOnset_tuned;
    end
    if nargin < 6 || isempty (tol_func)
        tol_func = @tol_tuned;
    end
    if nargin < 7 || isempty (nmf_func)
        nmf_func = @nmf_tuned;
    end
    if nargin < 8 || isempty (recons_func)
        recons_func = @recons_tuned_SASS;
    end    
    if nargin < 9 || isempty (makeMasks_func)
        makeMasks_func = @aln_makeMasks_midi;
    end    
    if nargin < 10 || isempty (nmf_saInit_func)
        nmf_saInit_func = @nss_init_zeroMask;    
    end

    % take spect, update spectInfo
    [spect, spectInfo] = spect_func(audio, spectInfo);
    assert(checkSpectInfo(spectInfo), "error in spect_func: missing values in return value for spectInfo!")

    % align midi
    notes_aligned = align_func(notes, audio, spect, spectInfo);

    % build W and H masks
    [W_mask, H_mask, trackVec] = makeMasks_func(notes_aligned, spectInfo);
    
    % apply tolerance to W and H
    [W_mask, H_mask] = tol_func(W_mask, H_mask, spectInfo);

    % initialise nmf matrices using masking information
    [W_init, H_init] = nmf_saInit_func(W_mask, H_mask, spectInfo);
    assert(all(size(W_mask) == size(W_init)), "error in nmf_saInit_func: size of W mask does not match W_init!");
    assert(all(size(H_mask) == size(H_init)), "error in nmf_saInit_func: size of H mask does not match H_init!");

    % perform nmf
    spect_mag = abs(spect);
    [W_out, H_out] = nmf_func (spect_mag, W_init, H_init);
    assert(isequal(size(W_init), size(W_out)), "error in nmf_func: W_out is the wrong size");
    assert(isequal(size(H_init), size(H_out)), "error in nmf_func: H_out is the wrong size");

    % reconstruct original sources
    sources_out = recons_func (spect, W_out, H_out, spectInfo, trackVec);
end