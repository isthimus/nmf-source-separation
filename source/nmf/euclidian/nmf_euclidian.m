function [W_out, H_out, final_error, iterations] = nmf_euclidian (V, W, H, varargin)
%{    
non-negative matrix factorization algorithm - repeatedly updates "W" and "H"
using a pair of update rules until the square euclidian distance between "V"
and W * H is below "threshold", then returns them as "W_out", "H_out". note
that the update is multiplicative - elements of "W" and "H" which start at zero
will remain so.

The fourth arg, if supplied, is the stationary point detection threshold. 
    - if arg5 = 0.01 we need an improvement of 1% every 1000 iterations.
    - default 0.00001 ie 0.001% 

The fifth arg, if supplied, is a max number of iterations.
    - default 1'000'000

The sixth arg, if supplied, is a completion threshold - if the function gets 
within this threshold it will immediately return the values it has for W,H.
    - normally not useful because stationary point detection covers most things
    - default 0 - i.e. default is to only use convergence detection

Other args will be ignored (silently!)

return values:
    "W_out", "H_out" are the results of the NMF calculation.
    "final_error" gives the square euclidian distance between V and (W_out * H_out)
    "iterations"  gives the number of update steps

%}
    % set defaults for varargs
    statPoint_thresh = 0.00001;
    max_iter = 1000000;
    done_thresh = 0;
    
    % set statPoint_thresh using varargin if prsent 
    if nargin >= 4
        statPoint_thresh = varargin{1};
    end

    % set max_iter using varargin if present
    if nargin >= 5
        max_iter = varargin{2};
    end

    % set done_thresh using varargin if present
    if nargin >= 6
        done_thresh = varargin{3};
    end

    %%%% check preconditions
    % emptiness
    assert (~isempty(V), "V is empty")
    assert (~isempty(W), "W is empty")
    assert (~isempty(H), "H is empty")
    
    % done_thresh
    assert (done_thresh >= 0, "done_thresh must be non-negative")

    % positive semidefiniteness
    assert (isempty(V(V<0)), "V contains negative elements")
    assert (isempty(W(W<0)), "W contains negative elements")
    assert (isempty(H(H<0)), "H contains negative elements")    
    % matrix shape
    assert (size(V, 1) == size(W, 1), "W*H must have the same shape as V")
    assert (size(V, 2) == size(H, 2), "W*H must have the same shape as V")
    
    %%%% apply the update rules until we have a good enough
    %%%% approximation or we run out of iterations 


    % loop variables
    % could do "i" more neatly using for and break but its a bit misleading
    i = 0;
    lastDistCheckpoint = square_euclidian_distance(V, W*H);
    stationaryPoint = 0; % flag showing if we've hit a stationary point


    while square_euclidian_distance (V, W*H) > done_thresh && i < max_iter
        % update rules. see lee and seung: "algorithms for non-negative matrix factorisation"
        H = H.*((W.' * V)./(W.' * W * H + eps));
        W = W.*((V * H.')./(W * H * H.' + eps));
        i = i + 1;

        % every 1000 iterations, check if we're at a stationary point
        if mod(i, 1000) == 0 
            disp('.');
            
            % remember our distance now and compare to last time
            currDistCheckpoint = square_euclidian_distance (V, W*H);
            delta = currDistCheckpoint-lastDistCheckpoint;
            if (delta * 100000) < currDistCheckpoint
                % if we got less than 0.001% improvement in the last 1000 iterations, we're at a local minimum. break loop.
                stationaryPoint = 1;
                fprintf("stationary at %d\n", currDistCheckpoint);
                break
            end

            % set lastDistCheckpoint ready for the next comparison
            lastDistCheckpoint = currDistCheckpoint;
        end
    end
    disp ('..');
    
    %%%% figure out if we converged sucessfully and set return values

    % set final_error return value
    final_error = square_euclidian_distance (V, W*H);

    % check whether we ran out of iterations 
    % !!! should this be a warning not an error, allowing recovery of W, H?
    if square_euclidian_distance (V, W*H) > done_thresh && stationaryPoint == 0
        ME = MException (                                       ...
            "nmf_euclidian:failed_to_converge",                 ...
            "hit max iterations and still not within done_thresh" ...
        );
        throw(ME)
    end
    
    % return values
    W_out = W;
    H_out = H;
    iterations = i;
    % final_error already assigned
    
end    
