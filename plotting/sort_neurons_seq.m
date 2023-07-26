function [idx, labels] = sort_neurons_seq( data_sets, num_neurons )
% 为多个数据集中的神经元生成排序索引，返回排好序的索引idx和对应的标签labels。
% 
% 输入：
%   data_sets：一个 cell 数组，包含多个数据集，每个数据集都是一个结构体数组。
%   num_neurons：一个整数，表示神经元的数量。
% 
% 输出：
%   排好序的索引idx和对应的标签labels。
% 


    
    % 初始化两个矩阵，spike_times 和 num_spikes，用于记录每个神经元的脉冲时间总和和每个神经元发放的脉冲数
    spike_times = zeros(num_neurons,length(data_sets));
    num_spikes = zeros(num_neurons,length(data_sets));
    
    t_offset = 0;  % 时间偏移量
    all_offsets = zeros( 1, length(data_sets) );  % all_offsets用于保存所有数据集的时间偏移量
    
    % 通过循环遍历每个数据集
    for i = 1:length(data_sets)
        
        data = data_sets{i};
        
        % 对于每个数据集的每个时间步骤，统计对应的神经元发放的脉冲时间，并累计到对应的spike_times和num_spikes矩阵中
        for j = 3:length(data)
            
            % 移除0脉冲（脉冲次数为0的数据）
            tmp_Zt = data(j).Zt(:,data(j).Zt(1,:)>0);
            
            data_lenght = double( size(tmp_Zt,2) );
            
            % 用sparse函数将脉冲时间信息填充到data_spikes中
            data_spikes = sparse( double( tmp_Zt(1,:) ), ...
                                  double( 1:data_lenght ), ...
                                  double( tmp_Zt(2,:) + t_offset ), ...
                                  num_neurons, data_lenght );
            
            % 更新num_spikes和spike_times的值
            spike_times(:,i) = spike_times(:,i) + sum( data_spikes, 2 );
            num_spikes(:,i) = num_spikes(:,i) + sum( data_spikes > 0, 2 );
        end
        
        all_offsets(i) = t_offset;  % 将当前数据集的时间偏移量保存到all_offsets中
        
        % 如果变量data为空，则跳过该数据集的处理
        if isempty(data)
            continue;
        end
        
        t_offset = t_offset + data(1).time(end);  % 更新t_offset变量以计算该数据集的偏移时间 
    end
    
    av_spike_times = zeros(num_neurons,1);  % 平均脉冲时间初始化（用于记录每个输出神经元的平均脉冲时间）   
    labels = zeros(num_neurons,1);  % 输出神经元对应的标签初始化（用于标记每个输出神经元代表的标签）
    
    % 对于每个神经元 i，找到具有最大脉冲计数的数据集 n_i，并根据该数据集计算神经元的平均发放时间 av_spike_times(i)
    for i = 1:num_neurons
        % n_i = find( num_spikes(i,:) > 0, 1, 'first' );
        [v,n_i] = max( num_spikes(i,:) );
        
        if isempty(n_i)
            av_spike_times(i) = inf;
        else
            av_spike_times(i) = spike_times(i,n_i)/num_spikes(i,n_i);
            
            data = data_sets{n_i};
            
            tm = data(1).time;
            lbls = data(1).labels;
            
            % 使用该数据集n_i中的时间戳tm和标签lbls来为神经元i分配标签，这通过检查av_spike_times(i)是否位于标签的时间窗口内来完成
            for j = 1:length( lbls )
                
                t_av_rel = av_spike_times(i) - all_offsets(n_i);
                
                if ( t_av_rel >= tm( lbls(j).start_sample ) ) && ...
                   ( t_av_rel <= tm( lbls(j).stop_sample ) )
                    labels( i ) = lbls(j).descriptor - 'A' + 1;
                end
            end
        end
    end
    
    % 将av_spike_times中的元素排序，并用排序后的索引来重排labels数组，以便它们与排序后的神经元顺序相对应
    [v,idx] = sort(av_spike_times);
    labels = labels(idx);
end
