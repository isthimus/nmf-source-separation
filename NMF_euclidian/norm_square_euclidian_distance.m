function out = norm_square_euclidian_distance (A, B)

    % !!! talk about potentail asymmetry and how avoided
    % !!! talk about loss of precision from norm, and potential other
    % normFactors?
    if any(size(A) ~= size(B))
        ME = MException ("norm_square_euclidian_distance:bad_input", "A and B must have the same shape");
        throw (ME)
    end
    
    if sum(isnan(A(:))) > 0
       ME = MException ("norm_square_euclidian_distance:bad_input", "A contains NaN!");
       throw (ME) 
    end
    
    if sum(isnan(B(:))) > 0
       ME = MException ("norm_square_euclidian_distance:bad_input", "B contains NaN!");
       throw (ME) 
    end
      
    normFactor = (sum(A(:)) + sum(B(:))) / 2;
    normA = A./normFactor; normB = B./normFactor;
    
    diffs = normA - normB;
    diff_squared = diffs.*diffs;
    out = sum(diff_squared(:));
    
end