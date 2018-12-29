function out = matfuzz_additive (mat, fuzz_depth, fuzz_prevalence, nonNegative)
    % fuzzes a matrix additively
    % "fuzz depth" = max value added or subtracted, as a proportion of matrix average
    % "fuzz prevalence" = number of elements fuzzed, as a proportion of total # of elems
    % if "nonNegative" is truthy elements made negative will be set to zero


    % figure out how much to fuzz
    max_fuzz = fuzz_depth * mean(mat(:));
    
    % figure out what elements to fuzz
    n_mat = numel (mat);
    numElemsFuzzed = floor(fuzz_prevalence * n_mat);
    elemsToFuzz = randperm(n_mat) <= numElemsFuzzed;

    % fuzz
    mat(elemsToFuzz) = arrayfun( @(x) x + max_fuzz*2*(rand-0.5), mat(elemsToFuzz));

    if nonNegative
        mat(mat < 0) = 0;
    end
    out = mat;
end
