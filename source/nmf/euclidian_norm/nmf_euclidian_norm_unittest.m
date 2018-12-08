% unit test for euclidian NMF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% empty V

ME = [];
try
    nmf_euclidian_norm([],[1],[1],1000)
catch ME
end

if isempty(ME) || ME.identifier ~= "nmf_euclidian_norm:bad_input"
    
    throw (MException ("unittest:nmf_euclidian_norm", "Doesn't handle empty V:"))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% empty W, H

ME = [];
try
    nmf_euclidian_norm([1],[],[],1000)
catch ME
end

if isempty(ME) || ME.identifier ~= "nmf_euclidian_norm:bad_input"
    throw (MException ("unittest:nmf_euclidian_norm", "Doesn't handle empty W, H"))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% negtive threshold

ME = [];
try
    nmf_euclidian_norm([1],[1],[1],-1000)
catch ME
end

if isempty(ME) || ME.identifier ~= "nmf_euclidian_norm:bad_input"
    throw (MException("unittest:nmf_euclidian_norm", "Doesnt handle negative threshold"))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bad matrix shapes in distance function 

ME = [];
try
    norm_square_euclidian_distance([1,2,3],[1;2])
catch ME
end

if isempty(ME) || ME.identifier ~= "norm_square_euclidian_distance:bad_input"
    throw (MException("unittest:nmf_euclidian_norm", "Doesnt handle badly shaped matrices to norm_square_euclidian_distance"))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% declare some helper matrices
six_horiz_A = [1,2,3;4,5,6];
six_horiz_B = [1,3,5;2,4,6];

V = magic(20);

ones20 = ones(20);
rng(6312206);
rand20_A = rand(20,20)*50;
rand20_B = rand(20,20)*50;
rand20_A_cpy = rand20_A;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check norm_square_euclidian_distance gives sensible values

if norm_square_euclidian_distance(six_horiz_A, six_horiz_B) ~= 0.0227
    throw (MException("unittest:nmf_euclidian_norm", "norm_square_euclidian_distance gives wrong answers"))
end

if norm_square_euclidian_distance(six_horiz_B, six_horiz_A) ~= 0.0227
    throw (MException("unittest:nmf_euclidian_norm", "norm_square_euclidian_distance not commutative"))
end

if norm_square_euclidian_distance(rand20_A, rand20_B) ~= norm_square_euclidian_distance(rand20_B, rand20_A)
    throw (MException("unittest:nmf_euclidian_norm", "norm_square_euclidian_distance not commutative"))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check NMF results 

[W,H,~] = nmf_euclidian_norm(V, rand20_A, ones20, 0.001, 99999);
if (rand20_A ~= rand20_A_cpy)
    throw (MException("unittest:nmf_euclidian_norm", "NMF mutates W,H"))
end

if norm_square_euclidian_distance(W*H, V) > 0.01
    throw (MException("unittest:nmf_euclidian_norm", "NMF gives invalid answers"))
end

[W,H,~] = nmf_euclidian_norm(V, rand20_A, rand20_B, 0.001, 99999);
if norm_square_euclidian_distance(W*H, V) > 0.01
    throw (MException("unittest:nmf_euclidian_norm", "NMF gives invalid answers"))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure it doesnt hang when given an impossible problem
ME = [];
try
    [W,H,~] = nmf_euclidian_norm(V, rand20_A, zeros(20), 0.001, 9999);
catch ME
end

if isempty(ME) || ME.identifier ~= "nmf_euclidian_norm:failed_to_converge"
    disp (ME.identifier)
    throw (MException("unittest:nmf_euclidian_norm", "Doesn't handle 'out of iterations' gracefully"))
end

ME = [];
try
    [W,H,~] = nmf_euclidian_norm(V, zeros(20), rand20_B, 0.001, 9999);
catch ME
end

if isempty(ME) || ME.identifier ~= "nmf_euclidian_norm:failed_to_converge"
    disp (ME.identifier)
    throw (MException("unittest:nmf_euclidian_norm", "Doesn't handle 'out of iterations' gracefully"))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure it can handle matrices with some zero elems

endW = rand(20,20) * 50;
gaps  = randperm(numel(endW));
endW(gaps(1:50)) = 0;

% !!! talk about normalisation, number of iterations, etc etc 
endH = rand(20,20) * 50;
gaps = randperm(numel(endH));
endH(gaps(1:50)) = 0; 

V = endW*endH;

startW = endW.*rand(20,20) * 2;
startH = endH.*rand(20,20) * 2;

try
    [W,H,~] = nmf_euclidian_norm (V, startW, startH, 100);
catch ME
    disp (ME.identifier)
end

disp("done");

