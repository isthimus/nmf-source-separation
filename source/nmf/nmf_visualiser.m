function nmf_visualiser(audioFile, nmf_func, nmf_init_func, nmf_init_params)
    %{
    visualises the effect of NMF using a series of spectrograms. also first
    steps towards a proper harness

    "audioFile" should be a path to the audio file to test, as a string.
    "nmf_func" should be a function handle with prototype nmf_func(V, W, H, threshold, [varargin])
    "nmf_init_func" should return [W_init, H_init]. its prototype is nmf_init_func(num_freq_bins, num_time_bins, params)
    "nmf_init_params" is the set of parameters to pass to nmf_init_func. use a cell array if ther's multiple parameters
    %}

    run('../scripts/setpaths.m');
    % rng(6399795) % not seeding randomness for now 
    
    % get audio file as vector
    [audio_vec, Fs] = audioread(audioFile);
    
    % plot the audio
    n= [1: length(audio_vec)];
    plot(n,audio_vec)
    title('audio time domain')
    sound(audio_vec, Fs)
    waitforbuttonpress
   
    % get spectrogram  and plot
    % !!! discuss overlap etc
    % !!! magic numbers
    % !!! nfft
    % spectrogram wrapper in subfunction?
    
    
    % define the analysis and synthesis parameters !!! JUST FROM EXAMPLE
    wlen = ceil(Fs/50); hop = ceil(3*wlen / 4); nfft = 1024; minThresh_dB = -110;
    anal_win = blackmanharris(wlen, 'periodic'); synth_win = hamming(wlen, 'periodic');

    %audio_spect = spectrogram(audio_vec, wlen, wlen - hop, 'MinThreshold',minThresh_dB);
    audio_spect = stft(audio_vec, anal_win, hop, nfft, Fs);
    
    %audio_spect = audio_spect(1:256, :);
    %audio_spect = audio_spect(1:nfft/2, :);
    audio_spect_mag = abs(audio_spect);
    audio_spect_mag(20*log10(audio_spect_mag) < minThresh_dB) = 0;
    spectrogram(audio_vec, wlen, wlen - hop, 'MinThreshold',minThresh_dB, 'yaxis')
   
    title('audio spectrum')
    waitforbuttonpress

    % display the actual spectrogram matrix (its orientation is different)
    imagesc(20*log10(audio_spect_mag));
    title('magnitude spectrum')
    waitforbuttonpress
    
    % smooth and display again
    smoothing_kernel = ones(5); % sake of argument
    audio_spect_mag = conv2(audio_spect_mag, smoothing_kernel, 'same');
    imagesc(20*log10(audio_spect_mag));
    title('magnitude spectrum after smoothing')
    waitforbuttonpress
    
    % initialise W and H and perform the actual nmf process
    [num_freq_bins, num_time_bins] = size(audio_spect);
    [W_init, H_init] = nmf_init_func(num_freq_bins, num_time_bins, nmf_init_params{:});
    [W_out, H_out]   = nmf_func (audio_spect_mag, W_init, H_init, 0.00001);
    
    K = size(W_init, 2);
    for i = 1:K

        % display the contribution for each "basis vector" of W
        colormap bone
        disp(size(H_out(i,:)))
        M = H_out(i,:).*W_out(:,i);
        imagesc(M);
        
        title(['contribution #', num2str(i)])
        waitforbuttonpress
    end

    % display the target spectrum (dB for fine detail)
    % imagesc(20*log10(audio_spect_mag))
    imagesc(audio_spect_mag)
    title ('target spectrum')
    waitforbuttonpress
    
    % display the NMF approximation (dB for fine detail)
    % imagesc(20*log10(W_out * H_out))
    imagesc(W_out * H_out)
    title ('NMF approximation')
    waitforbuttonpress
    
    % display the difference (dB for fine detail)
    imagesc(abs(audio_spect_mag - W_out * H_out));
    title ('difference')


    % wait and close figures
    waitforbuttonpress
    close all
    
    % graph and play separated sources, no smoothing
    imagesc(W_out)
    title('W before erode')
    waitforbuttonpress
    
    W_out = poormans_erode(W_out, 5, 5);
    
    imagesc(W_out)
    title('W before erode')
    waitforbuttonpress
    
    %sources = nmf_reconstruct_keepPhase (audio_spect, W_out, H_out, anal_win, synth_win, hop, nfft, Fs);
    sources = nmf_reconstruct_pitchTrack (audio_spect, W_out, H_out, 5, anal_win, synth_win, hop, nfft, Fs);
    K = size(sources, 1);
    for i = 1:K
        source_vec = sources(i, :);
      
        n= [1: length(source_vec)];
        plot(n,source_vec)
        title('source time domain')
        sound(source_vec, Fs)
        waitforbuttonpress
       
    end
    close all
    
end

function out = poormans_erode (mat, n_odd, thresh)
    [rows, cols] = size(mat);
    out = zeros(size(mat));
    for iter1 = 1:rows-n_odd
       for iter2 = 1:cols
            submat = mat(iter1:iter1 + n_odd, iter2);
            if all(submat>thresh)
               out(iter1 + ceil(n_odd/2), iter2) = mat(iter1 + ceil (n_odd/2), iter2);
            end
       end
    end
end