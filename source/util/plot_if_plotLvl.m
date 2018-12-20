function plot_if_plotLvl(plot_level, plotIf, figTitle, waitAndClose, plot_func, varargin)
    % plots "varargin{:}" using "plot_func" if "plot_level" > "plotIf"
    % sets title to "title"
    % puts each plot in a new figure
    % if WaitAndClose is true, waits for return key, closes all the
    % accumulated figures and is ready to start again 
    
    persistent currFig
    if isempty(currFig); currFig = 1; end   

    % skip if condition not met
    if plot_level >= plotIf
        
        % set current figure and plot using args
        figure(currFig)
        plot_func(varargin{:})
        title(figTitle)
        currFig = currFig + 1;
        
        % special case for imagesc 
        % since it's used so often, and not having a colorbar is a really
        % illogical default
        if isequal(plot_func, @imagesc)
           colorbar
        end
        
        if waitAndClose
           wait_returnKey
           close all
           currFig = 1;
        end
    end
end
