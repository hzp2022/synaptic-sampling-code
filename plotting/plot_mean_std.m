function plot_mean_std( mean, std, it, color )
% plot_mean_var( data, it, color )
% 
% 绘制平均值和标准差，使用阴影区域表示标准差。
%
% 输入：
%   mean： 一个向量，表示数据的平均值。
%   std：  一个向量，表示数据的标准差。
%   it：   一个向量，表示数据的迭代次数或时间步。
%   color：一个向量，表示用于绘制曲线和阴影的颜色。
% 
% 具体处理逻辑如下：
%   1.将函数的hold设置为on，以便在同一图中绘制多个曲线。
%   2.使用area函数绘制标准差区域，其中x轴为it向量，y轴为平均值减去标准差和平均值加上标准差所形成的区域，颜色为color向量加上0.7后的最小值。同时将边框样式设置为none，使得标准差区域没有边框。
%   3.由于area函数返回的是两个图形对象，第一个对象是边框，第二个对象是填充区域。因此，使用delete函数删除第一个对象。
%   4.使用plot函数绘制平均值曲线，颜色为color向量。
% 

    hold on;
    h = area( [ it', it' ], [ mean(data,2)-std(data,1,2), 2*std(data,1,2) ], ...
              'LineStyle', 'none', 'FaceColor', min(1,color+0.7) );
    delete(h(1));
    plot( it, mean(data,2), 'Color', color );
end
