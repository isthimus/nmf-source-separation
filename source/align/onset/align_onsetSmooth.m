function out = align_onsetSmooth (in, ksize, use_root)
	if nargin < 2
		ksize = 5; 
	end
	if nargin < 3
		use_root = true; % true for root, false for geometric.
	end

	if use_root
		h = sqrt(1:-1/ksize:1/ksize);
	else
		h = (0.7).^(0:ksize-1);
    end
    
	out = conv(in, h);
	out = out(1:length(in));
end