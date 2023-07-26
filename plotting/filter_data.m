function [data_set] = filter_data( data_set, field_names, varargin )
% 用于过滤数据的 MATLAB 函数
% 其目的是从数据集中提取一个或多个字段，然后对它们进行预处理，例如根据指定的神经元列表过滤数据、对神经元 ID 进行重新映射等。
% 
% 输入参数：
%   data_set：需要被过滤的数据集
%   field_names：需要过滤的字段名，可以是单个字符串或字符串数组
% 
% varargin：
%   neurons：需要过滤的神经元ID列表
%   neuron_map：用于重新映射神经元ID的映射表
%   remap：是否进行重新映射
% 

    % 解析可选参数列表
    [ neurons, ...
      neuron_map, ...
      remap ] = snn_process_options( varargin, ...
                                     'neurons', [], ...
                                     'neuron_map', [], ...
                                     'remap', true );
    
    % 如果输入参数field_names是一个字符数组，则将其转换为一个包含一个字符串的单元素cell数组
    if ischar( field_names )
        field_names = { field_names };
    end
    
    % 逐个处理输入参数中指定的字段
    for i=1:length(field_names)

        data_field = data_set.(field_names{i});
        
        % 如果neurons不为空，则根据neurons中的神经元ID过滤数据，即将包含这些神经元的数据提取出来，并根据filter对数据进行切片，只保留符合条件的数据。
        if ~isempty( neurons )
            % 将数据按照给定的神经元ID进行过滤，将包含这些神经元的数据提取出来，即filter
            filter = any( repmat( data_field(1,:), length(neurons), 1 ) == repmat( neurons(:), 1, size(data_field,2) ), 1 );
            data_field = [ data_field(1,filter); data_field(2,filter) ];  % 根据filter对数据进行切片，只保留符合条件的数据
            
            % 如果 remap 为真且neuron_map为空，则根据neurons对数据进行重新映射，生成一个新的神经元ID序列，该序列与数据中出现的神经元ID对应
            if remap && isempty( neuron_map )
                neuron_map = zeros( 1, max( neurons ) );
                neuron_map( neurons ) = 1:length(neurons);
            end
        end
        
        % 当remap为真并且neuron_map为空时，根据数据中出现的神经元ID生成一个新的神经元ID序列，该序列与数据中出现的神经元ID对应
        if remap && isempty( neuron_map )
            neurons_used = sort( unique( data_field(1,:) ) );
            neuron_map = zeros( 1, max( neurons_used ) );
            neuron_map( neurons_used ) = 1:length(neurons_used);
        end
        
        % 如果neuron_map不为空，则根据映射表重新映射神经元ID
        if ~isempty( neuron_map )
            data_field(1,:) = neuron_map( data_field(1,:) );
        end
        % 将处理后的数据写回数据集中相应的字段
        data_set.(field_names{i}) = data_field;
    end
end
