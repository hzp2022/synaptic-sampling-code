function [net, data_out] = snn_process_data( net, fcn_data_processor, data_gen, ...
                                             step_size, num_runs, keep_data_order, ...
                                             lead_in, field_collectors )
% snn_process_data: process the data set using the given processor function. 使用给定的处理器函数处理数据集。
%
% [net, data_out] = snn_process_data( net, fcn_data_processor, data, ...
%                                     step_size, num_runs, keep_data_order, ...
%                                     lead_in, field_collectors )
%
% Process the data set using the given processor function. 
% The function handler fcn_data_processor is called for each data block of given data set.
% 使用给定的处理器函数来处理数据集。对于给定数据集的每个数据块，都会调用函数处理程序fcn_data_processor。
%
% input
%   net:                A SNN network.  一个SNN网络
%                       See <a href="matlab:help snn_new">snn_new</a>.
%   fcn_data_processor: Function handler pointing to a function with interface:  
%                       指向一个具有接口的函数的函数处理程序:
%                       [net,Z,P] = fcn_data_processor( net, data, ct )
%   data_gen:           A snn data structure or a string containing a file patterns that points to files from which the data structures should be loaded.
%                       一个snn数据结构或一个包含文件模式的字符串，它指向应从其加载数据结构的文件。
%                       See <a href="matlab:help snn_load_data">snn_load_data</a>.
%   step_size:          The block size of the data blocks.  数据块的块大小。
%   num_runs:           The number of times the data set should be processed.  数据集应被处理的次数。 
%   keep_data_order:    If true the data is processed in the given order, if false the order of the data is randomised before being processed.
%                       如果为真，数据按给定的顺序处理，如果为假，数据的顺序在被处理之前是随机的。
%   lead_in:            An integer number. snn_process_data patches the data with the given number of time steps from previous data set.  
%                       一个整数。snn_process_data使用先前数据集中给定数量的时间步长修补数据。
%   field_collectors:   A cell array strings that holds the field names of fields that are collected from the net structure.
%                       The fields are collected after each block that was processed and stored in the data_out structure.
%                       一个元胞数组字符串，用于保存从net结构中收集的字段的名称。这些字段在每个数据块被处理后被收集，并存储在data_out结构中。
%
% output
%   net:                The modified network structure.  修改后的网络结构。
%   data_out:           The processed data containing the default fields X and P and any additional fields that where collected by the field_collectors.
%                       处理后的数据包含默认字段X和P以及由字段收集器收集的任何额外字段。
%
% David Kappel 6.12.2010
%

    % 用perm记录排列顺序（得到一个升序的自然数列，由于我们一次只处理一个数据，故perm为1）
    if keep_data_order  
        perm = 1:num_runs;
    else
        perm = randperm(num_runs);
    end
    
    data_out = [];  % 定义变量dataout接收fcn_data_processor（这里是snn_sample_ctsp_lognormal的函数句柄）处理过的数据集
    
    % 如果net没有time字段，则给net添加time字段并初始化为0
    if ~isfield(net,'time')
        net.time = 0;
    end
    
    % 生成和处理num_runs（数据集应该被处理的次数，由于是在线学习，故这里num_runs为1）次数据
    for i=1:num_runs  
        if strcmp(func2str(data_gen.fcn_generate), '@(data_gen)(def_data_generator(data_gen))')  
            data_set = data_gen.fcn_generate( data_gen );
        else
            all_train_images = snn_load_data( 'MNIST\data_set\train_set_images.mat' ).train_images;
            data_set = data_gen.fcn_generate( data_gen, all_train_images(:,net.iteration+1) );  % 随机生成混合高斯pattern的脉冲序列（此处的data_set就是生成的一个脉冲序列的信息）
        end
        
        % 对reset_psps为ture的处理（本实验无需重新设置PSPs）
        if isfield( net, 'reset_psps' ) && net.reset_psps
            if isfield( net, 'hX_init' )
                net.hX = net.hX_init;
                net.hZ = net.hZ_init;
            else
                net.hX(:) = 0;
                net.hZ(:) = 0;
            end
            
            if isfield( net, 'last_spike_t' )
                net.last_spike_t(:) = 0;
            end
        end

        net = fcn_data_processor( net, data_set, [1,length(data_set.time)] );  % 给net喂一个脉冲序列得到修改后的net结构（该过程中提取了winner神经元来生成给定WTA网络的输出）
        net.time = net.time + data_set.time(end);  % 将模式时间长度0.2000累加到net的time字段

        % 定义data_fields结构体作为中间数据结构来收集data_out（train_set）
        if ( nargout > 1 ) 

            % 遍历field_collectors里面的每个字段，如果是net中有的字段，则将net中的字段和字段值复制到data_out，反之将data_set中的对应字段值复制到data_out（train_set）
            for c = 1:length(field_collectors)
                cur_field = field_collectors{c};  
                if isfield(net,cur_field)&&(cur_field~="time")         
                    if cur_field(end) == 't'      
                        data_fields.(cur_field) = net.(cur_field); 
                    else
                        data_fields.(cur_field) = net.(cur_field)(:);  
                    end
                else
                    data_fields.(cur_field) = data_set.(cur_field);    
                end
            end
            
            % 将当前的样本点信息（3维空间中的一个点）记录到data中
            data_fields.cur_sample = data_set.cur_sample;

            data_out = append_data( data_out, data_fields ); 
            data_out.time = data_out.time(1,3:end);
        end
        
        if isfield(net, 'p_user_interupt')
            break;
        end
    end
end
