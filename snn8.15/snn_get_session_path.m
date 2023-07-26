function session_path = snn_get_session_path()
% returns the save path of the current session.  返回当前会话的保存路径。
%
% session_path = snn_get_session_path()
%
% David Kappel
% 29.10.2014
%
%

    session_path = snn_options( 'SessionPath' );
    
    if isempty(session_path)
        error('no session selected.');
    end
end
