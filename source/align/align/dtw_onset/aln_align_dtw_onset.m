function notes_aligned = aln_align_dtw_onset (...
    notes, ...
    audio, ...
    spect, ... 
    spectInfo, ...
    onset_func, ...
    chroma_onset_ratio, ...
    use_vel, ...
    midiOnset_useRoot ...
)
% ALN_ALIGN_DTW_ONSET - align a midi score to an audio vector using chroma and onset based dtw
%
%   arguments:
%       notes - an array representing the midi score, in the format produced by midiInfo(readmidi(...))  
%       audio - the audio vector
%       spect - the mixture spectrogram
%       spectInfo - a struct containing the following parameters
%           synthwin - synthesis window   
%           analwin - analysis window
%           hop - hop size
%           nfft - fft length
%           fs - sampling frequency
%           num_freq_bins - number of frequency bins in the spectrogram
%           num_time_bins - number of time bins in the spectrogram
%           audio_len_samp - lenght of the original audio
%      onset_func - a handle to the onset detecting function to use
%               interface - onset_features = onset_func(spect, spectInfo)
%               the onset_features array should be a 1D array at timeBin-rate
%      chroma_onset_ratio - the weighting (from 0 to 1) between chroma and onset features. 
%           0 = all chroma
%           1 = all onset
%      use_vel - a flag indicating whether MIDI velocity should be incorporated or ignored
%      midiOnset_useRoot - 
%           0 = use a root-based smoothing kernel
%           1 = use an exponential smoothing kernel
%
%   return values:
%       notes_aligned - the realigned MIDI score, in the same format as "notes"
%
%   description:
%       This function extracts chromagrams from both the MIDI score in notes and the audio in audio,
%       then uses DTW (dynamic time warping) to align the MIDI chromagram to the audio chromagram
%       it then propogates this information to the original notes array, producing a realigned
%       MIDI score in notes_aligned.
   
    % default args
    if nargin < 6
        chroma_onset_ratio = 0.5; % 1 => all chroma, 0 => all onset.
    end
    if nargin < 7
        use_vel = true;
    end
    if nargin < 8
        midiOnset_useRoot = false;
    end
    assert (0 < chroma_onset_ratio && chroma_onset_ratio < 1, "chroma_onset_ratio should be between 0 and 1!")

    % extract chroma from midi and audio. normalise audio
    chroma_midi = aln_getChroma_midi (notes, spectInfo, use_vel);
    chroma_midi = mat_normalise(chroma_midi, 1);

    chroma_audio = aln_getChroma_audio (audio, spectInfo);
    chroma_audio = mat_normalise(chroma_audio, 1);

    % get the chroma-based dtw cost matrix
    C_chroma = aln_dtw_buildCostMatrix(chroma_midi, chroma_audio);

    % extract onsets from midi and audio (at timeBin-rate)
    onset_midi  = aln_getOnset_midi(notes, spectInfo);
    onset_audio = onset_func(spect, spectInfo);

    % get the onset-based dtw cost matrix
    C_onset = aln_dtw_buildCostMatrix (onset_midi, onset_audio);

    % make the final cost matrix using a weighted sum of the two
    C_final = chroma_onset_ratio*C_chroma + (1-chroma_onset_ratio)*C_onset;
    
    % traceback to find warping path
    % make sure IM, IA are column vectors first
    [~, IM, IA] = aln_dtw_traceback(C_final);
    if isrow(IM); IM = IM'; end
    if isrow(IA); IA = IA'; end
    IM = aln_resolveWarpingPath(IM, IA);

    % warp the midi and return
    notes_aligned = aln_midiPathWarp (notes, IM, spectInfo);
end