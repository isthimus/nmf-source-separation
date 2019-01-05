function out = square_euclidian_distance (A, B)

    % check preconditions
    assert(isequal(size(A), size(B)), "A and B must have the same shape")
    assert(sum(isnan(A(:))) == 0, "A contains NaN!")
    assert(sum(isnan(B(:))) == 0, "B contains NaN!")
      
    % find euclidian distance - take element-wise distances, square them, and sum. 
    diffs = A - B;
    diff_squared = diffs.*diffs;
    out = sum(diff_squared(:));
    
end