function sorted_hist_plot( data, num_bins, idx, field_name )
% 绘制指定数据字段的脉冲直方图。
%
% 输入：
%   data：输入的数据结构体，包含若干个字段。
%   num_bins：将数据划分为的区间数。
%   idx：绘制脉冲直方图的区间索引向量，即只绘制部分区间。
%   field_name：要绘制脉冲直方图的字段名。
% 
% 输出：
%   一个脉冲直方图，其中水平条形的高度表示对应区间内数据的归一化值。
% 

    data_field = data.(field_name)(1,:);  % 将数据结构体data中的名为field_name的字段提取出来，并赋值给变量data_field

    h = hist( data_field, 1:num_bins );  % 使用hist函数将数据data_field分成num_bins个区间，并计算每个区间中的数据个数，结果赋值给h
    
    % 绘制水平条形图，其中条形的高度为数据h(idx)的归一化值，即h(idx)除以时间范围data.time(end)-data.time(1)。idx是一个索引向量，用于选择要绘制的区间
    barh( 1:length(idx), h(idx)./(data.time(end)-data.time(1)) );
    
    min_y_dist = 0.02;  % 设定最小垂直距离为0.02

    y_dist = 0.5;  % 设定默认垂直距离为0.5
    
    % 如果默认垂直距离除以要绘制的区间数小于最小垂直距离，则将垂直距离设为最小垂直距离乘以要绘制的区间数
    if y_dist/length(idx) < min_y_dist
        y_dist = min_y_dist*length(idx);
    end
    
    % 设定y轴的范围，使得绘图区域上下各有一个距离为y_dist的空白区域
    ylim([1-y_dist,length(idx)+y_dist]);
    set(gca,'YDir','reverse')  % 将y轴反转，以使得y轴上的条形与输入数据的顺序相同
end
