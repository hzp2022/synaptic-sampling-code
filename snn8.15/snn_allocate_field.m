function field = snn_allocate_field( net, field_name, dim )
% allocate an array of size DIM the same type as FIELD_NAME
% 分配一个与FIELD_NAME类型相同的大小为DIM的数组。
% 
% David Kappel
% 04.12.2014
%
    idx = strmatch(field_name, {net.p_allocators{1:3:end}}, 'exact');    
    if isempty(idx)
        error('Network has no field named %s',field_name);
    end
    field = alloc_field( net, net.p_allocators{(idx-1)*3+2}, dim );
end
