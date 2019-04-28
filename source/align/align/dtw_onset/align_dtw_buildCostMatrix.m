function C_out = dtw_buildCostMatrix(X,Y, dist_func)
    % builds a cost matrix which the dtw_traceback function can use to find 
    % a warping path between X and Y

    % C_direct(i, j) is the direct cost between X(:,i) and Y(:,j) according to dist_func
    % C_out(i,j) is the cost of the cheapest path from C_direct(1,1) to C_direct(i,j)

    % only works with row vectors - if given columns then transpose them
    if iscolumn(X); X = X'; end
    if iscolumn(Y); Y = Y'; end

    %default args
    if nargin < 3
        % if no dist_func is given use the euclidian distance
        dist_func = @(a,b) sqrt(sum((a-b).^2));
    end

    % get x and y len, preallocate C_direct
    xlen = size(X, 2);
    ylen = size(Y, 2);
    C_direct = zeros(ylen, xlen);

    % build C_direct
    for i = 1:xlen
        for j = 1:ylen
            C_direct(j,i) = dist_func(X(:,i), Y(:,j));
        end
    end

    imagesc(C_direct);
    axis xy;
    wait_returnKey();
    close all;

    % preallocate C_out
    % make it overlarge and initialise with Inf to simplify the logic
    C_out = zeros(ylen+1, xlen+1);
    C_out(:,1) = Inf;
    C_out(1,:) = Inf;
    C_out(1,1) = 0;

    % build C_out
    for i = 1:xlen
        for j = 1:ylen
            % account for the extra Inf rows
            i_out = i+1;
            j_out = j+1;

            cj  = C_out(j_out-1,i_out);
            ci  = C_out(j_out,i_out-1);
            cij = C_out(j_out-1,i_out-1);

            C_out(j_out, i_out) = C_direct(j,i) + min([ci, cj, cij]);
        end
    end

    % discard the Inf rows and return
    C_out = C_out(2:end, 2:end);
end