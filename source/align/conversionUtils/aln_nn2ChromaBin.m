function chromaVal = aln_nn2ChromaBin(nn)
	chromaVal = mod(nn + 3, 12) + 1;
end