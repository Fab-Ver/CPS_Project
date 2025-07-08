function plot_agent_states_vs_ref(x_hat_all, x_ref_col, t, observer_type)
    % Reshape input to [12 x N]
    x_hat_all = squeeze(x_hat_all);  % [12 x N]
    x_ref_col = squeeze(x_ref_col);  % [12 x N]

    N_agents = 6;
    n_states = 2;
    colors = lines(N_agents);  % Distinct colors for agents

    %% Plot State 1
    figure; hold on; grid on;
    plot(t, x_ref_col(1, :), 'k--', 'LineWidth', 1.5, 'DisplayName', 'x_1^{ref}');
    for i = 1:N_agents
        idx = (i-1)*n_states + 1;
        plot(t, x_hat_all(i, :), '-', 'Color', colors(i, :), ...
            'DisplayName', sprintf('x_1^{hat} (agent %d)', i), 'LineWidth', 1.5);
    end
    xlabel('Time [s]');
    ylabel('State 1 Value');
    title(sprintf('State 1: Estimated vs Reference [%s Observer]', observer_type));
    legend('Location', 'bestoutside');

    %% Plot State 2
    figure; hold on; grid on;
    plot(t, x_ref_col(2, :), 'k--', 'LineWidth', 1.5, 'DisplayName', 'x_2^{ref}');
    for i = 1:N_agents
        idx = (i-1)*n_states + 2;
        plot(t, x_hat_all(idx, :), '-', 'Color', colors(i, :), ...
            'DisplayName', sprintf('x_2^{hat} (agent %d)', i), 'LineWidth', 1.5);
    end
    xlabel('Time [s]');
    ylabel('State 2 Value');
    title(sprintf('State 2: Estimated vs Reference [%s Observer]', observer_type));
    legend('Location', 'bestoutside');
end
