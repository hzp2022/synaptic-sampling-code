function save_path = do_learning_task( varargin )
% DO_LEARNING_TASK runs an experiment that uses the HMM SEM network. 
% DO_LEARNING_TASK运行使用HMM SEM 网络的实验。
%
% function save_path = do_learning_task( exp_path, pat_sequences, ... )
%
% 将patterns训练到HMM SEM网络中。返回包含训练结果的路径。
%

%% init  初始化

    % 处理传递给do_learning_task函数的参数
    [ num_neurons, ...           % 输出神经元数量
      num_inputs, ...            % 输入神经元数量
      num_train_sets, ...        % 训练集数量
      num_runs, ...              % 数据集应被处理的次数
      seq_probs, ...             % 序列概率
      seq_ids, ...               % 序列id
      save_interval, ...         % 两个保存文件之间的迭代次数
      num_test_sets, ...         % 测试集数量
      show_fig, ...              % 展示图像标志
      pat_labels, ...            % 模式标签
      num_epochs, ...            % 时期数
      train_set_generator, ...   % 训练集生成器
      net, ...                   % 网络
      pretrain_ff_weights, ...   % 预训练前馈权重标志
      field_collectors, ...      % 字段收集器
      net_V, ...                 % recurent网络
      regen_seqs, ...            % 在每个时期重新生成序列标志
      save_network_only, ...     % 仅保存网络标志
      sleep_phase_length, ...    % 睡眠时期时间长度
      network_modifier, ...      % 网络修改器
      varargin ] = snn_process_options( varargin, ...
                                        'num_neurons', 10, ...
                                        'num_inputs', [], ...
                                        'num_train_sets', 50000, ...
                                        'num_runs', 1, ...
                                        'seq_probs', [], ...
                                        'seq_ids', [], ...
                                        'save_interval', 10000, ...
                                        'num_test_sets', 10000, ...
                                        'show_fig', false, ...
                                        'pat_labels', {'1','2','3','4','5','6','7','8','9','10'}, ...
                                        'num_epochs', 1, ...
                                        'train_set_generator', [], ...
                                        'network', [], ...
                                        'pretrain_ff_weights', false, ...
                                        'collect', {}, ...
                                        'net_V', [], ...
                                        'regen_seqs', false, ...
                                        'save_network_only', false, ...
                                        'sleep_phase_length', 0, ...
                                        'network_modifier', [] );


    snn_options('RequiredMethods',{'train', 'sample', 'performance'});  % 设置SNN选项
    
    close all; drawnow;

    save_path = snn_get_session_path();  % 返回当前会话的保存路径：D:\synaptic-sampling-code\results\exp-mix-gauss\2023-03-15-14-39-35\
    
    if isempty( save_path )  
        return; 
    end

    data_set_files = dir( [ save_path, 'data_set_*.mat' ] ); 

    continue_training = 0;  % 继续训练flag
    cur_iteration = 1;      % 当前迭代（一个脉冲序列迭代一次）
    cur_epoch = 1;          % 当前epoch
    
    if ~isempty( data_set_files )  

        continue_training = sscanf( data_set_files(end).name, 'data_set_%d.mat' ); 

        u_input = input( sprintf( 'continue training at iteration? (default %i): ', continue_training ), 's' );

        if ~isempty( str2double( u_input ) )
            continue_training = str2double( u_input );
            cur_iteration = mod( continue_training, 100000 )+1;
            cur_epoch = floor( continue_training/100000 )+1;
            
            if (cur_iteration <= 0)
                cur_iteration = 1;
            end
            if (cur_epoch <= 0)
                cur_epoch = 1;
            end
        end
    end

%% create data sets  创建数据集

    if isempty( train_set_generator )  
        error( 'Argument ''train_set_genrator'' required!' );  
    end

    if ~isfield( train_set_generator, 'pat_labels' )  % 如果模式标签pat_labels不是结构体数组train_set_generator的一个字段
        train_set_generator.pat_labels = pat_labels;  % 给train_set_generator定义pat_labels字段
    end
    
    
    if isempty( num_inputs ) 
        if isempty( train_set_generator ) 
            error( 'Argument ''train_set_genrator'' or ''num_inputs'' required!' );  
        end    
        num_inputs = length( train_set_generator.patterns{1} );  
    end
    
    if ~isempty( net )          % 如果已经存在一个网络（初始状态无网络）
        continue_training = 1;  % 将继续训练标志置为1
    end
  
    snn_save('training_set.mat',train_set_generator);  % 将训练集生成器train_set_generator的所有字段及字段值保存到training_set.mat
    
%% create network  创建网络&测试数据集

    for epoch = cur_epoch:num_epochs   % 从当前epoch开始逐一遍历（暂时设置为只有一个epoch）
        
        if ( continue_training == 0 )  % 如果不是处于继续训练的状态（表明还没创建网络）
            
            % 创建一个新的网络
            net = snn_new( 'num_neurons', num_neurons, 'num_inputs', num_inputs, varargin{:} );

            % 创建测试数据集
            if regen_seqs || (epoch == 1)  % 如果每个epoch重新生成序列标志为1或者当前epoch为第1个epoch
                
                % 创建测试数据集
                snn_progress('creating test sets');  % 展示一个简单的进度条:creating test sets...
                test_set = cell(1,num_test_sets); 
                all_test_labels = snn_load_data( 'MNIST\data_set\test_set_labels.mat' ).test_labels+1;
                all_test_images = snn_load_data( 'MNIST\data_set\test_set_images.mat' ).test_images;
                for i = 1:num_test_sets                 
                    train_set_generator.seq_id = all_test_labels(i);
                    train_set_generator.mode = 'test'; 
                    test_set{i}.data = train_set_generator.fcn_generate( train_set_generator, all_test_images(:,i) );  
                    snn_progress(i/num_test_sets); 
                end
                snn_progress();  % 展示一个简单的进度条：done.
            end
                       
            % 预训练前馈权重的处理（本实验不做预训练处理）
            if pretrain_ff_weights
                pats = [ train_set_generator.patterns{1:num_patterns} ];
                net.W = repmat( log(pats/10), 1, ceil(num_neurons/num_patterns) )';
                net.W = max( -50, net.W(1:num_neurons,1:num_inputs) );
            end
            
            if ~isempty( net_V )  
                net.V = net_V;
            end
        else
            net = snn_set( net, varargin{:} );  % 继续训练情况下（表明已经有一个网络了）设置SNN网络参数，得到修改后的net结构
        end

        continue_training = 0;                  % 将继续训练标志置为0
        
        net.num_runs = 1;                       % 数据集应被处理的次数（每处理一次生成一个脉冲序列并对网络进行一次更新，这里我们一次处理一个脉冲序列，故设为1）                    
        net.hX_init = zeros( num_inputs, 2 );   % 前馈PSPs的初始化
        net.hZ_init = zeros( num_neurons, 2 );  % recurrent突触后电位的初始化
               
        dump_params( net, train_set_generator, varargin );  % 将net、train_set_generator、snn_options写入D:\synaptic-sampling-code\results\exp-mix-gauss\2023-03-18-08-56-04\params.txt

 %% train network  训练网络

        tic;                        % 启动秒表计时器     
        sim_train = [];             % 模型训练过程中产生的脉冲序列      
        mean_time_per_epoch = nan;  % 每个epoch的平均时间
        all_seq_ids = [];           % 记录每个epoch的所有脉冲序列id
        num_trials = [];            % 记录每个epoch的各脉冲序列属于第几个trial（本实验一次就处理一个脉冲序列所以每个脉冲序列都属于该次处理的第1个trial）
        test_accuracy = [];         % 记录测试准确率
        train_accuracy = [];        % 记录训练准确率
        % neuron_labels = -1*ones(1,num_neurons);  % 测试：记录每次迭代后各输出神经元所代表的标签
        neuron_labels = rand_int(1,num_neurons,1,10);
        last_iteration = false;     % 记录是否为最后一次迭代

        % 遍历整个训练集
        for i = cur_iteration:(num_train_sets+1) 

            iteration = net.iteration;  % 拿到net的iteration字段值（初始时为0）
            
            if ~isempty(network_modifier)  
                net = network_modifier.fcn_modify( network_modifier, net );
            end
            
            if num_train_sets - iteration < save_interval
                last_iteration = true;  % 用于判断是否为最后一次迭代
            end
            
            % 如果当前网络的迭代次数iteration能整除两个保存文件之间的迭代次数save_interval（本实验每处理50个脉冲序列就将这50个脉冲序列和该时刻的net存入data_set_xxxxxxxxx.mat）
            if ( mod(iteration,save_interval) == 0 )  
                fprintf( '\niteration: %i/%i\n', iteration, num_train_sets );        % 打印迭代进度（eg：iteration: 150/162000）
                file_name = sprintf( 'data_set_%02d%07d.mat', epoch-1, iteration );  % 将file_name设置为'data_set_xxxxxxxxx.mat'
               
                if save_network_only  
                    snn_save( file_name, 'net', 'sim_train' ); 
                else  
                    net_sim = net;
                        for j = 1:num_test_sets
                            net_sim.use_inhibition = true; 
                            [sim_test{j},~] = snn_simulate( net_sim, test_set{j}.data, 'collect', { 'Xt', 'Pt', 'Zt', 'T', field_collectors{:}} );  
                        end 
                    
                    % 计算当前模型性能（条件熵，仅能代表分类结果（测试数据被分类为某一类别）的不确定性）
                    cur_performance = snn_performance_s(sim_test,net);
                    performance( epoch, iteration/save_interval+1 ) = cur_performance; 
                        
                    data_set.net = net;
                  
                    data_set.sim_train = sim_train;
                    data_set.sim_test = sim_test;
                    data_set.performance = performance;

                    % 若是最后一次迭代，则绘制条件熵
                    if last_iteration
                        plot_conditinal_entropy(data_set.performance,last_iteration);  % 绘制条件熵
                    end

                    % 计算并绘制训练准确率
                    train_accuracy = plot_train_accurracy(num_neurons,neuron_labels,train_accuracy,sim_train,iteration,save_interval,last_iteration,train_set_generator.num_patterns);
                    cur_train_accuracy = train_accuracy(1,end);

                    % 确定各个输出神经元所代表的标签（根据当前迭代的所有训练数据确定，输出神经元对哪个标签的平均响应次数最多则代表该标签）
                    if ~isempty(sim_train)
                        neuron_labels = get_neuron_labels_s(sim_train,num_neurons,pat_labels);
                    end 
                    
                    % 计算并绘制测试准确率
                    test_accuracy = plot_test_accurracy(num_neurons,neuron_labels,test_accuracy,sim_test,iteration,save_interval,last_iteration,train_set_generator.num_patterns);
                    cur_test_accuracy = test_accuracy(1,end);

                    % 非仅保存网络情况下，将要用的字段保存到到file_name（data_set_xxxxxxxxx.mat）
%                     snn_save( file_name, 'net', 'sim_train', 'sim_test', 'all_seq_ids', ...
%                              'performance', 'num_trials', 'seq_probs','neuron_labels' );
                    snn_save( file_name, 'net', 'sim_train', 'sim_test', 'all_seq_ids', ...
                             'performance','neuron_labels','cur_train_accuracy','cur_test_accuracy','train_accuracy','test_accuracy' );

                    % 展示输入脉冲序列、输出脉冲序列、网络活动At和performance
                    if show_fig
                        plot_data_set( data_set );
                    end 
                    
                end
                
%                 % 如果是最后一次迭代，则绘制输出脉冲序列
%                 if last_iteration
%                     plot_output_sequence(neuron_labels,sim_test,num_neurons,num_test_sets,train_set_generator.pattern_length,'Output after Learning');
%                 end
                
                % 进度提示
                time_elapsed = toc;  % 处理save_interval（本实验为50）个脉冲序列所经过的时间
                tic;                 % 再次启动秒表计时器
                % 计算每个epoch的平均时间
                if isnan(mean_time_per_epoch) || (i <= cur_iteration+save_interval)  
                    mean_time_per_epoch = time_elapsed;  
                else
                    mean_time_per_epoch = time_elapsed*0.05 + 0.95*mean_time_per_epoch; 
                end
                % 计算预计完成时间，然后打印提示信息（eg：elapsed time: 2.28s,   estimated time to finish: 2 hour(s).）
                if i>cur_iteration  
                    est_time_finish = round(mean_time_per_epoch/save_interval*(num_train_sets-i+1));  
                    units = {'second', 'minute', 'hour'}; 
                    unit_id = 1;  
                    % 将估计完成时间转化为时、分、秒
                    while (unit_id<=length(units)) && (est_time_finish>=100)  
                        est_time_finish = round(est_time_finish/60);  
                        unit_id = unit_id+1; 
                    end
                    fprintf( 'elapsed time: %.2fs,   estimated time to finish: %.0f %s(s).\n', time_elapsed, est_time_finish, units{unit_id} );  
                end
                
                sim_train = [];  % 将sim_train重置为[]

            end
            
            % 记录当前脉冲序列的id（后面根据该id在指定集群得到sample）
            if isempty( seq_ids ) 
                seq_id = find( cumsum(seq_probs) > rand(), 1 );
            else
                seq_id = seq_ids( mod(i-1,length(seq_ids))+1 );  % 在seq_ids中逐一拿到id
            end

            all_seq_ids( epoch, i ) = seq_id;     % 定义数组all_seq_ids按行分别存储每个epoch的所有脉冲序列id（每次遍历一个脉冲序列就添加一个id）
            train_set_generator.seq_id = seq_id;  % 将当前脉冲序列的id记录到train_set_generator
            train_set_generator.mode = 'train';   % 将train_set_generator的mode设置为train（为每个脉冲序列都指定mode为'train'）

            net.num_runs = num_runs;  % 更新net的num_runs字段（本实验num_runs恒为1）
            
            if i ~= num_train_sets+1
                % 在所有提供的输入序列（本实验为1个脉冲序列）上一次性更新网络权重
                [net,cur_sim_train] = snn_update_ct( net, [], ...
                                                 'set_generator', train_set_generator, ...
                                                 'collect', field_collectors );
            end
                                         
            % 对睡眠时期的处理（本实验没有睡眠时期）
            if (sleep_phase_length > 0)  
                eta_old=net.eta; hX_old=net.hX; hZ_old=net.hZ;
                net.eta=-eta_old; net.hX(:)=0;
                snn_update_ct( net, append_data( [], [], 'min_length', sleep_phase_length ) );
                net.eta=eta_old; net.hX=hX_old; net.hZ=hZ_old;
            end

            num_trials( epoch, i ) = net.num_trials;  % 定义数组num_trials按行分别存储每个epoch的各脉冲序列属于第几个trial（本实验一次就处理一个脉冲序列所以每个脉冲序列都属于该次处理的第1个trial）

            net.num_runs = 1;  % 将net的num_runs再次置为1

            sim_test = cell(num_test_sets,1);  
            
            if iteration == 0
                sim_train{1} = cur_sim_train;
            else
                sim_train{mod(iteration,save_interval)+1} = cur_sim_train;
            end

        end

        cur_iteration = 1;  % 将当前的迭代标记重新置为1（即遍历下一个脉冲序列）  

    end
end

