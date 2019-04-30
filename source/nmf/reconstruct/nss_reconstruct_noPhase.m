function sources_out = nss_reconstruct_noPhase (spect, W, H, spectInfo)
    % other params self explanatory
    % returns a matrix where each column is one separated  out source

    % doesnt collect phase from original spectrogram - essentially just sets all
    % starting phases to 0 in each nfft frame

    assert (~isempty(W), 'assertion failure - W is empty!');
    assert (~isempty(H), 'assertion failure - H is empty!');
    
    sources_out = [];
    
    K = size(W, 2);
    for iter = 1:K
        % get the contribution for basis vector i of W
        source_i_mag = H(iter,:).*W(:,iter);

        % would expect phase generation here.
        source_i_fullspect = source_i_mag;
        
        source_i_timedomain = nss_istft(source_i_fullspect, spectInfo);
        assert(size(source_i_timedomain,1) == 1, 'internal assertion failure - size of source_i_timedomain is not (1, X)!')
        
        if isempty(sources_out)
           sources_out = source_i_timedomain;
        else
           % !!! preallocate
           sources_out = [sources_out; source_i_timedomain]; %#ok<*AGROW>
        end
     
    end
end