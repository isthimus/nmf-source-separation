function chroma = align_getChroma_audio (audio_vec, spectInfo) 
    % we need to choose the chromagram arguments such that:
    % - first chroma bin is centred at spectInfo.wlen/2
    % - chroma hop is equal to spectInfo.hop 

    % however the chromagram_IF function is hardcoded such that chroma_nfft = chroma_wlen = 4 * chroma_hop
    % so we do a dirty hack and transform the audio slightly such that the bins line up

    chroma_nfft = 4 * spectInfo.hop; % ensures the hop sizes line up

    cwc = ceil(chroma_nfft ./ 2); % first window centre for the chromagram 
    swc = ceil(spectInfo.wlen ./2); % first window centre for the spectrogram

    % !!! need to unit test the below.
    if cwc > swc
        % chromagram first centre is later - need to zero pad
        audio_vec = [zeros(cwc-swc,1); audio_vec; zeros(cwc-swc,1)];
    else % swc >= cwc
        % chromagram first centre is earlier - need to trim samples off the start
        audio_vec = audio_vec( (swc-cwc)+1  : end - (swc-cwc));
    end

    % now we can take the chromagram as normal
    chroma = chromagram_IF(audio_vec, spectInfo.fs, chroma_nfft);

    assert (size(chroma, 2) = spectInfo.num_time_bins, "alignment error between chromagram and spectrogram")


end