function test_accuracy = plot_test_accurracy(num_neurons,neuron_labels,test_accuracy,sim_test,iteration,save_interval,last_iteration,num_patterns)
% 绘制测试准确率。
% 
% 输入：
%   neuron_labels：   各输出神经元所代表的标签
%   test_accuracy：   存储测试准确率的数组，每计算一次准确率往数组末尾添加一个元素
%   sim_test：        模拟后的测试集
%   num_test_sets：   测试数据数量
%   iteration：       当前迭代次数（记录处理第几个训练数据）
%   save_interval：   每次迭代处理的训练数据数量
% 
% 可变输入：
%   last_iteration:   标记是否为最后一次迭代（方便保存最后一次迭代结束的准确率图）      
% 
% 输出：
%   test_accuracy：   添加了当前准确率的测试准确率数组
% 

%% 计算测试准确率
    
    % 预测测试集中每一个数据的标签
    labels = -1*ones(1,length(sim_test));
    for y = 1:length(sim_test) 
%         labels(y) = pre_data_label(sim_test{y},neuron_labels,num_neurons,num_patterns); 

        % 直接取max
        spike_rates = zeros(1,num_neurons);
        for i = 1:num_neurons
            spike_rates(1,i) = sum(sim_test{y}.Zt(1,:)==i);
        end
        [~,max_response_neuron_index] = max(spike_rates);
        labels(y) = neuron_labels(max_response_neuron_index);
    end

    % 计算准确率
    num = 0;
    for j = 1:length(sim_test)
        if labels(j) == sim_test{j}.seq_id
            num = num + 1;
        end
    end
    if iteration ~=0
        cur_accuracy = [num/length(sim_test);iteration/save_interval];
        test_accuracy = [test_accuracy,cur_accuracy];
    else
        test_accuracy = [0;0];
    end

%% 测试准确率可视化
    y_ticks = 0:0.1:1;
    x_ticks = 0:1:test_accuracy(2,end);
    plot(test_accuracy(2,:), test_accuracy(1,:));
    ylim([0 1]);
    xticks(x_ticks);
    yticks(y_ticks);
    xticklabels(x_ticks);
    yticklabels(y_ticks);
    title('Test Accuracy');
    xlabel('itration');
    drawnow;

    if last_iteration
        save_fig( gcf, 'Test Accuracy' );
    end
end