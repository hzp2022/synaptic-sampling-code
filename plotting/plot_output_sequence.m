function plot_output_sequence(neuron_labels,sim_test,output_neurons_num,num_data,pattern_length,figure_name)
% 绘制输出脉冲序列。
% 
% 输入：
%   neuron_labels:     各输出神经元所代表的标签
%   output_sequence:   输出脉冲序列（一般是将多个输出脉冲序列拼成一个长脉冲序列，注意时间的连续性）
%   output_neurons_num:输出神经元的数量
%   num_test_sets:     待绘制数据集中的数据数量
%   pattern_length:    模式时间长度
%   figure_name:       保存图像时的文件名称
% 



%% 预处理
    % 从sim数据集中获取所有自由运行数据的输出脉冲序列（最后一次迭代首次模拟得到的sim_free）
    output_sequence = cell(length(sim_test),1);
    for s = 1:length(sim_test)
        cur_output_sequence = sim_test{s}.Zt;
        output_sequence{s,1} = cur_output_sequence;
    end

    % 将指定sim数据的所有output_sequence拼接（时间上连续）
    for y = 1:length(output_sequence)
        output_sequence{y}(1,:) = neuron_labels(output_sequence{y}(1,:));  % 映射各输出神经元所代表的标签（可视化时调整坐标轴标签）
        if y ~= 1
            output_sequence{y}(3,:) = output_sequence{y}(3,:) + pattern_length*(y-1);
        end
    end 


    % 设置刻度
    x_ticks = 0:pattern_length*10:pattern_length*num_data;
    y_ticks = 1:output_neurons_num;
    
    % 设置每个输出神经元的颜色
    colors = hsv(output_neurons_num);
    % 初始化错误脉冲颜色
    error_color = [0 0 0];
    
    % 创建画布
    figure();
    hold on;

%% 不调整坐标轴标签的版本
%     
%     % 遍历每个元胞
%     for i = 1:numel(output_sequence)
%         % 获取输出神经元索引和脉冲时间
%         neuron_index = output_sequence{i}(1,:);
%         pulse_times = output_sequence{i}(2,:);
%         
%         for j = 1:numel(neuron_index)
%             % 计算横坐标
%             x = pulse_times(j) * 1000;
%             y = neuron_index(j);
%             line([x x], [y-0.3 y+0.3], 'Color', colors(y,:), 'LineWidth', 0.5);
%             
%             % 判断是否在200ms内
%             if x >= x_ticks(neuron_labels(neuron_index(j))) && x < x_ticks(neuron_labels(neuron_index(j))+1)
%                 % 绘制小竖线
%                 y = neuron_index(j);
%                 line([x x], [y-0.4 y+0.4], 'Color', colors(y,:), 'LineWidth', 0.5);
%             else
%                 % 绘制错误脉冲
%                 y = neuron_index(j);
%                 line([x x], [y-0.4 y+0.4], 'Color', error_color, 'LineWidth', 0.5);
%             end
%         end
%     end
%     
%     % 设置坐标轴
%     xlim([0 pattern_length*1000*num_data]);
%     % xticks(x_ticks);
%     xticklabels(x_ticks);
%     ylim([0.5 output_neurons_num+0.5]);
%     yticks(y_ticks);
%     yticklabels(cellstr(num2str(neuron_labels')));
%     
%     % 添加标签
%     xlabel('Time [ms]');
%     ylabel('Output Neurons');
%     title(figure_name);
%     
%     save_fig( gcf, figure_name );

%% 调整坐标轴标签的版本
    % 遍历每个元胞
    for i = 1:numel(output_sequence)
        % 获取输出神经元索引和脉冲时间
        neuron_index = output_sequence{i}(1,:);
        pulse_times = output_sequence{i}(3,:);
        
        for j = 1:numel(neuron_index)
            % 计算横坐标
            x = pulse_times(j);
            y = neuron_index(j);
            line([x x], [y-0.3 y+0.3], 'Color', colors(y,:), 'LineWidth', 0.5);
            
            % 判断是否在200ms内
            if output_sequence{i}(1,j) == output_sequence{i}(2,j)
%             if x >= x_ticks(neuron_labels(neuron_index(j))) && x < x_ticks(neuron_labels(neuron_index(j))+1)
                % 绘制小竖线
                y = neuron_index(j);
                line([x x], [y-0.3 y+0.3], 'Color', colors(y,:), 'LineWidth', 0.5);
            else
                % 绘制错误脉冲
                y = neuron_index(j);
                line([x x], [y-0.3 y+0.3], 'Color', error_color, 'LineWidth', 0.5);
            end
        end
    end
    
    % 设置坐标轴
    xlim([0 pattern_length*num_data]);
    xticks(x_ticks);
    xticklabels(x_ticks);
    ylim([0.5 output_neurons_num+0.5]);
    yticks(y_ticks);
    yticklabels(y_ticks);
    
    % 添加标签
    xlabel('Time [s]');
    ylabel('Output Neurons');
    title(figure_name);
    
    save_fig( gcf, figure_name );

end
