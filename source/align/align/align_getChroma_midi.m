function chroma = align_getChroma_midi (notes, spectInfo, use_vel)
    % extracts a chroma estimate from an unaligned midi score, for DTW based alignmment
    
    % if use_vel is not given, default to false
    if nargin < 3
        use_vel = false;
    end

    % preallocate chroma array
    chroma = zeros(12, spectInfo.num_time_bins);

    % get chroma val, start, end, and (vel)
    nns = notes(:, 3);
    vels = notes(:, 4) ./ 127; % normalise vels to 1
    start_sec = notes(:, 5);
    end_sec = notes(:, 6);

    chroma_vals = align_nn2chroma(nns);
    
    start_bins = align_secs2TimeBin(
        start_sec, ...
        spectInfo.fs, ...
        spectInfo.wlen, ...
        spectInfo.hop, ...
        spectInfo.audio_len_samp ...
    );

    end_bins = align_secs2TimeBin(
        end_sec, ...
        spectInfo.fs, ...
        spectInfo.wlen, ...
        spectInfo.hop, ...
        spectInfo.audio_len_samp ...
    );        

    % paint chroma according to values (norm vel to 1 for noo)
    if use_vel
        for i = 1:size(notes,1)
            chroma(chroma_vals(i), start_bins(i) : end_bins(i)) = vels(i);
        end
    else
        for i = 1:size(notes,1)
            chroma(chroma_vals(i), start_bins(i) : end_bins(i)) = 1;
        end
    end
end