%% Part 1

clear;
close all;
clc;

%% 1.0

fs = 20;
[tStart, tEnd, tStep] = deal(0, 1, 1 / fs);
t = tStart:tStep:tEnd - tStep;
N = length(t);
f = 0:fs / N:(N - 1) * fs / N;
x1 = exp(1j * 2 * pi * 5 * t) + exp(1j * 2 * pi * 8 * t);
x2 = exp(1j * 2 * pi * 5 * t) + exp(1j * 2 * pi * 5.1 * t);
y1 = fft(x1);
y2 = fft(x2);

figure('Name', 'Frequency Resolution');
subplot(2, 1, 1);
plot(f, abs(y1) / max(abs(y1)));
xlabel('Frequency (Hz)');
ylabel('y1');
title('FFT(x1)');
subplot(2, 1, 2);
plot(f, abs(y2) / max(abs(y2)));
xlabel('Frequency (Hz)');
ylabel('y2');
title('FFT(x2)');

%% 1.1

fs = 50;
[tStart, tEnd, tStep] = deal(-1, 1, 1 / fs);
t = tStart:tStep:tEnd - tStep;
N = length(t);
f = -fs / 2:fs / N:fs / 2 - fs / N;
x = cos(2 * pi * 5 * t);
y = fftshift(fft(x));

figure('Name', 'Fourier Transform');
subplot(2, 1, 1);
plot(t, x);
xlabel('Time (s)');
ylabel('x');
title('cos(10\pi t)');
subplot(2, 1, 2);
plot(f, abs(y) / max(abs(y)));
xlabel('Frequency (Hz)');
ylabel('y');
title('FFT(x)');
