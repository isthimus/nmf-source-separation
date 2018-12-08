PROJECT_PATH = fullfile('../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

[hn_brahms, Fs] = audioread(fullfile(TRIOS_DATA_PATH, 'brahms/horn.wav'));

hn_brahms = hn_brahms(1:1.487e6);
n = [1 : length(hn_brahms)];
%
audiowrite(fullfile(DEV_DATA_PATH, 'TRIOS_hn_6note.wav'), hn_brahms, Fs);


plot (n,hn_brahms);


%%{
waitforbuttonpress


colormap bone

%spectrogram(vln_brahms, ceil(Fs/50), ceil(Fs/200),[], Fs, 'MinThreshold',-100,  'yaxis');
spectrogram(hn_brahms, ceil(Fs/50), 'yaxis');
view(-30,65)
xlabel('time (samples)')
colorbar off 
waitforbuttonpress

spectrogram(hn_brahms, ceil(Fs/50), ceil(Fs/100), 'MinThreshold',-100,  'yaxis');
xlabel('time (seconds)')
waitforbuttonpress


%close all
%%}