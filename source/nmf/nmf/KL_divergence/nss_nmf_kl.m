function [W_out, H_out, final_error, iterations] = nss_nmf_kl (V, W, H, varargin)
%{    
non-negative matrix factorization algorithm - repeatedly updates "W" and "H"
using a pair of update rules until the KL divergence between "V"
and W * H is small enough (see args below), then returns them as "W_out", "H_out". note
that the update is multiplicative - elements of "W" and "H" which start at zero
will remain so.

The fourth arg, if supplied, is the stationary point detection threshold. 
    - if arg5 = 0.01 we need an improvement of 1% every 1000 iterations.
    - default 0.0001 ie 0.01% 

The fifth arg, if supplied, is a max number of iterations.
    - default 1'000'000

The sixth arg, if supplied, is a completion threshold - if the function gets 
within this threshold it will immediately return the values it has for W,H.
    - normally not useful because stationary point detection covers most things
    - default 0 - i.e. default is to only use convergence detection

Other args will be ignored (silently!)

return values:
    "W_out", "H_out" are the results of the NMF calculation.
    "final_error" gives the KL divergence between V and (W_out * H_out)
    "iterations"  gives the number of update steps

%}

    SUPPRESS_PRINT=1;

    % set defaults for varargs
    statPoint_thresh = 0.0001;
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
    assert (size(W, 2) == size(H, 1), "size mismatch in W and H")
    assert (size(V, 1) == size(W, 1), "W*H must have the same shape as V")
    assert (size(V, 2) == size(H, 2), "W*H must have the same shape as V")
    
    %%%% apply the update rules until we have a good enough
    %%%% approximation or we run out of iterations 

    % loop variables
    % could do "i" more neatly using "for" and "break" but it's a bit misleading
    i = 0;
    lastDistCheckpoint = KL_divergence(V, W*H);
    ld = lastDistCheckpoint;
    atStationaryPoint = 0;
    while i < max_iter && KL_divergence(V, W*H) > done_thresh
        
        %% apply update rules
        %% see lee and seung "algorithms for non negative matrix factorisation"

        % update H
        WH = W * H;
        for a = 1:size(H,1)
            for m = 1:size(H,2)
                Ham_factor = sum(W(:,a) .* V(:,m) ./ WH(:,m)) ...
                   ./ sum(W(:, a));
                H(a,m) = H(a,m) * Ham_factor;
            end
        end

        % recalculate WH, then update W
        WH = W * H;
        for j = 1:size(W,1)
            for a = 1:size(W,2)
                Wja_factor = sum(H(a,:) .* V(j,:) ./ WH(j,:)) ...
                   ./ sum(H(a,:));
                W(j,a) = W(j,a) * Wja_factor;
            end
        end

        if KL_divergence (V, W*H) > ld
            assert (0==1, "bad update rule")
        end
        ld = KL_divergence(V, W*H);

        %% every 1000 iterations, check if we're at a stationary point
        if mod(i, 1000) == 0 
            if ~SUPPRESS_PRINT; disp('.'); end;
            
            % remember our distance now and compare to last time
            currDistCheckpoint = KL_divergence(V, W*H);
            delta = currDistCheckpoint-lastDistCheckpoint;
            if delta < currDistCheckpoint * statPoint_thresh
                % if we got less than required improvement in the last 1000 iterations,
                % we're at a local minimum. break loop.
                atStationaryPoint = 1;
                if ~SUPPRESS_PRINT; fprintf('stationary at %d\n', currDistCheckpoint); end;
                break
            end

            % set lastDistCheckpoint ready for the next comparison
            lastDistCheckpoint = currDistCheckpoint;
        end

        %increment iterator and end while
        i = i + 1;
    end
    if ~SUPPRESS_PRINT; disp ('..'); end;
    
    %%%% figure out if we converged sucessfully and set return values

    % set final_error return value
    final_error = KL_divergence (V, W*H);

    % check whether we ran out of iterations 
    % !!! should this be a warning not an error, allowing recovery of W, H?
    if final_error > done_thresh && atStationaryPoint == 0
        ME = MException (                                       ...
            "nss_nmf_is:failed_to_converge",                 ...
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
