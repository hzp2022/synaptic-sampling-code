function plot_data_trials( sim_data, num_neurons, num_inputs, idx, run_id, lbls, pat_labels, colors )
% 绘制神经网络的输入和输出脉冲序列，以及直方图。
% 
% 输入参数：
%     sim_data:    包含神经网络仿真数据的结构体。如果给定了字符串，则从该字符串指定的文件中加载数据结构
%     num_neurons: 输出神经元数量
%     num_inputs:  输入神经元数量
%     idx:         一个整数或向量，指定要绘制的模式或模式范围
%     run_id:      数据结构中要使用的运行ID。默认为1
%     lbls:        神经元标签。默认为get_neuron_labels函数生成的标签
%     pat_labels:  模式标签
%     colors:      绘图使用的颜色
% 
% 输出：
%     一个figure对象，并包含了神经网络输入输出和神经元直方图的图形
% 
% 辅助函数：
%   get_neuron_labels，get_data_labels，snn_plot，sorted_hist_plot
% 

    % 如果没有指定 run_id，则将其默认设置为1
    if (nargin < 5)
        run_id = 1;
    end
    
    % 如果没有指定lbls，则使用get_neuron_labels函数生成的标签
    if (nargin < 6)
        lbls = get_neuron_labels( sim_data(run_id), num_neurons, 5 );
    end
    
    plot_heights = [ .30, .30 ];  % plot_heights定义了绘图的高度比例

    sim_data(run_id).Zt_y_range = 1:num_neurons;  % 设置模式范围
    sim_data(run_id).idx = idx;  % 设置神经元索引
    
    % 定义各种参数和常量，用于布局和绘图的大小和位置
    h_fig = figure;
    hist_w = .08;
    x_l_border = .18;
    x_r_border = .10;
    y_border = .12;
    hist_border = .04;
    plot_border = .14;
    hist_max = 20;
    max_x_neurons = min(num_inputs,20);
    label_dist = 4;
    title_dist = 8;
    
    p_x = x_l_border + hist_w + hist_border;
    p_y = y_border + plot_heights(2) + plot_border;
    plot_w = 1 - hist_w - x_l_border - x_r_border - hist_border;    
    
    pos = get( h_fig, 'Position' );
    pos(3) = 280; pos(4) = 280;
    set( h_fig, 'Position', pos, 'Renderer', 'painters' );
    
    % 如果lbls不为空，则将其添加到sim_data(run_id).Zt中
    if ~isempty( lbls )
        sim_data(run_id).Zt = [ sim_data(run_id).Zt(1,:); ...
                                lbls( sim_data(run_id).Zt(1,:) ); ...
                                sim_data(run_id).Zt(2,:) ];
    end
    
    % 获取sim_data(run_id)中的模式和输入数据，并将大于max_x_neurons的输入数据排除
    Lt = sim_data(run_id).Lt;
    Xt = sim_data(run_id).Xt;
    x_idx = Lt(1,:) <= max_x_neurons;
    Lt = [ Lt(1,x_idx); Lt(2,x_idx); Lt(3,x_idx) ];
    Xt = [ Xt(1,x_idx); Xt(2,x_idx) ];
    sim_data(run_id).Lt = Lt;
    sim_data(run_id).Xt = Xt;
    sim_data(run_id).Lt_y_range = 1:max_x_neurons;
    
    % 如果pat_labels不为空，则将其作为get_data_labels函数的输入参数，将函数生成的标签赋值给sim_data(run_id).Zt_labels
    if ~isempty( pat_labels )
        sim_data(run_id).Zt_labels = get_data_labels( sim_data(run_id).Zt, pat_labels );
    end
    
    % 使用snn_plot函数绘制神经元和模式活动的时间序列图
    [h_fig,h_axes] = snn_plot( sim_data(run_id), '[ _, Lt[stlc], _, Zt[sx] ]', ...
                               'figure', h_fig, 'numbering', 'none', 'colors', colors, ...
                               'axis_grid', [ x_l_border, p_y, hist_w, plot_heights(1); ...
                                              p_x, p_y, plot_w, plot_heights(1); ...
                                              x_l_border, y_border, hist_w, plot_heights(2); ...
                                              p_x, y_border, plot_w, plot_heights(2) ] );
                                          
    
    % 在第二个图中添加标题“network inputs”
    axes(h_axes(2));
    h_title = title( 'network inputs' );

    set( h_title, 'Units', 'points' );
    pos = get( h_title, 'Position' );
    pos(2) = pos(2) + title_dist;
    set( h_title, 'Position', pos );
    
    set( h_title, 'Units', 'normalized' );
    pos = get( h_title, 'Position' );
    pos(1) = .5 - ((hist_w + hist_border)/2)/plot_w;
    set( h_title, 'Position', pos );
    
    set( gca, 'YTick', [], 'YTickLabel', {}, ...
              'YTickMode', 'manual', 'YTickLabelMode', 'manual' );
    
    % 在第四个图中添加标题“network outputs”
    axes(h_axes(4));
    h_title = title( 'network outputs' );

    % set( h_title, 'Units', 'points' );
    % pos = get( h_title, 'Position' );
    % pos(2) = pos(2) + title_dist;
    % set( h_title, 'Position', pos );

    set( h_title, 'Units', 'normalized' );
    pos = get( h_title, 'Position' );
    pos(1) = .5 - ((hist_w + hist_border)/2)/plot_w;
    set( h_title, 'Position', pos );
    xlabel( 'time [ms]' );  % 设置x轴标签为"time [ms]”
    
    set( gca, 'YTick', [], 'YTickLabel', {}, ...
              'YTickMode', 'manual', 'YTickLabelMode', 'manual' );

    % 使用sorted_hist_plot函数绘制输入脉冲序列的直方图
    axes(h_axes(1));
    sorted_hist_plot( sim_data(run_id), max_x_neurons, 1:max_x_neurons, 'Xt' );
    set( gca, 'FontName', snn_options( 'FontName' ), 'FontSize', snn_options( 'FontSize' ) );
    h_y_label = ylabel( 'input neuron' );
    % pos = get( h_y_label, 'Position' );
    % pos(1) = -label_dist;
    % set( h_y_label, 'Position', pos );
    xlabel( '' );
    set( gca, ... %'YTick', [0.5, num_inputs+0.5], ...
              ... %'YTickLabel', {'1',num2str(num_inputs)}, ...
              'YTickMode', 'manual', 'YTickLabelMode', 'manual', ...
              'XTick', [0, hist_max], ...
              'XTickLabel', {'0', sprintf('%i',hist_max)}, ...
              'XTickMode', 'manual', 'XTickLabelMode', 'manual' );
    xlim( [0, hist_max] );

    % 使用sorted_hist_plot函数绘制输出脉冲序列的直方图
    axes(h_axes(3));
    sorted_hist_plot( sim_data(run_id), num_neurons, idx, 'Zt' );
    set( gca, 'FontName', snn_options( 'FontName' ), 'FontSize', snn_options( 'FontSize' ) );
    h_y_label = ylabel( 'trial' );
    % pos = get( h_y_label, 'Position' );
    % pos(1) = -label_dist;
    % set( h_y_label, 'Position', pos );
    xlabel( '# spikes' );
    set( gca, ... % 'YTick', [0.5, num_neurons+0.5], ...
              ... % 'YTickLabel', {'1',num2str(num_neurons)}, ...
              'YTickMode', 'manual', 'YTickLabelMode', 'manual', ...
              'XTick', [0, hist_max], ...
              'XTickLabel', {'0', sprintf('%i',hist_max)}, ...
              'XTickMode', 'manual', 'XTickLabelMode', 'manual' );
    xlim( [0, hist_max] );

end
