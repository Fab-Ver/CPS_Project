function plot_estimation_errors_by_state(x_hat_all, x_ref_col, t, observer_type)
    % Estimation Error
    state_estimation_error = abs(squeeze(x_ref_col - x_hat_all));  % [12 x N]
    
    % Parameters
    N_agents = 6;
    n_states = 2;
    colors = lines(N_agents);

    % State 1
    figure; hold on; grid on;
    for i = 1:N_agents
        idx = (i-1)*n_states + 1;
        plot(t, state_estimation_error(idx, :), '-', 'Color', colors(i, :), ...
            'DisplayName', sprintf('|e_1| (agent %d)', i), 'LineWidth', 1.5);
    end
    xlabel('Time [s]');
    ylabel('Estimation Error');
    title(sprintf('Position Estimation Error [%s Observer]', observer_type));
    legend('Location', 'bestoutside');

    % State 2
    figure; hold on; grid on;
    for i = 1:N_agents
        idx = (i-1)*n_states + 2;
        plot(t, state_estimation_error(idx, :), '-', 'Color', colors(i, :), ...
            'DisplayName', sprintf('|e_2| (agent %d)', i), 'LineWidth', 1.5);
    end
    xlabel('Time [s]');
    ylabel('Estimation Error');
    title(sprintf('Velocity Estimation Error [%s Observer]', observer_type));
    legend('Location', 'bestoutside');

end