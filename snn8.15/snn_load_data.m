function data = snn_load_data( file_pattern, varargin )
% snn_load_data: loads experiment data form disk  从磁盘上加载实验数据
%
% data = load_experiment( file_pattern )
% data = load_experiment( file_pattern, ... )
%
% Loads experiment data form disk. Additional to the file_pattern
% an arbitrary number of field names can be given that should be
% loaded. If no field names are given all fields are read form
% the fieles.
% 将实验数据从磁盘上加载。除了file_pattern之外，还可以给出任意数量的应该被加载的字段名。
% 如果没有给定字段名，所有字段都从fieles中读取。
%  
% A SNN data file is a .mat file that (at least) contains the fields:
% 一个SNN数据文件是一个.mat文件，它（至少）包含字段:
%     X: network input.  网络输入
%
% input
%   file_pattern:  A string containing a file name or a pattern containing
%                  placeholders like '*' if multiple files should be loaded.
%                  一个包含文件名的字符串，如果要加载多个文件，则是一个包含占位符的模式，如'*'。
%
% output
%   data:          The SNN data structure containing the loaded fields.  包含加载字段的SNN数据结构。
%
% David Kappel 07.06.2010
%

    if (nargin<1)
        error( 'Not enough input arguments!' );
    end

    files = dir( file_pattern );
    filedir = fileparts( file_pattern );
    
    verbose = snn_options( 'verbose' );
    
    if isempty(verbose)
        verbose = true;
    end

    if isempty(files)
        error( 'No files found that match pattern ''%s''!', file_pattern );
    end
    
    for i=1:length(files)
        if verbose
            disp( [ '  loading file : ', files(i).name ] );
        end
        data(i) = load( fullfile( filedir, files(i).name ), varargin{:} );
    end
end
