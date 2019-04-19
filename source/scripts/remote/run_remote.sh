MKC_MATLAB_FILETORUN=$1
echo ${MKC_MATLAB_FILETORUN}
matlab -r ${MKC_MATLAB_FILETORUN}\;exit\; -nosplash -nodesktop -wait -log
