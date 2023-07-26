function save_path = gen_results_path( exp_path, flag )
% generate path within the given directory  在给定的目录中生成路径
%
% save_path = changelog_gen_path( path )
%
% David Kappel
% 10.10.2011
%

    if (nargin<2) || isempty(flag)
        mode = lower(input( 'Start new session (n), Continue last session (l), Continue other session (o), Testing (t), Abord (a): ', 's' ));
    else
        mode = lower(flag);
    end
    
    if ~isempty( strmatch(mode, {'l','o'}, 'exact') )
        cur_save_path_idx = 0;
        exp_path_dirs = dir( exp_path );
        
        for f_i = length( exp_path_dirs ):-1:1
            if exp_path_dirs( f_i ).isdir
                cur_save_path_idx = f_i;
                break;
            end
        end
        
        if (cur_save_path_idx==0)
            error('no sessions found.');
        end
        
        cur_save_path = exp_path_dirs( cur_save_path_idx ).name;
    end
    
    if isempty(exp_path) || (exp_path(1)~='/')
        exp_path = fullfile(pwd,exp_path);
    end

    switch lower(mode)
        case 'a'
            error('user aborted.');
        
        case 't'
            save_path = [ tempname, '/' ];
            mkdir( save_path );
            
        case 'l'
            save_path = [fullfile( exp_path, cur_save_path ),'/'];
            
        case 'o'
            path_idxs = nan(1,length( exp_path_dirs ));
            num_paths = 0;
            
            for f_i = length( exp_path_dirs ):-1:1
                if exp_path_dirs( f_i ).isdir && ( exp_path_dirs( f_i ).name(1) ~= '.' )
                    num_paths = num_paths+1;
                    path_idxs(num_paths) = f_i;
                end
            end            
            
            fprintf( 'sessions found:\n' );
            
            for f_i=1:num_paths
                fprintf( '  [%2i] %s', f_i-1, exp_path_dirs( path_idxs(f_i) ).name );
                if (mod(f_i,4) == 0)
                    fprintf( '\n' )
                end
            end
            
            u_input = input( '\nSelect session: ', 's' );
            
            if ~isempty( str2num( u_input ) )
                cur_save_path = exp_path_dirs( path_idxs(str2num( u_input )+1) ).name;
            end
            
            save_path = [fullfile( exp_path, cur_save_path ),'/'];
            
        case 'n'
            while true
                exp_folder = sprintf( '%04i-%02i-%02i-%02i-%02i-%02i/', round(clock) );
                [s,mess,messid] = mkdir(exp_path,exp_folder);
                if ~s
                    error(mess);
                end
                if ~strcmp(messid,'MATLAB:MKDIR:DirectoryExists')
                    break;
                end
                pause(rand);
            end
            save_path = fullfile( exp_path, exp_folder );
            
        case 'f'
            save_path = exp_path;
        otherwise
            error('option not recoginzed.');
    end
end

