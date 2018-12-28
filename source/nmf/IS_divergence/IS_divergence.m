function out = IS_divergence (A,B)
    % finds the Itakura-Seito divergence between matrices A and B
    % see Fevotte et al, 
    %"Nonnegative Matrix Factorisation with the Itakura-Seito Divergence"

    % check preconditions
    assert( isequal(size(A), size(B)), "A and B must have the same shape")
    assert( sum(isnan(A(:))) == 0, "A contains NaN!")
    assert( sum(isnan(B(:))) == 0, "B contains NaN!")

    % find the IS_divergence
    divergences = A./B - log(A./B) - 1;
    out = sum(divergences(:));