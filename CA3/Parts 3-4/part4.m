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

%% 4.5 Adding noise

str = 'signal';
bitrates = 1:3;
noise = 0.01;
result = test(str, bitrates, noise, mapset);
print_result(result)
plot_noisy_signal(str, bitrates, noise, mapset, fs, char_bin_len)

%% 4.6 Increasing noise

str = 'signal';
bitrates = 1:3;
fixed_noise = 1.5;

noise = 0.8;
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

noise = 1.4;
result = test(str, bitrates, noise, mapset);
print_result(result)
plot_noisy_signal(str, bitrates, noise, mapset, fs, char_bin_len)

noise = 1.6;
result = test(str, bitrates, noise, mapset);
print_result(result)
plot_noisy_signal(str, bitrates, noise, mapset, fs, char_bin_len)

for bitrate = 1:3
    error = fixed_noise_error(str, bitrate, fixed_noise, mapset, char_bin_len);
    disp(['Error (bitrate=', num2str(bitrate), ', noise=', num2str(fixed_noise), '): ', num2str(error), '%'])
end

%% 4.7 Noise threshold

str = 'signal';
for bitrate = 1:3
    thold = noise_threshold(str, bitrate, mapset);
    disp(['Noise threshold (bitrate=', num2str(bitrate), '): ', num2str(thold)])
end

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

function plot_noisy_signal(str, bitrates, noise, mapset, fs, char_bin_len)
    bin = str2bin(str, mapset);

    figure('Name', 'Amplitude Code with Noise', 'Position', [100, 100, 1200, 600])

    for bitrate = bitrates
        x = coding_freq(bin, bitrate);
        x = x + noise * randn(size(x));
        t = 0:(1 / fs):(ceil(length(str) * char_bin_len / bitrate) - 1 / fs);

        subplot(length(bitrates), 1, bitrate)
        plot(t, x)
        title(['Bitrate = ', num2str(bitrate), ', Noise = ', num2str(noise)])
    end
end

function thold = noise_threshold(str, bitrate, mapset)
    bin_send = str2bin(str, mapset);
    signal_send = coding_freq(bin_send, bitrate);

    thold = 2;
    nStep = 0.02;

    for noise = nStep:nStep:2
        for i = 1:100
            signal_receive = signal_send + noise * randn(size(signal_send));
            bin_receive = decoding_freq(signal_receive, bitrate);
            str_receive = bin2str(bin_receive, mapset);
            if ~strcmp(str, str_receive)
                thold = noise - nStep;
                return
            end
        end
    end
end

function error = fixed_noise_error(str, bitrate, noise, mapset, char_bin_len)
    bin_send = str2bin(str, mapset);
    signal_send = coding_freq(bin_send, bitrate);

    errors = 0;
    test_count = 1000;
    total_parts_count = test_count * ceil(length(str) * char_bin_len / bitrate);

    for i = 1:test_count
        signal_receive = signal_send + noise * randn(size(signal_send));
        bin_receive = decoding_freq(signal_receive, bitrate);

        for j = 1:bitrate:length(bin_send) - bitrate
            if ~strcmp(bin_send(j:j + bitrate - 1), bin_receive(j:j + bitrate - 1))
                errors = errors + 1;
            end
        end

        % Check last part
        padding = mod(bitrate - mod(length(bin_send), bitrate), bitrate);
        if ~strcmp(bin_send(j + bitrate:end), bin_receive(j + bitrate:end - padding))
            errors = errors + 1;
        end
    end

    error = errors * 100 / total_parts_count;
end
