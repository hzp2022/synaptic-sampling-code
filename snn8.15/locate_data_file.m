function file_name = locate_data_file( data_set_dir, i, epoch, ignore_er )
% Locate the data set file in the given directory  给定目录下定位数据集文件
%
% file_name = locate_data_file( data_set_dir, index )
%
% Locate the data set file with given index in the given
% directory and returns the file location. data_set_dir
% must be a string pointing to a directory, index must
% be an interger. If no matching file was found, an empty
% string is returned.
% 在给定的目录中找到具有给定索引的数据集文件，并返回文件位置。 
% data_set_dir必须是一个指向目录的字符串，index必须是一个整数。
% 如果没有找到匹配的文件，将返回一个空字符串。
% 

    if (nargin < 3)
        epoch = [];
    end

    if  ~isempty(data_set_dir) && ( data_set_dir(end) ~= '/' )
        data_set_dir(end+1) = '/';
    end
    
    file_names_dir = [];
    
    if ischar( i )
        if exist( [ data_set_dir, i ], 'file' )
            file_name = [ data_set_dir, i ];
            return;
        elseif strcmp(i,'end') || strcmp(i,'last')
            file_names_dir = dir( [ data_set_dir, 'data_set_*.mat' ] );
            if ~isempty(file_names_dir)
                file_names_dir = file_names_dir(end);
            end
        elseif strcmp(i,'first')
            file_names_dir = dir( [ data_set_dir, 'data_set_*.mat' ] );
            if ~isempty(file_names_dir)
                file_names_dir = file_names_dir(1);
            end
        else
            if strcmp(i,'all')
                file_names_dir = dir( [ data_set_dir, 'data_set_*.mat' ] );
            else
                file_names_dir = dir( [ data_set_dir, i ] );
            end
        end
    elseif isnumeric(i)
        for fi = i
            if isempty(epoch)
                file_names_dir = [ file_names_dir, dir( [ data_set_dir, sprintf( 'data_set_*%08d.mat', fi ) ] ) ];
            else
                file_names_dir = [ file_names_dir, dir( [ data_set_dir, sprintf( 'data_set_*%d%05d.mat', epoch-1, fi ) ] ) ];
            end
        end
    end
    
    if isempty(file_names_dir)
        if ignore_er
            file_name = [];
        else
            error( 'no file found ''%s''', [ data_set_dir, i ] );
        end
    elseif length(file_names_dir) == 1
        file_name = [ data_set_dir, file_names_dir(1).name ];
    else
        file_name = cell(1,length(file_names_dir));
        for fi = 1:length(file_names_dir)
            file_name{fi} = file_names_dir(fi).name;
        end
    end

end

