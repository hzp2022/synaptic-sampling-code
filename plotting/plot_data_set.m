function data_set = plot_data_set( data_set, i, fig )
% 绘制data_set。
% 
% 输入参数：
%   data_set：待绘制的数据集（一个结构体）如果给定一个字符串，数据结构将从其所指向的文件中加载数据集。
%   i：待绘制的模式（测试、训练、自由运行）的编号，只有data_set为字符串时才会使用。
%   fig：可选参数，表示用于绘制的图形窗口的编号，默认为1。
% 
% 输出参数：
%   返回更新后的数据集。
% 
% 辅助函数：
%   sort_neurons_seq，append_data，snn_plot
%
    
    % 检查是否提供了图形窗口编号，如果没有，则将fig设置为1
    if (nargin<3)
        fig = 1;
    end
    
    % 如果输入的数据结构是字符串类型，则从该字符串所指向的文件中加载数据集
    if ischar( data_set )
        
        src_file_name = locate_data_file( data_set, i );

        fprintf( 'loading dataset %s...\n', src_file_name );
        
        if isempty( src_file_name )
            error( 'File not found!' );
        end
        
        data_set = load( src_file_name );
    end
    
    % 为测试数据集中的神经元生成排序索引，得到排好序的索引idx
    idx = sort_neurons_seq( data_set.sim_test, data_set.net.num_neurons );
    
    % 定义一个空的数据结构plot_data，后面会将各数据集追加到plot_data，以便后面使用plot_data来绘制图形
    plot_data = [];
    
    % 对于每个训练模式，函数会将其添加到plot_data中，并用浅红色绘制
    for j = 1:min(5,length(data_set.sim_train))
%         plot_data = append_data( plot_data, data_set.sim_train(j), [1,.7,.7] );
        plot_data = append_data( plot_data, data_set.sim_train(j) );
    end
    
    % 对于每个测试模式，函数会将测试集和自由运行数据集的每一个序列都添加至plot_data，并分别用浅绿色和浅黄色绘制
    for j = 1:length(data_set.sim_test)
        
        train_set = data_set.sim_test{j};
        
        % 将测试集中的每个序列都添加到plot_data中，并用浅绿色绘制
        for k = 1:length(train_set)        
%             plot_data = append_data( plot_data, train_set(k), [.7,1,.7] );
            plot_data = append_data( plot_data, train_set(k) );
        end
        
%         % 将自由运行数据集中的每个序列都添加到plot_data中，并用浅黄色绘制
% %         plot_data = append_data( plot_data, data_set.sim_free{j}, [1,1,.6] );
%         plot_data = append_data( plot_data, data_set.sim_free{j} );
    end

    for s = 1:length(data_set.sim_free)
        % 将自由运行数据集中的每个序列都添加到plot_data中，并用浅黄色绘制
%         plot_data = append_data( plot_data, data_set.sim_free{j}, [1,1,.6] );
        plot_data = append_data( plot_data, data_set.sim_free{s} );
    end
    
    % 将神经元排序索引idx和神经元数目（y轴范围）添加到plot_data中
    plot_data.idx = idx;
    plot_data.Zt_y_range = (1:data_set.net.num_neurons);
    
% %     plot_data.A_v = data_set.A_v;
% %     plot_data.A_w = data_set.A_w;


%     % 如果A_v和A_w不为空，则将A_v和A_w整合到At中，并更新到plot_data.At（A_w记录在脉冲时间前馈突触的活动，A_v记录在脉冲时间recurrent突触的活动）
%     if ~isempty( plot_data.A_v ) && ~isempty( plot_data.A_w )
%         At = zeros(5,size(plot_data.At,2));
%         At(1,:) = plot_data.At(1,:);
%         At(2,:) = plot_data.A_v;
%         At(3,:) = plot_data.A_w;
%         At(4,:) = plot_data.At(1,:) - plot_data.A_v - plot_data.A_w;
%         At(end,:) = plot_data.At(end,:);  
%         plot_data.At = At;
%     end
    
    % 根据是否有可重构权重矩阵R_all绘制指定样式的图像
    if isfield( plot_data, 'R_all' )
        snn_plot( plot_data, '[ Lt[st], Zt[stx], At[pt], R_all[pt], _ ]', 'figure', fig );
    else        
%         snn_plot( plot_data, '[ Lt[st], Zt[stx], At[pt], Rt[pt], _ ]', 'figure', fig );
        snn_plot( plot_data, '[ Lt[st], Zt[stx], At[pt], _ ]', 'figure', fig );
    end
       
    subplot( 6, 1, 6 );  % 创建一个子图区域，6 行 1 列，用于显示模型性能随迭代次数的变化趋势
    
    plot( data_set.performance );  % 将模型性能的变化情况 data_set.performance 绘制出来
    title( 'performance' );
    xlabel( 'iteration' );

    drawnow;
end
