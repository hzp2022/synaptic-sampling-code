function data = generate_mix_gauss_pattern_sequence_nd( pat_gen, varargin )  
% generate_mix_gauss_pattern_sequence_nd
%
% 生成由给定长度的速率模式组成的尖峰序列。
%

    % 如果输入参数pat_gen为字符数组且为'init'
    if ischar( pat_gen ) && strcmp( pat_gen, 'init' )  

        % 处理传递给generate_mix_gauss_pattern_sequence_nd函数的参数
        [ pattern_length, ...          % 模式时间长度
          pattern_padding_length, ...  % 模式填充长度
          background_noise, ...        % 背景噪声
          num_patterns, ...            % 模式集群个数
          num_dim, ...                 % 数据维度（类比特征个数）
          input_dim, ...               % 输入维度（输入神经元的个数）
          input_std, ...               % 输入的标准差
          pattern_rate, ...            % 模式率（单个输入神经元的脉冲发射率由神经元调谐曲线下的感觉体验支持给出（在0Hz和80Hz之间归一化））
          varargin ] = snn_process_options( varargin, ...                        
                                            'pattern_length', 0.100, ...          
                                            'pattern_padding_length', 0.000, ...  
                                            'background_noise', 2, ...            
                                            'num_patterns', 7, ...                
                                            'num_dim', 3, ...                     
                                            'input_dim', 1000, ...                
                                            'input_std', 0.3, ...                
                                            'pattern_rate', 80 );                

        % 定义一个结构体data，并初始化一些键值对
        data = struct;  
        data.num_inputs = input_dim;                           
        data.input_std = input_std;                            
        data.pattern_length = pattern_length;                  
        data.pattern_padding_length = pattern_padding_length;  
        data.background_noise = background_noise;              
        data.pattern_rate = pattern_rate;                      
        data.num_dim = num_dim;                                
        data.num_patterns = num_patterns;                      
        

%         data.gauss_means = 0.5+0.2*randn(num_dim,num_patterns);  % 高斯均值（每个分量都是从Normal(0.5, 0.2^2)中独立抽取的，对于每个集群都有三个维度的高斯均值）
%         data.gauss_means = [0.1 0.9 0.1;0.9 0.1 0.9;0.5 0.5 0.1];
%         data.gauss_means = [0.4848 0.3891 0.8657;0.6500 0.3946 0.4121;0.5276 0.8331 0.4324]; % 效果还行
        data.gauss_means = [0.3620    0.1320    0.6810    0.1670    0.2070    0.8660    0.6920;...
                            0.5490    0.8660    0.7340    0.6300    0.8090    0.3300    0.3990;...
                            0.4080    0.3730    0.5650    0.1030    0.8420    0.5640    0.2250];
        
%         data.gauss_vars = 0.04*repmat(eye(num_dim),1,num_patterns)+0.01*randn(num_dim,num_dim*num_patterns);  % 高斯聚类中心的协方差矩阵（由0.04Ⅱ+0.01ξ随机给出，其中Ⅱ是3维的身份矩阵，ξ是一个从Normal(0, 1)中随机抽取的数值矩阵，eg：第一行为随机变量x分别与7个集群的x,y,z的方差or协方差）     
        data.gauss_vars = [0.0480   -0.0060   -0.0010    0.0540   -0.0030   -0.0110    0.0330    0.0220         0    0.0260    0.0050 -0.0170    0.0480    0.0050    0.0070    0.0420    0.0080   -0.0110    0.0390   -0.0050    0.0110;...
                           0.0060    0.0260    0.0010   -0.0020    0.0360   -0.0050   -0.0010    0.0340    0.0110   -0.0040    0.0440 -0.0220   -0.0020    0.0270   -0.0060    0.0030    0.0470    0.0040   -0.0030    0.0400    0.0050;...
                           0.0130   -0.0140    0.0460   -0.0050    0.0100    0.0240    0.0100   -0.0210    0.0400   -0.0010   -0.0010  0.0390   -0.0190    0.0090    0.0420   -0.0040   -0.0080    0.0370   -0.0040   -0.0120    0.0360];
        
        data.tuning_means = rand(num_dim,input_dim);  % 调谐均值（取（0,1）之间的随机数，对于每个sample每个神经元都有三个维度的调谐均值）              
        
        data.fcn_generate = @( data_gen, i )( generate_mix_gauss_pattern_sequence_nd( data_gen, i ) );  % 设置函数句柄（方便后面将其作为参数传递给另一个函数）
    
    % 如果输入参数pat_gen是结构体
    elseif isstruct( pat_gen )   

        i = pat_gen.seq_id;       % 随机取的一个id（3-7中的一个数，见run_expriment.m（定义所有待生成的脉冲序列id）和do_learning_task.m（取一个id））                
        n_dim = pat_gen.num_dim;  % 数据维度（3）
    
        
        sample = pat_gen.gauss_means(:,i) + pat_gen.gauss_vars(:,((i-1)*n_dim+1):(i*n_dim))*randn(n_dim,1);  % 在集群i中采一个样本点
        
        
        % 高斯分布的exp部分除以exp^(1/2)（1000个输入神经元中的每一个都被分配到一个σ=0.3的高斯调谐曲线，调谐曲线中心独立而平等地分布在单位立方体上）
        pattern = exp( -(1/(pat_gen.input_std)^2)*sum( (repmat(sample,1,pat_gen.num_inputs) - pat_gen.tuning_means(:,1:pat_gen.num_inputs)).^2, 1 ) )';  
        
        if pat_gen.pattern_length > 0.0  
        
            if ( pat_gen.pattern_padding_length > 0 )  

                % 有模式填充情况下生成由给定长度的速率模式组成的尖峰序列（本实验无模式填充）
                data = generate_pattern_sequence( { pat_gen.background_noise*ones(numel(pattern),1), pat_gen.background_noise + pat_gen.pattern_rate*pattern }, ...  
                                                  { [1,2,1] }, ...                                                                                                   
                                                  [pat_gen.pattern_padding_length/2, pat_gen.pattern_length, pat_gen.pattern_padding_length/2], ...                              
                                                  varargin{:}, ...                                                                                                   
                                                  10, ...                                                                                                           
                                                  0, ...                                                                                                             
                                                  {' ', sprintf('%.0f',pat_gen.seq_id) } );                                                                                                                                        
            else
                % 无模式填充情况下生成由给定长度的速率模式组成的尖峰序列
                data = generate_pattern_sequence( { pat_gen.background_noise*ones(numel(pattern),1), pat_gen.background_noise + pat_gen.pattern_rate*pattern }, ...  % patterns：{背景噪声对应的脉冲数量,背景噪声对应的脉冲数量+神经元发射脉冲数量的期望}
                                                  { 2 }, ...                                    % pattern_sequence:模式序列在pattern的索引位置为2，即pattern{2}
                                                  pat_gen.pattern_length, ...                   % pattern_length:模式时间长度0.2s
                                                  varargin{:}, ...                              % num_sequence:生成脉冲序列的个数
                                                  10, ...                                       % targets_per_pattern:（待定）
                                                  0, ...                                        % length_std:模式时间长度标准差（这里固定0.2s故为0）
                                                  {' ', sprintf('%.0f',pat_gen.seq_id) } );     % pattern_lable:{'','模式标签'}
            end
        end
        
        % 在data中记录pattern和sample
        data.cur_pattern = pattern;  
        data.cur_sample = sample;
        data.seq_id = pat_gen.seq_id;

    else
        error( 'unexpected input type!' );  
    end

end
