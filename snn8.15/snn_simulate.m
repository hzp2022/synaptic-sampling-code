function [data_out,net] = snn_simulate( net, data_in, varargin )
% function [data_out] = snn_simulate( net, data_in, varargin )
% snn_simulate: generates the output of a given network  生成给定网络的输出
%
% data = snn_simulate( net, data, ... )
%
% Generates the output of a given network.  生成给定网络的输出
%
% input
%   net:           一个SNN网络。See <a href="matlab:help snn_new">snn_new</a>.
%   data:          用于加载数据的数据集或文件模式。
%
% optional arguments
%   step_size:        在重新计算性能之前训练的样本数。
%   lead_in:          将从以前的训练集中复制的样本数。
%   collect:          一个包含应从网络结构中收集的字段列表的字符串。这些字段在每个被处理的块之后被收集，并存储在data_out结构中。 
%                     该字符串必须具有以下格式:
%                     '[<field1>,<field2>,...,<fieldN>]'
%
% output
%   data:          网络模拟数据。
%
% see also
%   <a href="matlab:help snn_new">snn_new</a>
%   <a href="matlab:help snn_load_data">snn_load_data</a>
%   <a href="matlab:help snn_train">snn_train</a>
%

    if (nargin<2)
        error('Not enought input arguments!');
    end

    if ~isstruct( net )
        error('Unexpected argument type for ''data''!');
    end

    [ step_size, ...
      lead_in, ...
      collect, ...
      set_generator, ...
      verbose ] = ...
        snn_process_options( varargin, ...
                             'step_size', inf, ...
                             'lead_in', 0, ...
                             'collect', {}, ...
                             'set_generator', [], ...
                             'verbose', snn_options( 'verbose' ) );
    
    if isempty( verbose )
        verbose = true;
    end
    
    if isempty( set_generator )
        set_generator.fcn_generate = @( data_gen )( def_data_generator( data_gen ) );
        set_generator.data = data_in;
    end
                        
    if (verbose)
        disp('simulating network...');
    end

    [net, data_out] = snn_process_data( net, net.p_sample_fcn, ...
                                        set_generator, step_size, 1, ...
                                        true, lead_in, collect );


    %% dafault data generator
    function data_set = def_data_generator( data_gen )
        data_set = data_gen.data;
    end
end
