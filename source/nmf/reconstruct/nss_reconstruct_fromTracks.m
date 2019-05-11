function sources_out = nss_reconstruct_fromTracks (spect, W, H, spectInfo, trackVec)
    % reconstructs audio after nmf
    % returns a matrix where each row is one separated  out source
    
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

