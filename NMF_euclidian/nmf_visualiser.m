function nmf_visualiser(audioFile, nmf_func, nmf_init_func, nmf_init_params)
    %{
    visualises the effect of NMF using a series of spectrograms. also first
    steps towards a proper harness

    "audioFile" should be a path to the audio file to test, as a string.
    "nmf_func" should be a function handle with prototype nmf_func(V, W, H, threshold, [varargin])
    "nmf_init_func" should return [W_init, H_init]. its prototype is nmf_init_func(num_freq_bins, num_time_bins, params)
    "nmf_init_params" is the set of parameters to pass to nmf_init_func. use a cell array if ther's multiple parameters
    %}

    colormap bone
    % rng(6399795) % not seeding randomness for now 
    
    % get audio file as vector
    [audio_vec, Fs] = audioread(audioFile);
   
    % plot the audio
    n= [1: length(audio_vec)];
    plot(n,audio_vec)
    
    title('audio time domain')
    waitforbuttonpress
   
    % get spectrogram  and plot
    % !!! discuss overlap etc
    % !!! magic numbers
    % !!! nfft
    % spectrogram wrapper in subfunction?
    
    audio_spect = spectrogram(audio_vec, ceil(Fs/50), ceil(Fs/200), 'MinThreshold',-110);
    audio_spect = audio_spect(1:257, :);
    audio_spect_mag = abs(audio_spect);
    spectrogram(audio_vec, ceil(Fs/50), ceil(Fs/200), 'MinThreshold',-110, 'yaxis')
   
    title('audio spectrum')
    waitforbuttonpress

    % display the actual spectrogram matrix (its orientation is different)
    imagesc(audio_spect_mag);
    title('magnitude spectrum')
    waitforbuttonpress

    % initialise W and H and perform the actual nmf process
    [num_freq_bins, num_time_bins] = size(audio_spect);
    [W_init, H_init] = nmf_init_func(num_freq_bins, num_time_bins, nmf_init_params);
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
    waitforbuttonpress

    %close figures and exit
    close all
end