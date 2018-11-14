function out = square_euclidian_distance (A, B)
    if any(size(A) ~= size(B))
        ME = MException ("square_euclidian_distance:bad_input", "A and B must have the same shape");
        throw (ME)
    end
        
    diffs = A - B;
    diff_squared = diffs.*diffs;
    out = sum(diff_squared(:));
    
end