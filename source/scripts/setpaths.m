% add everything to the matlab path so we can call all the functions we
% need
% for now this only adds from source folder and all subfolders, ie
% benchmarks is not included.
% might move benchmarks or expand this up later.

SOURCE_ROOT = fullfile('../');
addpath(genpath(SOURCE_ROOT));
