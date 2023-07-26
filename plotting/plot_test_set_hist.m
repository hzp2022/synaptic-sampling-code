function data_set = plot_test_set_hist( data_set, varargin )
% 绘制数据结构的直方图，如果输入参数为字符串，则从文件中加载数据结构。
%
% 输入：
%   data_set：一个数据结构或一个字符串。如果它是一个字符串，则会从该字符串所指向的文件中加载数据结构。
%   varargin：一系列可选参数，用于定制绘图的样式和布局等（由snn_process_options解析）。
% 
% 输出：
%   data_set：绘图函数不改变输入数据结构，因此输出参数与输入参数相同。
% 
% 辅助函数：
%   get_neuron_labels，get_grid_layout，plot_input_hist，plot_data_hist
% 


    if ischar( data_set )
        data_set = load( data_set );
    end
    
    [ idx, ...
      lbls, ...
      pat_labels, ...
      run_id, ...
      seq_id, ...
      file_name, ...
      set_name, ...
      input_neurons, ...
      box, ...
      dy, ...
      dx, ...
      varargin ] = snn_process_options( varargin, ...
                                        'neuron_order', [], ...
                                        'neuron_labels', [], ...
                                        'pat_labels', [], ...
                                        'run_id', 1, ...
                                        'seq_id', 1, ...
                                        'file_name', [], ...                                        
                                        'set_name', 'sim_test', ...
                                        'input_neurons', 1:20, ...
                                        'box', 'off', ...
                                        'dy', 4, ...
                                        'dx', 1 );

    if isempty(idx)
        idx = 1:data_set.net.num_neurons;
    end
    
    if isempty( pat_labels )
        if isfield( data_set, 'pat_labels' )
            pat_labels = data_set.pat_labels;
        elseif isfield( data_set, 'train_set_generator' ) && ...
               isfield( data_set.train_set_generator, 'pat_labels' )
            pat_labels = data_set.train_set_generator.pat_labels;
        else
            pat_labels = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J' };
        end
    end
    
    if isempty(lbls)
        lbls = get_neuron_labels( data_set.(set_name), data_set.net.num_neurons, pat_labels );
    end

    if isfield( data_set.net, 'groups' )
        groups = data_set.net.groups;
    else
        groups = struct;
    end
    
    [h,fig] = get_grid_layout( [20,1000*data_set.(set_name){seq_id}.time(end)], ...
                               [length(input_neurons),length(idx)], 'plot_y_border', 16, ...
                               'dy', dy, 'dx', dx );
    
    plot_input_hist( data_set, 'idx_neurons', input_neurons, 'neuron_labels', lbls, ...
                     'pat_labels', pat_labels, 'plot_axis', h(2), 'hist_axis', h(1), ...
                     'run_id', run_id, 'seq_id', seq_id, 'set_name', set_name, varargin{:} );
     
    plot_data_hist( data_set, 'neuron_order', idx, 'neuron_labels', lbls, ...
                    'pat_labels', pat_labels, 'plot_axis', h(4), 'hist_axis', h(3), ...
                    'groups', groups, 'run_id', run_id, 'seq_id', seq_id, ...
                    'set_name', set_name, varargin{:} );

    axes( h(1) );
    xlim( [0,20] );
    ylabel( 'upstream neurons' );
    set( h(1), 'Box', 'on', 'XTick', [] );

    axes( h(3) );
    xlim( [0,20] );
    ylabel( 'circuit neurons' );
    xlabel('# spikes');
    set( h(3), 'Box', 'on', 'XTick', [0,20] );
    
    set( h(2), 'Box', box, 'XTick', [], 'YTick', [] );
    set( h(4), 'Box', box, 'YTick', [] );
    axes( h(4) ); xlabel( 'time [ms]' );
    
    if ~isempty( file_name )
        save_fig( fig, file_name );
    end
end
