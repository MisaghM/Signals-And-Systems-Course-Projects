%% Part 4

clear
close all
clc

%% 4.1 Mapset

load('mapset.mat')
char_bin_len = length(mapset{2, 1});

%% 4.2 Coding frequency

fs = 100;

%% 4.3 Coding a message

str = 'signal';
bin = str2bin(str, mapset);

figure('Name', 'Frequnecy Code', 'Position', [100, 100, 1200, 600])

for bitrate = 1:3
    x = coding_freq(bin, bitrate);
    t = 0:(1 / fs):(length(str) * char_bin_len / bitrate - 1 / fs);

    subplot(3, 1, bitrate)
    plot(t, x)
    title(['Bitrate = ', num2str(bitrate)])
end
