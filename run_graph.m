% setup simulation
delta_t = 0.1; % [s]
simulation_duration = 30; % [s]

inertia = [1, 1.1, 1.2];
initial_rate = [0.01; 0.3; 0];
measurement_noise = 4/180*pi; % standard deviation of noise on vector components
perturbation_torque = 0.01;

rate_gyro_white_noise_deg_p_s = 0.03; % [deg/s/sqrt(Hz)]
rate_gyro_white_noise = rate_gyro_white_noise_deg_p_s/180*pi; % [rad/s/sqrt(Hz)]
rate_gyro_bias_instability_deg_p_s = 0.003; % [deg/s]
rate_gyro_bias_instability_time = 200; % [s]
rate_gyro_bias_random_walk_white_noise = (rate_gyro_bias_instability_deg_p_s/sqrt(rate_gyro_bias_instability_time))/180*pi; % [rad/s/sqrt(Hz)]

filter_model = 'mekf_gyro' % one of 'mekf_cst_mom', 'mekf_gyro', 'basic'


nb_runs = 5
att_error_graphs = zeros(nb_runs, simulation_duration/delta_t);
rate_error_graphs = zeros(nb_runs, simulation_duration/delta_t);

for run_i = 1:nb_runs
    sim = Simulation3DBody(filter_model, ...
                           delta_t, ...
                           inertia, ...
                           initial_rate, ...
                           measurement_noise, ...
                           perturbation_torque, ...
                           rate_gyro_white_noise, ...
                           rate_gyro_bias_random_walk_white_noise);

    idx = 1;
    for t = 0:delta_t:simulation_duration

        att_err = quatmult(sim.body.getAttitude, quatconj(sim.kalman.get_attitude));
        att_err = asin(norm(att_err(2:4)))*2;
        att_err_deg = att_err * 180 / pi;
        att_error_graphs(run_i, idx) = att_err_deg;

        rate_err = norm(sim.body.getRate() - sim.kalman.get_omega);
        rate_err_deg_per_sec = rate_err * 180 / pi;
        rate_error_graphs(run_i, idx) = rate_err_deg_per_sec;


        idx = idx+1;
        sim.update()
    end
end

figure
semilogy(att_error_graphs')
title([strrep(filter_model, '_', ' ') ' attitude error [deg]'])

figure
semilogy(rate_error_graphs')
title([strrep(filter_model, '_', ' ') ' rate error [deg/s]'])

