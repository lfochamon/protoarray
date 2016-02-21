MSG_SIZE = 1000*1024;
Fs = 16e3;

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

% Remove transient from the begining
mic = mic(:,200:end);


% Plot
t = (0:size(mic,2)-1)/Fs;

figure();

% % Channel 1
% subplot(2,4,1);
% plot(t, mic(1,:));
% grid;
% ylabel('Amplitude [V]');
% xlabel('Time [s]');
% title('Channel 1');
% 
% % Channel 2
% subplot(2,4,2);
% plot(t, mic(2,:));
% grid;
% ylabel('Amplitude [V]');
% xlabel('Time [s]');
% title('Channel 2');
% 
% % Channel 3
% subplot(2,4,3);
% plot(t, mic(3,:));
% grid;
% ylabel('Amplitude [V]');
% xlabel('Time [s]');
% title('Channel 3');
% 
% % Channel 4
% subplot(2,4,4);
% plot(t, mic(4,:));
% grid;
% ylabel('Amplitude [V]');
% xlabel('Time [s]');
% title('Channel 4');
% 
% % Channel 5
% subplot(2,4,5);
% plot(t, mic(5,:));
% grid;
% ylabel('Amplitude [V]');
% xlabel('Time [s]');
% title('Channel 5');
% 
% % Channel 6
% subplot(2,4,6);
% plot(t, mic(6,:));
% grid;
% ylabel('Amplitude [V]');
% xlabel('Time [s]');
% title('Channel 6');

% Channel 7
% subplot(2,4,7);
plot(t, mic(7,:));
grid;
ylabel('Amplitude [V]');
xlabel('Time [s]');
title('Channel 7');

mic7 = mic(7,:)-mean(mic(7,:));
mic7 = 0.4*mic7/max(mic7);
player = audioplayer(mic7, Fs);
play(player);

% fanalysis(mic(7,:)-mean(mic(7,:)), Fs, 20);

% % Channel 8
% subplot(2,4,8);
% plot(t, mic(8,:));
% grid;
% ylabel('Amplitude [V]');
% xlabel('Time [s]');
% title('Channel 8');
