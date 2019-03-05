% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% setup matlab path and pick up some useful path strings
run('./setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

% test align_resolveWarpingPath
if 1 
    % make two vectors for alignment
    a = [0 0 0 0 0 10 0 0 0 0 0 0 10 0 0 10 0 0 0 0 0];
    b = [0 0 0 0 0 1  7 1 1 1 7 1  1 1 1  7 0 0 0 0 0];
    
    % plot unaligned
    plot(a); hold on; plot (b); 
    title('unaligned');
    wait_returnKey
    close all
    
    % align with dtw
    [~, ia, ib] = dtw (a, b);
    
    % plot a(ia) against b(ib)
    % theyre aligned now but this is longer than the original sequence!
    plot(a(ia)); hold on; plot(b(ib)); 
    title('ia - ib');
    wait_returnKey
    close all;

    % now resolve the warping path to bring ia into line with an unmodified ib
    ia_r = align_resolveWarpingPath(ia, ib);
    plot(a(ia_r)); hold on; plot(b); 
    title('ia resolved to b');
    wait_returnKey
    close all;

    % bring ib into line with ia instead 
    ib_r = align_resolveWarpingPath (ib, ia);
    plot (a); hold on; plot (b(ib_r));
    title ('ib resolved to a');
    wait_returnKey
    close all;

    % plot the various indices
    stem (1:length(a)); hold on; stem (ia); stem(ia_r);
    title ("index types");
    wait_returnKey
    close all;

    % upsample, smooth and try again 
    a = upsample(a, 10);
    b = upsample(b, 10);

    linsmooth_IR = [1:20, 19:-1:1] ./ 20;
    quadsmooth_IR = linsmooth_IR .* linsmooth_IR;
    a = conv(a, quadsmooth_IR);
    b = conv(b, quadsmooth_IR);

    % plot unaligned
    plot(a); hold on; plot (b); 
    title('unaligned');
    wait_returnKey
    close all
    
    % align with dtw
    [~, ia, ib] = dtw (a, b);
    
    % plot a(ia) against b(ib)
    % theyre aligned now but this is longer than the original sequence!
    plot(a(ia)); hold on; plot(b(ib)); 
    title('ia - ib');
    wait_returnKey
    close all;

    % now resolve the warping path to bring ia into line with an unmodified ib
    ia_r = align_resolveWarpingPath(ia, ib);
    plot(a(ia_r)); hold on; plot(b); 
    title('ia resolved to b');
    wait_returnKey
    close all;

    % bring ib into line with ia instead 
    ib_r = align_resolveWarpingPath (ib, ia);
    plot (a); hold on; plot (b(ib_r));
    title ('ib resolved to a');
    wait_returnKey
    close all;

    % quick and dirty test to make sure it works with matrices
    %{
    v_a = [a;   2*a; 1.3*a];
    v_b = [b; 1.3*b;   2*b];
    %}
    v_a = [a; 2*a; 1.3*a];
    v_b = [b; 2*b; 1.3*b];


    % align with dtw
    [~, v_ia, v_ib] = dtw (v_a, v_b);

    % resolve a to b
    v_ia_r = align_resolveWarpingPath (v_ia, v_ib);

    % see if theyre different
    plot (ia_r); hold on; plot(v_ia_r);
    title('vectorised vs non vectorised warping'); 
    wait_returnKey;
    close all;

    % show that the differences are basically rounding errors
    plot (v_ia_r - ia_r)
    title('vectorised vs non vectorised warping - difference'); 
    wait_returnKey
    close all;

end 

% verify that align_resolveWarpingPath can handle vectors
if 1

end