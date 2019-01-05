function out = norm_square_euclidian_distance (A, B)

    % !!! talk about potentail asymmetry and how avoided (ie could have just normed one)
    % !!! benchmark loss of precision from norm

    % check preconditions
    assert( isequal(size(A), size(B)), "A and B must have the same shape")
    assert( sum(isnan(A(:))) == 0, "A contains NaN!")
    assert( sum(isnan(B(:))) == 0, "B contains NaN!")
      
    % normalise such that sum of the two matrices = 2
    normFactor = (sum(A(:)) + sum(B(:))) / 2;
    normA = A./normFactor; normB = B./normFactor;
    
    % find euclidian distance - take element-wise distances, square them, and sum. 
    diffs = normA - normB;
    diff_squared = diffs.*diffs;
    out = sum(diff_squared(:));
    
end