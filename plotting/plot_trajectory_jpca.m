function plot_trajectory_jpca( m_data )
% 使用联合主成分分析（jPCA）方法分析多元时间序列数据中的共同变化并绘制神经元的轨迹
% 
% 介绍jPCA：
%   它可以用来发现数据中的主要模式和共性，而忽略单个时间序列的随机噪声和个体差异。
%   与传统的主成分分析（PCA）不同，jPCA将数据中的每个时间点视为一个向量，通过寻找在所有时间点上共同变化的主成分，
%   提取出代表数据的主要结构，并将其可视化。
% 
% 输入:
%   m_data：一个数据结构，包含了用于计算jPCA的实验数据和相关的神经网络参数等信息。
% 
% 输出:
%   该函数没有输出参数，但是会在新的窗口中显示数据结构的可视化结果。
%   具体来说，它会绘制出jPCA的结果，即将多维时间序列映射到二维空间中，并且用不同的颜色表示不同的试验条件。
%

    % params:
    % neurons = 126:148;
    neurons = 68:80;  % 定义变量neurons，它是一个包含一组神经元编号的向量。这些神经元将被用于计算 peth（perievent time histogram）
    % neurons = 1:m_data.net.num_neurons;

    samples = 0.105:0.001:0.145;  % 定义变量samples，它是一个包含一组时间点的向量。这些时间点将被用于计算peth
    sigma = 0.01;                 % 定义变量sigma，它是一个标准差值，用于计算peth
    subset_size = 10;             % 定义变量subset_size，它是一个整数，指定了每个模式（pattern）子集的大小
    
    [num_pat,num_sets] = size(m_data.test_data);  % 计算测试数据集的大小和数量
    num_samples = length(samples);  % 计算时间点数量
    num_neurons = length(neurons);  % 计算神经元数量
    
    num_sets = 20;  % 重新设置num_sets变量的值
        
    P = zeros( num_neurons, num_samples, num_pat, num_sets );  % 定义变量 P，它是一个包含 peth 数据的四维矩阵
    
    % 计算 PCA 系数
    pca_coeff = [sin((0:(num_neurons-1))*(2*pi/(num_neurons-1))); ...
                 cos((0:(num_neurons-1))*(2*pi/(num_neurons-1)))]';
    
    fprintf( 'computing peth...      0%%' );
    
    % 按照m_data的 I 值进行排序
    [v,idx] = sort( m_data.I(neurons) );
    
    % 用 get_peth 函数计算 PETH 数据并保存在 P 变量中
    for i = 1:num_sets
        for j = 1:num_pat
            P(:,:,j,i) = get_peth( m_data.test_data{j,i}.Zt, neurons(idx), samples, sigma );
        end        
        fprintf('%c%c%c%c%3d%%',8,8,8,8,round(100*i/num_sets))  % 输出运行进度的消息
    end
    
    % 输出运行进度的消息，表示程序已经完成
    fprintf('%c%c%c%cdone.\n',8,8,8,8);
    
    % 定义颜色向量，用于将轨迹与特定的神经元图案关联起来
    colors = [ [1,0,0]; [0,1,0]; [0,0,1]; [.7,.7,0] ];
    
    % 调用 jPCA 函数计算 jPCA，其中将 P 重新排列为一个三维矩阵
    P_jpca = jPCA( reshape(P,[num_neurons,num_samples,num_pat*num_sets]) );
    
    figure; hold on;
    
    % 循环遍历每个神经元和模式子集，并使用plot函数绘制jPCA轨迹。其中，每个模式子集的轨迹颜色使用预定义的colors向量中的颜色。
    for j=1:num_pat
        for i=0:(subset_size-1)
            plot( P_jpca(1,:,i*num_pat+j), P_jpca(2,:,i*num_pat+j), '-', 'Color', colors(j,:) );
            plot( P_jpca(1,1,i*num_pat+j), P_jpca(2,1,i*num_pat+j), '.', 'Color', colors(j,:) );
            plot( P_jpca(1,end,i*num_pat+j), P_jpca(2,end,i*num_pat+j), 'r', 'Color', colors(j,:) );
        end
    end
end
