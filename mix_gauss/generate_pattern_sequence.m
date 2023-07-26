function data = generate_pattern_sequence( patterns, ...             % patterns
                                           pat_sequences, ...        % 目标pattern在patterns的索引
                                           pattern_length, ...       % 模式时间长度  
                                           num_sequences, ...        % 要生成的脉冲序列个数   
                                           targets_per_pattern, ...  % 每个pattern的目标数（待定，用于确定data(i).T）
                                           length_std, ...           % 模式时间标准差        
                                           pat_labels )              % 模式标签    
% 
% 生成由给定长度的速率模式组成的脉冲序列。
%

    seq_id = [];  % 脉冲序列id（标签）            
    
    time_padding = 0;  % 时间填充      
    
    st_process = 'poisson';  % 将脉冲序列的生成过程建模为poisson过程
    
    % 对不同输入参数的不同预处理
    if (nargin <= 2) && isstruct( patterns ) 
        set_generator = patterns;                                 
        patterns = set_generator.patterns;                       
        seq_id = set_generator.seq_id;                            
        pattern_length = set_generator.pattern_length;            
        targets_per_pattern = set_generator.targets_per_pattern;  
        length_std = set_generator.length_std;                    
        num_sequences = 1;                                        
        
        if isfield( set_generator, 'process' )                    
            st_process = set_generator.process;                   
        end
        
        if isfield( set_generator, 'time_padding' )              
            time_padding = set_generator.time_padding;            
        end
        
        if (nargin == 2) && ischar( pat_sequences ) && strcmp( pat_sequences, 'free_run' )  
            if isfield( set_generator, 'free_run_seqs' )                
                pat_sequences = set_generator.free_run_seqs{ seq_id };  
            else            
                pat_sequences = set_generator.pat_sequences{ seq_id };  
                pat_sequences(end) = length( patterns );               
            end
        else
            pat_sequences = set_generator.pat_sequences{ seq_id };      
        end
        
    elseif (nargin < 5)                           
        error( 'Not enought input arguments!' ); 
    elseif (nargin < 6)                           
        length_std = 0;                         
    end


    num_inputs = size( patterns{1}, 1 );  % 输入神经元个数
    
    num_pats = length( patterns );  % 全部pattern的个数（这里为2，一个是噪声的pattern，另一个是神经元活动+噪声的pattern）
    
    if iscell( pat_sequences )                        
        num_patterns = length( pat_sequences );  % 目标pattern个数（神经元活动+噪声的pattern）
    else
        [ num_patterns, pats_per_input ] = size( pat_sequences ); 
     	pat_sequences = mat2cell( pat_sequences, 1, repmat( pats_per_input, 1, num_patterns ) ); 
    end
    
    if ( numel( pattern_length ) == 1 )  % 为所有目标pattern定义相同的pattern_length（扩展为对应维度的列向量），本实验目标pattern只有一个，故无变化
        pattern_length = repmat( pattern_length, length( pat_sequences{1} ), 1 );  
    end
    
    if ( numel( length_std ) == 1 )  % 为所有目标pattern定义相同的length_std（扩展为对应维度的列向量），本实验目标pattern只有一个，故无变化
        length_std = repmat( length_std, length( pat_sequences{1} ), 1 );  
    end
        
    if (nargin < 7)  
        pat_labels = mat2cell( char( 'A' + (1:num_pats) - 1 ), 1, ones(1,num_pats) );  
    end
    
    sample_rate = 1000;  % 采样速率（单位时间采的sample个数）         
    
    data = struct();  % 定义结构体data（函数输出）
    
    % 生成num_sequences（本实验是1）个脉冲序列
    for i = 1:(num_sequences) 

        seq = pat_sequences{ mod(i-1,num_patterns)+1 };  % 得到目标pattern在patterns中的索引（2）
        pats_per_input = length( seq );  % 每个输入产生的pattern个数（1）                  
        
        pat_lengths = zeros(pats_per_input,1);  % 定义pat_lengths存储模式时间长度，并初始化为[]
        
        % 定义一些变量
        Xt = [];          % 用于存放pat（主要是考虑一个input有多个pattern的情况，遍历各个pattern产生的脉冲序列逐一添加至Xt末尾，本实验Xt=pat）         
        Lt = [];          % 用于存放更详细的pat信息：在pat的基础上为每个脉冲添加了该脉冲所属pattern索引（本实验为2，具体的是在pat中添加一行2）   
        time = 0;         % 用于记录当前脉冲序列的每个脉冲的发射时刻以及模式时间长度（其中模式时间长度作为time的最后一个元素）      
        labels = struct;  % 用于存放脉冲序列的id以及该脉冲序列的第一个和最后一个脉冲的脉冲数量编号

        t = 1;  % 计数器（用于记录一个pattern下产生的脉冲序列的脉冲个数）

        % 对一个input产生的所有目标pattern逐一进行处理（这里一个input对应一个目标pattern，故循环只跑一次）
        for l=1:pats_per_input  

            pat_no = seq(l);  % 定义中间变量，记录当前遍历到的目标pattern在patterns的索引（这里目标pattern只有一个，pat_no固定为2）

            pat_lengths(l) = randn()*length_std(l) + pattern_length(l);  % 计算当前遍历到的目标pattern的模式时间长度（本实验固定为0.2s）
            
            % 对模式时间长度<0.01s的情况发出警告                                      
            if (pat_lengths(l) < 0.010)  
                pat_lengths(l) = 0.010;  
                warning( 'Minimum pattern length is 10ms' ); 
            end
            
            % 生成给定长度的速率模式
            pat = generate_rate_pattern( patterns{ pat_no }, pat_lengths(l), st_process );
            
            pat(2,:) = pat(2,:) + sum( pat_lengths(1:(l-1)) );  % 由于每个input我们只生成一个pattern，故此处无需更新当前pattern对应的脉冲序列的各脉冲的脉冲时间
            
            num_spikes = size(pat,2);  % 生成的脉冲序列的脉冲数量（pat的列数）

            Xt = [ Xt, pat ];  % 将pat追加到Xt
            Lt = [ Lt, [pat(1,:); repmat(pat_no, 1, num_spikes); pat(2,:)] ];  % 将pat的第1行追加到Lt作为Lt的第一行，pat_no（即目标pattern在patterns中的索引）作为Lt的第二行，pat的第2行作为Lt的第三行
            time = [ time, pat(2,:) ];  % 将pat的第二行追加到time（time初值为0）

            if pat_no > length( pat_labels )                    
                labels(l).descriptor = '';                 
            else
                labels(l).descriptor = pat_labels{pat_no};  % 根据当前pattern索引（2）将该pattern标签记录到labels结构体   
            end
            labels(l).start_sample = t;              % 记录对当前pattern开始采样的脉冲序列的第一个脉冲序号                     
            labels(l).stop_sample = (t+num_spikes);  % 记录对当前pattern结束采样的脉冲序列的最后一个脉冲序号+1

            t = t+num_spikes;  % 每一个pattern结束都更新起始采样脉冲序号t
        end
        
        time = [ time, sum( pat_lengths )+time_padding ];  % 将模式时间长度添加至time的末尾

        total_length = ceil( time(end)*sample_rate );  % 0.2s内采到的总的sample个数 = 模式时间长度*sample_rate

        T = ceil( targets_per_pattern*pats_per_input*((1:total_length)/total_length));  % 得到1x200的矩阵其中1,2,...10各20个（暂时不知道该变量的含义和作用） 

        % 定义data结构体，设置data的字段（一个中间结构体，每次存储的是一个脉冲序列的信息）
        data(i).Xt = Xt;  
        data(i).Lt = Lt;  
        data(i).T = T; 
        data(i).time = time;                      
        data(i).x_range = single( 1:num_inputs );  
        data(i).labels = labels;                  
        data(i).sample_rate = sample_rate;         
        data(i).seq_id = seq_id;                  
    end
end
