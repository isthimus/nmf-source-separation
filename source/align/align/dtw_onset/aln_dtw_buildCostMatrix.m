function C = dtw_buildCostMatrix(X,Y, dist_func)
    % builds a cost matrix which the dtw_traceback function can use to find 
    % a warping path between X and Y

    % C(i, j) is the direct cost between X(:,i) and Y(:,j) according to dist_func

    % only works with row vectors - if given columns then transpose them
    if iscolumn(X); X = X'; end
    if iscolumn(Y); Y = Y'; end

    %default args
    if nargin < 3
        % if no dist_func is given use the euclidian distance
        dist_func = @(a,b) norm(a-b);
    end

    % get x and y len, preallocate C
    xlen = size(X, 2);
    ylen = size(Y, 2);
    C = zeros(ylen, xlen);

    % build C
    for i = 1:xlen
        for j = 1:ylen
            C(j,i) = dist_func(X(:,i), Y(:,j));
        end
    end
end