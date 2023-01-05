%% Part 3

clear
close all
clc

%% 3.1 Mapset

load('mapset.mat')
char_bin_len = length(mapset{2, 1});

%% 3.2 Coding amplitude

fs = 100;

%% 3.3 Coding a message

str = 'signal';
bin = str2bin(str, mapset);

figure('Name', 'Amplitude Code')
for bitrate = 1:3
    x = coding_amp(bin, bitrate);
    t = 0:(1 / fs):(length(str) * char_bin_len / bitrate - 1 / fs);

    subplot(3, 1, bitrate)
    plot(t, x)
    title(['Bitrate = ', num2str(bitrate)])
end
