% cd to the folder this script is in
script_path = mfilename('fullpath');
if ispc
    script_path = script_path(1: find(script_path == '\', 1, 'last'));
elseif isunix
    script_path = script_path(1: find(script_path == '/', 1, 'last'));
end
cd(script_path)

% set matlab path and pick up some other useful paths
run('./setpaths.m')
PROJECT_PATH = fullfile('../../');
TRIOS_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/TRIOS');
DEV_DATA_PATH = fullfile(PROJECT_PATH, '/datasets/development');

audiopath = fullfile(TRIOS_DATA_PATH, '/brahms/piano.wav');
[audio, Fs] = audioread(audiopath);
disp(audioinfo(audiopath));

audio = audio(1:92309);

%doorbell = doorbell(1:1.487e6);
n = [1 : length(audio)];
audiowrite(fullfile(DEV_DATA_PATH, 'TRIOS_brahms_2bar_short.wav'), audio, Fs);
%audiowrite(fullfile(DEV_DATA_PATH, 'TRIOS_vln_Db6_B6_2.wav'), vlnB, Fs);

audio = audio(:,1);

plot (n,audio);
waitforbuttonpress;


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