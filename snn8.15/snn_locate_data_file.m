function file_name = snn_locate_data_file( i, epoch, ignore_er )
% Locate the data set file in the current session directory  在当前会话目录中找到数据集文件
%
% file_name = snn_locate_data_file( index, epoch )
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

    if nargin<3
        ignore_er = false;
    end
    if nargin<2
        epoch = [];
    end
    if nargin<1
        i = 'last';
    end
    file_name = locate_data_file( snn_get_session_path, i, epoch, ignore_er );
end
