function notes_aligned = aln_dtw (notes, audio, spectInfo, use_vel)
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
    
    spect = num_stft(audio,spectInfo);

    %{
    figure(1);
    subplot(3,1,1);
    imagesc(chroma_audio);
    subplot(3,1,2);
    imagesc(chroma_midi);  
    subplot(3,1,3);
    imagesc(abs(spect));

    figure(2); 
    imagesc(C);
    %}

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

