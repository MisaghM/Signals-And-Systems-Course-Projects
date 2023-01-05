%% Part 2

clear
close all
clc

%% 2.1

fs = 50;
[tStart, tEnd, tStep] = deal(-1, 1, 1 / fs);
t = tStart:tStep:tEnd - tStep;
N = length(t);
f = (-fs / 2):(fs / N):(fs / 2 - fs / N);

x = dirac(t);
x(x == inf) = 1;
y = fftshift(fft(x));

figure('Name', 'Dirac Delta')
subplot(2, 1, 1)
plot(t, x)
xlabel('Time (s)')
ylabel('x_6')
title('\delta(t)')
subplot(2, 1, 2)
plot(f, abs(y) / max(abs(y)))
xlabel('Frequency (Hz)')
ylabel('y_6')
title('FFT(x_6)')

%% 2.2

fs = 50;
[tStart, tEnd, tStep] = deal(-1, 1, 1 / fs);
t = tStart:tStep:tEnd - tStep;
N = length(t);
f = (-fs / 2):(fs / N):(fs / 2 - fs / N);

x = ones(1, N);
y = fftshift(fft(x));

figure('Name', 'Constant Function')
subplot(2, 1, 1)
plot(t, x)
xlabel('Time (s)')
ylabel('x_7')
title('x(t) = 1')
subplot(2, 1, 2)
plot(f, abs(y) / max(abs(y)))
xlabel('Frequency (Hz)')
ylabel('y_7')
title('FFT(x_7)')
