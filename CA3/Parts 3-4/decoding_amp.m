function binary = decoding_amp(signal, bitrate)
    fs = 100;

    parts_count = length(signal) / fs;
    binary = blanks(parts_count * bitrate);

    [tStart, tEnd, tStep] = deal(0, 1 - 1/fs, 1/fs);
    signal_parts = reshape(signal, [], parts_count)';

    for i = 1:parts_count
        t = tStart:tStep:tEnd;

        y = 2 * sin(2 * pi * t);
        x = signal_parts(i, :);

        x(x > 1) = 1;
        x(x < -1) = -1;

        corr_integral = trapz(x .* y) / fs;
        corr_integral = abs(corr_integral);

        closest = round(corr_integral * (pow2(bitrate) - 1));
        num = dec2bin(closest, bitrate);
        binary(bitrate * (i - 1) + 1:bitrate * (i - 1) + bitrate) = num;

        tStart = tStart + 1;
        tEnd = tEnd + 1;
    end
end
