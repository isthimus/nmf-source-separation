function sources_out = nmf_separate_sources (nmf_func, nmf_init_func, spectrogram_func, reconstruction_func, audio_vec, plot_level)
    % performs source separation using one of a range of nmf functions.
    % returns a matrix where each column is one separated out source.
    
    % "audio_vec" is a vector containing the audio to be worked on. !!! stereo?
    % "plot_level" is a verbosity-like flag stating how much info to plot
    % all other inputs are function handles with prototypes as below
    % use partial application to make them match if necessary
    
    % [W_out, H_out] = nmf_func(V, W, H)
    % [W_init, H_init] = nmf_init_func(num_freq_bins, num_time_bins)
    % spectrogram = spectrogram_func(vector)
    %       NB: so the above will usually be a big partial application of "spectrogram(_)"
    % sources_out = reconstruction_func(W, H)
    
    % eg - to make nmf_euclidian_norm match nmf_func:
    % myThreshold = 10; myMaxIter = 10000;
    % p = @(V, W, H) nmf_euclidian_norm(V, W, H, myThreshold, myMaxIter)
    % nmf_separate_sources(p, <some>, <other>, <args>, ...)

    currFig = 1;
    
    % get spectrogram
    spect = spectrogram_func(audio_vec);
    
    % plot if plotFlag is non zero
    if plot_level >= 1
        
        % audio spectrum
        figure(currFig);
        imagesc(abs(spect))
        title ('spectrogram (abs value)')
        currFig = currFig + 1;
    end
    
    % initialise W and H 
    [num_freq_bins, num_time_bins] = size(spect);
    [W_init, H_init] = nmf_init_func(num_freq_bins, num_time_bins);
   
    % plot if plotFlag is non zero
    if plot_level >= 1
        
        % W
        figure(currFig);
        imagesc(W_init);
        title ('init W');
        currFig = currFig + 1;
        
        % H
        figure(currFig);
        imagesc(H_init);
        title ('init H');
        currFig = currFig + 1;
        
        % reset figure number and wait for button press
        currFig = 1;
        waitforbuttonpress
        close all
    end
    
    % perform NMF
    [W_out, H_out] = nmf_func (V, W, H);
    
    % plot if plotFlag is non zero 
    if plot_level >= 1
        figure (currFig);
        imagesc (W_out);
        title  ('W_out');
        currFig = currFig + 1;
        
        figure (currFig);
        imagesc(H_out);
        title ('H_out');
        currFig = currFig + 1;
        
        if plot_level >=2
            % iterate over basis vectors in W
            K = size(W_init, 2);
            for i = 1:K

                % display the contribution for each basis vector of W
                figure(currFig)
                M = H_out(i,:).*W_out(:,i);
                imagesc(M);
                title(['contribution #', num2str(i)]);
                currFig = currFig + 1;
            end
        end
    end
    
    % call reconstruction_func and return the original sources
    sources_out = reconstruction_func (W_out, H_out);
    
end