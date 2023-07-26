function ranking = get_recognized_number_ranking(neuron_labels, spike_rates,num_patterns)
% 对神经元的响应（spike_rates）进行统计和排序。
% 
% 输入：
%   assignments:神经元分类，即各输出神经元所代表的标签
%   spike_rates:各个输出神经元发放的脉冲数量
% 输出：
%   ranking:按降序排序的各个类别索引向量
% 
    summed_rates = zeros(1,10);     % 存储各个数字类别（0-9）的平均神经元响应
    num_assignments = zeros(1,10);  % 存储每个类别的神经元数量

    for i = 1:num_patterns
        num_assignments(i) = length(find(neuron_labels == i)); 
        if num_assignments(i) > 0
%             summed_rates(i) = sum(spike_rates(neuron_labels == i)) / num_assignments(i);
            summed_rates(i) = sum(spike_rates(neuron_labels == i)) ;
        end
    end
%     class_indexs_of_non_response = find( summed_rates == 0 );  % ps:类别'0'的索引为1

    [~, ranking] = sort(summed_rates, 'descend'); 

%     for j = 1:length(class_indexs_of_non_response)
%         ranking(class_indexs_of_non_response(j)) = 0;
%     end

end
