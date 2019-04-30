function sources_out = nss_reconstruct_keepPhase (spect, W, H, spectInfo)
    % reconstructs audio after nmf
    % returns a matrix where each row is one separated  out source

    assert (~isempty(spect), 'assertion failure - spect is empty!');
    assert (~isempty(W), 'assertion failure - W is empty!');
    assert (~isempty(H), 'assertion failure - H is empty!');
    
    sources_out = [];
    
    K = size(W, 2);
    for iter = 1:K
        % get the contribution for basis vector i of W
        source_i_mag = H(iter,:).*W(:,iter);
        
        % spect_phases is a matrix with all elements magnitude 1
        % and phases matching spect
        spect(spect == 0) = 1;
        spect_phases = spect./abs(spect);
        
        % combine to get the full spectrogram, and transform to time domain
        source_i_fullspect = source_i_mag.*spect_phases;
        source_i_timedomain = nss_istft(source_i_fullspect, spectInfo);
        
        s_i_t_size = size(source_i_timedomain);
        assert(s_i_t_size(1) == 1, 'internal assertion failure - size of source_i_timedomain is not (1, X)!')
        
        if isempty(sources_out)
           sources_out = source_i_timedomain;
        else
           % !!! preallocate
           sources_out = [sources_out; source_i_timedomain]; %#ok<*AGROW>
        end
     
    end
end