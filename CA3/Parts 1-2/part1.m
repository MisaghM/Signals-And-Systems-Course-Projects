%% Part 1

clear
close all
clc

%% 1.0

fs = 20;
[tStart, tEnd, tStep] = deal(0, 1, 1 / fs);
t = tStart:tStep:tEnd - tStep;
N = length(t);
f = 0:(fs / N):((N - 1) * fs / N);
x1 = exp(1j * 2 * pi * 5 * t) + exp(1j * 2 * pi * 8 * t);
x2 = exp(1j * 2 * pi * 5 * t) + exp(1j * 2 * pi * 5.1 * t);
y1 = fft(x1);
y2 = fft(x2);

figure('Name', 'Frequency Resolution')
subplot(2, 1, 1)
plot(f, abs(y1) / max(abs(y1)))
xlabel('Frequency (Hz)')
ylabel('y_1')
title('FFT(x_1)')
subplot(2, 1, 2)
plot(f, abs(y2) / max(abs(y2)))
xlabel('Frequency (Hz)')
ylabel('y_2')
title('FFT(x_2)')

%% 1.1

fs = 50;
[tStart, tEnd, tStep] = deal(-1, 1, 1 / fs);
t = tStart:tStep:tEnd - tStep;
N = length(t);
f = (-fs / 2):(fs / N):(fs / 2 - fs / N);
x1 = cos(2 * pi * 5 * t);
y1 = fftshift(fft(x1));

figure('Name', 'cos(10\pi t)')
subplot(2, 1, 1)
plot(t, x1)
xlabel('Time (s)')
ylabel('x_1')
title('cos(10\pi t)')
subplot(2, 1, 2)
plot(f, abs(y1) / max(abs(y1)))
xlabel('Frequency (Hz)')
ylabel('y_1')
title('FFT(x_1)')

%% 1.2

fs = 50;
[tStart, tEnd, tStep] = deal(-1, 1, 1 / fs);
t = tStart:tStep:tEnd - tStep;
N = length(t);
f = (-fs / 2):(fs / N):(fs / 2 - fs / N);
x2 = rectangularPulse(t);
y2 = fftshift(fft(x2));

figure('Name', '\Pi(t)')
subplot(2, 1, 1)
plot(t, x2)
xlabel('Time (s)')
ylabel('x_2')
title('\Pi(t)')
subplot(2, 1, 2)
plot(f, abs(y2) / max(abs(y2)))
xlabel('Frequency (Hz)')
ylabel('y_2')
title('FFT(x_2)')

%% 1.3

fs = 50;
[tStart, tEnd, tStep] = deal(-1, 1, 1 / fs);
t = tStart:tStep:tEnd - tStep;
N = length(t);
f = (-fs / 2):(fs / N):(fs / 2 - fs / N);
x3 = x1 .* x2;
y3 = fftshift(fft(x3));

figure('Name', 'cos(10\pi t) \Pi(t)')
subplot(2, 1, 1)
plot(t, x3)
xlabel('Time (s)')
ylabel('x_3')
title('cos(10\pi t) \Pi(t)')
subplot(2, 1, 2)
plot(f, abs(y3) / max(abs(y3)))
xlabel('Frequency (Hz)')
ylabel('y_3')
title('FFT(x_3)')

%% 1.4

fs = 100;
[tStart, tEnd, tStep] = deal(0, 1, 1 / fs);
t = tStart:tStep:tEnd - tStep;
N = length(t);
f = 0:(fs / N):((N - 1) * fs / N);
x4 = cos(2 * pi * 15 * t + 0.25 * pi);
y4 = fft(x4);
smallValue = 1e-6;
y4(abs(y4) < smallValue) = 0;
theta4 = angle(y4);

figure('Name', 'cos(30\pi t + \pi/4)')
subplot(2, 1, 1)
plot(f, abs(y4) / max(abs(y4)))
xlabel('Frequency (Hz)')
ylabel('y_4')
title('FFT(x_4)')
subplot(2, 1, 2)
plot(f, theta4 / pi)
xlabel('Frequency (Hz)')
ylabel('\theta_4/\pi')
title('Phase of FFT(x_4)')

%% 1.5

fs = 50;
[tStart, tEnd, tStep] = deal(-19, 19, 1 / fs);
t = tStart:tStep:tEnd - tStep;
N = length(t);
f = (-fs / 2):(fs / N):(fs / 2 - fs / N);
x5 = zeros(1, N);
for k = -9:9
    x5 = x5 + rectangularPulse(t - 2 * k);
end
y5 = fftshift(fft(x5));

figure('Name', 'Rectangular Pulse Train')
subplot(2, 1, 1)
plot(t, x5)
xticks(-20:2:20)
xlabel('Time (s)')
ylabel('x_5')
title('\Pi(t - 2k)')
subplot(2, 1, 2)
plot(f, abs(y5) / max(abs(y5)))
xlabel('Frequency (Hz)')
ylabel('y_5')
title('FFT(x_5)')
