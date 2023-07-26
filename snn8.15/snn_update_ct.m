function [net, train_set] = snn_update_ct( net, train_set, varargin )
% snn_update_ct: 更新具有连续时间输入的SNN网络
%
% [net, train_set] = snn_update_ct( net, train_set, ... )
%
%  一次更新所有提供的输入序列上的网络权重。
%
% input
%   net:              一个SNN网络或一个整数。如果通过一个数字，就会创建一个具有给定数量神经元的网络。
%                     See <a href="matlab:help snn_new">snn_new</a>.
%   train_set:        训练数据或文件模式来加载数据。
%
% optional arguments
%   collect:          一个包含应从网络结构中收集的字段列表的字符串。这些字段在每个被处理的块之后被收集，并存储在data_out结构中。
%                     该字符串必须具有以下格式:
%                     '[<field1>,<field2>,...,<fieldN>]'
%
% see also
%   <a href="matlab:help snn_new">snn_new</a>
%   <a href="matlab:help snn_load_data">snn_load_data</a>
%

    if (nargin<2)  
        error('Not enought input arguments!');
    end

    if ~isstruct( net )  
        error('Unexpected argument type for ''net''!');
    end
    
    % 处理传递给本函数的参数
    [ field_collectors, ...
      set_generator ] = snn_process_options( varargin, ...
                                             'collect', {}, ...
                                             'set_generator', [] );
                         
    verbose = snn_options( 'verbose' );  % 获取snn选项的verbose字段（用于标记是否输出日志信息，此处为0）
    
    if isempty( verbose ) 
        verbose = true;
    end
    
    % 如果p_required_fields是net的字段，则将net中对应字段值添加到field_collectors
    if isfield( net, 'p_required_fields' )
        req_fields = snn_parse_args(net.p_required_fields);
        field_collectors = { field_collectors{:}, req_fields{:}};
    end
    
    field_collectors = { field_collectors{:},'seq_id','labels'};
    field_collectors = unique( field_collectors );  % 字段去重
    
    % 一次处理的sample个数（该模型为在线学习，一次处理一个sample，一个sample对应一个脉冲序列）
    if isfield( net, 'num_samples' )
        num_samples = net.num_samples;
    else
        num_samples = 1;
    end
    
    if isempty( set_generator )
        set_generator.fcn_generate = @( data_gen )( def_data_generator( data_gen ) );
        set_generator.data = train_set;
    end
    
    if (verbose)
        fprintf('updating network... trial:      0');
    end
    
    net.got_sample = false;  % 给net定义标记字段got_sample：用于标记当前是否处于获取sample（三维空间中的一个点）的状态
    
    num_trials = 0;  % 试验次数（记录当前脉冲序列属于本次处理的第几个脉冲序列，由于我们每次处理一个脉冲序列所以num_trials每次只累加到1）
    
    % 若当前net不处于获取sample的状态，则根据所提供的输入序列更新网络的全部权重
    while ~net.got_sample
        
        num_trials = num_trials + 1;  % 试验次数+1
        
        if (verbose)
            fprintf('%c%c%c%c%c%5d',8,8,8,8,8,num_trials);
        end        
        
        % 使用set_generator生成num_samples个数据（1个脉冲序列），并使用net.p_sample_fcn来处理数据（生成一个处理一个）
        [net, train_set] = snn_process_data( net, net.p_sample_fcn, ...
                                             set_generator, inf, num_samples, ...
                                             true, 0, field_collectors );

        % 更新网络
        net = net.p_train_fcn( net, train_set, 1:length(train_set) );
    end

    net.num_trials = num_trials;  % 更新net的num_trials字段
    
    if (verbose)
        fprintf( '\n' );
    end
    
    %% dafault data generator 默认数据生成器
    function data_set = def_data_generator( data_gen, i )
        data_set = data_gen.data(i);
    end
end
