% WARNING - file write function written specifically for this bench
% does funny things with sample rate conversion and such
% NOT a general file I/O function, should not appear on matlab PATH.
% do not pass go, do not collect $200

function write_to_wavFile (onsets, audio, spectInfo, filename)
    % write onset to file as a wav
    if iscolumn(onsets)
        % if its 1D just normalise by maximum
        onsets_norm = onsets / max(onsets);
    else
        % if its multidimensional just show the magnitudes in the file 
        onsets_norm = zeros(size(onsets,2), 1);
        for k = 1:size(onsets, 2)
            onsets_norm(k) = norm(onsets(:, k));
        end
        onsets_norm = onsets_norm / max(onsets_norm);
    end

    % upsample to audio rate
    % the zero padding either side is because time bins are irregularly spaced
    onsets_ar = [
        zeros(spectInfo.wlen./2, 1); ...
        upsample(onsets_norm, spectInfo.hop); ...
        zeros(spectInfo.wlen./2-spectInfo.hop, 1) ...
    ];

    % check the shape of the output
    assert(ndims(audio) == ndims(onsets_ar), "audio-rate onset measure is the wrong shape");
    
    % audio might be longer than onsets_ar by up to hop - 1 (since stft() ignores the last few samps)
    % make sure the difference is no more than that
    assert(size(audio,1) - size(onsets_ar, 1) < spectInfo.hop, "missing timeBins in audio rate onset measure");

    % convolve with a rectangular kernel to get rid of all the zeros
    % does not account for the wlen/2 - hop samples on the very start and end.
    % leaves them as 0. this is only about 1/88th of a sec so no matter
    onsets_ar = conv(onsets_ar, ones(spectInfo.hop, 1), 'same');

    % pad onsets_ar so its length exactly matches audio
    % somewhat redundant but makes alignment in sonic visualiser more reliable
    onsets_ar = [
        onsets_ar; ...
        zeros(length(audio) - length(onsets_ar), 1) ...
    ];

    % write to file
    audiowrite(filename, onsets_ar, spectInfo.fs);
end