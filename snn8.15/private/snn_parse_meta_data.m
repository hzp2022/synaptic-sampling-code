function params = snn_parse_meta_data( file_name, section_name, num_fields )  
% SNN_PARSE_META_DATA reads the meta data from an m-file  
% SNN_PARSE_META_DATA 从一个m-file中读取元数据。
%
% params = snn_parse_meta_data( file_name, section_name, num_fields )
%
% Reads meta data from m-file. The meta data within the m-files
% documentation text is used to adjust the the network structure. Meta data
% is organised in sections. A meta data section starts with a line:
%
% 从m-files中读取元数据。m-files中的元数据文件文本被用来调整网络结构。
% 元数据是按sections组织的。一个元数据sections以一行开始:
%
% @<section name>: and ends with an empty comment line (a line that only
% contains a '%'). The meta data sections may contrain any number of
% parameter value pairs separated with white spaces and may be followed by
% some describing text. Eeach line contrains a single parameter followed by
% num_fields values. Meta data is used to adjust the behaviour of the
% network. Each SNN method should define its default parameters in the
% 'default parameters' meta data section.
%
% @<section name>:并以空注释行结束(只包含'%'的一行)。元数据部分可以限制任何数量的参数值对，
% 用空格隔开，后面可以有一些描述性文本。每一行都限制了一个参数，后面跟着num_fields的值。
% 元数据被用来调整网络的行为。每个SNN方法应该在 "默认参数" 元数据部分定义其默认参数。
%
% example:
%
% @default parameters:
%   eta           0.5              Here I define the default learn rate  这里我定义了默认的学习率
%   train_method  st               Here I define the default sample method  在这里我定义了默认的采样方法  
%   some_matrix   [ 0, 0, 10, 10 ] Here I define some matrix  这里我定义了一些矩阵
%   some_string   'some text'      Here I define some string  这里我定义了一些字符串
%

    meta_data_lines = textread( file_name, '%s', 'delimiter','\n' );  % 将snn_train_rs.m当做文本文件读入到元胞数组meta_data_lines中（使用换行符作为分隔符）
        
    sections = strmatch( [ '% @', section_name, ':' ], meta_data_lines );  % 搜索'%@section_name:'并返回找到该部分的行的索引
    
    params = cell( 0, num_fields+1 );  % 定义params元胞数组并给定初始size（后面通过逐个（多个）添加得到完整params）
    
    for sec_start_line = sections
        for cur_line = (sec_start_line+1):length(meta_data_lines) % 从'%@section_name'所在行的下一行开始遍历所有行
            
            toks = strread( meta_data_lines{cur_line}(2:end), '%s' );  % 从当前行（字符串）提取cell字段（以空格作为分隔，每个cell都是一个字符串）得到一个cell数组
            
            if ( isempty(toks) )
                break;
            end
            
            if ( toks{1}(1) == '@')  
                break;
            end
            
            pars = cell( 1, num_fields+1 );  % 部分参数（用于传递参数的的中间元胞数组）
            par_depth = 0;    % 参数深度
            str_tok = false;  % 标记字符串的第一个字符是否为单引号
            idx = 1;
            
            for i=1:length(toks)
                 
                if ( toks{i}(1) == '''' )  % 如果toks{i}的第一个字符是单引号
                    str_tok = true;
                end

                pars{idx} = [ pars{idx}, toks{i} ];  % 将toks{i}添加到pars中的特定位置idx上
                
                if str_tok
                    if ( toks{i}(end) == '''' )
                        str_tok = false;
                    else
                        pars{idx} = [ pars{idx}, ' ' ];  % 将空格字符添加到pars中的特定位置idx上                       
                    end
                else
                    % 跟踪参数列表的深度
                    par_depth = par_depth + length( strfind( toks{i}, '[' ) ) - ...  % 每当遇到一个[时，深度加1
                                            length( strfind( toks{i}, ']' ) );       % 每当遇到一个]时，深度减1
                end

                if ( par_depth == 0 ) && ~str_tok  % 参数列表的深度为0且toks{i}的第一个字符不是单引号
                    
                    idx = idx+1;
                    
                    if ( idx > num_fields+1 )  % 限制读取的字段数量（一个字段包括两个参数）
                        break;
                    end
                end
            end
            
            if ( par_depth ~= 0 ) || str_tok  % 参数列表的深度不为0且toks{i}的第一个字符是单引号
                error( [ 'Error while parsing meta data in file ''%s'' at line %u!\n', ...
                         'Unbalanced braces or quotes!' ], file_name, cur_line );  % 解析文件snn_train_re.m中当前行的元数据时出错，括号或引号不平衡！
            end

            params = { params{:}, pars{:} };  % 将pars的所有元素添加到params的末尾
            
        end
    end
end
