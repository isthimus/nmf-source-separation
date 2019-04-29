function nss_visualiser(audioFile, nmf_func, nmf_init_func, nmf_init_params)
    %{
    visualises the effect of NMF using a series of spectrograms. also first
    steps towards a proper harness

    "audioFile" should be a path to the audio file to test, as a string.
    "nmf_func" should be a function handle with prototype nmf_func(V, W, H, threshold, [varargin])
    "nmf_init_func" should return [W_init, H_init]. its prototype is nmf_init_func(num_freq_bins, num_time_bins, params)
    "nmf_init_params" is the set of parameters to pass to nmf_init_func. use a cell array if there's multiple parameters
    %}

    run('../scripts/setpaths.m');
    % rng(6399795) % not seeding randomness for now 
    
    % get audio file as vector
    [audio_vec, Fs] = audioread(audioFile);
    
    % plot the audio
    n= [1: length(audio_vec)];
    audio_vec = audio_vec (:, 1);
    plot(n,audio_vec)
    title('audio time domain')
    sound(audio_vec, Fs)
    wait_returnKey
    
    % define the analysis and synthesis parameters
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
    wait_returnKey

    % display the actual spectrogram matrix (its orientation is different)
    imagesc(20*log10(audio_spect_mag));
    colorbar
    title('magnitude spectrum')
    wait_returnKey
    close all
    
    % initialise W and H and perform the actual nmf process
    [num_freq_bins, num_time_bins] = size(audio_spect);
    [W_init, H_init] = nmf_init_func(num_freq_bins, num_time_bins, nmf_init_params{:});
    [W_out, H_out, final_err, iterations]   = nmf_func (audio_spect_mag, W_init, H_init);
    
    fprintf (" final_err = %d\n", final_err);
    fprintf ("iterations = %d\n", iterations);
    
    %colormap bone
    K = size(W_init, 2);
    for i = 1:K

        % display the contribution for each "basis vector" of W
        M = H_out(i,:).*W_out(:,i);
        imagesc(M);
        colorbar
        title(['contribution #', num2str(i)])
        
        % wait for return key before starting next contribution
        wait_returnKey
    end

    % display the target spectrum (dB for fine detail)
    % imagesc(20*log10(audio_spect_mag))
    imagesc(audio_spect_mag)
    colorbar
    title ('target spectrum')
    wait_returnKey
    
    % display the NMF approximation (dB for fine detail)
    % imagesc(20*log10(W_out * H_out))
    imagesc(W_out * H_out)
    colorbar
    title ('NMF approximation')
    wait_returnKey
    
    % display the difference
    imagesc(abs(audio_spect_mag - W_out * H_out));
    colorbar
    title ('difference')
    wait_returnKey
    
    % display difference in dB for fine detail
    diff_db = 20*log10(audio_spect_mag ./ ( W_out * H_out));
    diff_db(diff_db > 200) = 200;
    imagesc(diff_db)
    colorbar
    title ('difference - dB')
    wait_returnKey
    
    % close figures
    close all
    
    % graph and play separated sources
    imagesc(W_out)
    colorbar
    title('W\_out')
    wait_returnKey
    
    sources = nss_reconstruct_keepPhase (audio_spect, W_out, H_out, anal_win, synth_win, hop, nfft, Fs);
    %sources = nss_reconstruct_pitchTrack (audio_spect, W_out, H_out, 5, anal_win, synth_win, hop, nfft, Fs);
    K = size(sources, 1);
    for i = 1:K
        source_vec = sources(i, :);
      
        n= [1: length(source_vec)];
        plot(n,source_vec)
        title('source time domain')
        sound(source_vec, Fs)
        wait_returnKey
       
    end
    close all
    
end