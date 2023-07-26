function save_fig( h_ref, file_name, base_path, formats )
% 将h_ref指定的图形保存到指定的file_name中。
% save_fig会在“figures”子文件夹中创建3个文件，分别以fig、eps和pdf格式存储图形，分辨率为300 dpi。
% 

    if nargin < 3 || isempty( base_path )
        base_path = snn_get_session_path;
    end
    if nargin < 4
        formats = {'fig','eps'};
    end
    if ~iscell(formats)
        formats = {formats};
    end

    file_path = fullfile( base_path , 'figures', file_name );
    
    [success,ms,e] = mkdir(fullfile(base_path ,'figures'));
    
    if ~success
        error('could not create folder %s.',fullfile(base_path ,'figures'));
    end        

    set( h_ref, 'PaperPositionMode', 'auto' );
    
    % f_h = [ '-f', num2str(h_ref) ];  % 这里会报错,将其修改为下面代码

    f_h = [ '-f', num2str(h_ref.Number) ];  

    renderer=['-' lower(get(h_ref, 'Renderer'))];
    
	if strcmpi(renderer, '-none')
        renderer = '-painters';
    end
    
    for i = 1:length(formats)
    
        switch formats{i}
            case 'fig'
               saveas( h_ref, file_path, 'fig' );
            case 'eps'
                print( f_h, '-depsc', renderer, '-r300', file_path );
            case 'png'
                print( f_h, '-dpng', renderer, '-r300', file_path );                
        end
    end
    
    fprintf('figure saved to ''%s''\n',file_path)
end
