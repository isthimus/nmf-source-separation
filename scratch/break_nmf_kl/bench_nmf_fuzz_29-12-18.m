% fuzz testing of nmf algorithms to make sure the update rules
% are properly implemented
% also gives some idea of how global the minima are

% make a "legacy" version of the nmf_init_rand function
% it's interface has changed and i'm loath to change this script 
% until I have FSA benchmarks running
nmf_init_rand_legacy = @(nfb,ntb,k,avg)...
    nmf_init_rand(struct("num_freq_bins",nfb,"num_time_bins", ntb), k, avg);


FUZZ_ATTEMPTS = 50; % set this in accordance with your patience and CPU GHz

% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('../setpaths.m')
PROJECT_PATH = fullfile('../../..');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

rng(0);

% make some Vs
v_magic_100 = magic(100);
v_magic_100x10000 = repmat(magic(100), 1, 100);
v_rand_100 = 50 * rand(100);
v_rand_100x10000 = 50 * rand(100, 10000);

[audioVec_doorbell, ~] = audioread(fullfile(DEV_DATA_PATH, 'doorbell.wav'));
v_spect_doorbell = stft(              ...
    audioVec_doorbell,                ...
    blackmanharris(1024, 'periodic'), ...
    1024/8,                           ...
    1024*4,                           ...
    1                                 ...
);

Vs = {
    "v_magic_100",       v_magic_100;
%    "v_magic_100x10000", v_magic_100x10000;
    "v_rand_100",        v_rand_100;
%    "v_rand_100x10000",  v_rand_100x10000;
%    "v_spect_doorbell",  abs(v_spect_doorbell);
};

% make some inits
% prototype - V -> W_init, H_init
inits = {
    % rand
    "init_rand_k03",      @(V) nmf_init_rand_legacy(size(V,1), size(V,2),  3, 10);
    "init_rand_k10",      @(V) nmf_init_rand_legacy(size(V,1), size(V,2), 10, 10);
    "init_rand_k50",      @(V) nmf_init_rand_legacy(size(V,1), size(V,2), 50, 10);

    % preconverge is
    "init_is_k10",        @(V) nmf_is(V, rand(size(V,1), 10), ones(10, size(V,2)));
    "init_is_k50",        @(V) nmf_is(V, rand(size(V,1), 50), ones(50, size(V,2)));

    % preconverge kl
    "init_kl_k10",        @(V) nmf_kl(V, rand(size(V,1), 10), ones(10, size(V,2)));
    "init_kl_k50",        @(V) nmf_kl(V, rand(size(V,1), 50), ones(50, size(V,2)));

    % preconverge euclidian
    "init_euclidian_k10", @(V) nmf_euclidian(V, rand(size(V,1), 10), ones(10, size(V,2)));
    "init_euclidian_k50", @(V) nmf_euclidian(V, rand(size(V,1), 50), ones(50, size(V,2)));
};


% make some fuzzes
fuzzes = {
    "fuzz_some_abit", @(mat) matfuzz_additive(mat, 0.1, 0.1, 1);
    "fuzz_many_abit", @(mat) matfuzz_additive(mat, 0.4, 0.1, 1);
    "fuzz_all_abit",  @(mat) matfuzz_additive(mat, 1  , 0.1, 1);

    "fuzz_some_alot", @(mat) matfuzz_additive(mat, 0.1, 0.8, 1);
    "fuzz_many_alot", @(mat) matfuzz_additive(mat, 0.4, 0.8, 1);
};


% collect nmf funcs
nmf_funcs = {
  "nmf_euclidian", @nmf_euclidian, @square_euclidian_distance;
  "nmf_is",        @nmf_is,        @IS_divergence;
  "nmf_kl",        @nmf_kl,        @KL_divergence;  
};

fprintf('########################################\n')
fprintf('TEST TYPE - %s\n', mfilename())
fprintf('########################################\n')

testnum= 1;
% run fuzz test
for nmf_i = 1:size(nmf_funcs,1)
for init_i = 1:size(inits,1)
for V_i = 1:size(Vs,1)
for fuzz_i = 1:size(fuzzes,1)

    % save randState
    randState = rng;

    % get params from various lists
    V = Vs{V_i, 2};
    init_func = inits{init_i, 2};
    nmf_func = nmf_funcs{nmf_i, 2};
    dist_func = nmf_funcs{nmf_i, 3};
    fuzz_func = fuzzes{fuzz_i, 2};

    % get initial W, H and perform nmf
    [W_init, H_init] = init_func (V);
    [W_out, H_out, final_err, ~] = nmf_func(V, W_init, H_init);

    % fuzz results, print to terminal if a better point is found.
    for k = 1:FUZZ_ATTEMPTS
        W_fuzz = fuzz_func(W_out);
        H_fuzz = fuzz_func(H_out);
        if (dist_func(V, W_fuzz*H_fuzz) < final_err)
            fprintf ('----------------------------------------\n');
            fprintf ('fuzz decreased dist_func!\n');
            fprintf ('params:\n');
            disp(Vs       (V_i, 1));
            disp(inits    (init_i, 1));
            disp(nmf_funcs(nmf_i, 1));
            disp(fuzzes   (fuzz_i, 1));
            fprintf ('prefuzz dist: %d\n' , final_err);
            fprintf ('postfuzz dist: %d\n', dist_func(V, W_fuzz*H_fuzz));
            fprintf ('rand state at start of loop body:\n');
            disp(randState);
            fprintf ('----------------------------------------\n');
        end
    end
    if (V_i == 1 && fuzz_i == 1);
        fprintf('\n')
    end

    fprintf('.');
    testnum =testnum + 1;

end 
end 
end
end
