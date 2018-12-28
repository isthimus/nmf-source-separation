function out = floor_to_multiple(num, floorTo)
    % out will be the larget (furthest from -Inf) integer multiple of 
    % floorTo less than num. works for positive and negative num. floorTo 
    % must be positive.
    
    assert (floorTo > 0, "floorTo must be positive")
    out = num - mod(num, floorTo);
end