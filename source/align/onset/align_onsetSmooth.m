function out = align_onsetSmooth (in, ksize)
	if nargin = 1; ksize = 5; end;

	h = sqrt(1:-1/ksize:0);
	out = conv(in, h);
	out = out(1:length(in));
end