function data_set = mix_data( data_set, data, varargin )
% 将数据追加到数据集的末尾。
%
% 如果data_set和data中都包含某个数据字段，则会将两个数据集的该字段数据进行混合，
% 具体混合方式就是将两个数据集的数据拼接在一起，并进行时间戳排序。
% 

    if isempty( data_set )
        data_set = struct;
        data_set.Zt = [];
        data_set.Xt = [];
        data_set.Lt = [];
        data_set.At = [];
        data_set.Rt = [];
        data_set.time = 0;
    end

    if isempty( data )
        return;
    end

    if isfield(data,'Zt') && isfield(data_set,'Zt')
        data_set.Zt = mix(data_set.Zt, data.Zt);
    end
    if isfield(data,'Xt') && isfield(data_set,'Xt')
        data_set.Xt = mix(data_set.Xt, data.Xt);
    end
    if isfield(data,'At') && isfield(data_set,'At')
        data_set.At = mix(data_set.At, data.At);
    end
    if isfield(data,'Rt') && isfield(data_set,'Rt')
        data_set.Rt = mix(data_set.Rt, data.Rt);
    end
    if isfield( data, 'Lt' ) && isfield(data_set,'Lt')
        data_set.Lt = mix(data_set.Lt, data.Lt);
    end
    if isfield(data,'time') && isfield(data_set,'time')
        data_set.time = sort([data_set.time, data.time]);
    end
    
    
    function mixed_data = mix( A, B )
    % mix two data sets  % 混合两个数据集
        if isempty( A ) && isempty( B )
            mixed_data = [];
            return;
        elseif isempty( A )
            tmp = B(1,:);            
            [srt_time,idx] = sort(B(2,:));
        elseif isempty( B )
            tmp = A(1,:);
            [srt_time,idx] = sort(A(2,:));
        else            
            tmp = [ A(1,:), B(1,:) ];
            [srt_time,idx] = sort([A(2,:), B(2,:)]);
        end
        mixed_data = [ tmp(idx); srt_time ];
    end
end
