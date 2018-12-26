% cd to the folder this script is in
script_path = mfilename('fullpath');
script_path = script_path(1: find(script_path == '\', 1, 'last'));
cd(script_path)

% set matlab path and pick up some other useful paths
run('./setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

audiopath = 'C:\Users\Helen\third-year-project\score-aware-source-separation\datasets\PHENICX\audio\beethoven\bassoon1.wav';
% audiopath = fullfile(TRIOS_DATA_PATH, 'brahms/horn.wav');
[hn_brahms, Fs] = audioread(audiopath);
disp(audioinfo(audiopath));

hn_brahms = hn_brahms(1:1.487e6);
n = [1 : length(hn_brahms)];
%audiowrite(fullfile(DEV_DATA_PATH, 'TRIOS_hn_6note.wav'), hn_brahms, Fs);
t = 0:1/4.4e4:5;
y = chirp(t,0,2.5,4000); 

%audiowrite(fullfile(DEV_DATA_PATH, 'chirp.wav'), y, 4.4e4)


plot (n,hn_brahms);
disp (max(hn_brahms(:)))


%{
wait_returnKey


colormap bone

%spectrogram(vln_brahms, ceil(Fs/50), ceil(Fs/200),[], Fs, 'MinThreshold',-100,  'yaxis');
spectrogram(hn_brahms, ceil(Fs/50), 'yaxis');
view(-30,65)
xlabel('time (samples)')
colorbar off 
wait_returnKey

spectrogram(hn_brahms, ceil(Fs/50), ceil(Fs/100), 'MinThreshold',-100,  'yaxis');
xlabel('time (seconds)')
wait_returnKey


%close all
%}