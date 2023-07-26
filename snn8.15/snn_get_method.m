function method = snn_get_method( fcn_name )
% snn_get_method: returns the method handler for given method name.  返回给定方法名称的方法处理程序。
%
% method = snn_get_method( fcn_name )
%
% David Kappel 30.09.2014
%

    method = eval( ['@(net,data,ct)(',fcn_name,'(net,data,ct))'] );
end
