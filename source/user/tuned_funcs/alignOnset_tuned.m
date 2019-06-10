function notes_aligned = alignOnset_tuned(n,a,s,si)
% ALIGNONSET_TUNED - calls the best onset-detecting alignment function with 
% the best performing set of parameters, as found during testing.
% 
%   arguments:
%       n (notes) - an array representing the midi score, in the format produced by midiInfo(readmidi(...))  
%       a (audio) - the audio vector
%       s (spect) - the audio spectrum according to spect_func.
%                   NB not all alignment functions use this argument so it might be unused
%       si (spectInfo) - a struct containing the following parameters
%           synthwin - synthesis window   
%           analwin - analysis window
%           hop - hop size
%           nfft - fft length
%           fs - sampling frequency
%           num_freq_bins - number of frequency bins in the spectrogram
%           num_time_bins - number of time bins in the spectrogram
%           audio_len_samp - length of the original audio
%
%   return values:
%       notes_aligned - the realigned MIDI score





    onset_tuned = @(s,si)aln_onset_specDiffR(s,si,1,0);
    notes_aligned = aln_align_dtw_onset(n,a,s,si,onset_tuned, 0.3, true);
end