function snn_include( varargin )
% snn_include: adds the given directories to the SNN search dirs  将给定的目录添加到SNN的搜索目录中。
%
% snn_include
% snn_include( dir )
% snn_include( dir1, dir2, ... )
%
% Add the list of directories to the SNN search dirs. The search dirs are used to locate SNN methods. Calling
% snn_include without arguments will just add the SNN toolbox path to the matlab paths. The seach dirs can be
% shown by calling snn_options with argument 'search_dirs'
% 将目录列表添加到SNN搜索目录中。搜索目录是用来定位SNN方法的。调用snn_include而不加参数，
% 只是将SNN工具箱路径添加到matlab路径中。搜索目录可以通过调用snn_options的参数'search_dirs'来显示。
%
% see also  
%   <a href="matlab:help snn_list_methods">snn_list_methods</a>
%   <a href="matlab:help snn_options">snn_options</a>
%
%
% David Kappel
% 17.11.2010
%
%

    if ( nargin < 1 )  % 调用snn_include而不加参数  
        addpath( pwd );  % 将当前路径(SNN工具箱路径)添加到matlab路径(搜索路径)中
        return;
    end
    
    if ~iscellstr( varargin )  % 确定可变长度输入参数列表是否为字符向量元胞数组
        
        if ischar( varargin )  % 确定可变长度输入参数列表是否为字符数组
            varargin = cellstr( varargin );  % 将可变长度输入参数列表转换为字符向量元胞数组
        else
            error( 'Unexpected argument type!' );  % 抛出错误并显示消息：意外的参数类型！
        end
    end

    search_dirs = snn_options( 'search_dirs' );  % 获取搜索目录
    
    if isempty( search_dirs )  % 如果搜索目录为空
        search_dirs = {};  % 将搜索目录设置为一个空元胞数组
    end

    for i = 1:length( varargin )  % 遍历可变长度参数列表(1*N的元胞数组)的每一个元素
        
        dir = varargin{i};  % 将varargin的第i个元素赋值给dir
    
        if ~ischar( dir )  % 如果dir不是字符数组
            error( 'Unexpected argument type!' );  % 抛出错误并显示消息：意外的参数类型！
        end

        if ~exist( dir, 'dir' )  % 如果不存在dir文件夹
            
            home_path = what( [ 'snn', snn_version ] );  % 以结构体数组形式列出文件夹snn8.15中的MATLAB Code files
            
            if isempty( home_path )  % 如果文件夹snn8.15中没有MATLAB Code files
                error( 'Toolbox home path not found!' );  % 抛出错误信息并显示消息：未找到工具箱主路径！
            end
            
            dir = fullfile( home_path.path, dir );  % 返回包含文件完整路径的字符向量：home_path.path\dir
            
            if ~exist( dir, 'dir' )  % 如果不存在dir文件夹           
                error( 'Directory ''%s'' not found!', dir );  % 抛出错误信息并显示消息：找不到目录dir！
            end
        end

        path_info = what( dir );  % 以结构体数组形式列出文件夹dir中的MATLAB Code files
        
        if isempty(path_info)  % 如果文件夹dir中没有MATLAB Code files
            error( 'Directory ''%s'' not found!', dir );  % 抛出错误信息并显示消息：找不到目录dir！
        end
        
        if length(path_info) > 1   % 如果文件夹dir中的MATLAB Code files数量>1
            path_info = path_info(1);  % 将path_info设置为path_info的第一个元素
            warning( 'Multiple matching paths for ''%s'' found!', dir );  % 显示警告信息：找到dir的多个匹配路径！
            warning( 'Will use: ''%s''.', path_info.path );  % 显示警告信息：将使用path_info.path.
        end

        if isempty( strmatch( path_info.path, search_dirs, 'exact' ) )  % 将path_info.path与search_dirs的每一行进行比较，以查找整个字符向量的完全匹配项。如果找不到匹配项

            search_dirs = { search_dirs{:} path_info.path };  % 将search设置为1*2的元胞数组{search_dirs{:} path_info.path },其中search_dirs{:}表示将search_dirs中的所有元素重构成一个列向量
            addpath( path_info.path );  % 将文件夹path_info.path添加到搜索路径最前面
        end
    end
    
    snn_options( 'search_dirs', search_dirs );  % 设置搜索目录
end

