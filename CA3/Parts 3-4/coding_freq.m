function signal = coding_freq(bin_msg, bitrate)
    fs = 100;

    zero_padding = mod(bitrate - mod(length(bin_msg), bitrate), bitrate);
    bin_msg = [bin_msg, zeros(1, zero_padding) + '0'];
    bin_split = reshape(bin_msg, bitrate, [])';

    freq_count = 2 ^ bitrate;
    freqs = fs / (4 * freq_count):fs / (2 * freq_count):(fs / 2 - fs / (4 * freq_count));
    freqs = floor(freqs);

    [tStart, tEnd, tStep] = deal(0, 1 - 1 / fs, 1 / fs);
    signal_parts = zeros(size(bin_split, 1), fs);

    for i = 1:size(bin_split, 1)
        t = tStart:tStep:tEnd;

        freq = freqs(bin2dec(bin_split(i, :)) + 1);
        signal_parts(i, :) = sin(2 * pi * freq * t);

        tStart = tStart + 1;
        tEnd = tEnd + 1;
    end

    signal = reshape(signal_parts', 1, []);
end
