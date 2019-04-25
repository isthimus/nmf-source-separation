function out = align_onset_leadingEdge (in)
	% a leading edge is here defined as the first index in a contiguous series of non-zero indices
	% out will have a 1 at all leading edges and a 0 elsewhere
	
	out = zeros(size(in));
	last_wasZero = true;
	for i = 1:length(in)
		if last_wasZero && in(i) ~= 0
			out(i) = 1;

		last_wasZero = in(i) == 0;
	end
end