function hops = find_window_hop (win1, varargin)
    % wrapper for find_window_hop_multi
    % args - win1, [win2, allow_scaling, threshold]
    
    %defaults
    win2 = win1;
    allow_scaling= 1;
    tolerance = 10e-3;
    
    % get args from varargin if needed
    if nargin >= 2
        win2 = varargin{1}; 
    end
    
    if nargin >= 3
        allow_scaling = varargin{2};
    end
    
    if nargin >=  4
        tolerance = varargin{3};
    end

    % find hop sizes and return
    hops = find_window_hop_multi( win1, win2, allow_scaling, tolerance);
end