function nmf_visualiser(audioFile, nmf_func, nmf_init_func, nmf_init_params)
    % visualises the effect of NMF on a series of spectrograms. also first
    % steps towards a proper harness.
    colormap summer 
    rng(6399795) % !!! is this a good shout long term?
    [audio_vec, Fs] = audioread(audioFile);
   
    n= [1: length(audio_vec)];
    plot(n,audio_vec)
    waitforbuttonpress
   
    audio_spect = spectrogram(audio_vec, ceil(Fs/50), ceil(Fs/200), 'MinThreshold',-100);
    audio_spect_mag = abs(audio_spect);
    spectrogram(audio_vec, ceil(Fs/50), ceil(Fs/200), 'MinThreshold',-100, 'yaxis')
    disp(mean(audio_spect(:)))
    disp(max(audio_spect(:)))
   
    waitforbuttonpress

    imagesc(audio_spect_mag);
    waitforbuttonpress
    [num_freq_bins, num_time_bins] =  size(audio_spect);
   
    [W_init, H_init] = nmf_init_func(num_freq_bins, num_time_bins, nmf_init_params);
    
    tmp = W_init < 0;
    disp (sum(tmp(:)))
    tmp = H_init < 0;
    disp (sum(tmp(:)))
    tmp = abs(audio_spect) < 0;
    disp (sum(tmp(:)))
    
    [W_out, H_out]   = nmf_func (audio_spect_mag, W_init, H_init, 0.00001);
    
    
    
    K = size(W_init, 2);
    for i = 1:K
        colormap bone
        disp(size(H_out(i,:)))
        M = H_out(i,:).*W_out(:,i);
        imagesc(M);
        waitforbuttonpress
    end
    imagesc(20*log10(audio_spect_mag))
    waitforbuttonpress
    imagesc(20*log10(W_out * H_out))
    waitforbuttonpress
    imagesc(20*log10(abs(audio_spect_mag - W_out * H_out)));
    waitforbuttonpress
    close all
end