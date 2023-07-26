function plot_input_hist( data_set, varargin )
% 绘制神经网络的输入直方图和对应的神经元活动的变化情况。
% 
% 输入：
%   data_set：数据集，包含神经网络的训练和测试数据等信息。
%   varargin：可选参数列表，用于指定绘图的一些参数，比如要显示的神经元编号、颜色等等。
% 
% 输出：
%   这个函数没有明确的输出，它的作用是在当前的绘图窗口中生成输入直方图和神经元活动变化图。
% 
% 函数的代码逻辑如下：
%   1.调用一个名为snn_process_options的函数，根据输入参数列表和默认值来确定一些绘图所需的参数。
%   2.如果用户没有指定颜色，那么检查数据集中是否已经指定了颜色，如果有，就使用数据集中指定的颜色，否则使用默认颜色。
%   3.从数据集中获取神经元的活动和输入数据，然后根据指定的神经元编号选择要绘制的神经元。
%   4.调用一个名为snn_plot的函数，用于绘制神经元活动变化图。根据输入数据绘制出神经元的活动变化情况，并可以指定一些参数来控制绘图的样式。
%   5.如果指定了绘制直方图的坐标轴，则调用sorted_hist_plot函数来绘制输入直方图，并根据指定的神经元编号和其他参数进行设置。
% 
% 辅助函数：
%   snn_plot，sorted_hist_plot
% 


    [ x_neurons, ...
      lbls, ...
      colors, ...
      pat_labels, ...
      plot_axis, ...
      hist_axis, ...
      run_id, ...
      seq_id, ...
      hold_it, ...
      set_name ] = snn_process_options( varargin, ...
                                        'idx_neurons', 1:20, ...
                                        'neuron_labels', [], ...
                                        'colors', [], ...
                                        'pat_labels', [], ...
                                        'plot_axis', [], ...
                                        'hist_axis', [], ...
                                        'run_id', 1, ...
                                        'seq_id', 1, ...
                                        'hold', 'off', ...
                                        'set_name', 'sim_test' );

                                    
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

    Lt = sim_data.Lt;
    Xt = sim_data.Xt;
    
    x_idx = any( repmat(Lt(1,:),length(x_neurons),1) == repmat( x_neurons', 1, size(Lt,2)), 1 );
    
    id2idx = zeros(1,max(x_neurons));
    id2idx(x_neurons) = 1:length(x_neurons);

    n_id = id2idx( Lt(1,x_idx) );
    
    Lt = [ n_id; Lt(2,x_idx); Lt(3,x_idx) ];
    Xt = [ Xt(1,x_idx); Xt(2,x_idx) ];
    sim_data.Lt = Lt;
    sim_data.Xt = Xt;
    sim_data.Lt_y_range = 1:length(x_neurons);

    snn_plot( sim_data, '[Lt[sctl] ]', ...
              'axis', plot_axis, 'numbering', 'none', 'colors', colors, ...
              'show_titles', false, 'hold', hold_it );
                                          
                                          
    if hist_axis
        axes( hist_axis );
        sorted_hist_plot( sim_data, data_set.net.num_neurons, x_neurons, 'Xt' );
        set( gca, 'LineWidth', 0.8, 'FontName', snn_options( 'FontName' ), ...
                  'FontSize', snn_options( 'FontSize' ), ...
                  'YTick', [0.5, length(x_neurons)+0.5], ...
                  'YTickLabel', {'1',num2str(length(x_neurons))}, ...
                  'YTickMode', 'manual', 'YTickLabelMode', 'manual' );
    end    
end
