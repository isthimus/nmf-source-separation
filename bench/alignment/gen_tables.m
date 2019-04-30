function [testvectors, testdefs] = gen_tables(switches);
    % generates input tables for testbench.m

    if nargin == 1
        % pull out switches if given
        TESTVECS_SOLO = switches.TESTVECS_SOLO;
        TESTVECS_MIX  = switches.TESTVECS_MIX;
        TESTDEFS_VANILLA = switches.TESTDEFS_VANILLA;
        TESTDEFS_ONSET_VEL = switches.TESTDEFS_ONSET_VEL;
        TESTDEFS_ONSET_NOVEL = switches.TESTDEFS_ONSET_NOVEL;
    else
        % autofill if not
        TESTVECS_SOLO = true;
        TESTVECS_MIX  = true;
        TESTDEFS_VANILLA = true;
        TESTDEFS_ONSET_VEL = true;
        TESTDEFS_ONSET_NOVEL = true;
    end

    % make empty testvectors/testdefs
    % a testdef is the algorithm/parameters used to solve the problem in a particular way
        % eg aln_align_dtw, no velocity
    % a testvec is a particular case of the problem
        % in this case that's an audio file, plus a ground-truth midi file
    testvectors = cell(0);
    testdefs = cell(0);

    % pick up some useful path strings
    PROJECT_PATH = fullfile('../../');
    TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
    PHENICX_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/PHENICX');
    DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

    % BUILD TEST VECTORS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if TESTVECS_SOLO
        % nice easy solo piano with lots of clear onsets
        testvectors{end+1} = struct( ...
            "name"       , "triosMozartPiano", ...
            "audioPath" , fullfile(TRIOS_DATA_PATH, "mozart/piano.wav"), ...
            "midiPath"  , fullfile(TRIOS_DATA_PATH, "mozart/piano.mid") ...
        );
        % viola with long notes - hard to avoid false positives
        testvectors{end+1} = struct( ...
            "name"       , "triosMozartViola", ...
            "audioPath" , fullfile(TRIOS_DATA_PATH, "mozart/viola.wav"), ...
            "midiPath"  , fullfile(TRIOS_DATA_PATH, "mozart/viola.mid") ...
        );
        % something low - cello
        testvectors{end+1} = struct( ...
            "name"       , "triosSchubertCello", ...
            "audioPath" , fullfile(TRIOS_DATA_PATH, "schubert/cello.wav"), ...
            "midiPath"  , fullfile(TRIOS_DATA_PATH, "schubert/cello.mid") ...
        );
        % something high - flute
        testvectors{end+1} = struct( ...
            "name"       , "phenicxBrucknerFlute", ...
            "audioPath" , fullfile(PHENICX_DATA_PATH, "audio/bruckner/flute.wav"), ...
            "midiPath"  , fullfile(PHENICX_DATA_PATH, "annotations/bruckner/flute.mid") ... 
        );
    end

    if TESTVECS_MIX
        % mix - TRIOS brahms
        midi_stack( ...
            "./tmp/triosBrahmsMix.mid", ...
            fullfile(TRIOS_DATA_PATH, "brahms/piano.mid"), ...
            fullfile(TRIOS_DATA_PATH, "brahms/horn.mid"), ...
            fullfile(TRIOS_DATA_PATH, "brahms/violin.mid") ...
        );
        testvectors{end+1} = struct( ...
            "name"       , "triosBrahmsMix", ...
            "audioPath" , fullfile(TRIOS_DATA_PATH, "brahms/mix.wav"), ...
            "midiPath"  , "./tmp/triosBrahmsMix.mid" ...
        );
        
        % mix - TRIOS mozart
        midi_stack( ...
            "./tmp/triosMozartMix.mid", ...
            fullfile(TRIOS_DATA_PATH, "mozart/piano.mid"), ...
            fullfile(TRIOS_DATA_PATH, "mozart/clarinet.mid"), ...
            fullfile(TRIOS_DATA_PATH, "mozart/viola.mid") ...
        );
        testvectors{end+1} = struct( ...
            "name"       , "triosMozartMix", ...
            "audioPath" , fullfile(TRIOS_DATA_PATH, "mozart/mix.wav"), ...
            "midiPath"  , "./tmp/triosMozartMix.mid" ... 
        );

        % mix - TRIOS lussier
        midi_stack( ...
            "./tmp/triosLussierMix.mid", ...
            fullfile(TRIOS_DATA_PATH, "lussier/bassoon.mid"), ...
            fullfile(TRIOS_DATA_PATH, "lussier/piano.mid"), ...
            fullfile(TRIOS_DATA_PATH, "lussier/trumpet.mid") ...
        );
        testvectors{end+1} = struct( ...
            "name"       , "triosLussierMix", ...
            "audioPath" , fullfile(TRIOS_DATA_PATH, "lussier/mix.wav"), ...
            "midiPath"  , "./tmp/triosLussierMix.mid" ... 
        );

        % mix - TRIOS schubert
        midi_stack( ...
            "./tmp/triosSchubertMix.mid", ...
            fullfile(TRIOS_DATA_PATH, "schubert/cello.mid"), ...
            fullfile(TRIOS_DATA_PATH, "schubert/piano.mid"), ...
            fullfile(TRIOS_DATA_PATH, "schubert/violin.mid") ...
        );
        testvectors{end+1} = struct( ...
            "name"       , "triosSchubertMix", ...
            "audioPath" , fullfile(TRIOS_DATA_PATH, "schubert/mix.wav"), ...
            "midiPath"  , "./tmp/triosSchubertMix.mid" ... 
        );

        % mix - TRIOS take five
        midi_stack( ...
            "./tmp/triosTakeFiveMix.mid", ...
            fullfile(TRIOS_DATA_PATH, "take_five/kick.mid"), ...
            fullfile(TRIOS_DATA_PATH, "take_five/piano.mid"), ...
            fullfile(TRIOS_DATA_PATH, "take_five/ride.mid"), ...
            fullfile(TRIOS_DATA_PATH, "take_five/saxophone.mid"), ...
            fullfile(TRIOS_DATA_PATH, "take_five/snare.mid") ... 
        );
        testvectors{end+1} = struct( ...
            "name"       , "triosTakeFiveMix", ...
            "audioPath" , fullfile(TRIOS_DATA_PATH, "take_five/mix.wav"), ...
            "midiPath"  , "./tmp/triosTakeFiveMix.mid" ... 
        );

        % !!! NB not using PHENICX at the moment as no "mix.wav" is provided. not to 
        % hard to hack together midi files but audio is a different matter
        % (gain settings, etc).
        % maybe will come back to it.
    end

    % BUILD TESTDEFS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
        
    % NB test_func interface is test_func(notes,audio,spect,spectInfo)

    % build a standard spectInfo
    si_std = struct( ... 
        "wlen"         , 1024, ... 
        "nfft"         , 1024 * 4, ...
        "hop"          , 1024 / 4, ...
        "analwin"      , blackmanharris(1024, 'periodic'), ...
        "synthwin"     , hamming(1024, 'periodic'), ...
        "max_freq_bins", 300 ... 
    );


    %standard (ie chroma-only) alignment functions
    if TESTDEFS_VANILLA
        % vanilla dtw, use_vel
        testdefs{end+1} = struct (...
            "name"     , "vanillaUseVel", ...
            "testFunc" , @(n,a,s,si)aln_align_dtw(n,a,si,false), ...
            "spectInfo", si_std ...
        );

        % vanilla dtw, no vel
        testdefs{end+1} = struct (...
            "name"     , "vanillaNoVel", ...
            "testFunc" , @(n,a,s,si)aln_align_dtw(n,a,si,true), ...
            "spectInfo", si_std ...
        );
    end

    % alignment functions which use onset detection
    if TESTDEFS_ONSET_VEL

        % partial function representing a block normalised spectral difference with 
        % leading edge detection and smoothing
        % s and si are the spect and spectinfo for aln_onsUtil_specDiff_taxi
        % tol and drop are tolerance and dropout thresh for the normalisation
        onset_taxi = @(s,si,tol,drop) ...
            aln_onsUtil_smooth( ...
                aln_onsUtil_leadingEdge( ...
                    block_normalise( ...
                        aln_onsUtil_specDiff_taxi(s,si), ...
                        100, ...
                        drop ...
                    ), ...
                    tol ...
                ) ...
            );


        % partial function representing a block normalised spectral difference with 
        % leading edge detection and smoothing
        % s and si are the spect and spectinfo for aln_onsUtil_specDiff_rectL2
        % tol and drop are tolerance and dropout thresh for the normalisation
        onset_rect = @(s,si,tol,drop) ...
            aln_onsUtil_smooth( ...
                aln_onsUtil_leadingEdge( ...
                    block_normalise( ...
                        aln_onsUtil_specDiff_rectL2(s,si), ...
                        100, ...
                        drop ...
                    ), ...
                    tol ...
                ) ...
            );

        % choose tolerances, dropout_thresh, chroma ratios
        tols =  [1, 10];
        drops = [0, 6];
        chroma_ratios = [0.1, 0.3, 0.5, 0.7, 0.9];

        % generate testDefs using every combination of the above values
        for tol_i   = 1:length(tols)
        for drop_i  = 1:length(drops)
        for ratio_i = 1:length(chroma_ratios)
            
            tol = tols(tol_i);
            drop = drops(drop_i);
            ratio = chroma_ratios(ratio_i);

            % taxi first
            name = sprintf("OnsetTaxiRatio%.1fTol%iDrop%i", ratio,tol,drop);
            onsFunc = @(s,si)onset_taxi(s,si, tol, drop);
            
            testdefs{end+1} = struct (...
                "name"     , name, ...
                "testFunc" , @(n,a,s,si)aln_align_dtw_onset(n,a,s,si,onsFunc,ratio,true), ...
                "spectInfo", si_std ...
            );

            % then rect
            name = sprintf("OnsetRectRatio%.1fTol%iDrop%i", ratio,tol,drop);
            onsFunc = @(s,si)onset_rect(s,si, tol, drop);
            
            testdefs{end+1} = struct (...
                "name"     , name, ...
                "testFunc" , @(n,a,s,si)aln_align_dtw_onset(n,a,s,si,onsFunc,ratio,true), ...
                "spectInfo", si_std ...
            );
        
        end; end; end;

    end    

    % alignment functions which use onset detection - but not midi velocity
    if TESTDEFS_ONSET_NOVEL

        % partial function representing a block normalised spectral difference with 
        % leading edge detection and smoothing
        % s and si are the spect and spectinfo for aln_onsUtil_specDiff_taxi
        % tol and drop are tolerance and dropout thresh for the normalisation
        onset_taxi = @(s,si,tol,drop) ...
            aln_onsUtil_smooth( ...
                aln_onsUtil_leadingEdge( ...
                    block_normalise( ...
                        aln_onsUtil_specDiff_taxi(s,si), ...
                        100, ...
                        drop ...
                    ), ...
                    tol ...
                ) ...
            );


        % partial function representing a block normalised spectral difference with 
        % leading edge detection and smoothing
        % s and si are the spect and spectinfo for aln_onsUtil_specDiff_rectL2
        % tol and drop are tolerance and dropout thresh for the normalisation
        onset_rect = @(s,si,tol,drop) ...
            aln_onsUtil_smooth( ...
                aln_onsUtil_leadingEdge( ...
                    block_normalise( ...
                        aln_onsUtil_specDiff_rectL2(s,si), ...
                        100, ...
                        drop ...
                    ), ...
                    tol ...
                ) ...
            );

        % choose tolerances, dropout_thresh, chroma ratios
        tols =  [1, 10];
        drops = [0, 6];
        chroma_ratios = [0.1, 0.3, 0.5, 0.7, 0.9];

        % generate testDefs using every combination of the above values
        for tol_i   = 1:length(tols)
        for drop_i  = 1:length(drops)
        for ratio_i = 1:length(chroma_ratios)
            
            tol = tols(tol_i);
            drop = drops(drop_i);
            ratio = chroma_ratios(ratio_i);

            % taxi first
            name = sprintf("NVOnsetTaxiRatio%.1fTol%iDrop%i", ratio,tol,drop);
            onsFunc = @(s,si)onset_taxi(s,si, tol, drop);
            
            testdefs{end+1} = struct (...
                "name"     , name, ...
                "testFunc" , @(n,a,s,si)aln_align_dtw_onset(n,a,s,si,onsFunc,ratio,false), ...
                "spectInfo", si_std ...
            );

            % then rect
            name = sprintf("NVOnsetRectRatio%.1fTol%iDrop%i", ratio,tol,drop);
            onsFunc = @(s,si)onset_rect(s,si, tol, drop);
            
            testdefs{end+1} = struct (...
                "name"     , name, ...
                "testFunc" , @(n,a,s,si)aln_align_dtw_onset(n,a,s,si,onsFunc,ratio,false), ...
                "spectInfo", si_std ...
            );
        
        end; end; end;

    end