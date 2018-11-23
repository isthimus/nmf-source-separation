PROJECT_PATH = '/user/HS124/mc00385/third_year_project/score-aware-source-separation';
TRIOS_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');

[vln_brahms, Fs] = audioread(fullfile(TRIOS_PATH, 'brahms/violin.wav'));
pno_syn_brahms = audioread(fullfile(TRIOS_PATH, 'brahms/piano_syn.wav'));

n = [1 : length(vln_brahms)];

plot (n,vln_brahms);
waitforbuttonpress

colormap bone
spectrogram(vln_brahms, ceil(Fs/50), [],[], Fs, 'MinThreshold',-100,  'yaxis');
xlabel('time (samples)')

waitforbuttonpress

%spectrogram(vln_brahms, ceil(Fs/50), [],[], Fs, 'MinThreshold',-110,  'yaxis');
spectrogram(vln_brahms, ceil(Fs/50), 'yaxis');
view(-30,65)
xlabel('time (samples)')
colorbar off 

waitforbuttonpress
close all

