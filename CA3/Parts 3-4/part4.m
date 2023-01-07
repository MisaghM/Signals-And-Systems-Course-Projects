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

%% 4.4 Decoding a message

str = 'signal';
bitrates = 1:3;
noise = 0;
result = test(str, bitrates, noise, mapset);
print_result(result)

%% Functions

function result = test(str, bitrates, noise, mapset)
    bin_send = str2bin(str, mapset);
    result = cell(length(bitrates), 1);

    for i = 1:length(bitrates)
        bitrate = bitrates(i);
        signal_send = coding_freq(bin_send, bitrate);
        signal_receive = signal_send + noise * randn(size(signal_send));
        bin_receive = decoding_freq(signal_receive, bitrate);
        str_receive = bin2str(bin_receive, mapset);
        result{i} = ['Recieved (bitrate=', num2str(bitrate), ', noise=', num2str(noise), '): ', str_receive];
    end
end

function print_result(result)
    for i = 1:length(result)
        disp(result{i})
    end
end
