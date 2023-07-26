% function [neuron_labels,accuracy,num_spikes,get_label_sim_free] = plot_accurracy(accuracy,sim_test,sim_free,num_neurons,num_test_sets,iteration,save_interval,pat_labels,free_run_data,field_collectors,net,h)
function accuracy = plot_accurracy(neuron_labels,accuracy,sim_test,sim_train,num_neurons,num_test_sets,iteration,save_interval,varargin)
% 绘制准确率。
% 
% 输入：
%   accuracy：        存储准确率的数组，每计算一次准确率往数组末尾添加一个元素
%   sim_test：        模拟后的测试集
%   sim_free：        模拟后的自由运行数据集
%   num_neurons：     输出神经元数量
%   num_test_sets：   测试数据数量
%   iteration：       当前迭代次数（记录处理第几个训练数据）
%   save_interval：   每次迭代处理的训练数据数量
%   pat_labels：      模式的所有标签
%   free_run_data：   模拟前的自由运行数据集
%   field_collectors：字段收集器
%   net：             当前网络
% 
% 可变输入：
%   istest:           标记当前绘制的准确率是否为测试准确率
%   last_iteration:   标记是否为最后一次迭代（方便保存最后一次迭代结束的准确率图）      
% 
% 输出：
%   neuron_labels：各输出神经元所代表的标签
%   accuracy：     添加了当前准确率的准确率数组
%   num_spikes：   确定各输出神经元代表的标签的那组输出脉冲序列的各输出神经元发放的脉冲数量
%   sim_free:      能确定各输出神经元所代表标签的sim_free数据
% 


% %     % 通过自由运行数据集确定神经元代表的标签（方案一，不可行）
% %     [neuron_labels, ~] = get_neuron_labels(sim_free,num_neurons,pat_labels);
% 
%     % 通过自由运行数据集确定神经元代表的标签（方案二）
%     % 对于有输出神经元没有代表标签的情况的处理，不断循环直到所有输出神经元都代表一个标签（需要重新snn_simulate）
%     net_sim = net;
%     [neuron_labels, num_spikes] = get_neuron_labels(sim_free,num_neurons,pat_labels);
%     
%     if all(neuron_labels ~= -1)&&(length(unique(neuron_labels)) == length(neuron_labels))
%         get_label_sim_free = sim_free;
%     else
%         while true
%             for w = 1:length(free_run_data)
%                 net_sim.use_inhibition = true;
%                 [get_label_sim_free{w},net_sim] = snn_simulate( net_sim, free_run_data{w}.data, 'collect', { 'Xt', 'Pt', 'Zt', 'T', field_collectors{:}} );        
%             end 
% 
%             [neuron_labels, num_spikes] = get_neuron_labels(get_label_sim_free,num_neurons,pat_labels);
% 
% %             % 允许多个输出神经元代表1个标签
% %             if all(neuron_labels ~= -1)
% %                 break;
% %             end
%         
%             % 不允许多个输出神经元代表1个标签
%             if all(neuron_labels ~= -1)&&(length(unique(neuron_labels)) == length(neuron_labels))
%                 break;
%             end  
%         end
%     end

%     % 预测测试集中每一个数据的标签（方案一:滑动窗口，投票）
%     for y = 1:length(sim_test)
%         sim_test{y}.Zt = [sim_test{y}.Zt(1,:);neuron_labels(sim_test{y}.Zt(1,:));sim_test{y}.Zt(2,:)];
%         cur_label = get_data_labels(sim_test{y}.Zt,{num2str(neuron_labels(1)),num2str(neuron_labels(2)),num2str(neuron_labels(3))});
%         labels{y} = {cur_label};
%     end 

    [istest,last_iteration,varargin] = snn_process_options(varargin,...
                                     'istest',false,...
                                     'last_iteration',false);
    if istest
%% 计算测试准确率
        % 预测测试集中每一个数据的标签（取脉冲数量最多的输出神经元所代表的标签）  
        for y = 1:length(sim_test) 
            cur_num_spikes = zeros(1,num_neurons);
            for i = 1:num_neurons
                cur_num_spikes(1,i) = sum(sim_test{y}.Zt(1,:)==i);
            end
            [~,cur_label] = max(cur_num_spikes);
            cur_label = neuron_labels(cur_label);
            labels{y} = cur_label;
        end
        % 计算准确率
        num = 0;
        for j = 1:num_test_sets
            if labels{j} == sim_test{j}.seq_id
                num = num + 1;
            end
        end
        cur_accuracy = [num/num_test_sets;iteration/save_interval];
        accuracy = [accuracy,cur_accuracy];
    
%% 可视化
        y_ticks = 0:0.1:1;
        x_ticks = 0:1:accuracy(2,end);
        plot(accuracy(2,:), accuracy(1,:));
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

    else
%% 计算训练准确率（方案一：通过逐个脉冲计算）
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

%% 计算训练准确率（方案二：通过逐个数据计算）
        % 预测训练集中每一个数据的标签（取脉冲数量最多的输出神经元所代表的标签）  
        if ~isempty(sim_train)
            for y = 1:length(sim_train) 
                cur_num_spikes = zeros(1,num_neurons);
                for i = 1:num_neurons
                    cur_num_spikes(1,i) = sum(sim_train{y}.Zt(1,:)==i);
                end
                [~,cur_label] = max(cur_num_spikes);
                cur_label = neuron_labels(cur_label);
                labels{y} = cur_label;
            end
            % 计算准确率
            num = 0;
            for j = 1:save_interval
                if labels{j} == sim_train{j}.seq_id
                    num = num + 1;
                end
            end
            cur_accuracy = [num/save_interval;iteration/save_interval];
            accuracy = [accuracy,cur_accuracy];
        else
            accuracy = [0;0];
        end

%% 可视化
        y_ticks = 0:0.1:1;
        x_ticks = 0:1:accuracy(2,end);
        plot(accuracy(2,:), accuracy(1,:));
        ylim([0 1]);
        xticks(x_ticks);
        yticks(y_ticks);
        xticklabels(x_ticks);
        yticklabels(y_ticks);
        title('Train Accuracy');
        xlabel('itration');
        drawnow;

        if last_iteration
            save_fig( gcf, 'Train Accuracy' );
        end
    end
end