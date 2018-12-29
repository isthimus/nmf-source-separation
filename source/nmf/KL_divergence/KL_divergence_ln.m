function out = KL_divergence (A,B)
    % finds the KL divergence between matrices A and B
    % see lee and seung, "algorithms for non-negative matrix factorisation"

    % check preconditions
    assert( isequal(size(A), size(B)), "A and B must have the same shape")
    assert( sum(isnan(A(:))) == 0, "A contains NaN!")
    assert( sum(isnan(B(:))) == 0, "B contains NaN!")

    % find individual divergences and sum, then return as "out"
    divs = A.*log(A./B) - A + B;
    out = sum(divs(:));
end