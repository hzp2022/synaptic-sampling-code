function snn_save( file_name, varargin )
% save object to session path  保存对象到会话路径
%
% snn_save( file_name, variable_name, ... )
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

    file_path = fullfile( snn_get_session_path, [file_base,ext] );
 
    fprintf('saving data to file: %s...\n',file_path);
    
    if (nargin==2) && isstruct( varargin{1} )
        data = varargin{1};
        save(file_path, '-struct', 'data');        
        if isvarname(file_base) && snn_options('FileCache')
            snn_options(['FILE_CACHE__',file_base],data);
        end
    else
        args = sprintf('''%s'', ',varargin{:});
        evalin( 'caller', sprintf( 'save( ''%s'', %s );', file_path, args(1:(end-2)) ) );
    end
end
