function snn_progress( pct )
% disp a simple progress bar  展示一个简单的进度条（pct指示完成的百分比）

    if nargin==1
        if ischar(pct)  % 当传递字符串作为参数时，打印该字符串后跟着...和%%0
            fprintf( '%s...   %%0', pct );
        else
            if pct<0  % 当传递负数作为参数时，打印字符串'failed!'
                fprintf('%c%c%c%cfailed!\n',8,8,8,8);
            else
                % 当传递数值作为参数时打印一个进度条，进度条显示已完成的百分比
                fprintf('%c%c%c%c%3d%%',8,8,8,8,max(0,min(100,round(100*pct))));  
            end
        end
    else
        fprintf('%c%c%c%cdone.\n',8,8,8,8);  % 如果没有传递参数，打印字符串'done.'
    end
end


