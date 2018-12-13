function plot_if_plotLvl(plot_level, plotIf, title, waitAndClose, plot_func, varargin)
    % plots "varargin{:}" using "plot_func" if "plot_level" > "plotIf"
    % sets title to "title"
    % puts each plot in a new figure
    % if WaitAndClose is true, waits for return key, closes all the
    % accumulated figures and is ready to start again 
    
    persistent currFig
    if isempty(currFig); currFig = 1; end   

    if plot_level >= plotIf
        figure(currFig)
        plot_func(varargin{:})
        title(title)
        currFig = currFig + 1;
        
        if waitAndClose
           wait_returnKey
           close all
           currFig = 1;
        end
    end
end
