function loglik_all = plot_performance( src_path )
% 在src_Path中绘制结果的性能图。
% 
% 输入：
%   src_path：  表示结果文件的路径。
% 
% 输出：
%   loglik_all：所有数据的对数似然，可以用于绘制性能图。
% 

    % 在base_path和src_path拼接成的路径下查找所有子目录
    [base_path,vu] = snn_process_options( default_options(), 'base_path', '' );
    source_dirs = dir( [base_path,src_path] );    
    source_dirs = source_dirs([source_dirs.isdir]);
    
    loglik_all = [];
    
    % 从每个子目录中读取名为performance_kl.mat的文件，计算文件中loglik变量的均值，并将所有的均值存储到loglik_all变量中
    for i = 3:length(source_dirs)
        cur_file = [base_path,src_path,source_dirs(i).name,'/performance_kl.mat'];
        if ~exist(cur_file,'file')
            fprintf('skipping file %s!\n', cur_file);
            continue;
        end
        fprintf('reading file %s...\n', cur_file);
        data = load(cur_file,'loglik');
        loglik_all = [ loglik_all, mean(data.loglik,2) ];
    end
end
