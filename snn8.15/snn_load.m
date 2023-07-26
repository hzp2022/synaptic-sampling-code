function data = snn_load( file_name, varargin )
% load file from session path  从会话路径加载文件
%
% data = snn_load( file_name, variable_name, ... )
%
% David Kappel
% 29.10.2014
%
%

    [path,file_base,ext] = fileparts(file_name);
    
    if ~isempty(path)
        error('subfolders are not allowed.');
    end
    
    if isempty(ext)
        ext = '.mat';
    end

    data = [];
    
    file_path = fullfile( snn_get_session_path, [file_base,ext] );
    
    if isvarname(file_base) && snn_options('FileCache')
        data = snn_options(['FILE_CACHE__',file_base]);
    end

    if isempty(data)
        fprintf('loading data file: %s...\n',file_path);
        data = load(file_path, varargin{:} );
        if isvarname(file_base) && snn_options('FileCache')
            snn_options(['FILE_CACHE__',file_base],data);
        end
    else
        fprintf('loaded from cache: %s...\n',file_path);
    end
end

