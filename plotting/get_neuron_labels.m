function [labels, num_spikes] = get_neuron_labels( sim_data, num_neurons, pat_labels, mean_ft )
%
% Get the neuron lables from the porvided simulation data.  从提供的仿真数据中获取神经元标签。
%

    num_patterns = length( pat_labels );  % 获取待匹配标签的数量

    num_spikes = zeros(num_neurons,num_patterns);  % 记录每个输出神经元在每个集群（标签）的发放次数
    
    % 如果输入的 sim_data 不是 cell 类型，则把 sim_data 放到 cell 里
    if ~iscell( sim_data )
        tmp = cell(1,1);
        tmp{1} = sim_data;
        sim_data = tmp;
    end
    
    % 如果没提供mean_ft参数，则利用sim_data中的数据计算每个神经元在每个集群的平均发放时间mean_ft和发放次数num_spikes
    if (nargin < 4)
        
        % 初始化平均发放时间mean_ft和发放次数num_spikes
        mean_ft = zeros( length(sim_data), num_neurons );
        num_spikes = zeros( length(sim_data), num_neurons );
        
        for i_c = 1:length(sim_data)

            data_set = sim_data{i_c};  % 从sim_data中取一个数据

            if isempty( data_set )
                continue;
            end

            for i_s = 1:length( data_set )
                
                Zt = data_set(i_s).Zt;  % 拿到该数据下网络产生的输出脉冲历史
                seq_id = data_set(i_s).seq_id;  % 拿到该数据的seq_id

                % 遍历每个输出脉冲时间，计算平均发放时间mean_ft和发放次数num_spikes
                for t = 1:size( Zt, 2 )

                    mean_ft(seq_id,Zt(1,t)) = mean_ft(seq_id,Zt(1,t)) + Zt(2,t);  % 计算数据标签为seq_id条件下所有输出脉冲时间的累加和
                    num_spikes(seq_id,Zt(1,t)) = num_spikes(seq_id,Zt(1,t)) + 1;  % 计算数据标签为seq_id条件下所有输出脉冲的数量
                end
            end
        end
        
        mean_ft = mean_ft./num_spikes;  % 平均发放时间=总发放时间/总输出脉冲数量
    end
    
    labels = -ones(1,num_neurons);  % 初始化输出神经元的labels为全-1
    
%     %% 方案一 设为首次响应的标签
%     % 重新遍历sim_data中的每个数据
%     for i_c = 1:length(sim_data) 
%         
%         data_set = sim_data{i_c};  % 从sim_data中取一个数据
%         
%         if isempty( data_set )
%             continue;
%         end
%         
%         for i_s = 1:length( data_set )
%             
%             lbls = data_set(i_s).labels;    % 拿到该数据的labels（一个包含当前pattern的标签descriptor、第一个脉冲序号start_sample和最后stop_sample字段的结构体）
% 
%             tm = data_set(i_s).time;        % 拿到该数据的输入脉冲时间
%             seq_id = data_set(i_s).seq_id;  % 拿到该数据的seq_id
%             
%             % 指定每个神经元对应的标签，如果神经元没有对应的标签，则对应的元素为-1
%             for i = 1:num_neurons
%                 for j = 1:length( lbls )
% 
%                     l_id = strmatch( lbls(j).descriptor, pat_labels, 'exact' );  % 查找当前数据的标签在待匹配label中的索引（即标签）
%                     
%                     % 如果平均发放时间在当前数据的脉冲时间范围内（基本都会在范围内的）且第i个输出神经元还未被指定则将输出神经元i指定为该数据对应标签的专家，效果：将神经元i的标签设置为平均发射时间落在首个pattern时间的该pattern标签
%                     if ( mean_ft(seq_id,i) >= tm( lbls(j).start_sample ))  && ...
%                        ( mean_ft(seq_id,i) <= tm( lbls(j).stop_sample ) ) && ...
%                        ( labels( i ) < 0 ) && ~isempty(l_id)
%                          labels( i ) = l_id;  
%                     end
%                 end
%             end
%         end        
%     end

%% 方案二 设为脉冲数量最多的标签(一样多的情况，则取首次响应的标签)
    for i = 1:num_neurons
        if (~all(num_spikes(:, i) == 0))&&( labels( i ) < 0 )
            [~,label] = max(num_spikes(:,i));
            if num_spikes(label,i) > 0.5*sum(num_spikes(label,:))
                labels( i ) = label(1);
            end
        end
    end
end
