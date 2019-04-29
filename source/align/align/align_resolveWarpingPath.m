function out = aln_resolveWarpingPath (IX, IY)
	to_keep = logical(ones(size(IX)));

	trail = IY(1);
	for i = 2:size(IY, 1)
		if (IY(i) == trail)
			to_keep(i) = 0;
		end
		trail = IY(i);
	end

	out = IX(to_keep);
end