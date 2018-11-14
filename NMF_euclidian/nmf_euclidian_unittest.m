% unit test for euclidian NMF
% TODO make this into a function that just returns 1 or 0 or smth so that i acn
% write a script later that traverses the folder heirachy, runs
% *_unittest.m, and tells me if my damn codebase is broken or not

% today in "lessons learned the hard way on placement" 



A = [1 2 3 4; 1 2 3 4];
B = [1 2 3 5; 1 2 3 5];

square_euclidian_distance( 1, 1 )
[A, B]  = nmf_euclidian ( [1 2 3 4; 1 3 3 4; 1 4 3 4; 1 5 3 4], [1 1 1 1; 1 1 1 1; 1 1 1 1; 1 1 1 1], [0.1 0.2 0.4 0.1; 0.1 0.2 0.4 0.1; 0.1 0.1 0.1 0.1; 0.1 0.2 0.1 0.1], 0.000001)
disp (A*B)