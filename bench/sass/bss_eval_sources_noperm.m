function [SDR,SIR,SAR,perm]=bss_eval_sources_noperm(se,s)
    % VERSION OF bss_eval which does not consider permutations, i.e. it 


% BSS_EVAL_SOURCES Ordering and measurement of the separation quality for
% estimated source signals in terms of filtered true source, interference
% and artifacts.
% 
% The decomposition allows a time-invariant filter distortion of length
% 512, as described in Section III.B of the reference below.
%
% [SDR,SIR,SAR,perm]=bss_eval_sources(se,s)
%
% Inputs:
% se: nsrc x nsampl matrix containing estimated sources
% s: nsrc x nsampl matrix containing true sources
%
% Outputs:
% SDR: nsrc x 1 vector of Signal to Distortion Ratios
% SIR: nsrc x 1 vector of Source to Interference Ratios
% SAR: nsrc x 1 vector of Sources to Artifacts Ratios
% perm: nsrc x 1 vector containing the best ordering of estimated sources
% in the mean SIR sense (estimated source number perm(j) corresponds to
% true source number j)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2008 Emmanuel Vincent
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt)
% If you find it useful, please cite the following reference:
% Emmanuel Vincent, Rémi Gribonval, and Cédric Févotte, "Performance
% measurement in blind audio source separation," IEEE Trans. on Audio,
% Speech and Language Processing, 14(4):1462-1469, 2006.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
