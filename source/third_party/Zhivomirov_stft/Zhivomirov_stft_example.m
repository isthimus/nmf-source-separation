clear, clc, close all

% load an audio signal
[x, Fs] = audioread('track.wav'); 
x = x(:, 1);                                  

% signal parameters
xlen = length(x);                   
t = (0:xlen-1)/Fs;                  

% define the analysis and synthesis parameters
wlen = 1024;
hop = wlen/8;
nfft = 4*wlen;

% generate analysis and synthesis windows
anal_win = blackmanharris(wlen, 'periodic');
synth_win = hamming(wlen, 'periodic');

% perform time-frequency analysis and resynthesis of the signal
[STFT, ~, ~] = stft(x, anal_win, hop, nfft, Fs);
[x_istft, t_istft] = istft(STFT, anal_win, synth_win, hop, nfft, Fs);
disp ("size is: ")
disp (size(x_istft))

% plot the original signal
figure(1)
plot(t, x, 'b')
grid on
xlim([0 max(t)])
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('Time, s')
ylabel('Signal amplitude')
title('Original and reconstructed signal')

% plot the resynthesized signal 
hold on
plot(t_istft, x_istft, '-.r')
legend('Original signal', 'Reconstructed signal')