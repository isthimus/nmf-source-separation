function [W_out, H_out, iterations] = nmf_euclidian (V, W, H, threshold, varargin) %#ok<STOUT>
%{    
non-negative matrix factorization algorithm - repeatedly updates W and H
using a pair of update rules until the square euclidian distance between V
and W * H is below "threshold", then returns them as W_out, H_out. note
that the update is multiplicative - elements of W and H which start at zero
will remain so.

The fifth arg, if supplied, is a max number of iterations. default 1000.
Other args will be ignored (silently!)
%}
    % set max_iter using varargin if present
    max_iter = 1000;
    if nargin > 4
        max_iter = varargin(1);
    end

    % check W, V, H nonempty
    if isempty(W) || isempty(V) || isempty(H)
        ME = MException ("nmf_euclidian:bad_input", "one or more of V, W, H is empty");
        throw(ME)
    end
    
    % check threshold is sensible
    if threshold < 0
        ME = MException ("nmf_euclidian:bad_input", "threshold must be non negative");
        throw (ME)
    end
    
    % check for negative values in input
    if ~isempty(V(V < 0)) || ~isempty(W(W < 0)) || ~isempty(H(H < 0))
        ME = MException ("nmf_euclidian:bad_input", "W,V,H must have all elements >= 0");
        throw(ME)
    end
    
    % check matrix dimensions
    if size(V)(1) ~= size(W)(1) || size(V)(2) ~= size(H)(2)
        ME = MException ("nmf_euclidian:bad_input", "W * H must have the same shape as V");
        throw (ME)
    end
    
    % repeatedly apply the update rules  until we have a good enough
    % approximation or we run out of iterstions 
    iterations = 0;
    while square_euclidian_distance (V, W*H) > threshold && iterations < max_iter
        H = H.*((W.' * V)./(W.' * W * H));
        W = W.*((V * H.')./(W * H * H.'));
        iterations += 1;
    end
    
    % check whether the attempt was sucessful, or whether we ran out of iterations 
    % in the fullness of time we may need to return W and H somehow
    if square_euclidian_distance (V, W*H) > threshold
        ME = MException ("nmf_euclidian:failed_to_converge", "hit max iterations and still not within threshold");
        throw(ME)
    end
    
    W_out = W;
    H_out = H;
    
end    
