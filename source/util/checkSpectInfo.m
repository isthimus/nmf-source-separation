function valid_flag = checkSpectInfo(spectInfo, prespect, print_ans)
    % checks a spectInfo for validity
    % prespect is a flag to say whether we're checking before the spect call or after
    % print_ans is a flag saying whether to print the results
    % both defaut to false

    % default args
    if nargin <= 1
        prespect = false;
    end
    if nargin <= 2
        print_ans = false;
    end

    % get required fields in a list
    % other allowable prespect_fields: max_freq_bins
    prespect_fields = ["wlen", "nfft", "hop", "fs", "analwin", "synthwin"];
    postspect_fields = ["num_time_bins", "num_freq_bins", "audio_len_samp"];

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