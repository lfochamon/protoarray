function G = fanalysis(X,FS, Nd)

% Frequency analysis using PSD through Welch method
% X - First signal
% Y - Second signal (0 if no cross-spectrum is necessary)
% Nd - Number of segments to average
% N - Number of points per segment (0 if number of segments is set)
% FS - Sampling frequency

N = 2*length(X)/(Nd + 1);
N = 2^floor(log2(N));

OVERLAP = N/2;

Nd = 2*(length(X) - OVERLAP)/N;

eps = 1/Nd;

fprintf('\nError of the spectrum estimate:\n');
fprintf('\n %f <= G/G^ <= %f \n',1/(1+2*eps^0.5),1/(1-2*eps^0.5));

X = X - mean(X);

% ----------------------Gx,x
[G, f] = pwelch(X,N,OVERLAP,N,FS);

figure();
plot(f,10*log10(abs(G)));
grid;
xlim([0 FS/2]);
xlabel('Frequency');
ylabel('dB');
title('G_{x,x}');

end

