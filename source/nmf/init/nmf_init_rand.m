function [W_out, H_out] = nmf_init_rand (num_freq_bins, num_time_bins, k, avg)
    % given the shape of V and a value for K (ie number of basis vectors),
    % build a random pair of matrices to act as the initial W and H
    
    % make sure the "avg" argument is right
    if size(avg) == [1,1]
        avg = [avg, avg];
    elseif ~isequal(size(avg),[1,2])
        ME = MException ("nmf_init_rand:bad_input", "avg should be a scalar or a 2 element vector");
        throw(ME)
    end
    
    if any(avg(:) <= 0)
        ME = MException ("nmf_init_rand:bad_input", "avg should be all positive");
        throw(ME)
    end
    
   % build random matrices od the required size and avg
    W_out = (rand(num_freq_bins, k)+ 0.5) * avg(1);
    H_out = (rand(k, num_time_bins) + 0.5) * avg(2);
end
