MSG_SIZE = 1000*1024;
Fs = 32e3;

% Load data from file
fid = fopen('buff');
x = fread(fid, inf, 'ubit8');
fclose(fid);

% Fix Linux endianess
for i = 1:4:length(x)
    x(i:i+3) = flipud(x(i:i+3));
end

mic = zeros(8,MSG_SIZE/20);
status = zeros(MSG_SIZE/20,1);
for i = 1:MSG_SIZE/100
    x_idx = (i-1)*100;
    mic_idx = (i-1)*6+1;
    
    status(i) = 2.^[24 16 8 0] * x(x_idx+1:x_idx+4);
    
    samples = reshape(x(x_idx+5:x_idx+24*4+5-1), 2, 48)'* 2.^[8 ; 0];
    mic(:,mic_idx:mic_idx+5) = reshape(samples, 8, 6);
end

% Convert two's completement
neg_idx = logical( bitshift(mic, -15) );                    % Find negative values
mic(neg_idx) = -( bitcmp(mic(neg_idx), 'uint16') + 1 );     % Update negative values

% Convert to volts
mic = mic*2.4/2^15;


% Plot
t = (0:size(mic,2)-1)/Fs;

figure();
for i = 1:8
    subplot(2,4,i);
    plot(t, mic(i,:));
end
