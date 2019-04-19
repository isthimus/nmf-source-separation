% Turn on recording of the command window output
diary('tmp_matlab_diary.txt');
disp('Hello, World!');
fileToRun = getenv('MKC_MATLAB_FILETORUN');
run(fileToRun);
% Turn recording back off
diary off;
exit;