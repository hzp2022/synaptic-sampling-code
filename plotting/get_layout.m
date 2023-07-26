function [h,fig] = get_layout( widths, heights, varargin )
% 创建适合于网格布局的坐标轴
%
% h = get_layout( widths, heights )
% 
% 输入参数：
%   widths：表示要创建的坐标轴的列数
%   heights：表示要创建的坐标轴的行数
%   varargin：包括：figure（要使用的 Figure 对象）、left_border、right_border、plot_x_border 和 plot_y_border
% 
% 代码逻辑：
%   1.解析可选参数，并检查是否提供了 Figure 对象。如果没有提供，则创建一个新的 Figure 对象。
%   2.设置 Figure 对象的单位为点，并计算出一些绘图的边界和大小参数。
%   3.创建一个新的 Figure 对象，并设置一些绘图参数。
%   4.该函数调用 snn_plot 函数来创建适合网格布局的坐标轴，并返回这些坐标轴的句柄 h 和 Figure 对象 fig。
%

    [ fig, ...
      left_border, ...
      right_border, ...
      plot_x_border, ...
      plot_y_border ] = ...
        snn_process_options( varargin, ...
                             'figure', [], ...
                             'left_border', 20, ...
                             'right_border', 8, ...
                             'plot_x_border', 6, ...
                             'plot_y_border', 6 );


    if isempty(fig)
        fig = figure;
    end
    
    set( fig, 'Units', 'points' );
    
    t_range = 1000*(sim_data.time(end) - sim_data.time(1));
    fig_w = 88 + t_range;
    
    dy = 1; dx = 1;

    
    h_fig = figure;
    hist_w = 16/fig_w;
    x_l_border = 50/fig_w;
    x_r_border = 30/fig_w;
    y_border = .14;
    hist_border = 16/fig_w;
    plot_border = .08;
    hist_max = 20;
    max_x_neurons = min(num_inputs,20);
    label_dist = 4;
    title_dist = 8;
    show_hists = false;
    
    
    p_x = x_l_border + hist_w + hist_border;
    p_y = y_border + plot_heights(2) + plot_border;
    plot_w = 1 - hist_w - x_l_border - x_r_border - hist_border;    
    
    pos = get( h_fig, 'Position' );
    pos(3) = 280; pos(4) = 280;
    set( h_fig, 'Position', pos, 'Renderer', 'painters' );
    
    Lt = sim_data(run_id).Lt;
    Xt = sim_data(run_id).Xt;
    x_idx = Lt(1,:) <= max_x_neurons;
    Lt = [ Lt(1,x_idx); Lt(2,x_idx); Lt(3,x_idx) ];
    Xt = [ Xt(1,x_idx); Xt(2,x_idx) ];
    sim_data(run_id).Lt = Lt;
    sim_data(run_id).Xt = Xt;
    sim_data(run_id).Lt_y_range = 1:max_x_neurons;
    
    if ~isempty( pat_labels )
        sim_data(run_id).Zt_labels = get_data_labels( sim_data(run_id).Zt, pat_labels );
    end
    
    [fig,h] = snn_plot( [], 'init', 'figure', fig, 'axis_grid', axis_grid );

end