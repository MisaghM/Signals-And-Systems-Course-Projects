function signal = coding_amp(bin_msg, bitrate)
    fs = 100;

    zero_padding = mod(bitrate - mod(length(bin_msg), bitrate), bitrate);
    bin_msg = [bin_msg, zeros(1, zero_padding)];
    bin_split = reshape(bin_msg, bitrate, [])';

    coeffs = 0:(1 / (pow2(bitrate) - 1)):1;
    [tStart, tEnd, tStep] = deal(0, 1 - 1/fs, 1/fs);
    signal_parts = zeros(length(bin_split), fs);

    for i = 1:length(bin_split)
        t = tStart:tStep:tEnd;

        coeff = coeffs(bin2dec(char(bin_split(i, :) + '0')) + 1);
        signal_parts(i, :) = coeff * sin(2 * pi * t);

        tStart = tStart + 1;
        tEnd = tEnd + 1;
    end

    signal = reshape(signal_parts', 1, []);
end
