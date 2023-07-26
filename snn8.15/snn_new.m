function net = snn_new( varargin )
% snn_new: creates a new SNN network  创建一个新的SNN网络
%
% net = snn_new( num_neurons, num_inputs, ... )
%
% Creates a new SNN network. Optional parameters will
% modifie the network behaviour. Parameters that can
% be passed here are the same as to the
% <a href = "matlab:help snn_set">snn_set</a> function.
% 创建一个新的SNN网络。可选的参数将修改网络的行为。
% 这里可以传递的参数与<a href = "matlab:help snn_set">snn_set</a>函数的参数相同。
%
% input
%   num_neurons:  number of wta neurons.  WTA神经元的数量。
%   num_inputs:   number of network inputs.  网络输入的数量。
%
% output
%   net:          The snn network structure.  snn网络结构。
% 
% see also  
%   <a href = "matlab:help snn_set">snn_set</a>
%   <a href = "matlab:help snn_train">snn_train</a>
%
% David Kappel
% 04.01.2010
%
    
    net.p_required_methods = snn_options('RequiredMethods');  % 获取SNN选项——必要的方法
    
    net.iteration = 0;    
    net.train_time = 0;
    
    net = snn_set( net, varargin{:} );
end
