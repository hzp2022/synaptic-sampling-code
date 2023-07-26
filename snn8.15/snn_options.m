function [varargout] = snn_options( varargin )
% snn_options: sets and gets global SNN options  设置和获取全局SNN选项
%
% options = snn_options
% value = snn_options( op_name )
% value = snn_options( op_name_1, op_value_1, op_name_2, op_value_2, ... )
%
% Sets and gets global SNN options. If op_value is given the option is set
% to the new value and the old one is returned. If the option does not
% exist, or is set the first time [] is returned. If no option name is
% provided the whole options structure is rectured.
% 设置和获取全局SNN选项。如果op_value被给定，选项被设置为新的值，并返回旧的值。
% 如果选项不存在，或者第一次被设置，则返回[]。如果没有提供选项名称，则重新构造整个选项结构。
%
% inputs
%   op_name:   A string containing the option name.  包含选项名称的字符串。
% 
% David Kappel
% 20.08.2010
%

    global snn_options__;  % 将变量声明为全局变量
    
    if isempty( snn_options__ )  % 如果snn_options__为空        
        snn_options__ = struct;  % 创建结构体snn_options__     
    end

    if ( nargin > 0 )  % 如果有输入参数
        
        for k=1:2:length(varargin)  % 遍历varargin的奇数索引位置元素1,3,5,...(对应op_name_1,op_name_2,op_name_3...)
        
            op_name = varargin{k};  
                        
            if ~ischar( op_name )   % 如果op_name不是字符数组
                error( 'Unexpected argument type for ''op_name''!' );  % 抛出错误并显示消息:op_name的意外参数类型!
            end

            if isfield( snn_options__, op_name )  % 如果op_name是结构体snn_options__的一个字段
                varargout((k+1)/2) = { snn_options__.(op_name) };  % 将元胞数组varargout的第(k+1)/2个元素设置为snn_options__.(op_name)
            else
                varargout((k+1)/2) = { [] };  % 将元胞数组varargout的第(k+1)/2个元素设置为[]
            end

            if ( nargin > k )  % 如果输入参数个数>k
                
                new_value = varargin{k+1};  % 将元胞数组varargin的第k+1个元素赋值给new_value
                
                if isempty( new_value )  % 如果new_value为空
                    if isfield( snn_options__, op_name )  % 如果op_name是结构体snn_options__的一个字段
                        snn_options__ = rmfield( snn_options__, op_name );  % 删除结构体snn_options__的op_name字段
                    end
                else
                    snn_options__.(op_name) = new_value;  % 将结构体snn_options__的op_name字段的值修改为new_value
                end
            end
        end
    else        
        varargout(1) = { snn_options__ };  % 如果没有输入参数,则直接将结构体snn_options__赋值给元胞数组varargout的第1个位置
    end
end

