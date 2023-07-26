function [args,start_pos,end_pos] = snn_dispatch_args( net, token )
% Dispatch an argument string  发送一个参数字符串
%
% [args,start_pos,end_pos] = snn_dispatch_args( net, token )
%
% Dispatch an rgument of the form [<arg1>,<arg2>,...,<argN>].
% The argument fields can be any real valued argument, or a
% field name referencing to a field inside the net structure.
% snn_dispatch_args always returns a matrix containing real
% values or generates an error if any of the arguments inside
% the token string is eighter not real valued or not referencing
% to a field.
% 发送一个形式为[<arg1>,<arg2>,...,<argN>]的参数。
% 参数字段可以是任何实值参数，也可以是引用网状结构中的字段名。
% snn_dispatch_args总是返回一个包含实值的矩阵，或者如果标记字符串
% 中的任何一个参数不是实值或者没有引用到一个字段，则会产生一个错误。
%
% 17.11.2010
%

    % 将形式[<arg1>,<arg2>,...,<argN>]的token解析为字符串元胞数组toks：{{<arg1>},...,{<argN>}}
    [toks,start_pos,end_pos] = snn_parse_args( token );  

    args = zeros( 1, numel(toks) );      % 定义函数输出args，初始化为(1×toks数组的元素数目)全零的向量

    % 逐一遍历toks
    for d = 1:length( toks )  

        value = str2double( toks{d} );   % 将当前遍历到的元素由字符串转为double型的数值并赋值给value

        if strcmp( toks{d}, 'nan' )      % 如果当前遍历到的元素是'nan'，则将nan赋值给arg
            args(d) = nan;  
        elseif ~isnan( value )           % 如果value是一个数值，则将value赋值给arg
            args(d) = value;
        else                             % 上面两种情况的其他情况                  

            if ~isfield( net, toks{d} )  % 如果当前遍历到的元素不是结构体net中的字段，则抛出错误：参数未定义！
                error( 'Parameter ''%s'' undefined in allocator comamnd ''%s''!',toks{d}, token );
            end
            
            args(d) = net.(toks{d});     % net结构体中以该字符串为字段名的字段值赋值给arg
        end
    end
end
