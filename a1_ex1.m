%% clean up
clear all; close all;
clc;
%% load data
data = load("./es1_emg/ES1_emg.mat").Es1_emg.matrix;
emg = data(:,1);

fs = 2000;                      % sammple frequency
t = 0:1/fs:(length(emg)-1)/fs;  % time vector
%% bandpass filter design 30Hz-450Hz
bpfilt = designfilt('bandpassiir', ...
    'FilterOrder',20,'HalfPowerFrequency1',30, ...
    'HalfPowerFrequency2',450,'SampleRate',2000);

% filter emg signal
emg_bp = filtfilt(bpfilt,emg);

%% rectify the signal
emg_rect = abs(emg_bp);

%% lowpass filter for emg envelop

lpfilt = fir1(100,3/1000,'low');
emg_envelope = filtfilt(lpfilt,1,emg_rect);

%% Down-sample the envelope
f_downsampling = 20;
emg_downsample = downsample(emg_envelope, fs/f_downsampling);
% time vector for downsampled emg signal
t_downsampling = 0:1/f_downsampling:(length(emg_downsample)-1)/f_downsampling;

% %% plot emg envelop and motion data
% subplot_titles = ["Deltoid Accelerometer - X",
%                   "Deltoid Accelerometer - Y",
%                   "Deltoid Accelerometer - Z",
%                   "Deltoid EMG envelop"];
% figure();
% for i=1:3
%     subplot(4,1,i);
%     plot(t, data(:,i+1));
%     subtitle(subplot_titles(i));
%     xlabel("time [s]");
%     grid on;
% end
% subplot(4,1,4);
% plot(t_downsampling, emg_downsample);
% subtitle(subplot_titles(4));
% xlabel("time [s]");
% grid on;

%% plot emg pre-processed
figure();
tiledlayout("flow");

nexttile([1,1]);
plot(t, emg); hold on;
plot(t, emg_bp, 'r');
grid on;
title("emg bandpassed 30Hz-450Hz");
xlabel("time [s]");
legend(["raw emg","bp emg"]);

nexttile([1,1]);
plot(t, emg_rect); hold on;
plot(t, emg_envelope, 'g');
grid on;
title("emg envelope");
xlabel("time [s]");
legend(["rectified emg", "emg envelope"]);

nexttile([1,2]);
a_y_detrend = detrend(data(:,3));
a_y = (a_y_detrend - min(a_y_detrend)) / max(a_y_detrend - min(a_y_detrend));
plot(t, a_y); hold on;
plot(t_downsampling, emg_downsample / max(emg_downsample),'r');
grid on;
title("acceleration Y with EMG envelop");
xlabel("time [s]");
legend(["Deltoid acceleration Y","EMG envelop"]);