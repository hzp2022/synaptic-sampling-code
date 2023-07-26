function data_set = plot_mem_task( data_set, neurons, varargin )
% 将神经元（neurons）的记忆表现（即在记忆任务中的表现）绘制成图形，并将结果存储在数据集（data_set）中。
%
% 输入：
%   data_set：一个 struct 类型的变量，存储了实验数据。
%   neurons：一个整数，表示需要可视化的神经元的数量。
%   varargin：可选参数，用于指定可视化参数。
%       'weights'：一个逻辑类型的变量，表示是否绘制权重矩阵的图形。默认为 true。
%       'patterns'：一个逻辑类型的变量，表示是否绘制模式矩阵的图形。默认为 true。
%       'raster'：一个逻辑类型的变量，表示是否绘制神经元的 raster 图。默认为 true。
%       'activity'：一个逻辑类型的变量，表示是否绘制神经元活动率随时间变化的图。默认为 true。
% 输出：
%  data_set：一个 struct 类型的变量（更新后的 data_set 变量），存储了实验数据和可视化结果。
% 
% 函数功能：
%   该函数的功能是绘制神经网络的模式存储和恢复实验的结果。输入参数 data_set 是一个 struct 类型的变量，
%   其中包含了实验数据和实验的参数设置。函数会根据 neurons 参数指定的数量，对神经网络的前 neurons 个
%   神经元进行可视化，绘制神经元的 raster 图和活动率随时间变化的图。同时，函数还会绘制权重矩阵和模式
%   矩阵的图形，用于观察神经网络的学习效果。
% 
% 辅助函数：
%   plot_raster：绘制 raster 图。
%   plot_activity：绘制神经元活动率随时间变化的图。
%   plot_weights：绘制权重矩阵的图。
%   plot_pattern：绘制模式矩阵的图。
% 

    if ischar( data_set )
        data_set = load( data_set );
    end
    
    [ num_z_neurons, ...
      max_num_trials, ...
      idx, ...
      set_name, ...
      plot_spikes, ...
      highlight_groups, ...
      seq_id, ...
      run_id, ...
      single_neuron_seq_ids, ...
      dy, ...
      peth_set, ...
      base_path, ...
      fig_file ] = snn_process_options( varargin, ...
                                        'num_neurons', [], ...
                                        'max_num_trials', 20, ...
                                        'neuron_order', [], ...
                                        'data_set', 'test_data', ...
                                        'plot_spikes', false, ...
                                        'highlight_groups', [], ...
                                        'seq_id', 1, ...
                                        'run_id', 1, ...
                                        'single_neuron_seq_ids', [], ...
                                        'dy', 2, ...
                                        'peth_set', 'peth_free', ...
                                        'base_path', '', ...
                                        'fig_file', [] );
    
    colors = snn_options( 'colors' );
    
    if isempty(idx)
        rank = data_set.rank_free{seq_id};
        idx = zeros(size(rank));
        idx(rank) = 1:length(rank);
    end

    [num_seqs,num_trials] = size(data_set.(set_name));
    num_neurons = max( idx );
    
    if isempty( num_z_neurons )
        num_z_neurons = 1:length( idx );
    end
    
    num_trials = min( max_num_trials, num_trials );

    [h,fig] = get_grid_layout( 1000*data_set.(set_name){1}.time(end), ...
                               [repmat( num_trials, 1, length(neurons) ), 4*length( num_z_neurons ) ], ...
                               'plot_y_border', [repmat(6,1,length(neurons)-1),40], ...
                               'dy', dy, 'right_border', 40 );
                           
    x_limit = [ 1000*data_set.(set_name){seq_id}.time(1), 1000*data_set.(set_name){seq_id}.time(end) ];
    
    show_labels = true;
    
    if isempty(single_neuron_seq_ids)
        single_neuron_seq_ids = repmat(seq_id,1,length(neurons));
    end
    
    idx = [ idx(num_z_neurons), idx(  not(sparse( 1, num_z_neurons, true, 1, length(idx) )) ) ];
    
    for i=1:length(neurons)
        
        plot_single_neuron_trials( data_set, neurons(i), ...
                                   'trials', 1:num_trials, ...
                                   'seq_id', single_neuron_seq_ids(i), ...
                                   'num_neurons', num_neurons, ...
                                   'neuron_order', idx, ...
                                   'set_name', set_name, ...
                                   'neuron_labels', 1:num_neurons, ...
                                   'plot_axis', h(i) )
                               
        if show_labels
            snn_plot( data_set.(set_name){seq_id}, '[ Xt[?tl] ]', 'axis', h(i), ...
                      'numbering', 'none', 'colors', colors, ...
                      'show_titles', false );
            show_labels = false;
        else
            snn_plot( data_set.(set_name){seq_id}, '[ Xt[?t] ]', 'axis', h(i), ...
                      'numbering', 'none', 'colors', colors, ...
                      'show_titles', false );
        end
                    
        if (i==length(neurons))
            set( h(i), 'Box', 'off', 'YTick', [1,num_trials] );
            xlabel( 'time [ms]' );
        else
            set( h(i), 'Box', 'off', 'XTickLabel', [], 'YTick', [1,num_trials] );
        end
        xlim( x_limit );
        axes( h(i) );  ylabel( 'trial' );
    end
    
    axes( h(end) ); xlabel( 'time [ms]' );
    
    im_data =  data_set.(peth_set){seq_id}; %./...
    
    imagesc( 1000*data_set.(set_name){seq_id}.time, ...
             1:length( num_z_neurons ), im_data(idx(1:length(num_z_neurons)),:), [0,200] );
         
    % imagesc( im_data(idx(1:length(num_z_neurons)),:), [0,200] );
         

    colormap( [1:(-1/255):(0); 1:(-1/255):(0); 1:(-1/255):(0)]' );

    if plot_spikes
        group_ids = cumsum( [0,data_set.net.groups] );
        group_labels = zeros(1,data_set.net.num_neurons);
        col = 1;
        for i = 1:length(data_set.net.groups)
            if any(highlight_groups == i)
                group_labels((group_ids(i)+1):group_ids(i+1)) = col;
                col = col+1;                
            else
                group_labels((group_ids(i)+1):group_ids(i+1)) = size(colors,1);
            end
        end
        
        plot_data_hist( data_set, 'set_name', set_name, ...
                        'neuron_order', idx, ...
                        'plot_axis', h(end), ...
                        'hold', 'on', ...
                        'seq_id', seq_id, ...
                        'run_id', run_id, ...
                        'neuron_labels', group_labels, ...
                        'z_labels', data_set.(set_name){seq_id}.labels, ...
                        'num_neurons', length( num_z_neurons ) );
    else
        snn_plot( data_set.(set_name){seq_id}, '[ Xt[?tl] ]', 'axis', h(end), ...
                      'numbering', 'none', 'colors', colors, ...
                      'show_titles', false, 'hold', 'off' );
    end
    
    set( h(end), 'LineWidth', 0.8, 'FontName', snn_options( 'FontName' ), ...
                 'FontSize', snn_options( 'FontSize' ), ...
                 'YTick', [num_z_neurons(1),num_z_neurons(end)] );
             
    ylabel( 'neuron' );
    xlabel( 'time [ms]' );
    
    bar_pos = get( h(end), 'Position' );
    plot_width = bar_pos(3);
    bar_pos(3) = bar_pos(1)*0.4;
    bar_pos(1) = bar_pos(1)*1.2 + plot_width;
    bar_pos(2) = bar_pos(2) + bar_pos(4)*0.1;
    bar_pos(4) = bar_pos(4)*0.8;

    colorbar( 'West', 'Position', bar_pos, 'YTick', [0,1], ...
              'LineWidth', 0.8, 'FontName', snn_options( 'FontName' ), ...
              'FontSize', snn_options( 'FontSize' ) );

    if ~isempty( fig_file )
        save_fig( fig, [fig_file,'_peth'], base_path );
    end
    
    [h,fig] = get_grid_layout( 65, repmat( 65, 1, num_seqs ), ...
                               'plot_y_border', 25, ...
                               'plot_x_border', 25, ...
                               'dx', 1, 'dy', 1 );
          
    for i = 1:num_seqs
        axes( h(i) ); hist( data_set.spear_free(i,:), -1:0.2:1 ); xlim([-1.1,1.1]);
        ylim([0,100]);
        hold on; plot( repmat(data_set.spear_av(i),1,2), [0,100], '-r' );
        set( gca, 'YTick', [0,100], 'LineWidth', 0.8, 'FontName', snn_options( 'FontName' ), ...
             'FontSize', snn_options( 'FontSize' ) );
         
        ylabel( '# trials' );
        title( 'ABEFG' );
    end    
    xlabel( 'rank corr.' );
    
    if ~isempty( fig_file )
        save_fig( fig, [fig_file,'_corr'], base_path );
    end
end
