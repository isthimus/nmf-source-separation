% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('./setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');


% test align_resolveWarpingPath
if 0 
    % make two vectors for alignment
    a = [0 0 0 0 0 10 0 0 0 0 0 0 10 0 0 10 0 0 0 0 0];
    b = [0 0 0 0 0 1  7 1 1 1 7 1  1 1 1  7 0 0 0 0 0];
    
    % plot unaligned
    plot(a); hold on; plot (b); 
    title('unaligned');
    wait_returnKey
    close all
    
    % align with dtw
    [~, ia, ib] = dtw (a, b);
    
    % plot a(ia) against b(ib)
    % theyre aligned now but this is longer than the original sequence!
    plot(a(ia)); hold on; plot(b(ib)); 
    title('ia - ib');
    wait_returnKey
    close all;

    % now resolve the warping path to bring ia into line with an unmodified ib
    ia_r = align_resolveWarpingPath(ia, ib);
    plot(a(ia_r)); hold on; plot(b); 
    title('ia resolved to b');
    wait_returnKey
    close all;

    % bring ib into line with ia instead 
    ib_r = align_resolveWarpingPath (ib, ia);
    plot (a); hold on; plot (b(ib_r));
    title ('ib resolved to a');
    wait_returnKey
    close all;

    % plot the various indices
    stem (1:length(a)); hold on; stem (ia); stem(ia_r);
    title ("index types");
    wait_returnKey
    close all;

    % upsample, smooth and try again 
    a = upsample(a, 10);
    b = upsample(b, 10);

    linsmooth_IR = [1:20, 19:-1:1] ./ 20;
    quadsmooth_IR = linsmooth_IR .* linsmooth_IR;
    a = conv(a, quadsmooth_IR);
    b = conv(b, quadsmooth_IR);

    % plot unaligned
    plot(a); hold on; plot (b); 
    title('unaligned');
    wait_returnKey
    close all
    
    % align with dtw
    [~, ia, ib] = dtw (a, b);
    
    % plot a(ia) against b(ib)
    % theyre aligned now but this is longer than the original sequence!
    plot(a(ia)); hold on; plot(b(ib)); 
    title('ia - ib');
    wait_returnKey
    close all;

    % now resolve the warping path to bring ia into line with an unmodified ib
    ia_r = align_resolveWarpingPath(ia, ib);
    plot(a(ia_r)); hold on; plot(b); 
    title('ia resolved to b');
    wait_returnKey
    close all;

    % bring ib into line with ia instead 
    ib_r = align_resolveWarpingPath (ib, ia);
    plot (a); hold on; plot (b(ib_r));
    title ('ib resolved to a');
    wait_returnKey
    close all;

    % quick and dirty test to make sure it works with matrices
    %{
    v_a = [a;   2*a; 1.3*a];
    v_b = [b; 1.3*b;   2*b];
    %}
    v_a = [a; 2*a; 1.3*a];
    v_b = [b; 2*b; 1.3*b];


    % align with dtw
    [~, v_ia, v_ib] = dtw (v_a, v_b);

    % resolve a to b
    v_ia_r = align_resolveWarpingPath (v_ia, v_ib);

    % see if theyre different
    plot (ia_r); hold on; plot(v_ia_r);
    title('vectorised vs non vectorised warping'); 
    wait_returnKey;
    close all;

    % show that the differences are basically rounding differences
    plot (v_ia_r - ia_r)
    title('vectorised vs non vectorised warping - difference'); 
    wait_returnKey
    close all;
end 

% test align_getChroma_midi
if 1
    % go find some midi
    midi = readmidi (fullfile(DEV_DATA_PATH, 'TRIOS_brahms_2bar.mid'));

    % create a spectInfo (partially made up for this test script)
    spectInfo.wlen = 1024;
    spectInfo.nfft = spectInfo.wlen * 4;
    spectInfo.num_freq_bins = spectInfo.nfft / 2 + 1;
    spectInfo.hop = 1024/8;
    spectInfo.fs = 44000; 

    % build piano roll
    notes = midiInfo(midi, 0);
    % this is a slightly silly test script so we're just gonna make up spectInfo.audio_len_samp
    % something something, "smoke test", something mumble something
    % the "+44000" is just adding a second of silence on the end. other functions need to be able to handle it.
    endTimes = notes (:, 6);

    % spectInfo.audio_len_samp = ceil(max(endTimes(:)) * spectInfo.fs);
    spectInfo.audio_len_samp = ceil(max(endTimes(:)) * spectInfo.fs) + 44000;
    spectInfo.num_time_bins = align_samps2TimeBin(...;
        spectInfo.audio_len_samp, ... 
        spectInfo.wlen, ... 
        spectInfo.hop, ... 
        spectInfo.audio_len_samp ... 
    );

    % get pianoRoll
    [pianoRoll, pianoRoll_t, pianoRoll_nn] = piano_roll(notes, 0, spectInfo.hop/spectInfo.fs);
    pianoRoll_tb = align_secs2TimeBin (pianoRoll_t, spectInfo.fs, spectInfo.wlen, spectInfo.hop, spectInfo.audio_len_samp);

    % create a chromagram on the same timebase
    chromagram = align_getChroma_midi(notes, spectInfo, 0);

    % visual checking is actually a little funky because of pianoRoll_nn
    % first, make a tidy "timebin aligned" version of pianoRoll
    pianoRoll_tbAligned = zeros(size(pianoRoll, 1), spectInfo.num_time_bins);
    for i = 1:length(pianoRoll_tb);
        pianoRoll_tbAligned(:, pianoRoll_tb(i)) = pianoRoll_tbAligned(:, pianoRoll_tb(i)) + pianoRoll(:, i);
    end

    % add 0.5 to all rows of pianoRoll_tbAligned representing a C, to make them appear a different colour
    C_indices = mod(pianoRoll_nn, 12) + 1 == 1;
    pianoRoll_tbAligned(C_indices, :) = pianoRoll_tbAligned(C_indices, :) + 0.3;

    % build a new matrix which is the marked up pianoRoll concatenated with the chromagram, with a "line" of 0.7 values in between
    chromagram(1,:) = chromagram(1,:)  + 0.5;
    display_mat = [pianoRoll_tbAligned; ones(1, spectInfo.num_time_bins) * 0.7; chromagram];
    
    %plot for visual inspection
    imagesc(display_mat)
    title('visual check')
    caxis([0, 1.5])
    colorbar
    wait_returnKey()
    close all;
end

% prove that if end of audio is later than end of midi, the chromagram is still num_time_bins long
if 1
    midi = readmidi (fullfile(DEV_DATA_PATH, 'TRIOS_brahms_2bar.mid'));

    % create a spectInfo (partially made up for this test script)
    spectInfo.wlen = 1024;
    spectInfo.nfft = spectInfo.wlen * 4;
    spectInfo.num_freq_bins = spectInfo.nfft / 2 + 1;
    spectInfo.hop = 1024/8;
    spectInfo.fs = 44000; 

    % build piano roll
    notes = midiInfo(midi, 0);
    % this is a slightly silly test script so we're just gonna make up spectInfo.audio_len_samp
    % something something, "smoke test", something mumble something
    % the "+44000" is just adding a second of silence on the end. other functions need to be able to handle it.
    endTimes = notes (:, 6);

    % spectInfo.audio_len_samp = ceil(max(endTimes(:)) * spectInfo.fs);
    spectInfo.audio_len_samp = ceil(max(endTimes(:)) * spectInfo.fs) + 44000;
    spectInfo.num_time_bins = align_samps2TimeBin(...;
        spectInfo.audio_len_samp, ... 
        spectInfo.wlen, ... 
        spectInfo.hop, ... 
        spectInfo.audio_len_samp ... 
    );

    % get pianoRoll
    [pianoRoll, pianoRoll_t, pianoRoll_nn] = piano_roll(notes, 0, spectInfo.hop/spectInfo.fs);
    pianoRoll_tb = align_secs2TimeBin (pianoRoll_t, spectInfo.fs, spectInfo.wlen, spectInfo.hop, spectInfo.audio_len_samp);

    % create a chromagram on the same timebase
    chromagram = align_getChroma_midi(notes, spectInfo, 0);

    % lots of weird shunting around to gwet something i can look at. see above.
    pianoRoll_tbAligned = zeros(size(pianoRoll, 1), spectInfo.num_time_bins);
    for i = 1:length(pianoRoll_tb);
        pianoRoll_tbAligned(:, pianoRoll_tb(i)) = pianoRoll_tbAligned(:, pianoRoll_tb(i)) + pianoRoll(:, i);
    end

    subplot(2,1,1)
    imagesc(pianoRoll)
    title('unaligned vs aligned pianoRoll')
    subplot(2,1,2)
    imagesc(pianoRoll_tbAligned)
    wait_returnKey()
    close all;

    C_indices = mod(pianoRoll_nn, 12) + 1 == 1;
    pianoRoll_tbAligned(C_indices, :) = pianoRoll_tbAligned(C_indices, :) + 0.3;
    chromagram(1,:) = chromagram(1,:)  + 0.5;
    display_mat = [pianoRoll_tbAligned; ones(1, spectInfo.num_time_bins) * 0.7; chromagram];
    
    %plot for visual inspection
    imagesc(display_mat)
    title('visual check')
    caxis([0, 1.5])
    colorbar
    wait_returnKey()
    close all;
end