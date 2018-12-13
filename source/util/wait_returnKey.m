function wait_returnKey ()
    % blocks until return key is pressed
    % replacement for waitforbuttonpress since that makes interacting with
    % the plots impossible 
    pause;   
    while ~strcmp(get(gcf, 'CurrentKey'),  'return')
       pause; 
    end
end