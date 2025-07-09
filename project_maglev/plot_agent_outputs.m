function plot_agent_outputs(y_i_all, y_ref, t, observer_type, Q, R, noise, c_factor)
    % Plot agent outputs against reference in a single plot
    % y_i_all: individual agent outputs [N x 1 x time] or [N x time]
    % y_ref: reference signal [time x 1]
    % t: time vector [time x 1]
    % observer_type: 'cooperative' or 'local'
    % Q: Q matrix parameter (could be a scalar or matrix)
    % R: R parameter value
    % noise: noise parameter value
    
    % Handle different possible dimensions
    if ndims(y_i_all) == 3
        N = size(y_i_all, 1);
        y_i_reshaped = squeeze(y_i_all);
    else
        N = size(y_i_all, 1);
        y_i_reshaped = y_i_all;
    end
    
    % Create figure
    fig = figure('Name', ['Outputs vs Reference - ' observer_type], 'Position', [100 100 800 500]);
    
    % Plot individual agent outputs (y_i)
    hold on;
    colors = lines(N);
    for i = 1:N
        plot(t, y_i_reshaped(i,:), 'LineWidth', 1.5, 'Color', colors(i,:));
    end
    
    % Add reference line
    plot(t, y_ref, 'k--', 'LineWidth', 2);
    hold off;
    
    grid on;
    legend([arrayfun(@(i) ['Agent ' num2str(i)], 1:N, 'UniformOutput', false), 'Reference'], 'Location', 'best');
    title(['Agent Outputs vs Reference - ' observer_type]);
    xlabel('Time [s]');
    ylabel('Output');
    ylim([min(min(y_i_reshaped(:)), min(y_ref))-0.5, max(max(y_i_reshaped(:)), max(y_ref))+0.5]);
    
    % Calculate and display metrics
    mean_abs_error = mean(abs(y_i_reshaped - repmat(y_ref', N, 1)), 2);
    annotation('textbox', [0.15, 0.01, 0.7, 0.05], 'String', ...
        ['Mean Absolute Error by agent: ' num2str(mean_abs_error')], ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center');
    
    % Format parameters for filename
    if isnumeric(Q) && numel(Q) > 1
        % If Q is a matrix, use its trace
        Q_val = trace(Q);
    else
        Q_val = Q;
    end
    
   % Update the filename to include c_factor
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    filename = sprintf('results/img/agent_outputs_%s_Q%.0f_R%.1f_n%.3f_c%.1f_%s.png', ...
        observer_type, Q_val, R, noise, c_factor, timestamp);
    saveas(fig, filename);
    fprintf('Figure saved as: %s\n', filename);
end