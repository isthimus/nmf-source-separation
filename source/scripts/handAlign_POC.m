% learning how the midi library works and doing some
% basic testing of my helper functions

% suppress warnings from matlab due to the "if 0" blocks
%#ok<*UNRCH>

% cd to the folder this script is in
script_path = mfilename('fullpath');
if ispc
    script_path = script_path(1: find(script_path == '\', 1, 'last'));
elseif isunix
    script_path = script_path(1: find(script_path == '/', 1, 'last'));
end
cd(script_path)

% setup matlab path and pick up some useful path strings
run('./setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
PHENICX_DATA_PATH = fullfile (PROJECT_PATH, '/datasets/PHENICX');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

% make and view a piano roll
midi = readmidi ('jesu.mid');
spectInfo.wlen = 1024;
spectInfo.nfft = spectInfo.wlen * 4;
spectInfo.num_freq_bins = spectInfo.nfft / 2 + 1;
spectInfo.hop = 1024/8;
spectInfo.fs = 44000;

fs = spectInfo.fs;

% build piano roll
notes = midiInfo(midi, 0);
% this is a slightly silly test script so we're just gonna make up audio_len_samp
% something something, "smoke test", something mumble something
% the "+44000" is just adding a second of silence on the end. makeMasks needs to be able to handle it.
endTimes = notes (:, 6);
spectInfo.audio_len_samp = ceil(max(endTimes(:)) * fs);
%audio_len_samp = ceil(max(endTimes(:)) * fs) + 44000;
spectInfo.num_time_bins = align_samps2TimeBin(spectInfo.audio_len_samp, spectInfo);


hop = spectInfo.hop;
fs = spectInfo.fs;

[pianoRoll, pianoRoll_t, pianoRoll_nn] = piano_roll(notes, 0, hop/fs);
pianoRoll_tb = align_secs2TimeBin (pianoRoll_t, spectInfo);

% plot pianoRoll_t and pianoRoll_tb to make sure they correspond
if 1
    imagesc (pianoRoll_t, pianoRoll_nn, pianoRoll); 
    wait_returnKey();
    stem (pianoRoll_t, pianoRoll_tb);
    wait_returnKey();
    pianoRoll_ts = pianoRoll_t * fs;
    stem (pianoRoll_ts, pianoRoll_tb);
    wait_returnKey();
    close all;
end

% plot midi note number against linear-scale frequency.
% houston, do we have a problem here?
if 1
    spectInfo_halfNfft = spectInfo;
    spectInfo_halfNfft.nfft = spectInfo.nfft/2;

    spectInfo_doubleNfft = spectInfo;
    spectInfo_doubleNfft.nfft = spectInfo.nfft * 2;

    figure;hold on
    p1 = stem (align_nn2FreqBin([0:127], spectInfo_halfNfft));
    p2 = stem (align_nn2FreqBin([0:127], spectInfo));
    p3 = stem (align_nn2FreqBin([0:127], spectInfo_doubleNfft));
    legend ([p1,p2,p3],'nfft = 2048', 'nfft = 4096', 'nfft = 8192');
    title ("midi note num against freq bin for a linear frequency scale, fs =  44k");
    xlabel ("midi note number");
    ylabel ("freq bin");
    wait_returnKey()
    close all;
end

% run align_makeMasks_midi and plot along with piano roll for comparison
if 1 
    [W_mask, H_mask] = align_makeMasks_midi(notes, spectInfo);

    figure (1);
    %imagesc(W_mask);
    contour(W_mask);
    title("W\_mask");

    figure (2);
    imagesc(H_mask);
    title("H\_mask");

    figure (3);
    imagesc(pianoRoll);
    title("pianoRoll");

    wait_returnKey
    close all;

    for i = 1:size(W_mask, 2)
        stem(W_mask(:,i))
        wait_returnKey
    end
    close all;
end

% run align_makeMasks_midi, use as input to nmf_init_zeromask, display.
if 1
    [W_mask, H_mask] = align_makeMasks_midi(notes, spectInfo);
    [W_init, H_init] = nmf_init_zeroMask (W_mask, H_mask, spectInfo);

    figure (1);
    imagesc(W_init);

    figure (2);
    imagesc(H_init);

    wait_returnKey
    close all;
end

% make masks from a multitrack midi file and display the various stages
if 1
    % get a multitrack midi file
    midipath = fullfile (DEV_DATA_PATH, 'phenicx_beethoven_2track.mid');
    midi_multiChan = readmidi(midipath);
    notes_multiChan = midiInfo(midi_multiChan, 0);

    % pick up new audio length, put in spectInfo
    endTimes = notes_multiChan (:, 6);
    spectInfo.audio_len_samp = ceil(max(endTimes(:)) * fs) + 44000;

    % build piano roll
    [pianoRoll, pianoRoll_t, pianoRoll_nn] = piano_roll(notes_multiChan, 0, hop/fs);
    pianoRoll_tb = align_secs2TimeBin (pianoRoll_t, spectInfo);
    spectInfo.num_time_bins = align_samps2TimeBin(spectInfo.audio_len_samp, spectInfo);

    %perform alignment
    [W_mask, H_mask] = align_makeMasks_midi(notes_multiChan, spectInfo);

    % plot W_mask, H_mask, and pianoRoll
    figure (1);
    %imagesc(W_mask);
    contour(W_mask);
    title("W\_mask");

    figure (2);
    imagesc(H_mask);
    title("H\_mask");

    figure (3);
    imagesc(pianoRoll);
    title("pianoRoll");

    wait_returnKey
    close all;
end