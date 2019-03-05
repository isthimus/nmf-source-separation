function chromaVal = align_nn2Chroma (nn)
	freakout % make sure that the chromagram function does the same thing, ie C is 1st chroma bin. 
			 % if chroma starts from A, need to offset the whole thing before modulo.

	chromaVal = mod (nn, 12);


end