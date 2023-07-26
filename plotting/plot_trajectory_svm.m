function plot_trajectory_svm( m_data )
% 评估线性分类器在多个WTA电路的轨迹上的性能。
%
% 输入：
%   m_data包含以下字段：
%       m_data.net.num_neurons：整数，表示网络中神经元的数量。 
%       m_data.net.groups：一个包含整数的向量，表示网络中每个神经元组的大小。
%       m_data.I：一个包含神经元活动的向量，表示每个神经元在给定时间段内的总活动量。
%       m_data.test_data：一个包含测试数据的单元格数组，每个元素代表一个测试数据集。
%       m_data.test_data{i,j}.Zt：时间序列数据，即第i个测试数据集的第j个样本的神经元响应数据。
% 
% 大致流程：
%   1.首先定义了一些参数，如样本的数量和采样步长、高斯核函数的方差等。
%   2.接着根据输入的WTA电路网络，将神经元分组，方便后面逐组进行处理。
%   3.对于每一组神经元，先通过get_peth函数计算它们在给定采样步长和高斯核函数方差下的peri-event time histogram (PETH)。
%   4.然后将PETH转换成一个特征矩阵X，每行代表一个神经元的响应，每列代表一个采样点的响应。这里使用支持向量机(support vector machine, SVM)算法对特征矩阵X进行训练，并得到一个线性分类器。
%   5.最后，使用训练好的分类器对测试数据进行分类，并计算分类器的性能。同时，可以选择将分类结果可视化。
% 


    samples = 0.100:0.005:0.150;
    sigma = 0.01;
    
    num_samples = length(samples);
    num_neurons = m_data.net.num_neurons;
    
    num_sets = 100;
    num_pat = 2;
    
    m_data.net.groups(2:(end))

    wta_groups = [ 1,            1, cumsum(m_data.net.groups(1:(end-1)))+1; ...
                   num_neurons,  m_data.net.groups  ];
        
    classes = [ zeros(num_samples*num_sets,1); ones(num_samples*num_sets,1) ];
    
    perf_all = zeros(1,size(wta_groups,2));
    
    idx = randperm(num_samples*num_sets*num_pat);
    
    for group = 1:size(wta_groups,2)
        
        neuron_ids = wta_groups(1,group):(wta_groups(1,group)+wta_groups(2,group)-1);

        P = zeros( length(neuron_ids), num_samples, num_sets, num_pat );

        fprintf( 'computing peth...      0%%' );

        [v,n_idx] = sort( m_data.I(neuron_ids) );

        for i = 1:num_sets
            for j = 1:num_pat
                P(:,:,i,j) = get_peth( m_data.test_data{j,i}.Zt, neuron_ids(n_idx), samples, sigma );
            end        
            fprintf('%c%c%c%c%3d%%',8,8,8,8,round(100*i/num_sets))
        end
        
        fprintf('%c%c%c%cdone.\n',8,8,8,8);
            
        X = reshape(P,[length(neuron_ids),num_samples*num_pat*num_sets]);

        x_svm = svmtrain( X(:,idx(1:min(length(idx),500))), classes(idx(1:min(length(idx),500))), ...
                          'Method', 'QP', 'boxconstraint', 20, 'QuadProg_Opts',  optimset('MaxIter', 1000 ) );

        t_classes = svmclassify(x_svm,X');
        
        perf_all(group) = sum(all(reshape( t_classes == classes, [num_samples,num_pat*num_sets] ),1))/(num_sets*num_pat);

        fprintf( '%3i   size: %3i   performance: %f\n', group, length(neuron_ids), perf_all(group) );
    end

%     colors = [ [1,0,0]; [0,1,0]; [0,0,1]; [.7,.7,0] ];
%     figure;
%     
%     for k=1:12
%         for l=(k+1):12
%             for m=(l+1):12
%                 
%                 fprintf( '%i %i %i \n', k, l, m );
% 
%                 X_svm_proj = [ x_svm.SupportVectors(k,:) - x_svm.SupportVectors(j,:); x_svm.SupportVectors(k,:) - x_svm.SupportVectors(m,:) ]';
% 
%                 hold off;
% 
%                 for j=1:num_pat
%                     for i=1:num_sets
%                         sample = zeros( num_neurons, num_samples );
%                         for c = 1:num_neurons
%                             sample(:,c) = x_svm.ScaleData.scaleFactor(c) * ...
%                                           (P(:,c,i,j)' +  x_svm.ScaleData.shift(c));
%                         end
%                         p_proj = sample'*X_svm_proj;
%                         plot( p_proj(1,:), p_proj(2,:), '-', 'Color', colors(j,:) );
%                         hold on;
%                         plot( p_proj(1,:), p_proj(2,:), '.', 'Color', colors(j,:) );
%                     end
%                 end
% 
%                 waitforbuttonpress;
%     
%             end
%         end
%     end
end
