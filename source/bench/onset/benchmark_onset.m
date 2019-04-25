function [false_pos_percent, num_false_neg, num_total_onsets] = benchmark_onset(notes, onset, fs, tol_sec)
	% measures false positive percentage and number of missed offsets for a given onset measure and midi file
	% bit primitive but itll do the job
	% might need a slightly different approach for leading-edge shenanigans

	% !!! MORNING MATT. a good way to test this is to visualise groundTruth and
	%     make sure the onset times arent running into each other
	% 	  also think about whether tol_sec should be either side, or asymmetric
	%     also also grep offset.... 

	if nargin < 4
		tol_sec = 0.05 % either side! 
	end	

	% get a vector of note onset times, convert to samples
	noteOnsets = notes(:, 5);
	noteOnsets = floor(noteOnsets * fs
	assert(max(noteOnsets) < length(onset), "last midi event is after end of onset argument!")

	% convert tolerance to samps
	tol_samp = floor(tol_sec * fs);

	% preallocate ground truth vector
	% true =  samp is in an "onset period"
	% false = silence or a held note
	groundTruth = false(length(onset), 1);

	% iterate through onsetTimes
	for i = 1:onsetTimes
		% figure out the samples this onset relates to
		thisOnset = onsetTimes(i);
		onsetPeriod = max(thisOnset-tol_samp, 1) : min(thisOnset-tol_samp, length(groundTruth));

		% write into groundTruth
		groundTruth(onsetPeriod) = true;
	end


	% measure false pos percentage
	good = 0; bad = 0;
	for i = 1:length(onset)
		% only look at samples where theres no onset
		if ~groundTruth(i)
			if onset(i) == 0; good = good + 1;
			else; bad = bad + 1; end
		end
	false_pos_percent = (bad/(bad+good)) * 100;


	% count missed onsets
	num_false_neg = 0;
	for i = 1:length(onsetTimes)
		thisOnset = onsetTimes(i);
		onsetPeriod = max(thisOnset-tol_samp, 1) : min(thisOnset-tol_samp, length(groundTruth));

		if all(onset(onsetPeriod) == 0); num_false_neg = num_false_neg+1; end;


	% num_total onsets is just length(onsetTimes)
	num_total_onsets = length(onsetTimes)
	% also implicit return of num_false_neg and false_pos_percent
end