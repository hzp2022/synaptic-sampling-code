function neuron_labels = get_neuron_labels_s(sim_train,num_neurons,pat_labels)
% 自己编写的获取各输出神经元标签的方法。
% 根据当前迭代的所有训练数据确定，输出神经元哪个标签的平均响应次数最多则代表该标签。
% 

%     mixed_sim_train = [];
%     for i = 1:length(sim_train)
%         mixed_sim_train = append_data( mixed_sim_train, sim_train{i} );
%     end
% 
%     if isempty(mixed_sim_train)
%         neuron_labels = -1*ones(1,num_neurons);
%     else
%         neuronal_responses_to_label = zeros(num_neurons,length(pat_labels));
%         for u = 1:num_neurons
%             for v = 1:length(pat_labels) 
%                 neuronal_responses_to_label(u,v) = (sum(mixed_sim_train.Zt(1,:) == u & mixed_sim_train.Zt(2,:) == v-1)/sum(mixed_sim_train.seq_id(:) == v-1));
%             end                                  
%         end
%         [~, max_index] = max(neuronal_responses_to_label,[],2);
%         for j = 1:num_neurons
%             if all(neuronal_responses_to_label(j,:) == 0) ||  all(isnan(neuronal_responses_to_label(j,:)) | (neuronal_responses_to_label(j,:) == 0))
%                 max_index(j) = -1;
%             end
%         end
%         max_index(max_index > 0) = max_index(max_index > 0) - 1;
%         neuron_labels = max_index;
%     end


    mixed_sim_train = [];
    for i = 1:length(sim_train)
        mixed_sim_train = append_data( mixed_sim_train, sim_train{i} );
    end

    if isempty(mixed_sim_train)
        neuron_labels = -1*ones(1,num_neurons);
    else
        neuronal_responses_to_label = zeros(num_neurons,length(pat_labels));
        for u = 1:num_neurons
            for v = 1:length(pat_labels) 
                neuronal_responses_to_label(u,v) = (sum(mixed_sim_train.Zt(1,:) == u & mixed_sim_train.Zt(2,:) == v)/sum(mixed_sim_train.seq_id(:) == v));
            end                                  
        end
        [~, max_index] = max(neuronal_responses_to_label,[],2);
        neuron_labels = max_index';
    end 
end