function dump_params( net, set_generator, other, ex_path )
% write network parameters to text file
% 将网络参数、训练集参数和全局参数写入文本文件。
% 
% 具体实现：
% 打开一个文本文件，依次调用dump_network_params函数将参数信息写入文件中，最后关闭文件。
% 其中第四个参数 ex_path 是文本文件的路径，没有给出则默认使用当前会话的路径。

    if nargin<4
        ex_path = snn_get_session_path;
    end

    f = fopen( fullfile( ex_path,'params.txt' ), 'w' );
    
    fprintf(f,'Network parameters:\n');
    dump_network_params( net, ex_path, f );
    fprintf(f,'\n');

    fprintf(f,'Training set parameters:\n');
    dump_network_params( set_generator, ex_path, f );
    fprintf(f,'\n');

    fprintf(f,'Global parameters:\n');
    dump_network_params( snn_options, ex_path, f );

    fclose(f);
end
