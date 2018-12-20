function wait_returnKey ()
    % blocks until return key is pressed
    % replacement for waitforbuttonpress since that makes interacting with
    % the plots impossible 
    pause;   
    key = get(gcf, 'CurrentKey');
    while ~strcmp(key,  'return')
        if strcmp(key, 'q')
            close all
            error("utils:UserQuit", "user quit from wait_returnKey");
        end
        pause; 
    end
end