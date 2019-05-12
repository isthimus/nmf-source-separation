function notes_aligned = aln_align_dtw (notes, audio, spectInfo, use_vel)
% ALN_ALIGN_DTW - align a midi score to an audio vector using chroma-based dtw
%
%   arguments:
%       notes - an array representing the midi score, in the format produced by midiInfo(readmidi(...))  
%       audio - the audio vector
%       spectInfo - a struct containing the following parameters
%           synthwin - synthesis window   
%           analwin - analysis window
%           hop - hop size
%           nfft - fft length
%           fs - sampling frequency
%           num_freq_bins - number of frequency bins in the spectrogram
%           num_time_bins - number of time bins in the spectrogram
%           audio_len_samp - lenght of the original audio
%      use_vel - a flag indicating whether MIDI velocity should be incorporated or ignored
%
%   return values:
%       notes_aligned - the realigned MIDI score, in the same format as "notes"
%
%   description:
%       This function extracts chromagrams from both the MIDI score in notes and the audio in audio,
%       then uses DTW (dynamic time warping) to align the MIDI chromagram to the audio chromagram
%       it then propogates this information to the original notes array, producing a realigned
%       MIDI score in notes_aligned.



    % perform alignment between the MIDI in notes and the audio in audio,
    % using dtw along with chroma extraction.
    % notes_aligned is the realigned MIDI.
    % if use_vel is set to false, midi velocity is ignored.

    % default args
    if nargin < 4
        use_vel = true;
    end

    % extract chroma from midi and audio. normalise audio chroma
    chroma_midi = aln_getChroma_midi (notes, spectInfo, use_vel);
    chroma_midi = mat_normalise(chroma_midi, 1);
    
    chroma_audio = aln_getChroma_audio (audio, spectInfo);
    chroma_audio = mat_normalise(chroma_audio, 1);
    
    spect = nss_stft(audio,spectInfo);

    % perform dtw to find warping path between chroma
    C = aln_dtw_buildCostMatrix(chroma_midi, chroma_audio);
    [~, IM, IA] = aln_dtw_traceback(C);

    % warp midi using midiPathWarp and return
    % make sure IM, IA are column vectors first
    if isrow(IM); IM = IM'; end
    if isrow(IA); IA = IA'; end
    IM = aln_resolveWarpingPath (IM, IA);
    notes_aligned = aln_midiPathWarp (notes, IM, spectInfo);
end

