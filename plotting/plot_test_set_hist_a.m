function data_set = plot_test_set_hist_a( data_set, seq_id, run_id, lbls )
% 绘制测试集的直方图。
% 
% 输入：
%   data_set：数据结构，包含测试集的模拟结果。
%   seq_id：  一个整数，表示选择哪个数据序列。
%   run_id：  一个整数，表示选择哪个运行结果。
%   lbls：    可选参数，表示神经元标签的字符串数组。
% 
% 输出：
%   没有变化的data_set
% 
% 辅助函数：
%   get_neuron_labels，plot_data_hist_a
%
    
    % 将神经元的索引按照一定的顺序排列，并将测试集的模拟结果取出来
    % idx = sort_neurons_seq( data_set.sim_test, data_set.net.num_neurons );
    idx = 1:data_set.net.num_neurons; % sort_neurons_seq( data_set.sim_test, data_set.net.num_neurons );
    
    plot_data = data_set.sim_test{seq_id};
    plot_data = plot_data(run_id);
    plot_data.idx = idx;
    
    if isfield( data_set, 'pat_labels' )
        pat_labels = data_set.pat_labels;
    elseif isfield( data_set.train_set_generator, 'pat_labels' )
        pat_labels = data_set.train_set_generator.pat_labels;
    else
        pat_labels = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', '' };
    end

    % FIXMEEEEE
    pat_labels = { 'A', 'B', 'C', 'D', 'E', 'a', 'b', 'c', 'd', '' };
    
    if isfield( data_set, 'colors' )
        colors = data_set.colors;
    else
        colors =   [ 0.0, 0.0, 1.0; ... %A
                     0.0, 0.7, 0.0; ... %B
                     1.0, 0.0, 0.0; ... %C
                     0.9, 0.9, 0.0; ... %D
                     0.7, 0.7, 0.7; ... %E
                     0.8, 0.0, 0.8; ... %F
                     0.0, 0.6, 0.8; ... %G
                     0.8, 0.2, 0.2; ... 
                     0.2, 0.8, 0.2; ...
                     0.0, 0.0, 0.0; ];
    end
    
    if (nargin < 4)
        lbls = get_neuron_labels( data_set.sim_test, data_set.net.num_neurons, pat_labels );
    end
    
    % 根据输入参数中的标签信息和颜色信息绘制直方图
    plot_data_hist_a( data_set.sim_test{seq_id}, data_set.net.num_neurons, ...
                      data_set.net.num_inputs, idx, run_id, ...
                      lbls, pat_labels, colors );
    
    drawnow;
end
