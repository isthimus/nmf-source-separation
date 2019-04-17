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
if 1 
    % clear spectInfo from last time
    spectInfo = struct();

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
    % clear spectInfo from last time
    spectInfo = struct();

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
    spectInfo.audio_len_samp = ceil(max(endTimes(:)) * spectInfo.fs);
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

% test align_getChroma_audio
if 1 
    % clear spectInfo from last time
    spectInfo = struct();

    % get some audio
    [vln_short, fs] = audioread(fullfile(DEV_DATA_PATH, "TRIOS_vln_C5_Eb5_F5_Ab4.wav"));
    [vln_long, fs] = audioread(fullfile(TRIOS_DATA_PATH, "/brahms/violin.wav"));
    audio = {vln_long};

    % get some midi
    vln_long_m = readmidi(fullfile(TRIOS_DATA_PATH, "/brahms/violin.mid"));
    midi = {vln_long_m};


    % build a spectInfo
    % using some params from eNorm_source_sep_POC
    spectInfo.wlen = 1024;
    spectInfo.nfft = spectInfo.wlen * 4;
    spectInfo.hop = 1024/8;
    spectInfo.fs = fs; 

    % analysis and synth windows
    % !!! should be in spectInfo? 
    analwin = blackmanharris(spectInfo.wlen, 'periodic');
    synthwin = hamming(spectInfo.wlen, 'periodic');

    % build spectrogram function
    p_spect = @(x) ...
        stft(x, analwin, spectInfo.hop, spectInfo.nfft, spectInfo.fs);
    
    % iterate over the different audio files
    for i = 1:length(audio)

        % get audio and take its spect.
        % put info about final spectrogram size in spectInfo
        thisAudio = audio{i};
        thisMidi = midi{i};
        plot (thisAudio);
        wait_returnKey()
        close all;

        spect = p_spect(thisAudio);
        spectInfo.num_freq_bins = size(spect, 1); 
        spectInfo.num_time_bins = size(spect, 2);
        spectInfo.audio_len_samp = length(thisAudio);

        % create chromagram
        % might fail an assertion and error
        chroma_audio = align_getChroma_audio(thisAudio, spectInfo);
    
        chroma_midi = align_getChroma_midi(midiInfo(thisMidi, 0), spectInfo, 1);

        % assuming it hasn't errored - display the chromagram with spectrum as subplots
        figure(1);
        subplot(3,1,1);
         imagesc(abs(spect(1:100,:)));
         title('audio')
         colorbar;
        subplot(3,1,2);
         imagesc(chroma_audio);
         title('chroma\_audio');
         colorbar;
        subplot(3,1,3);
         imagesc(chroma_midi);
         title('chroma\_midi');
         colorbar;
        wait_returnKey();
        close all;
    end    
end

% show that dtw -> resolveWarpingPath works on midi/audio chroma
if 1
    % clear spectInfo from last time
    spectInfo = struct();

    % getsome audio
    [audio, fs] = audioread(fullfile(TRIOS_DATA_PATH, "/brahms/violin.wav"));
    spectInfo.audio_len_samp = length(audio);

    % get some midi
    midi = readmidi(fullfile(TRIOS_DATA_PATH, "/brahms/violin.mid"));
    notes = midiInfo(midi, 0);

    % build a spectInfo
    % using some params from eNorm_source_sep_POC
    spectInfo.wlen = 1024;
    spectInfo.nfft = spectInfo.wlen * 4;
    spectInfo.hop = 1024/4;
    spectInfo.fs = fs; 

    % analysis and synth windows
    % !!! should be in spectInfo? 
    analwin = blackmanharris(spectInfo.wlen, 'periodic');
    synthwin = hamming(spectInfo.wlen, 'periodic');

    % build spectrogram function, take spect
    p_spect = @(x) ...
        stft(x, analwin, spectInfo.hop, spectInfo.nfft, spectInfo.fs);
    spect = p_spect(audio);

    % pick up num_time_bins/num_freq_bins    
    spectInfo.num_freq_bins = size(spect, 1);
    spectInfo.num_time_bins = size(spect, 2);

    % extract chroma from midi and audio
    chroma_midi = align_getChroma_midi (notes, spectInfo, 1);
    chroma_audio = align_getChroma_audio (audio, spectInfo);

    assert (all (size(chroma_midi) == size(chroma_audio)), "bad chroma matrix sizes");

    % perform dtw to find warping path between chroma
    [~, IM, IA] = dtw (chroma_midi, chroma_audio);
    IM = align_resolveWarpingPath (IM, IA);

    % IM is a set of indices for chroma_midi which should align it to chroma_audio
    % build a new matrix representing the aligned chroma and compare
    chroma_midi_aligned = chroma_midi(:, IM);

    figure(1);
    subplot(3,1,1);
     imagesc(abs(spect(1:100,:)));
     axis xy;
     title('audio')
     colorbar;
    subplot(3,1,2);
     imagesc(chroma_audio);
     axis xy;
     title('chroma\_audio');
     colorbar;
    subplot(3,1,3);
     imagesc(chroma_midi);
     axis xy; 
     title('chroma\_midi');
     colorbar;

    figure(2);
    subplot(3,1,1);
     imagesc(chroma_midi);
     axis xy;
     title('chroma\_midi unaligned');
     colorbar;
    subplot(3,1,2);
     imagesc(chroma_audio);
     axis xy;
     title('chroma\_audio');
     colorbar;
    subplot(3,1,3);
     imagesc(chroma_midi_aligned);
     axis xy;
     title('chroma\_midi aligned');
     colorbar;

    figure (3);
     plot(IM);
     title("warping path");
    
    wait_returnKey();
    close all;

    % now try align_dtw
    notes_aligned = align_dtw(notes, audio, spectInfo, 0);

    % build the piano roll of unaligned notes. make explicit the gap at the start, if any.
    [pr_u, pr_u_t, pr_u_nn] = piano_roll(notes, 0, spectInfo.hop/spectInfo.fs);
    pr_u_tb = align_secs2TimeBin(pr_u_t, spectInfo.fs, spectInfo.wlen, spectInfo.hop, spectInfo.audio_len_samp);
    pr_u = [zeros(size(pr_u,1), min(pr_u_tb)) , pr_u];

    % build the piano roll of aligned notes. make explicit the gap at the start, if any.
    [pr_a, pr_a_t, pr_a_nn] = piano_roll(notes_aligned, 0, spectInfo.hop/spectInfo.fs);
    pr_a_tb = align_secs2TimeBin(pr_a_t, spectInfo.fs, spectInfo.wlen, spectInfo.hop, spectInfo.audio_len_samp);
    pr_a = [zeros(size(pr_a,1), min(pr_a_tb)) , pr_a];

    disp(spectInfo);

    figure(1);
    subplot(2,1,1);
     imagesc(pr_u);
     title("unaligned");
    subplot(2,1,2);
     imagesc(pr_a);
     title("aligned");
    wait_returnKey();
    close all;
end

% check if calls to align_getChromaAudio with different scaling are more/less useful
% answer - no
if 0
    % clear spectInfo from last time
    spectInfo = struct();

    % getsome audio
    [audio, fs] = audioread(fullfile(TRIOS_DATA_PATH, "/brahms/violin.wav"));
    spectInfo.audio_len_samp = length(audio);

    % some variants on the audio - first norm to +- 1, +- 10
    audio_norm_1 = mat_normalise(audio, 1);
    audio_norm_10 = mat_normalise(audio, 10); 

    % try some heavy handed compression
    audio_comp = audio;
    audioMax = max(abs(audio)); ratio = 0.2;
    comp_indices = audio_comp(abs(audio_comp) > 0.5 * audioMax);
    for i = 1:length(audio_comp)
        if ismember(i, comp_indices)
            thisSamp = audio_comp(i);
            if thisSamp < 0
                audio_comp(i) = ((thisSamp + 0.5 * audioMax) * ratio) - 0.5 * audioMax;
            else
                audio_comp(i) = ((thisSamp - 0.5 * audioMax) * ratio) + 0.5 * audioMax;
            end
        end
    end
    audio_comp_1 = mat_normalise(audio_comp, 1);
    audio_comp_10 = mat_normalise(audio_comp, 10); 

    % build a spectInfo
    % using some params from eNorm_source_sep_POC
    spectInfo.wlen = 1024;
    spectInfo.nfft = spectInfo.wlen * 4;
    spectInfo.hop = 1024/8;
    spectInfo.fs = fs; 

    % analysis and synth windows
    % !!! should be in spectInfo? 
    analwin = blackmanharris(spectInfo.wlen, 'periodic');
    synthwin = hamming(spectInfo.wlen, 'periodic');

    % build spectrogram function, take spect
    p_spect = @(x) ...
        stft(x, analwin, spectInfo.hop, spectInfo.nfft, spectInfo.fs);
    spect = p_spect(audio);

    % pick up num_time_bins/num_freq_bins    
    spectInfo.num_freq_bins = size(spect, 1);
    spectInfo.num_time_bins = size(spect, 2);

    figure(1);
    subplot(3,1,1);
     imagesc(align_getChroma_audio(audio, spectInfo));
     axis xy;
     title('audio');
     colorbar;
    subplot(3,1,2);
     imagesc(align_getChroma_audio(audio_norm_1, spectInfo));
     axis xy;
     title('norm 1');
     colorbar;
    subplot(3,1,3);
     imagesc(align_getChroma_audio(audio_norm_10, spectInfo));
     axis xy;
     title('norm 10');
     colorbar;

    figure(2);
    subplot(3,1,1);
     imagesc(align_getChroma_audio(audio, spectInfo));
     axis xy;
     title('audio');
     colorbar;
    subplot(3,1,2);
     imagesc(align_getChroma_audio(audio_comp_1, spectInfo));
     axis xy;
     title('comp 1');
     colorbar;
    subplot(3,1,3);
     imagesc(align_getChroma_audio(audio_comp_10, spectInfo));
     axis xy;
     title('comp 10');
     colorbar;

     wait_returnKey();
     close all;
end

% try smaller hop for align_getChroma_audio
if 1 
    % clear spectInfo from last time
    spectInfo = struct();

    % getsome audio
    [audio, fs] = audioread(fullfile(TRIOS_DATA_PATH, "/brahms/violin.wav"));
    spectInfo.audio_len_samp = length(audio);

    results = cell(1, 1);
    for i = 0:2

        % build a spectInfo
        % using some params from eNorm_source_sep_POC
        spectInfo.wlen = 1024;
        spectInfo.nfft = spectInfo.wlen * 4;
        assert(spectInfo.wlen/(2^i * 4) > 32);
        spectInfo.hop = spectInfo.wlen/(2^i * 4);
        spectInfo.fs = fs; 

        disp(spectInfo.hop);
        assert (mod(spectInfo.hop, 1) == 0, "DAMMIT JACK");

        % analysis and synth windows
        % !!! should be in spectInfo? 
        analwin = blackmanharris(spectInfo.wlen, 'periodic');
        synthwin = hamming(spectInfo.wlen, 'periodic');

        % build spectrogram function, take spect
        p_spect = @(x) ...
            stft(x, analwin, spectInfo.hop, spectInfo.nfft, spectInfo.fs);
        spect = p_spect(audio);

        % pick up num_time_bins/num_freq_bins    
        spectInfo.num_freq_bins = size(spect, 1);
        spectInfo.num_time_bins = size(spect, 2);

        % extract chroma from midi and audio
        chroma_audio = align_getChroma_audio (audio, spectInfo);

        results{i + 1} = chroma_audio;
    end

    % plot results

    figure(1)
    subplot(3,1,1)
     imagesc(results{1})
     axis xy
     title('hop 1/4')
     colorbar;
    subplot(3,1,2)
     imagesc(results{2})
     axis xy
     title('hop 1/8')
     colorbar;
    subplot(3,1,3)
     imagesc(results{3})
     axis xy
     title('hop 1/16')
     colorbar;
     
     wait_returnKey();
     close all;
end

