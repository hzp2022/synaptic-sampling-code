function [data_set] = append_data( data_set, other_data, min_length )
% 将other_data中的数据附加到data_set末尾（其中other_data和data_set都是结构体）
% 如果other_data中包含了time字段，那么它会被特殊处理
% 
% data_set：已有的数据集。
% other_data：待追加的数据，是一个结构体，其中包含了多个字段和对应的数据。这些数据会被逐个追加到data_set中的同名字段中。
% min_length：一个可选的标量参数，指定了data_set的时间维度的最小长度。如果min_length大于data_set的当前时间维度长度，那么data_set会被自动扩充到min_length。



    % 如果min_length参数被省略或为空，就不会对数据集的结束时间进行更改
    if nargin<3
        min_length = [];
    end
    
    % 检查data_set是否为空，如果是，则新建一个结构体作为data_set，其中只有一个time字段，初始值为[0, 0]
    if isempty( data_set )
        data_set = struct('time',[0,0]);
    end
    
    % 将other_data中的数据逐个追加到data_set中的同名字段中
    if ~isempty(other_data)
        t_offset = data_set.time(end);  % 时间偏移量（数据集中最后一个时间点的值）
        other_field_names = fieldnames(other_data);  % other_data中所有字段名称的cell 数组
        
        for i = 1:length(other_field_names)
            
            cur_field_name = other_field_names{i};    % 中间变量，用于存储当前字段名
            cur_field = other_data.(cur_field_name);  % 中间变量，用于存储当前字段值
            
            % 如果other_data中包含了time字段，那么它会被特殊处理，将它的值加上data_set中最后一个时间点的值，并追加到data_set.time中
            if strcmp(cur_field_name,'time')
                data_set.time = [ data_set.time, other_data.time+t_offset ];
            % 如果data_set中已经存在同名字段，那么新的数据会被追加到该字段的尾部
            elseif isfield(data_set,cur_field_name)
                if (cur_field_name(end) == 't') && ~isempty(cur_field)
                    cur_field(end,:) = cur_field(end,:) + t_offset;
                end
                data_set.(cur_field_name) = [ data_set.(cur_field_name), cur_field ];
            % 新的字段添加到data_set中
            else
                data_set.(cur_field_name) = cur_field;
            end
        end
    end
    
    % 如果附加的数据比当前数据集的结束时间要早，则将数据集的结束时间设置为min_length
    if ~isempty( min_length ) && (min_length > data_set.time(end))
        data_set.time = [data_set.time, min_length];
    end
end
