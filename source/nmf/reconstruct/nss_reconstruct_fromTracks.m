function sources_out = nss_reconstruct_fromTracks (spect, W, H, spectInfo, trackVec)
% NSS_RECONSTRUCT_FROMTRACKS - recover the source tracks after score-aware NMF
%
%   arguments:
%       spect - the original mixture spectrogram
%       W - the template matrix W after NMF convergence
%       H - the activation matrix H after NMF convergence
%
%       spectInfo - a struct containing the following parameters
%           synthwin - synthesis window   
%           analwin - analysis window
%           hop - hop size
%           nfft - fft length
%           fs - sampling frequency
%           num_freq_bins - number of frequency bins in the spectrogram
%           audio_len_samp - lenght of the original audio
%
%       trackVec - a vector of integers, such that trackVec(i) is the MIDI track
%           associated with template vector W(:,i) and activation vector H(i,:)
%
%   return values:
%       sources_out - a matrix whose rows are the separated out time-domain sources. 
%
%   description:
%       this function takes as input the W and H matrices produced by NMF convergence and uses them
%       to build a set of "contribution spectra" corresponding to the contribution of each template 
%       vector/activtion vector pair to the overall spectrum. contribution spectra which correspond 
%       to the same midi track (according to trackVec) are summed, giving one spectrogram for each MIDI channel.
%       Then the istft of each spectrum is taken and the resultant time domain sources returned in sources_out. 

    % unpack spectInfo
    num_freq_bins = spectInfo.num_freq_bins;
    num_time_bins = spectInfo.num_time_bins;
    audio_len_samp = spectInfo.audio_len_samp;
     
    % spect_phases is a matrix with all elements magnitude 1
    % and phases matching spect
    spect(spect == 0) = 1;
    spect_phases = spect./abs(spect);

    % preallocate sources_out and iterate over the sources
    numchans = length(unique(trackVec));
    sources_out = zeros(numchans, audio_len_samp);
    for i = unique(trackVec(:)).'

        % iterate over the indices in W,H corresponding to this source
        WH_indices = find(trackVec == i);
        source_i_mag = zeros(num_freq_bins, num_time_bins);
        for j = WH_indices(:).'
            
            % accumulate the STFT magnitudes from each index
            source_i_mag = source_i_mag + H(j,:).*W(:,j); 
        end

        % combine to get the full spectrogram, and transform to time domain
        source_i_fullspect = source_i_mag.*spect_phases;
        source_i_timedomain = nss_istft(source_i_fullspect, spectInfo);
 
        % write into sources_out
        sources_out(i,:) = mat_normalise(source_i_timedomain, 1);
    end

    %implicit return sources_out
end

