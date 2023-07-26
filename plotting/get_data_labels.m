function labels = get_data_labels( Zt, pat_labels, init_lbls )
% 从提供的网络输出中获取数据标签。
% 通过遍历网络输出Zt中的每一列，根据一定的规则获取数据标签，并将其存储在 labels 结构体中。
%

    window_length = 0.010;   % 用于计算投票的时间窗口长度
    min_win_length = 0.020;  % 用于更新标签的时间窗口长度（超过这个长度则标签有效）
    
    % 根据输入参数的不同情况，初始化结构体labels和整型变量l_offs
    if (nargin > 2)
        labels = init_lbls;
        if isempty( fieldnames( init_lbls ) )
            l_offs = 0;
        else
            l_offs = length(init_lbls);
        end
    else    
        labels = struct();
        l_offs = 0;  % 表示起始标签编号的偏移量，用于保证标签编号的连续性
    end
    
    % 根据输入的网络输出Zt中第二行（每个元素代表当前脉冲时间的输出脉冲所代表的标签）的最大值确定标签的数量
    num_patterns = max( Zt(2,:) );

    % 定义一个用于统计票数的矩阵vote_map
    vote_map = zeros( num_patterns, 1 );
    
    win_t = Zt(3,1);
    start_sample = 1;
    
    last_spike = 1;
    
    current_vote = -1;
    
    i = 1;
    
    % 遍历Zt的每一列，更新vote_map
    for t = 1:size(Zt,2)

        cur_t = Zt(3,t);
        
        if ( Zt(2,t) > 0 )
            vote_map( Zt(2,t) ) = vote_map( Zt(2,t) ) + 1;
        end
        
        while ( cur_t - win_t > window_length )
            if ( Zt(2,last_spike) > 0 )
                vote_map( Zt(2,last_spike) ) = vote_map( Zt(2,last_spike) )-1;
            end
            last_spike = last_spike + 1;            
            win_t = Zt(3,last_spike);
        end
        
        % 计算该投票窗口内得票最多的模式编号vote以及概率support
        [support,vote] = max( mk_normalised( vote_map ) );
        
        % 如果概率小于0.5，则将vote设为-1（即没有投票结果）
        if ( support < 0.5 )
            vote = -1;
        end
        
        % 在得票最多的模式编号发生变化时
        if ( current_vote ~= vote )
            
            win_length = Zt(3,t) - Zt(3,start_sample);
            
            % 如果时间窗口长度大于min_win_length，则将当前时间窗口的标签信息存储到labels结构体中，并将i的值+1。
            if ( win_length > min_win_length  ) && ( current_vote > 0 )
                
                labels(i+l_offs).start_time = max(0,Zt(3,start_sample)-window_length/2);
                labels(i+l_offs).stop_time = max(0,Zt(3,t)-window_length/2);
                labels(i+l_offs).descriptor = pat_labels{current_vote};
                labels(i+l_offs).show_border = true;
                i = i+1;
            end
            
            current_vote = vote;
            
            start_sample = t;            
        end        
    end
    
    % 如果在整个网络输出Zt的遍历过程中没有生成任何标签，则将labels设为空
    if (i==1)
        labels = [];
    end
    
    win_length = Zt(3,t) - Zt(3,start_sample);
    
    if ( win_length > min_win_length  ) && ( current_vote > 0 )

        labels(i).start_time = Zt(3,start_sample);
        labels(i).stop_time = Zt(3,t);
        labels(i).descriptor = pat_labels{current_vote};
    end
end
