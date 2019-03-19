%{
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
        audio_vec = [zeros(1,cwc-swc), audio_vec, zeros(1,cwc-swc)];
    else % swc >= cwc
        % chromagram first centre is earlier - need to trim samples off the start
        audio_vec = audio_vec( (swc-cwc)+1  : end - (swc-cwc));
    end
    % now we can take the chromagram as normal
    chroma = chromagram_IF(audio_vec, spectInfo.fs, chroma_nfft);
    
    % assert (size(chroma, 2) == spectInfo.num_time_bins, "alignment error between chromagram and spectrogram")

end
%}

function chroma = align_getChroma_audio (audio_vec, spectInfo)
    wlen = spectInfo.wlen;
    fs = spectInfo.fs;
    hop = spectInfo.hop;
    audio_len_samp = spectInfo.audio_len_samp;
    num_time_bins = spectInfo.num_time_bins;

    assert(mod(wlen/(2 * hop), 1) == 0, "wlen must be a multiple of 2*hop!");

    % choose chroma nfft such that the hop sizes line up
    chroma_nfft = 4 * hop;

    % the chromagram function divides the signal up in a slightly different way to the spectrogram
    % spectrogram(:, i) corresponds to chromagram (:, i + chroma_offset)
    chroma_offset = wlen /(2 * hop);

    num_chroma_bins_est = floor(audio_len_samp / hop) - 1;
    chroma = chromagram_IF(audio_vec, fs, chroma_nfft);
    num_chroma_bins = size(chroma, 2);

    assert(num_chroma_bins_est == num_chroma_bins, "chroma bins estimation formula is wrong!");
    assert(num_chroma_bins >= num_time_bins + chroma_offset, "chroma produced too few bins!")

    chroma = chroma(:, 1+chroma_offset : num_time_bins+chroma_offset);
end


