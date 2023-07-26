function plot_mean_var( data_mean, data_var, it, color )
% plot_mean_var( data, it, color )
%
% 绘制数据的平均值和方差，使用阴影区域表示方差
% 
% 输入参数：
%   data_mean：表示数据的平均值，是一个列向量
%   data_var： 表示数据的方差，是一个列向量
%   it：       表示数据的时间步长，是一个列向量
%   color：    表示绘制的颜色
% 
% 处理逻辑：
%   1.判断输入参数的个数，如果小于 4，则调用 plot_mean_var 函数并传入计算得到的平均值和方差，以及原始的方差数据和时间步长数据。
%   2.如果输入参数的个数为 4，则先使用 area 函数绘制数据的阴影区域。其中，阴影区域的横坐标是时间步长数据，纵坐标是平均值减去方差和平均值加上方差。绘制的颜色为输入的颜色和浅色之间的最小值。
%   3.将阴影区域中的第一个元素删除。
%   4.使用 plot 函数绘制数据的平均值。
%

    if nargin<4
        plot_mean_var( mean(data_mean,2), var(data_mean,2), data_var, it );
        return;
    end
    
    hold on;
    h = area( [ it', it' ], [ (data_mean-data_var)', 2*data_var' ], ...
              'LineStyle', 'none', 'FaceColor', min(1,color+0.7) );
    delete(h(1));
    plot( it, data_mean, 'Color', color );
end
