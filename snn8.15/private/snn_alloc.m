function net = snn_alloc( net, allocators, reset )
% Allocate the fields defined by allocators.  分配allocators定义的字段的字段值。
%
% net = snn_alloc( net, allocators )
% net = snn_alloc( net, allocators, reset )
%
% Allocate the fields defined in the allocators cell-array.  分配分配器cell-array中定义的字段。
%
% Generator function:
%   rand[A]     Random equally distributed numbers
%               between zero and A.  在零和A之间随机均匀分布的数。
%   rand[A,B]   Random equally distributed numbers
%               between A and B.  A和B之间随机均匀分布的数字。
%   randn[A,B]  Normal distributed numbers with
%               mean A and standard deviation B.  均值为A，标准差为B的正态分布数。
%   beta[A,B]   Beta distributed numbers.  Beta分布数字
%   spikes[A]   Boolean values, poisson distributed
%               with rate A.  布尔值，速率为A的泊松分布。
%   zeros       Zero float values with double precision.  具有双精度的零浮点值。
%   szeros      Zero float values with single precision.  具有单精度的零浮点值。
%   izeros      Zero int32 values.  零int32值。
%   ones        Ones float values with double precision.  具有双精度的1浮点值。
%   const[A]    Const float values with double precision
%               with value A.  值为A的双精度常量浮点值。
%
% 17.11.2010
%

    if (nargin < 2)  % 只有一个输入参数或者没有输入参数情况下，不重新设置网络结构
        reset = false;
    end

    % 3个为一组遍历allocators，检查net中是否已经存在该字段，如果存在且维度一致，则不重新分配，
    % 否则使用 alloc_field 函数重新生成数据并分配到结构体中。如果reset为true，则不管是否存在该字段，都会重新分配数据。
    for i=1:3:length(allocators)
        
        field_name = allocators{i};  % 字段名     
        gen_fct = allocators{i+1};   % 生成函数（定义见注释）
        dim = snn_dispatch_args( net, allocators{i+2} );  % 维度（eg：(10×1000)指10个WTA神经元,1000个输入神经元）
        
        if isfield( net, field_name ) && ~reset  % 如果field_name是net的字段且reset为false
            if any( size(net.( field_name )) ~= dim )  % 如果维度不一致
                net.( field_name ) = alloc_field( net, gen_fct, dim );  % 分配给定大小和数据类型的数组
            end
        else
            net.( field_name ) = alloc_field( net, gen_fct, dim );  % 分配给定大小和数据类型的数组
        end
    end
end
