function dump_network_params( net, ex_path, f )
% write network parameters to text file
% 将网络参数写入文本文件
% 输出一个结构体中所有非分配器（p_allocators）的字段及其值到指定文件中


    if nargin<2
        ex_path = snn_get_session_path;
    end

    file_is_local = false;
    
    if nargin<3
        f = fopen( fullfile( ex_path,'network_params.txt' ), 'w' );
        file_is_local = true;
    end
    
    all_fieldnames = fieldnames(net);
    
    for i = 1:length(all_fieldnames)
        
        field_name = all_fieldnames{i};
        field_value = net.(field_name);
        
        if strcmp( field_name, 'p_allocators' )
            break;
        else
            print_field(f,field_name,field_value);
        end
    end

    function print_field(f,field_name,field_value)
        
        if ischar(field_value)
            fprintf(f,'  %s = ''%s''\n',field_name,field_value);
        elseif iscell(field_value)
            fprintf(f,'  %s = { ... }    %s\n',field_name,print_size(field_value));
        elseif isa(field_value,'function_handle')
            fprintf(f,'  %s = %s\n',field_name,func2str(field_value));
        elseif isstruct(field_value)
            fprintf(f,'  %s = [struct]    %s\n',field_name,print_size(field_value));
        else
            str_val = mat2str(field_value);            
            if length( str_val ) > 50
                str_val = [str_val(1:50), ' ...]    ', print_size(field_value)];
            end            
            fprintf(f,'  %s = %s\n',field_name,str_val);
        end
    end

    function size_str = print_size(field_value)
        size_str = sprintf( '%i x ', size(field_value) );
        size_str = ['< ',size_str(1:(end-3)),' >'];
    end

    if file_is_local
        fclose(f);
    end
end
