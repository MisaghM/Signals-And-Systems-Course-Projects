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
fixed_noise = 0.5;

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

for bitrate = 1:3
    error = fixed_noise_error(str, bitrate, fixed_noise, mapset, char_bin_len);
    disp(['Error (bitrate=', num2str(bitrate), ', noise=', num2str(fixed_noise), '): ', num2str(error), '%'])
end

%% 3.7 Noise threshold

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
        t = 0:(1 / fs):(ceil(length(str) * char_bin_len / bitrate) - 1 / fs);

        subplot(length(bitrates), 1, bitrate)
        plot(t, x)
        title(['Bitrate = ', num2str(bitrate), ', Noise = ', num2str(noise)])
    end
end

function thold = noise_threshold(str, bitrate, mapset)
    bin_send = str2bin(str, mapset);
    signal_send = coding_amp(bin_send, bitrate);

    thold = 2;
    nStep = 0.02;

    for noise = nStep:nStep:2
        for i = 1:100
            signal_receive = signal_send + noise * randn(size(signal_send));
            bin_receive = decoding_amp(signal_receive, bitrate);
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
    signal_send = coding_amp(bin_send, bitrate);

    errors = 0;
    test_count = 1000;
    total_parts_count = test_count * ceil(length(str) * char_bin_len / bitrate);

    for i = 1:test_count
        signal_receive = signal_send + noise * randn(size(signal_send));
        bin_receive = decoding_amp(signal_receive, bitrate);

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
