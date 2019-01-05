PROJECT_PATH = '/user/HS124/mc00385/third_year_project/score-aware-source-separation';
TRIOS_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEVELOPMENT_PATH = fullfile(PROJECT_PATH, '/datasets/development');

[vln_brahms, Fs] = audioread(fullfile(TRIOS_PATH, 'brahms/violin.wav'));
pno_syn_brahms = audioread(fullfile(TRIOS_PATH, 'brahms/piano_syn.wav'));

vln_brahms = vln_brahms(3.1e5:4.3e5);
n = [1 : length(vln_brahms)];

%audiowrite(fullfile(DEVELOPMENT_PATH, 'TRIOS_vln_C5_Eb5_F5_Ab4.wav'), vln_brahms, Fs);


plot (n,vln_brahms);


%%{
waitforbuttonpress


colormap bone

%spectrogram(vln_brahms, ceil(Fs/50), ceil(Fs/200),[], Fs, 'MinThreshold',-100,  'yaxis');
spectrogram(vln_brahms, ceil(Fs/50), 'yaxis');
view(-30,65)
xlabel('time (samples)')
colorbar off 
waitforbuttonpress

spectrogram(vln_brahms, ceil(Fs/50), ceil(Fs/200),[], Fs, 'MinThreshold',-100,  'yaxis');
xlabel('time (seconds)')
waitforbuttonpress

close all
%%}