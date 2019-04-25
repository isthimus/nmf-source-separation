function out = align_peakPick_median (sig, n_median, min_delta, add_tail)
	% peak-picks from a column vector using an adaptive median-based threshold, 
	% and a proportional min_delta. if add_tail is false, detected peaks will be a
	% single-sample impulse. if true this impulse train will be convolved with
	% h = [sqrt(1), sqrt(0.9),  ... sqrt(0.1)]
	% see Ewert and Muller, 
	% "HIGH RESOLUTION AUDIO SYNCHRONIZATION USING CHROMA ONSET FEATURES"
	% for details

	%if given a matrix, treats each column independently

	% default args
	if nargin <= 1
		n_median = 4001;
	end
	if nargin <= 2
		min_delta = 5
	end
	if nargin <= 3
		add_tail = true;
	end
	p_off = 2; % num samples either side to check for peak, 
			  % after median and min_delta 
	h_len = 20;

	% precondition checks
	assert(all(sig >= 0), "negative values not supported! (but might be asy to incorporate - read code)");
	assert(n_median >= 1, "median size must be >= 1")
	assert(mod(n_median, 2) == 1, "median size must be odd")

	% find and subtract mean of signal(s), normalise to 1
	sig = sig - mean(sig)
	sig = sig ./ max(sig)

	% find rolling median
	sig_median = zeros(size(sig));
	m_off = floor(n_median/2); % num indexes either side used in median 
	for i = m_off+1 : size(sig,1)-m_off
		sig_median(i, :) = median(sig(i-m_off:i+m_off,:))
	end

	% fill in the edges by copying the first and last valid medians
	sig_median(1:m_off, :) = sig_median(m_off+1, :)
	sig_median(size(sig,1)+1-m_off:end, :) = sig_median(size(sig,1)-m_off, :);

	% divide every point of the signal by the rolling median to find the deltas
	% clamp from below with min_delta
	deltas = sig ./ sig_median;
	deltas(deltas < min_delta) = 0;

	% extract peaks
	for i = 1+p_off:size(deltas,1)-p_off
		if ~all(deltas(i-p_off:i+p_off, :) <= deltas(i))
			deltas(i) = 0;
		end
	end

	if add_tail
		% convolve with h = [sqrt(1), sqrt(0.9),  ... sqrt(0.1)]
		h = sqrt(1:-1/h_len:0);
		for i = 1:size(deltas, 2)
			c = conv(deltas(:, i), h)
			deltas(:, i) = c(1:size(deltas, 1));
		end	
	end

	% return
	out = deltas;
end