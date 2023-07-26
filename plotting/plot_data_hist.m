function plot_data_hist( data_set, varargin )
% 绘制一个数据集的直方图和相关的标签信息。
% 
% 输入参数：
%   data_set：包含数据的结构体，可以从指定的文件中加载。
%   varargin：可变长度输入参数。这些参数将被传递给 snn_process_options 和 snn_plot 函数，用于设置图形的样式和其他选项。
%           num_neurons：神经元的数量。
%           idx：        神经元的索引，可以按照这个索引的顺序绘制直方图。
%           lbls：       神经元的标签，用于标识每个神经元的功能或位置。
%           colors：     用于绘制不同组或神经元的颜色。
%           pat_labels： 用于标识数据的模式（例如输入模式或输出模式）。
%           z_labels：   用于标识 Zt 数据（即神经元状态的时间序列数据）的标签。
%           plot_axis：  用于绘制 Zt 数据的轴对象。
%           hist_axis：  用于绘制直方图的轴对象。
%           groups：     将神经元分为多个组，可以根据组别对神经元进行分组，以便更好地理解数据结构。
%           run_id：     用于选择运行数据的 ID。
%           seq_id：     用于选择数据序列的 ID。
%           set_name：   数据结构的名称，可以用于从文件中加载数据。
% 
% 代码逻辑：
%   1.使用 snn_process_options 函数将输入参数处理成标准的格式，以便于后续的绘图操作。
%   2.使用 get_neuron_labels 函数生成神经元的标签，如果没有指定标签的话。
%   3.使用 sort_neurons_seq 函数对神经元进行排序，并使用 sparse 函数将排序后的索引转换成布尔类型。如果输入的神经元索引为空，则将其设置为排序后的索引。如果输入的神经元索引数量小于实际数量，则将剩余的索引添加到末尾。
%   4.准备数据并进行绘图。如果数据结构包含多个运行实例，则选择指定的运行 ID 和序列 ID。
%   5.使用 get_data_labels 函数生成 Zt 数据的标签，如果没有指定标签的话。如果未指定要使用的轴对象，则创建一个新的图形并使用 gca 函数获取当前轴对象。
%   6.使用 snn_plot 函数绘制 Zt 数据并传递其他参数。如果指定了 hist_axis 参数，则该函数会在指定的轴对象上绘制直方图。
%
% 辅助函数：
%   get_neuron_labels，sort_neurons_seq，get_data_labels，snn_plot
% 

    [ num_neurons, ...
      idx, ...
      lbls, ...
      colors, ...
      pat_labels, ...
      z_labels, ...
      plot_axis, ...
      hist_axis, ...
      groups, ...
      run_id, ...
      seq_id, ...
      set_name, ...
      varargin ] = snn_process_options( varargin, ...
                                        'num_neurons', [], ...
                                        'neuron_order', [], ...
                                        'neuron_labels', [], ...
                                        'colors', [], ...
                                        'pat_labels', [], ...
                                        'z_labels', [], ...
                                        'plot_axis', [], ...
                                        'hist_axis', [], ...
                                        'groups', [], ...
                                        'run_id', 1, ...
                                        'seq_id', 1, ...
                                        'set_name', 'sim_test' );


    if isempty(num_neurons)
        if ~isempty( idx )
            num_neurons = length( idx );
        else
            num_neurons = data_set.net.num_neurons;
        end
    end
    
    if isempty(idx)
    	idx = sort_neurons_seq( data_set.(set_name), num_neurons );
    end
    
    if ( length(idx) < data_set.net.num_neurons )
        idx = [ idx, find(  not(sparse( 1, idx, true, 1, data_set.net.num_neurons )) ) ];
    end

    if isempty(lbls)
        lbls = get_neuron_labels( data_set.(set_name)(run_id), num_neurons, 5 );
    end
    
    if isempty(colors)
        if isfield(data_set,'colors')
            colors = data_set.colors;
        else
            colors = snn_options( 'colors' );
        end
    end

%% prepare data for plotting

    if (run_id > 1) && (size(data_set.(set_name),2) == 1)
        sim_data = data_set.(set_name){seq_id}(run_id);
    else
        sim_data = data_set.(set_name){seq_id,run_id};
    end

    sim_data.Zt_y_range = 1:num_neurons;
    sim_data.idx = idx;

    if ~isempty( lbls )
        sim_data.Zt = [ sim_data.Zt(1,:); ...
                        lbls( sim_data.Zt(1,:) ); ...
                        sim_data.Zt(2,:) ];
    end
    
    grp_lbls = struct;
    
    for i=2:2:(length(groups)-1)
        grp_lbls(i/2).show_border = false;
        grp_lbls(i/2).color = 1;
        grp_lbls(i/2).start_time = sim_data.time(1);
        grp_lbls(i/2).stop_time = sim_data.time(end)+0.01;
        grp_lbls(i/2).range = [ sum(groups(1:(i-1)))+1, sum(groups(1:i)) ];
    end
    
    if isempty( z_labels )
        sim_data.Zt_labels = get_data_labels( sim_data.Zt, pat_labels, grp_lbls );
    else
        sim_data.Zt_labels = z_labels;
    end
    
    if isempty( plot_axis )
        figure;
        plot_axis = gca;
    end
    
    snn_plot( sim_data, '[ Zt[stclx] ]', ...
              'axis', plot_axis, 'numbering', 'none', ...
              'colors', colors, ...
              'show_titles', false, varargin{:} );
                                          
                                          
    if ~isempty(hist_axis)
        
        axes(hist_axis);
        sorted_hist_plot( sim_data, num_neurons, idx, 'Zt' );
        set( gca, 'LineWidth', 0.8, 'FontName', snn_options( 'FontName' ), ...
                  'FontSize', snn_options( 'FontSize' ), ...
                  'YTickMode', 'manual', 'YTickLabelMode', 'manual', ...
                  'YTick', [0.5, num_neurons+0.5], ...
                  'YTickLabel', {'1', sprintf('%i',num_neurons)} );
    end

end
