function plot_conditinal_entropy(conditinal_entropy,last_iteration)
% 绘制条件熵。
% 
% 输入：
%   conditinal_entropy:条件熵
% 

    % y_ticks = 0:0.1:1;
    % x_ticks = 0:1:length(conditinal_entropy);

    plot( conditinal_entropy );
    
    % xlim([0 length(conditinal_entropy)]);
    % xticks(x_ticks);
    % xticklabels(x_ticks);
    % ylim([0 1]);
    % yticks(y_ticks);
    % yticklabels(y_ticks);
    title( 'Conditional Entropy' );
    xlabel( 'iteration' );

    if last_iteration
        save_fig( gcf, 'Conditional Entropy' );
    end

end