function data_set = plot_free_set_hist( data_set, seq_id, lbls )
% 绘制自由数据集直方图。如果给定了一个字符串，则从它所指向的文件中加载数据结构。
%
% 输入：
%   data_set：包含了模型训练和测试数据的数据结构。如果传入一个字符串，则会从该字符串对应的文件中加载数据结构。
%   seq_id：  表示要绘制哪个自由运行序列的编号。
%   lbls：    可选的神经元标签字符串数组，它可以被用于覆盖默认的标签。如果未提供lbls参数，则函数将使用get_neuron_labels函数获取神经元标签。
% 
% 输出：
%   data_set：处理后的数据集结构。
% 
% 处理逻辑：
%   1.对data_set进行一些预处理，包括使用 sort_neurons_seq 函数对神经元进行排序，使用 get_neuron_labels 函数获取神经元标签等。
%   2.根据输入的 seq_id 参数获取该序列的数据，并对其进行处理
%   3.使用 plot_data_hist 函数将数据可视化出来
% 
% 辅助函数：
%   sort_neurons_seq，get_neuron_labels，plot_data_hist
% 

    idx = sort_neurons_seq( data_set.sim_test, data_set.net.num_neurons );

    if isfield( data_set, 'train_set_generator' )
        data_set.pat_labels = data_set.train_set_generator.pat_labels;
    end
    
    % FIXMEEE
    data_set.pat_labels = { 'A', 'B', 'C', 'D', 'E', 'a', 'b', 'c', 'd', '' };
    
    if (nargin < 3)
        lbls = get_neuron_labels( data_set.sim_test, data_set.net.num_neurons, data_set.pat_labels );
    end
    
    sim_data = data_set.sim_free{seq_id};
    
    for i = length( sim_data.labels ):-1:1
        
        if ( sim_data.labels(i).stop_sample - sim_data.labels(i).start_sample ) > 1
            break;
        end
    end
    
    sim_data.labels = sim_data.labels(1:i);

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
    
    if isfield( data_set.net, 'groups' )
        groups = data_set.net.groups;
    else
        groups = struct;
    end
    
    plot_data_hist( sim_data, data_set.net.num_neurons, ...
                    data_set.net.num_inputs, idx, 1, lbls, ...
                    data_set.pat_labels, colors, groups );

    drawnow;
end
