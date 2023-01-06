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

%% 3.4 Decoding a message

str = 'signal';
bitrates = 1:3;
noise = 0;
result = test(str, bitrates, noise, mapset);
print_result(result)

%% 3.5 Adding noise

str = 'signal';
bitrates = 1:3;
noise = 0.01;
result = test(str, bitrates, noise, mapset);
print_result(result)
plot_noisy_signal(str, bitrates, noise, mapset, fs, char_bin_len)

%% 3.6 Increasing noise

str = 'signal';
bitrates = 1:3;

noise = 0.1;
result = test(str, bitrates, noise, mapset);
print_result(result)
plot_noisy_signal(str, bitrates, noise, mapset, fs, char_bin_len)

noise = 0.4;
result = test(str, bitrates, noise, mapset);
print_result(result)
plot_noisy_signal(str, bitrates, noise, mapset, fs, char_bin_len)

noise = 0.7;
result = test(str, bitrates, noise, mapset);
print_result(result)
plot_noisy_signal(str, bitrates, noise, mapset, fs, char_bin_len)

noise = 1;
result = test(str, bitrates, noise, mapset);
print_result(result)
plot_noisy_signal(str, bitrates, noise, mapset, fs, char_bin_len)

noise = 1.2;
result = test(str, bitrates, noise, mapset);
print_result(result)
plot_noisy_signal(str, bitrates, noise, mapset, fs, char_bin_len)

%% Functions

function result = test(str, bitrates, noise, mapset)
    bin_send = str2bin(str, mapset);
    result = cell(length(bitrates), 1);

    for i = 1:length(bitrates)
        bitrate = bitrates(i);
        signal_send = coding_amp(bin_send, bitrate);
        signal_receive = signal_send + noise * randn(size(signal_send));
        bin_receive = decoding_amp(signal_receive, bitrate);
        str_receive = bin2str(bin_receive, mapset);
        result{i} = ['Recieved (bitrate=', num2str(bitrate), ', noise=', num2str(noise), '): ', str_receive];
    end
end

function print_result(result)
    for i = 1:length(result)
        disp(result{i})
    end
end

function plot_noisy_signal(str, bitrates, noise, mapset, fs, char_bin_len)
    bin = str2bin(str, mapset);

    figure('Name', 'Amplitude Code with Noise')

    for bitrate = bitrates
        x = coding_amp(bin, bitrate);
        x = x + noise * randn(size(x));
        t = 0:(1 / fs):(length(str) * char_bin_len / bitrate - 1 / fs);

        subplot(length(bitrates), 1, bitrate)
        plot(t, x)
        title(['Bitrate = ', num2str(bitrate), ', Noise = ', num2str(noise)])
    end
end
