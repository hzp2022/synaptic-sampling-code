function snn_clear_cache( varargin )
% clear all cached files.  清除所有缓存的文件。
%
% David Kappel
% 29.10.2014
%
%

    if nargin==0
        fields = fieldnames( snn_options );
        for i = 1:length(fields)
            field = fields{i};
            if strncmp('FILE_CACHE__',field,12)
                snn_options(field,[]);
            end
        end
    else
        for i = 1:length(varargin)
            snn_options(['FILE_CACHE__',varargin{i}],[]);            
        end
    end
end

