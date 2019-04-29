function [W_mask_out, H_mask_out] = aln_tol_lin (W_mask, W_tol, H_mask, H_tol)
	% adds frequency-linear tolerance to the output of a makeMasks function 
	% can also add time-linear tolerance to H - but second two arguments are optional
	% !!! this could be muuuuch smarter. eg log tolerance, kernel not all ones, 
	% smart tolerance based on actual freq not quantised freq bin, etc etc etc

	% preconditions
	assert (W_tol >=  0, "cannot have a negative tolerance value");

	% decide whether to do the H matrix
	if nargin >= 4
		do_H = true;

		% extra preconditions for H
		assert(H_tol >= 0, "cannot have a negative tolerance value");
	else
		do_H = false;
	end

	% tolerance for W
	W_kernelSize = 1 + 2 * floor(W_tol);
	W_kernel = ones (W_kernelSize, 1);
	W_out = imdilate(W_mask, W_kernel);

	% tolerance for H, if doing H
	if do_H
		H_kernelSize = 1 + 2 * floor(H_tol);
		H_kernel = ones (1, H_kernelSize);
		H_out = imdilate(H_mask, H_kernel);
	end

end