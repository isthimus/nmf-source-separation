function hops = find_window_hop_multi(winA, winS, allow_scaling, tolerance)
    % finds the hop sizes at which winA (analysis window) and winS
    % (synth window) produce perfect reconstruction. if there are no
    % such hop sizes, returns []
    % if allow_scaling == true then a hop size which scales the signal but
    % otherwise allows PR will be included in the return value
    % first optional arg gives a tolerance value
    
    % get the effective wondow after an STFT/ISTFT pair
    p = winA .* winS;

    % all the hop lengths to try
    possible_hops = [1:length(p)];
    
    valid_hops = [];
    
    % iterate over all potential hops
    for i = 1:length(possible_hops)

        % get the window as if it were overlap-added at hop size
        % possible_hops(i)
        win_overlapped = hop_add_win(p, possible_hops(i));             
        
        % check if this window is always one
        % (or always constnt if we allow scaling)
        if all(abs(win_overlapped - 1) < tolerance) ...
        || (allow_scaling && all(abs(win_overlapped - win_overlapped(1)) < tolerance))    
            % add to valid hops if so
            valid_hops = [valid_hops; possible_hops(i)];
        end
        
        % return the valid_hops list we wrote
        hops = valid_hops;      
    end
end

