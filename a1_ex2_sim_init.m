
%% clean up
clear; clc;
close all;

%% load data
data = load("./es2_emg/ES2_emg.mat").ES2_emg;

% workspace variable for simulink model
Ts = 1e-3;  % sample time [s]
fs = 1/Ts;  % sample frequency [Hz]

% muscle emg signals
time = data.time;
biceps_right = [time, data.signals(:,1)];
biceps_left = [time, data.signals(:,2)];
trapezius_right = [time, data.signals(:,3)];
trapezius_left = [time, data.signals(:,4)];

%% bandpass FIR filter design for extract muscle signal 30-450Hz
rp_bp = 1;      % passband ripple [dB]
rs_bp = 40;     % stopband ripple [dB]
f_bp = [20 30 450 460]; % filter frequency characteristics
a_bp = [0 1 0];         % filter gains with respect to frequency

% convert ripples from dB to linear scale
rp_bp_lin = (10^(rp_bp/20)-1)/(10^(rp_bp/20)+1);
rs_bp_lin = 10^(-rs_bp/20);

% design bandpass filter
dev_bp = [rs_bp_lin rp_bp_lin rs_bp_lin];
[n_bp,fo_bp,ao_bp,w_bp] = firpmord(f_bp,a_bp,dev_bp,fs);
filter_coeff_bp = firpm(n_bp,fo_bp,ao_bp,w_bp);

%% lowpass FIR filter design for EMG envelop 3-6Hz -> 5
rp_lp = 3;      % bandpass ripple [dB]
rs_lp = 80;     % stopband ripple [dB]
f_lp = [3 10];  % [bandpass stopband]
a_lp = [1 0];   % filter gains with respect to frequency

% convert ripples from dB to linear scale
rp_lp_lin = (10^(rp_lp/20)-1)/(10^(rp_lp/20)+1);
rs_lp_lin = 10^(-rs_lp/20);

% design lowpass filter
dev_lp = [rp_lp_lin rs_lp_lin];
[n_lp,fo_lp,ao_lp,w_lp] = firpmord(f_lp,a_lp,dev_lp,fs);
filter_coeff_lp = firpm(n_lp,fo_lp,ao_lp,w_lp);

%% threshold definition for north-south-est-west & n-e, n-w, s-e, s-w
th1_biceps_right = 0.09;
th1_biceps_left = 0.09;
th1_trapezius_right = 0.08;
th1_trapezius_left = 0.055;

% slew rate constants for cursor movement
rate_limit_rising = 2;
rate_limit_falling = -2;

%% rotation matrix for n-e, n-w, s-e, s-w directions
theta = deg2rad(45);
R = [cos(theta) -sin(theta) 0;
     sin(theta)  cos(theta) 0;
         0            0     1];

%%
disp("init loaded");
