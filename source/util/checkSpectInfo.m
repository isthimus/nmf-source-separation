function valid_flag = checkSpectInfo(spectInfo, prespect, print_ans)
    % checks a spectInfo for validity
    % prespect is a flag to say whether we're checking before the spect call or after
    % print_ans is a flag saying whether to print the results
    % both defaut to false

    % current spec for a valid spectInfo
    % this is in a comment because its likely to change as everything gets smoothed out
    % pre spect call:
    %   audio_len_samp
    %   wlen
    %   nfft
    %   hop
    %   fs
    %
    % post spect call:
    %   num_freq_bins
    %   num_time_bins

    % default args
    if nargin <= 2
        print_ans = false;
    end
    if nargin <= 1
        prespect = false;
    end

    % get required fields in a list
    prespect_fields = ["audio_len_samp", "wlen", "nfft", "hop", "fs"];
    postspect_fields = ["num_time_bins", "num_freq_bins"];

    % check prespect fields
    valid_flag = true;
    missing_fields = [];
    for i = 1:length(prespect_fields)
        thisField = prespect_fields(i);
        if ~isfield(spectInfo, thisField)
            valid_flag = false;
            missing_fields = [missing_fields, thisField];
        end
    end

    % check postspect fields, if the flag says to
    if ~prespect
        for i = 1:length(postspect_fields)
            thisField = postspect_fields(i);
            if ~isfield(spectInfo, thisField)
                valid_flag = false;
                missing_fields = [missing_fields, thisField];
            end
        end
    end

    % print, if the flag says to
    if print_ans
        if valid_flag
            disp('no missing fields');
        else
            disp('*****missing fields:*****');
            for i = 1:length(missing_fields); disp (missing_fields(i)); end;
            disp('*************************');
        end
    end

    % implicit return of valid_flag
end