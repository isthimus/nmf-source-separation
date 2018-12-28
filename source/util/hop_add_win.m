function winout = hop_add_win (win, hop)
    % returns the output if window "win" is overlap-added at hop size "hop"

    % hops = all the delays involved for one window length
    % ie all multiples of "hop" less than length(win)
    L = length(win);
    hops = [0:hop:L-1];
   
    % build an impulse response which delays the signal by all the delay
    % lengths in "hops"
    hop_IR = zeros(L, 1);
    for i = 1:length(hops)
       hop_IR(hops(i) + 1) = 1;  
    end

    % create overlap-added window
    % circular convolution is used because it emulates adding windows
    % "before" as well as "after"
    winout = cconv(win, hop_IR, L);   
end