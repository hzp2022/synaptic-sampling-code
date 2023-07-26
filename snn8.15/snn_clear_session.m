function snn_clear_session()
% clear currently selected session.  清除当前选定的会话。
%
% snn_clear_session()
%
% David Kappel
% 29.10.2014
%
%

    session_path = snn_get_session_path;

    mode = lower(input( sprintf('remove folder %s and all its content? (y/n) ',session_path), 's' ));
    
    if ~strcmp(mode,'y')
        return;
    end
    
    fil = dir(session_path);
    
    if any(~[fil.isdir])
        mode = lower(input( sprintf('%i files will be lost! are you sure? (y/n) ',sum(~[fil.isdir])), 's' ));
        if ~strcmp(mode,'y')
            return;
        end
    end

    if any([fil(3:end).isdir])
        mode = lower(input( sprintf('%i subfolders will be lost! are you sure? (y/n) ',sum([fil(3:end).isdir])), 's' ));
        if ~strcmp(mode,'y')
            return;
        end
    end

    rmdir(session_path,'s');
    snn_options( 'SessionPath', [] );
end
