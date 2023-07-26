function meta_data = snn_dispatch_meta_data( file_name, section_name, num_fields )
% snn_dispatch_meta_data: 从m-file中读取元数据，并将每个数字字段转换成数值。
%
% meta_data = snn_dispatch_meta_data( file_name, section_name, num_fields )
%
%
% see also  
%   <a href="matlab:help snn_parse_meta_data">snn_parse_meta_data</a>
%   


    % 从m-file中读取元数据
    meta_data = snn_parse_meta_data( file_name, section_name, num_fields );  % 从snn_train_rs.m中读取parameters(.m文件中以注释的方式给出了一些参数设置)

    % 将每个数字字段转换成数值
    for p = 1:(num_fields+1):length(meta_data)        
        for i=1:num_fields
            
            d_value = meta_data{p+i};
            
            if ( d_value(1) == '''' ) && ( d_value(end) == '''' )  
                meta_data{p+i} = d_value(2:end-1);
            else
                num_value = str2num( d_value ); 

                if ~isempty( num_value )
                    meta_data{p+i} = num_value;
                end
            end
        end
    end
end
