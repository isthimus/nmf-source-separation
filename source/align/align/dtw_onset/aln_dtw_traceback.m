function [dist, ix, iy] = dtw_traceback (C)
    % traces back the cost matrix of a dtw operation to find the best warping path
    % based on the source code of the MATLAB native dtw function

    % infer the lengths of the original two vectors to be warped 
    ylen = size(C,1);
    xlen = size(C,2);
    
    % preallocate D
    % D is the cost of the cheapest path from C(1,1) to C(i,j)
    % make it overlarge and initialise with Inf to simplify the logic
    D = zeros(ylen+1, xlen+1);
    D(:,1) = Inf;
    D(1,:) = Inf;
    D(1,1) = 0;

    % build D
    for i = 1:xlen
        for j = 1:ylen
            % account for the extra Inf rows
            i_out = i+1;
            j_out = j+1;

            cj  = D(j_out-1,i_out);
            ci  = D(j_out,i_out-1);
            cij = D(j_out-1,i_out-1);

            D(j_out, i_out) = C(j,i) + min([ci, cj, cij]);
        end
    end

    % discard the Inf rows
    D = D(2:end, 2:end);

    % get return vals
    dist = D(end,end);
    [iy, ix] = traceback(D);
end

function [ix,iy] = traceback(C)
  % this function taken directly from matlab dtw() library function
  m = size(C,1);
  n = size(C,2);

  % pre-allocate to the maximum warping path size.
  ix = zeros(m+n,1);
  iy = zeros(m+n,1);

  ix(1) = m;
  iy(1) = n;

  i = m;
  j = n;
  k = 1;

  while i>1 || j>1
    if j == 1
      i = i-1;
    elseif i == 1
      j = j-1;
    else
      % trace back to the origin, ignoring any NaN value
      % prefer i in a tie between i and j
      cij = C(i-1,j-1);
      ci = C(i-1,j);
      cj = C(i,j-1);
      i = i - (ci<=cj | cij<=cj | cj~=cj);
      j = j - (cj<ci | cij<=ci | ci~=ci);
    end
    k = k+1;
    ix(k) = i;
    iy(k) = j;
  end

  ix = ix(k:-1:1);
  iy = iy(k:-1:1);

end