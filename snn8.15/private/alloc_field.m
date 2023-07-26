function M = alloc_field( net, type, dim )
% allocate an array of given size and data type
% 分配给定大小和数据类型的数组

    % fct_arg为type的[]内分别以数组元素为字段在net中的字段值（type是一个字符串，同时type的[]内的元素是非nan且非数值的条件下）
    % a_pos就是star_pos,即type（一个字符串）第一个左括号[位置
    [fct_args,a_pos] = snn_dispatch_args( net, type );

    gen_fct = type(1:a_pos-1);  % 生成函数即为：type字符数组的1到a_pos-1位置的字符串

    % 根据生成函数的具体实例分配给定大小和数据类型的数组 
    switch gen_fct  
        case 'rand'
            if length(fct_args)==1 
                M = fct_args(1)*rand( dim );  % rand( dim ):由(0,1)随机数组成的dim(1)×...×dim(N)数组
            elseif length(fct_args)==2  
                M = fct_args(1) + (fct_args(2)-fct_args(1))*rand( dim );  
            else
                error('wrong number of arguments')
            end

        case 'randn'
            M = fct_args(2)*randn( dim ) + fct_args(1);  % randn( dim ):由正态分布的随机数组成的dim(1)×...×dim(N)数组

        case 'beta'
            M = betarnd( fct_args(1), fct_args(2), dim );  % betarnd(A,B,dim):由具有参数A和B的beta分布的随机数组成的dim(1)×...×dim(N)数组

        case 'scbeta'
            M = fct_args(1)*betarnd( fct_args(2), fct_args(3), dim ); 

        case 'spikes'
            M = rand( dim )<=fct_args(1);  % 逻辑值(0/1)

        case 'szeros'
            M = zeros( dim, 'single' );  % 创建一个指定维度（dim）的零矩阵，并指定数据类型为单精度浮点数

        case 'izeros'
            M = zeros( dim, 'int32' );  % 创建一个指定维度（dim）的零矩阵，并指定数据类型为32位整型

        case 'zeros'
            M = zeros( dim );

        case 'ones'
            M = ones( dim );

        case 'const'
            M = fct_args(1)*ones( dim );

        otherwise
            fnc_name_field = strcat('p_',gen_fct,'_fcn');    % 暂时将p理解为私有
            if isfield(net,fnc_name_field)                   % 如果fnc_name_field是结构体net的字段
                M = net.(fnc_name_field)(net,dim,'sample');  % 此时该字段值是一个函数句柄（eg：@(net,data,ct)(snn_weight_prior_lognormal(net,data,ct))）
            else
                error('unknown allocator type: "%s"',gen_fct);  
            end
    end
end
