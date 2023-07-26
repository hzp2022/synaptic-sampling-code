function plot_free_run( data_set, seq_id )
% 将自由运行数据集中的输出神经元的输出脉冲序列进行可视化。
% 
% 输入：
%   data_set: 自由运行数据集，包含神经网络的相关信息和自由运行的输出脉冲序列等。
%   seq_id: 自由运行数据集中的序列 ID，用于指定要绘制的输出脉冲序列。
% 
% 输出：
%   返回h_fig句柄，该句柄可以用于后续的操作，例如保存图形或关闭窗口。
% 
% 辅助函数：
%   sort_neurons_seq，get_neuron_labels，get_data_labels，snn_plot
% 

    % 检查输入的 data_set 中是否包含标签，如果有则使用它，否则使用默认标签
    if isfield( data_set, 'pat_labels' )
        pat_labels = data_set.pat_labels;
%     elseif isfield( data_set.train_set_generator, 'pat_labels' )
%         pat_labels = data_set.train_set_generator.pat_labels;
    else
        pat_labels = { 'A', 'B', 'C', 'D', 'E', '' };
    end
    
    % 对神经元进行排序，得到包含按顺序排列的神经元的编号idx
    idx = sort_neurons_seq( data_set.sim_test, data_set.net.num_neurons );
    
    % 获取每个神经元的标签，这些标签将在绘图中使用
    lbls = get_neuron_labels( data_set.sim_test, data_set.net.num_neurons, pat_labels );
    
    % 设置sim_data变量，其中包含自由运行数据的所有信息
    sim_data = data_set.sim_free{seq_id};
    sim_data.idx = idx;
    sim_data.Zt_y_range = 1:data_set.net.num_neurons;
    
    start_time = 0;  % 设置start_time变量，表示绘图的起始时间
    
    Zt_l = [ sim_data.Zt(1,:); ...
             lbls( sim_data.Zt(1,:) ); ...
             sim_data.Zt(2,:) ];
    
    sim_data.Zt = [ sim_data.Zt(1,:); ...
                    lbls( sim_data.Zt(1,:) ); ...
                    sim_data.Zt(2,:) ];

    sim_data.Zt_labels = get_data_labels( Zt_l, pat_labels );                
    
    % 创建了一个h_fig图形窗口
    h_fig = figure;
    
    pos = get( h_fig, 'Position' );
    pos(3) = 400; pos(4) = 120;
    set( h_fig, 'Position', pos, 'Renderer', 'painters' );
    
    % 使用snn_plot函数绘制神经元的输出
    snn_plot( sim_data, '[ Zt[stl] ]', 'numbering', 'none', 'figure', h_fig, ...
              'start_time', start_time, 'reset_start_time', true, ...
              'axis_grid', [ 0.08, 0.28, 0.87, 0.52 ] );
          
    % xlim( [0, 1000*sim_data.time(end)-start_time-100] );
          
    xlabel( 'time [ms]' );     
    ylabel( 'output neuron' );
    
    drawnow;
end
