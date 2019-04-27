function out = mat_normalise(in, max_val)
	% normalises to +- max_val
	% use mat_normalise(mat, max/2) + max/2 to constrain to positive

	max_val_in = max(abs(in(:)));
	scale_factor = max_val ./ max_val_in;

	out = in .* scale_factor;

	% make doubly sure in case of floating point error
	out(out>max_val) = max_val;
end