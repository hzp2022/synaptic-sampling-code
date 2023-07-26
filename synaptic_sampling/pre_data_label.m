function pre_label = pre_data_label(sim_data,neuron_labels,num_neurons,num_patterns)
% 预测当前数据的标签。
% 
    % 输出神经元个数>总类别数，多个输出神经元代表同一个标签的情况（考虑到10个输出神经元情况下信息损失太大，准确率上不去）
    spike_rates = zeros(1,num_neurons);
    for i = 1:num_neurons
        spike_rates(1,i) = sum(sim_data.Zt(1,:)==i);
    end
    ranking = get_recognized_number_ranking(neuron_labels,spike_rates,num_patterns);
    pre_label = ranking(1); 
end