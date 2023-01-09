function binary = decoding_freq(signal, bitrate)
    fs = 100;

    parts_count = length(signal) / fs;
    binary = blanks(parts_count * bitrate);
    signal_parts = reshape(signal, [], parts_count)';

    freq_count = 2 ^ bitrate;
    freqs = fs / (4 * freq_count):fs / (2 * freq_count):(fs / 2 - fs / (4 * freq_count));
    freqs = floor(freqs);

    for i = 1:parts_count
        x = signal_parts(i, :);

        x(x > 1) = 1;
        x(x < -1) = -1;

        ft = abs(fftshift(fft(x)));
        [max_val, idx] = max(ft);
        freq = fs/2 + 1 - idx;

        [~, closest] = min(abs(freqs - freq));

        num = dec2bin(closest - 1, bitrate);
        if max_val == 0
            num = '00000';
        end
        binary(bitrate * (i - 1) + 1:bitrate * (i - 1) + bitrate) = num;
    end
end
