function train_accuracy = plot_train_accurracy(num_neurons,neuron_labels,train_accuracy,sim_train,iteration,save_interval,last_iteration,num_patterns)
% 绘制训练准确率。
% 
% 输入：
%   neuron_labels：   各输出神经元所代表的标签
%   train_accuracy：  存储训练准确率的数组，每计算一次准确率往数组末尾添加一个元素
%   sim_train：       模拟后的训练集
%   iteration：       当前迭代次数（记录处理第几个训练数据）
%   save_interval：   每次迭代处理的训练数据数量
% 
% 可变输入：
%   last_iteration:   标记是否为最后一次迭代（方便保存最后一次迭代结束的准确率图）      
% 
% 输出：
%   train_accuracy：  添加了当前准确率的训练准确率数组
% 

%% 方案一：通过逐个脉冲计算准确率
%         mixed_sim_train = [];
%         for i = 1:length(sim_train)
%             mixed_sim_train = append_data( mixed_sim_train, sim_train{i} );
%         end
%         if ~isempty(mixed_sim_train)
%             mixed_sim_train.Zt = [neuron_labels(mixed_sim_train.Zt(1,:));mixed_sim_train.Zt(2,:);mixed_sim_train.Zt(3,:)];
%             cur_train_accuracy = [(sum(mixed_sim_train.Zt(1,:) == mixed_sim_train.Zt(2,:)))/size(mixed_sim_train.Zt,2);iteration/save_interval];
%         else
%             cur_train_accuracy = [0;0];
%         end
%         accuracy = [accuracy,cur_train_accuracy];

%% 方案二：通过逐个数据计算
    % 预测训练集中每一个数据的标签（取脉冲数量最多的输出神经元所代表的标签）  
    if ~isempty(sim_train)

        % 预测训练集中每一个数据的标签
        labels = -1*ones(1,length(sim_train));
        for y = 1:length(sim_train) 
%             labels(y) = pre_data_label(sim_train{y},neuron_labels,num_neurons,num_patterns); 

        % 直接取max
        spike_rates = zeros(1,num_neurons);
        for i = 1:num_neurons
            spike_rates(1,i) = sum(sim_train{y}.Zt(1,:)==i);
        end
        [~,max_response_neuron_index] = max(spike_rates);
        labels(y) = neuron_labels(max_response_neuron_index);

        end

        % 计算准确率
        num = 0;
        for j = 1:length(sim_train)
            if labels(j) == sim_train{j}.seq_id
                num = num + 1;
            end
        end
        cur_accuracy = [num/length(sim_train);iteration/save_interval];
        train_accuracy = [train_accuracy,cur_accuracy];
    else
        train_accuracy = [0;0];
    end

%% 训练准确率可视化
    y_ticks = 0:0.1:1;
    x_ticks = 0:1:train_accuracy(2,end);
    plot(train_accuracy(2,:), train_accuracy(1,:));
    ylim([0 1]);
    xticks(x_ticks);
    yticks(y_ticks);
    xticklabels(x_ticks);
    yticklabels(y_ticks);
    title('Train Accuracy');
    xlabel('itration');
%     drawnow;

    if last_iteration
        save_fig( gcf, 'Train Accuracy' );
    end
end
