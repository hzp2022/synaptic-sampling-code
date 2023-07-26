function plot_single_neuron_trials( data_set, sorted_neuron_id, varargin )
% 将单个神经元的多个试验数据进行绘图展示。  
% 
% 输入：
%   data_set：        包含试验数据的数据集
%   sorted_neuron_id：要绘制的神经元的编号
%   num_neurons：     神经元的数量（可选）
%   neuron_order：    神经元的排序（可选）
%   neuron_labels：   神经元的标签（可选）
%   colors：          绘图的颜色方案（可选）
%   pat_labels：      数据集的样本标签（可选）
%   plot_axis：       绘图的坐标轴（可选）
%   hist_axis：       直方图的坐标轴（可选）
%   trials：          要绘制的试验编号列表（可选）
%   seq_id：          要绘制的序列编号（可选）
%   sorted_id：       是否使用排序后的神经元编号（可选）
%   set_name：        要绘制的数据集名称（可选）
% 
% 代码逻辑：
%   首先根据输入参数准备数据，包括选择要绘制的神经元、选择要绘制的试验、提取相应的标签等等。
%   然后，它将数据绘制在一个或多个子图中，可以绘制时间序列图和直方图（绘图的细节可以通过函数的可选参数进行调整）
%
% 辅助函数：
%   sort_neurons_seq，get_neuron_labels，get_data_labels，snn_plot，sorted_hist_plot
% 

    [ num_neurons, ...
      idx, ...
      n_lbls, ...
      colors, ...
      pat_labels, ...
      plot_axis, ...
      hist_axis, ...
      trials, ...
      seq_id, ...
      sorted_id, ...
      set_name ] = snn_process_options( varargin, ...
                                        'num_neurons', [], ...
                                        'neuron_order', [], ...
                                        'neuron_labels', [], ...
                                        'colors', [], ...
                                        'pat_labels', [], ...
                                        'plot_axis', [], ...
                                        'hist_axis', [], ...                                        
                                        'trials', [], ...
                                        'seq_id', 1, ...
                                        'sorted_id', true, ...
                                        'set_name', 'sim_test' );
    
    if isempty(num_neurons)
        num_neurons = data_set.net.num_neurons;
    end

    if isempty(idx)
    	idx = sort_neurons_seq( data_set.(set_name), num_neurons );
    end
    
    if isempty(n_lbls)
        n_lbls = get_neuron_labels( data_set.(set_name), num_neurons, data_set.pat_labels );
    end
    
    if isempty(trials)
        trials = 1:numel( data_set.(set_name) );
    end
    
    if isempty(colors)
        if isfield(data_set,'colors')
            colors = data_set.colors;
        else
            colors = snn_options( 'colors' );
        end
    end
    
%% prepare data for plotting    
    
    if sorted_id
        neuron_id = idx( sorted_neuron_id );
    else
        neuron_id = sorted_neuron_id;
    end
    
    lbls = repmat( n_lbls( neuron_id ), 1, length(trials) );
    
    sim_data = data_set.(set_name){seq_id,1};
    
    for i = length( sim_data.labels ):-1:1
        
        if ( sim_data.labels(i).stop_sample - sim_data.labels(i).start_sample ) > 1
            break;
        end
    end
    
    sim_data.labels = sim_data.labels(1:i);
    
    Zt = [];
    
    run_id = 1;
    
    for i = trials
        
        Zt_idx = ( data_set.(set_name){seq_id,i}.Zt(1,:) == neuron_id );
        Zt = [ Zt, [ repmat( run_id, 1, sum( Zt_idx ) ); ...
                     data_set.(set_name){seq_id,i}.Zt(2,Zt_idx) ] ];
                 
        run_id = run_id + 1;
    end
    
    sim_data.Zt = Zt;
    
%% plot data    
    
    if ~isempty( Zt )
        
        if ~isempty( lbls )
            sim_data.Zt = [ sim_data.Zt(1,:); ...
                            lbls( sim_data.Zt(1,:) ); ...
                            sim_data.Zt(2,:) ];
        end

        if ~isempty( pat_labels )
            sim_data.Zt_labels = get_data_labels( sim_data.Zt, pat_labels );
        end

        if isempty( plot_axis )
            figure;
            plot_axis = gca;
        end

        snn_plot( sim_data, '[ Zt[s] ]', 'axis', plot_axis, ...
                  'numbering', 'none', 'colors', colors, ...
                  'show_titles', false );
    end
    
    if ~isempty(hist_axis)
        
        axes(hist_axis);
        sorted_hist_plot( sim_data, length(trials), 1:length(trials), 'Zt' );
        set( gca, 'FontName', snn_options( 'FontName' ), 'FontSize', snn_options( 'FontSize' ), ...
                  'YTickMode', 'manual', 'YTickLabelMode', 'manual', ...
                  'YTick', [1, length(trials)], ...
                  'YTickLabel', {'1', sprintf('%i',length(trials))} );

    end
    
end
