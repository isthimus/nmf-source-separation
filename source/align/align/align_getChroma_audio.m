function chroma = aln_getChroma_audio (audio_vec, spectInfo)
    % extract vals from spectInfo
    wlen = spectInfo.wlen;
    fs = spectInfo.fs;
    hop = spectInfo.hop;
    audio_len_samp = spectInfo.audio_len_samp;
    num_time_bins = spectInfo.num_time_bins;

    % precondition checks
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


