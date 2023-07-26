function [tokens,start_pos,end_pos] = snn_parse_args( in_str )
% Dispatch an argument string  分派参数字符串
%
% tokens = snn_parse_args( in_str )
%
% Parse an rgument of the form [<arg1>,<arg2>,...,<argN>] into
% a cell array of string tokens <arg1>,...,<argN>.
% 将形式[<arg1>,<arg2>,...,<argN>]的结果解析为字符串元胞数组tokens：{{<arg1>},...,{<argN>}} 
%
% 17.11.2010
%

    in_str = in_str( in_str ~= ' ' );    % 移除in_str字符串中的所有空格
    start_pos = strfind( in_str, '[' );  % 查找in_str字符串中所有左括号[的位置，将它们的位置保存在start_pos
    end_pos = strfind( in_str, ']' );    % 查找in_str字符串中所有左括号]的位置，将它们的位置保存在end_pos
    
    if ( length( start_pos ) ~= length( end_pos ) )  % 判断左右括号数量是否相等，如果不相等，则抛出异常
        error( 'Unbalanced braces pair in allocator comamnd ''%s''!', in_str );
    end
    
    if isempty( start_pos ) || isempty( end_pos )  % 判断是否存在左右括号，如果不存在左括号或者右括号
        
        start_pos = length(in_str)+1;  % 左括号位置设置为in_str长度+1
        end_pos = length(in_str)+1;    % 右括号位置也设置为in_str长度+1
        tokens = {};  % 返回空的字符串元胞数组token
        return;
    end

    start_pos = start_pos(1);  % 取第一个左括号[的位置
    end_pos = end_pos(end);    % 取最后一个右括号]的位置
    
    % 使用strread函数将夹在[和]中的字符串按照逗号,分隔开，将每个子字符串存储在一个字符串元胞中，最终返回这些字符串元胞构成的字符串元胞数组tokens
    tokens = strread( in_str( start_pos+1:end_pos-1 ), '%s', 'delimiter', ',' );
end
