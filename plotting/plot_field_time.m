function [h,ax] = plot_field_time( data_set, field_name, idx, h )
% 绘制数据集中指定字段的时间序列。
%
% 输入参数：
%   data_set: 数据集，一个 struct 类型的变量。
%   field_name: 需要绘制时间序列的字段名。
%   idx: 可选参数，表示需要绘制的数据的索引，可以是一个标量或者一个向量。默认为空，表示绘制全部数据。
%   h: 可选参数，表示绘制时间序列的 axes 句柄。如果不指定，则会调用 get_grid_layout 函数创建一个新的 axes。
%
% 输出参数：
%   h: 绘制时间序列的 axes 句柄。
%   ax: 新创建的 axes 对象。
%
% 辅助函数：
%   get_grid_layout
% 

    % 根据数据集中的时间信息计算时间范围
    t_range = data_set.time(end)-data_set.time(1);
    
    unit = 's';
    sc = 1;
    
    % 如果时间跨度大于 60 秒，则单位为分钟
    if t_range > 60
        t_range = t_range/60;
        sc = sc*60;
        unit = 's';
    end
    % 如果时间跨度再大于 60 分钟，则单位为小时
    if t_range > 60
        t_range = t_range/60;
        sc = sc*60;
        unit = 'h';
    end
    
    % 如果没有指定 axes 句柄，则调用 get_grid_layout 函数创建一个新的 axes，并将第一个 axes 设置为当前 axes
    if nargin<4
        [h,ax] = get_grid_layout( t_range, 100, 'plot' );
        axes(ax(1));
    end
    
    % 根据输入参数 idx 和 field_name 从数据集中获取需要绘制的数据，如果没有指定 idx，则获取全部数据
    data = data_set.(field_name);
    if nargin>2
        data = data(idx,:);
    end        
    
    % 调用 plot 函数绘制时间序列图，横轴为时间（单位根据之前计算得到的时间单位确定），纵轴为指定字段的数值
    plot( data_set.time/sc, data );
    
    % 设置横轴标签为 "time [时间单位]"
    xlabel(sprintf('time [%s]',unit));
end
