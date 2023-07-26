function plot_3d_samples(all_samples_info,figure_name)
% 绘制在三维空间中的训练样本分布。
% 
% 输入：
%   all_samples_info: 所有样本点的信息（一个3维矩阵，每一列代表一个样本点）
%   figure_name:      保存图像时的文件名称
% 

    figure;
    hold on;
    grid on;
    axis equal;

    labels = unique(all_samples_info{1});
    colors = hsv(length(labels));
    
    for i = 1:length(labels)
        label = labels(i);
        samples = all_samples_info{2}(:,all_samples_info{1} == label);
        scatter3(samples(1,:), samples(2,:), samples(3,:), [], colors(i,:), 'filled');
    end

    legend('1','2','3','4','5','6','7');
%     legend('1','2','3');

    title(['All Samples Distribution, Total Number of Samples: ', num2str(length(all_samples_info{1}))]);
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    view(3);
    title(figure_name);
    save_fig( gcf, figure_name );
end