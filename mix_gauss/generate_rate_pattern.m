function pat = generate_rate_pattern( pattern, pattern_length, process )
% 生成给定长度的速率模式。
%

    if (nargin < 3) 
        process = 'poisson';  
    end
    
    switch process  
        case 'poisson'  % 如果是'poisson'过程
            num_spikes = poissrnd( pattern*pattern_length );  % 从 lambda=(脉冲发射率*模式时长) 的泊松分布中随机采样得到1000个输入神经元在200ms发射的脉冲数量


            pat = zeros(2,sum(num_spikes),'single');  % 初始化pat为 2 x (1000个神经元发射的总的脉冲数量) 的全零矩阵

            start_i = cumsum( [1; num_spikes(1:end-1)] );  % 记录每个输入神经元发射脉冲的开始位置（即从第几个脉冲开始是该神经元发射的，这里先简单地初始化为由第1个神经元到1000个神经元顺序发射）
            
            % 逐一遍历1000个输入神经元，根据当前输入神经元发射脉冲的起始索引位置和终止索引位置更新pat
            for i = 1:length(num_spikes)  

                pat( 1, start_i(i):( start_i(i)+num_spikes(i)-1) ) = i;   % 将pat第一行的所有对应位置均设为当前输入神经元的索引号
                pat( 2, start_i(i):( start_i(i)+num_spikes(i)-1) ) = ...  % 将pat第二行的所有对应位置均设为[模式时间长度*(0,1)的随机数]（为每个脉冲随机分配脉冲时间）
                    pattern_length*rand( 1, num_spikes(i) );
            end

            % 将pat按第二行升序重新排列，得到的结果就是按照时间顺序（pat第二行）发射的输入神经元序列（pat第一行）
            [v,idx] = sort( pat(2,:) );  
            pat = pat(:,idx);  
            
        case 'regular'  
            num_spikes = round( pattern*pattern_length );

            pat = zeros(2,sum(num_spikes),'single');

            start_i = cumsum( [1; num_spikes(1:end-1)] );

            for i = 1:length(num_spikes);

                pat( 1, start_i(i):(start_i(i)+num_spikes(i)-1) ) = i;
                pat( 2, start_i(i):(start_i(i)+num_spikes(i)-1) ) = pattern_length*(0:(1/num_spikes(i)):(1-(1/num_spikes(i))));
            end

            [v,idx] = sort( pat(2,:) );
            pat = pat(:,idx);
    end
end
