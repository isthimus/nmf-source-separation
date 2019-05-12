function sources_out = nss_reconstruct_noPhase (spect, W, H, spectInfo)
% NSS_RECONSTRUCT_KEEPPHASE - recover the sources after blind NMF, without attempting phase reconstruction.
%
%   arguments:
%       spect - the original mixture spectrogram
%       W - the template matrix W after NMF convergence
%       H - the activation matrix H after NMF convergence
%
%       spectInfo - a struct containing the following parameters
%           synthwin - synthesis window   
%           analwin - analysis window
%           hop - hop size
%           nfft - fft length
%           fs - sampling frequency
%           num_freq_bins - number of frequency bins in the spectrogram
%           audio_len_samp - lenght of the original audio
%
%   return values:
%       sources_out - a matrix whose rows are the separated out time-domain sources. 
%
%   description:
%       this function takes as input the W and H matrices produced by NMF convergence and uses them
%       to build a set of "contribution spectra" corresponding to the contribution of each template 
%       vector/activtion vector pair to the overall spectrum.
%       Then the istft of each spectrum is taken and the resultant time domain sources returned in sources_out. 
%       NB a "source" here is an instrument-note pair, NOT a single instrument! 

    
    sources_out = [];
    
    K = size(W, 2);
    for iter = 1:K
        % get the contribution for basis vector i of W
        source_i_mag = H(iter,:).*W(:,iter);

        % would expect phase generation here.
        source_i_fullspect = source_i_mag;
        
        source_i_timedomain = nss_istft(source_i_fullspect, spectInfo);
        assert(size(source_i_timedomain,1) == 1, 'internal assertion failure - size of source_i_timedomain is not (1, X)!')
        
        if isempty(sources_out)
           sources_out = source_i_timedomain;
        else
           % !!! preallocate
           sources_out = [sources_out; source_i_timedomain]; %#ok<*AGROW>
        end
     
    end
end