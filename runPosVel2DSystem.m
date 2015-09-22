close all; clear all; clc
% Use 2D state system (rotation angle and rate)

% Simulation Parameters
t_0 = 0.0;
t_end = 10.0;
dt = 0.1; % Time step
num_steps = ceil((t_end - t_0) / dt);

% Standard deviation of measurement noise
noiseStdDev = [0.01;
			   0.01];

% Initialise the system
theta_0 = 0.0;
omega_0 = 0.1;
sys_inertia = 1.0;
System = RotationBody2D();
System.setPos(theta_0);
System.setVel(omega_0);
System.setInertia(sys_inertia);

% KF Parameters
F = [1, dt
	 0, 1];
B = [0;
     0];
H = eye(2);

% Initialisation of KF
x_0 = [0;
       0];
P_0 = 0.1 * eye(2);
KF = KalmanFilter(F, B, H);
KF.reset(x_0, P_0)

% Logging outputs
time = [t_0];
x_pred = [x_0]; % KF predictions
x_est = [x_0]; % KF corrected estimate
x = [theta_0;
	 omega_0]; % Exact state of system

% Simulate rotating system and run KF
for i = 1:(num_steps + 1)
	time = [time, i * dt];
	System.update(0, dt);

	x = [x, System.measurePosVel([0; 0])];

	KF.predict(0, 0);
	x_pred = [x_pred, KF.x];

	KF.measure(System.measurePosVel(noiseStdDev), 0.5 * eye(2));
	x_est = [x_est, KF.x];
end

plot_KF_results(time, x, x_pred, x_est, ['Position'; 'Velocity'])
