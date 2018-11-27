PROJECT_PATH = '../';
TRIOS_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

[vln_dev, Fs] = audioread(fullfile(DEV_DATA_PATH, 'TRIOS_vln_Db6_B6.wav'));

%vln_dev = vln_dev(5.6e5:6.9e5);
n = [1 : length(vln_dev)];
%audiowrite(fullfile(DEVELOPMENT_PATH, 'TRIOS_hn_C5_Bb4_?.wav'), hn_brahms, Fs);


plot (n,vln_dev);


%%{
waitforbuttonpress


colormap bone

%spectrogram(vln_brahms, ceil(Fs/50), ceil(Fs/200),[], Fs, 'MinThreshold',-100,  'yaxis');
spectrogram(vln_dev, ceil(Fs/50), 'yaxis');
view(-30,65)
xlabel('time (samples)')
colorbar off 
waitforbuttonpress

spectrogram(vln_dev, ceil(Fs/50), ceil(Fs/200),[], Fs, 'MinThreshold',-100,  'yaxis');
xlabel('time (seconds)')
waitforbuttonpress

%close all
%%}