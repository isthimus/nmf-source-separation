function sources_out = nmf_separate_sources (nmf_func, nmf_init_func, spect_func, reconstruct_func, audio_vec, plot_level)
    % performs source separation using one of a range of nmf functions.
    % returns a matrix where each column is one separated out source.
    %
    % "audio_vec" is a vector containing the audio to be worked on. !!! stereo?
    % "plot_level" is a verbosity-like flag stating how much info to plot
    % all other inputs are function handles with prototypes as below
    % use partial application to make them match if necessary
    %
    % [W_out, H_out] = nmf_func(V, W, H)
    % [W_init, H_init] = nmf_init_func(num_freq_bins, num_time_bins)
    % spectrogram = spectrogram_func(vector)
    % sources_out = reconstruction_func(orig_audio_spectrogram, W, H)
    %   NB! reconstruction func to return a matrix whose rows are the sources
    %
    % eg - to make nmf_euclidian_norm match nmf_func:
    % myThreshold = 10; myMaxIter = 10000;
    % nmf_en_partial = @(V, W, H) nmf_euclidian_norm(V, W, H, myThreshold, myMaxIter)
    % nmf_separate_sources(nmf_en_partial, <some>, <other>, <args>, ...)
    
    % get spectrogram, plot if plot_level >= 1
    spect = spect_func(audio_vec);
    plot_if_plotLvl(plot_level, 1, 'spectrogram (abs value)', true, @imagesc, abs(spect))
    
    % initialise W and H, plot if plot_level >= 2
    [num_freq_bins, num_time_bins] = size(spect);
    [W_init, H_init] = nmf_init_func(num_freq_bins, num_time_bins);
    plot_if_plotLvl(plot_level, 2, 'W\_init', false, @imagesc, W_init)
    plot_if_plotLvl(plot_level, 2, 'H\_init', true,  @imagesc, H_init)
    
    % perform NMF, plot W and H and contributions if plot lvl high enough
    spect_mag = abs(spect);
    [W_out, H_out] = nmf_func (spect_mag, W_init, H_init);
    plot_if_plotLvl(plot_level, 1, 'W\_out', false, @imagesc, W_out)
    plot_if_plotLvl(plot_level, 1, 'H\_out', true,  @imagesc, H_out)
    if plot_level >= 2
       K = size(Winit, 2);
       for i = 1:K
           M = H_out(i,:).*W_out(:,i);
           plot_if_plotLvl (plot_level, 2, ['contribution #', num2str(i)], (i == K), @imagesc, M)
       end
    end
    
    % call reconstruction_func and return the original sources
    sources_out = reconstruct_func (spect, W_out, H_out);
    
    % if plot is 3, graph and play the separated sources 
    if plot_level >= 3
        K = size(sources_out, 1);
        for i = 1:K
            source_vec = sources_out(i, :);
            n= [1: length(source_vec)];
            plot(n,source_vec)
            title('source time domain')
            sound(source_vec, Fs)
            wait_returnKey
        end
    end
end
