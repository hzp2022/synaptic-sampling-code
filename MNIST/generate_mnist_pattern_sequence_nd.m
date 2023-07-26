function data = generate_mnist_pattern_sequence_nd( pat_gen, varargin )  
% generate_mnist_gauss_pattern_sequence_nd
%
% 生成由给定长度的速率模式组成的脉冲序列。
%

    % 如果输入参数pat_gen为字符数组且为'init'
    if ischar( pat_gen ) && strcmp( pat_gen, 'init' )  

        % 处理传递给generate_mnist_pattern_sequence_nd函数的参数
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
                                            'num_patterns', 10, ...                
                                            'num_dim', 784, ...                     
                                            'input_dim', 784, ...
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
        
%         data.tuning_means = rand(num_dim,input_dim); 
%         data.tuning_means = rand(num_dim,1);
%         data.tuning_means = diag(rand(num_dim, 1) * (1-eps) + eps, 0);

        data.fcn_generate = @( data_gen, image )( generate_mnist_pattern_sequence_nd( data_gen, image ) );  % 设置函数句柄（方便后面将其作为参数传递给另一个函数）
    
    % 如果输入参数pat_gen是结构体
    elseif isstruct( pat_gen )   

        if isempty(varargin)
            image = [];
        else
            image = cell2mat(varargin);
        end

        % sample = pat_gen.gauss_means(:,i) + pat_gen.gauss_vars(:,((i-1)*n_dim+1):(i*n_dim))*randn(n_dim,1);  % 在集群i中采一个样本点
        % pattern = exp( -(1/(pat_gen.input_std)^2)*sum( (repmat(sample,1,pat_gen.num_inputs) - pat_gen.tuning_means(:,1:pat_gen.num_inputs)).^2, 1 ) )'; 
        
%         sample = double(image(:));
%         pattern = exp( -(1/(pat_gen.input_std)^2)*sum( (repmat(sample,1,pat_gen.num_inputs) - pat_gen.tuning_means(:,1:pat_gen.num_inputs)).^2, 1 ) )'; 
%         pattern = exp( -(1/(pat_gen.input_std)^2)*(sample - pat_gen.tuning_means).^2); 
        
        pattern = double(image(:));  % 每个输出神经元的脉冲发射概率
        
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
                                                  1, ...                                        % num_sequence:生成脉冲序列的个数
                                                  10, ...                                       % targets_per_pattern:（待定）
                                                  0, ...                                        % length_std:模式时间长度标准差（这里固定0.2s故为0）
                                                  {' ', sprintf('%.0f',pat_gen.seq_id) } );     % pattern_lable:{'','模式标签'}
            end
        end
        
        % 在data中记录pattern和sample
        data.cur_pattern = pattern;  
        data.cur_sample = image;
        data.seq_id = pat_gen.seq_id;

    else
        error( 'unexpected input type!' );  
    end
end