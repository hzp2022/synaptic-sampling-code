% 该文件改编自PROCESS_OPTIONS函数，由Mark A. Paskin提供(见下文)。
%
% PROCESS_OPTIONS - Processes options passed to a Matlab function.
%                   This function provides a simple means of parsing attribute-value options.  
%                   Each option is named by a unique string and is given a default value.
%                   处理传递给Matlab函数的选项。
%                   这个函数提供了一个解析attribute-value选项的简单方法。
%                   每个选项由一个唯一的字符串命名，并给出一个默认值。
%
% Usage:  [var1, var2, ..., varn, [unused]] = process_options(args, str1, def1, str2, def2, ..., strn, defn)
%
% Arguments:   
%            args            - a cell array of input arguments, such as that provided by VARARGIN.
%                              Its contents should alternate between strings and values.
%                              一个输入参数的元胞数组，例如由VARARGIN提供的。
%                              它的内容应该在字符串和数值之间交替出现。
%            str1, ..., strn - Strings that are associated with a particular variable.
%                              与某一特定变量相关的字符串。
%            def1, ..., defn - Default values returned if no option is supplied.
%                              如果没有提供选项，则返回默认值。
%
% Returns:
%            var1, ..., varn - values to be assigned to variables.  要分配给变量的值。
%            unused          - an optional cell array of those string-value pairs that were unused;
%                              if this is not supplied, then a warning will be issued for each option in args that lacked a match.
%                              一个可选的元胞数组，包含那些未使用的字符串-值(string-value)对；
%                              如果没有提供这个，那么将对args中缺乏匹配的每个选项发出警告。
%
% Examples:
%
% Suppose we wish to define a Matlab function 'func' that has required parameters x and y, 
% and optional arguments 'u' and 'v'.With the definition
% 假设我们想定义一个Matlab函数'func'，它有必要的参数x和y，
% 以及可选的参数'u'和'v'。有了这个定义
%
%   function y = func(x, y, varargin)
%
%     [u, v] = process_options(varargin, 'u', 0, 'v', 1);
%
% calling func(0, 1, 'v', 2) will assign 0 to x, 1 to y, 0 to u, and 2 to v.
% The parameter names are insensitive to case; calling func(0, 1, 'V', 2) has the same effect.  The function call
% 调用func(0, 1, 'v', 2)将把0赋给x，1赋给y，0赋给u，2赋给v。
% 参数名称对大小写不敏感；调用func(0, 1, 'V', 2)有同样的效果。函数调用
%
%   func(0, 1, 'u', 5, 'z', 2);
%
% will result in u having the value 5 and v having value 1, but will issue a warning that the 'z' option has not been used. 
% On the other hand, if func is defined as
% 将导致u的值为5，v的值为1，但会发出警告说'z'选项没有被使用。
% 另一方面，如果func被定义为
%
%   function y = func(x, y, varargin)
%
%     [u, v, unused_args] = process_options(varargin, 'u', 0, 'v', 1);
%
% then the call func(0, 1, 'u', 5, 'z', 2) will yield no warning,and unused_args will have the value {'z', 2}.
% This behaviour is useful for functions with options that invoke other functions with options; 
% all options can be passed to the outer function and its unprocessed arguments can be passed to the inner function.
% 那么调用func(0, 1, 'u', 5, 'z', 2)将不会产生警告，unused_args的值是{'z', 2}。
% 这种行为对于有选项的函数调用其他有选项的函数很有用；
% 所有的选项可以传递给外层函数，其未处理的参数可以传递给内部函数。
%

function [varargout] = snn_process_options(args, varargin)

% Check the number of input arguments  检查输入参数（varargin）的数量
n = length(varargin);
if (mod(n, 2))  % 如果varargin的长度不是偶数
  error('Each option must be a string/value pair.');  % 抛出错误并显示消息：每个选项必须是一个键值对。
end

% Check the number of supplied output arguments  检查提供的输出参数（varargout）的数量
if (nargout < (n / 2))  % 如果varargout的长度 < varargin长度的一半
  error('Insufficient number of output arguments given');  % 抛出错误并显示消息：给出的输出参数数量不足
elseif (nargout == (n / 2))  % 如果varargout的长度 = varargin长度的一半
  warn = 1;                  % 情况标记
  nout = n / 2;              % 记录varargout的长度
else                         % 如果varargout的长度 > varargin长度的一半
  warn = 0;                  % 情况标记
  nout = n / 2 + 1;          % 记录varargout的长度
end

% Set outputs to be defaults  设置输出为默认值
varargout = cell(1, nout);       % 将varargout设置为一个1*nout的元胞数组
for i=2:2:n  
  varargout{i/2} = varargin{i};  % 将varargin的第i个位置的值逐一分配给varargout的第i/2个位置
end

% Now process all arguments  现在处理所有的参数
nunused = 0;  % 计数器（用于unused索引）
for i=1:2:length(args)  
  found = 0;  % found用于标记是否找到匹配项
  for j=1:2:n  
    if strcmpi(args{i}, varargin{j})       % 如果args和varargin在指定位置是不区分大小写的键的匹配项
      varargout{(j + 1)/2} = args{i + 1};  % 将arg的第i+1个位置的值分配给varargout的(j + 1)/2位置
      found = 1;  % 将found标记设为1
      break;
    end
  end
  if (~found)  % 如果没有找到键的匹配项
    if (warn)  % 如果varargout的长度==varargin长度的一半（此条件下没有unused来接收未使用参数故应发出警告）
      warning(sprintf('Option ''%s'' not used.', args{i}));  % 显示警告信息：warning：Option 'args{i}' not used
      args{i}  % 打印args{i}
    else
      nunused = nunused + 1;  % 计数器+1
      unused{2 * nunused - 1} = args{i};  % 将未使用的参数（该索引位置为键）赋值给unused指定位置
      unused{2 * nunused} = args{i + 1};  % 将未使用的参数（该索引位置为值）赋值给unused指定位置
    end
  end
end

% Assign the unused arguments  指定未使用的参数
if (~warn)      % 如果varargout的长度 > varargin长度的一半
  if (nunused)  % 计数器不为0（unused里面有值）
    varargout{nout} = unused;   % 将varargout的最后一个元素的值设置为unused元胞数组
  else          % 计数器为0（unused为空）
    varargout{nout} = cell(0);  % 将varargout的最后一个元素的值设置为一个由空矩阵构成的0*0元胞数组
  end
end
