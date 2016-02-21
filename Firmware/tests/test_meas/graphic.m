function graphic( data, Fs)
%GRAFIC Summary of this function goes here
%   Detailed explanation goes here

NFFT = 2^nextpow2(length(data));

y = fft(data,NFFT)/length(data);

f = Fs/2*linspace(0,1,NFFT/2+1);

figure();
subplot(2,1,1);
plot(f,20*log10(abs(y(1:NFFT/2+1))),'k','LineWidth',1.5);
xlim([0 Fs/2]);
grid;

subplot(2,1,2);
plot(f,unwrap(angle(y(1:NFFT/2+1))),'k','LineWidth',1.5);
xlim([0 Fs/2]);
grid;

end
