% print results from chroma_hop_sizes
% loads "spectInfo" and "results"
load('results/chroma_hop_sizes')
hop = spectInfo.hop;
wlen = spectInfo.hop;

% plot results
figure(1)
subplot(3,1,1)
 imagesc(results{1})
 axis xy
 title(strcat ('hop = ' ,num2str(wlen/2^0 * 4)))
 colorbar;
subplot(3,1,2)
 imagesc(results{2})
 axis xy
 title(strcat ('hop = ' ,num2str(wlen/2^1 * 4)))
 colorbar;
subplot(3,1,3)
 imagesc(results{3})
 axis xy
 title(strcat ('hop = ' ,num2str(wlen/2^2 * 4)))
 colorbar;

wait_returnKey();
close all;

tb = 1 : size(results{1}, 2);

r1 = results{1};
r2 = results{2};

figure(1)
  imagesc(r1(tb) - r2(tb*2))
  axis xy
  title ("diff of two largest")
  colorbar;
wait_returnKey()
close all;