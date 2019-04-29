function sources_out = nss_reconstruct_keepPhase (audio_spect, W, H, varargin)
    % NB varargin will be passed directly as an argument list to istft from the
    % Zhivomirov toolbox
    % other params self explanatory
    % returns a matrix where each column is one separated  out source

    assert (~isempty(audio_spect), 'assertion failure - audio_spect is empty!');
    assert (~isempty(W), 'assertion failure - W is empty!');
    assert (~isempty(H), 'assertion failure - H is empty!');
    
    sources_out = [];
    
    K = size(W, 2);
    for iter = 1:K
        % get the contribution for basis vector i of W
        source_i_mag = H(iter,:).*W(:,iter);
        
        % audio_spect_phases is a matrix with all elements magnitude 1
        % and phases matching audio_spect
        audio_spect(audio_spect == 0) = 1;
        audio_spect_phases = audio_spect./abs(audio_spect);
        
        % combine to get the full spectrogram
        source_i_fullspect = source_i_mag.*audio_spect_phases;
        
        % !!! catch and rethrow exception here for better error checking
        source_i_timedomain = istft(source_i_fullspect, varargin{:});
        
        s_i_t_size = size(source_i_timedomain);
        assert(s_i_t_size(1) == 1, 'internal assertion failure - size of source_i_timedomain is not (1, X)!')
        
        if isempty(sources_out)
           sources_out = source_i_timedomain;
        else
           % !!! preallocate
           % TODO handle silly buggers with non-zero alignment
           sources_out = [sources_out; source_i_timedomain]; %#ok<*AGROW>
        end
     
    end
end