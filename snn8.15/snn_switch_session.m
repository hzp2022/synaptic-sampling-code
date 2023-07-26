function snn_switch_session( exp_path, mode )
% switch to new or existing session  切换到新的或现有的会话
%
% mode: 'new'/'n' [default], 'last'/'l', 'testing'/'t', 'old'/'o'
%
% snn_switch_session( exp_path )
% snn_switch_session( exp_path, mode )
%
% David Kappel
% 29.10.2014
%
%

    if nargin<2  % 如果没有提供模式，则默认使用'snn_options__'中的'DefaultSessionMode'参数
        mode = snn_options('DefaultSessionMode');  
    end
    
    if isempty(mode)
        mode = '';
    end
    
    session_base = '';

    if nargin==0  % 如果exp_path是空的，则默认使用用户的当前工作路径
        mode = 'user';
        exp_path = '';
        old_session_path = snn_options( 'SessionPath' );
        if ~isempty(old_session_path)
            session_base = fileparts(old_session_path(1:(end-1)));
        end
    end
    
    % 根据提供snn_options('BasePath')和exp_path构建会话基路径
    if nargin>0 && exp_path(1)==filesep
        session_base = exp_path;
    end
    
    if isempty(session_base)
        session_base = fullfile(snn_options('BasePath'),exp_path);
    end

    % 根据提供的会话基路径以及模式标志生成保存路径
    if (regexp(session_base(find(session_base == filesep,1+(session_base(end)==filesep),'last')+1:end),'\d\d\d\d-\d\d-\d\d-\d\d-\d\d-\d\d')==1)
        mode = 'f';
    end

    switch mode
        case {'','n','new'}
            flag = 'n';
        case {'t','testing'}
            flag = 't';
        case {'l','last'}
            flag = 'l';
        case {'o','old'}
            flag = 'o';
        case {'f','flat'}
            flag = 'f';
        otherwise
            flag = '';
    end
    
    snn_clear_cache;  % 清除所有缓存文件

    save_path = gen_results_path( session_base, flag );  % 生成新的保存路径
    
    % 初始化随机种子
    snn_randomize; 
    
    % 将'snn_options__'中的'SessionPath'设置为该保存路径
    snn_options( 'SessionPath', save_path );
    
    % 打印：切换到的会话路径
    fprintf( 'switched to session: %s.\n', save_path );
end
