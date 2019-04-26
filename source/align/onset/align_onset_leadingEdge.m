function out = align_onset_leadingEdge (in, tol)
	% a leading edge is here defined as the first index in a contiguous series of non-zero indices
	% out will have a 1 at all leading edges and a 0 elsewhere
	% in is a column vector like
	
	% default args
	if nargin == 1
		tol = 1;
	end
	
	% circular buffer
	% invariant - will be all true if last tol samps were 0
	prev_zeros = true(tol, 1); 
	pz_index = 1;

	% preallocate return value
	out = zeros(size(in));
	
	% iterate through signal
	for i = 1:length(in)

		% mark leading edges
		if all(prev_zeros) && in (i) ~= 0
			out (i) = 1;
		end

		prev_zeros(pz_index) = (in(i) == 0);

		% advance circular buffer index
		pz_index = pz_index + 1;
		if pz_index > length(prev_zeros)
			pz_index = 1;
		end
	end
end

