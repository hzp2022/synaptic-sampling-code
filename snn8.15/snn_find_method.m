function [method_name,method_suffix] = snn_find_method( type, pattern )
% snn_find_method: returns the full name of spcified SNN method  返回指定的SNN方法的全名
%
% method_name = snn_find_method( type, pattern )
% method_name = snn_find_method( type )
%
% Retruns the full name of the specified SNN method.  返回指定SNN方法的全名。
% Searches all snn search directories and returns the first
% method name that matches the pattern. If no method
% was found an error is thrown.
% 搜索所有的snn搜索目录，并返回符合模式的第一个方法名称。如果没有找到任何方法，则抛出一个错误。
%
% input
%   type:        The snn method type. Can be 'train','sample' or 'performance'.   
%                snn方法的类型。可以是 "训练"、"采样" 或 "性能"。
%   pattern:     A name pattern string that may contain place holders like '*'. Default is '*'.
%                一个名称模式的字符串，可以包含像'*'这样的占位符。默认是'*'。
%
% output
%   method_name: The full method name.  完整的方法名称。
%
% see also  
%   <a href="matlab:help snn_include">snn_include</a>
%
% Daid Kappel 17.11.2010
%

    if (nargin<1)
        error( 'Not enough input arguments!' );
    end
    
    if (nargin<2)
        method_name = '*';
    end
    
    if ~ischar( type )
        error( 'Unexpected input type for argument ''type''!' );
    end

    if ~ischar( pattern )
        error( 'Unexpected input type for argument ''method_name''!' );
    end

    search_dirs = snn_options( 'search_dirs' );

    method = [ 'snn_', type, '_', pattern ];

    for p = 1:length(search_dirs)

        path_info = what( search_dirs{p} );  % 列出 folderName 的路径、文件和文件夹信息

        if isempty( path_info ) || isempty( path_info.path )
            continue;
        end

        method_list = dir( [ path_info.path, '/', method, '.m' ] );  % 返回指定文件的属性
        
        if ~isempty( method_list )
            method_name = method_list(1).name;   % 等价于method_list.name（eg：snn_train_rs.m）
            method_name = method_name(1:end-2);  % 将文件类型后缀（.m）去除得到method_name
            method_suffix = method_name((length([ 'snn_', type, '_' ])+1):end);  % 得到方法后缀（eg：rs）
            return;
        end
    end

    error( 'No %s method found matching pattern ''%s''!', type, pattern );
end
