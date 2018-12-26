function hops = check_window_hop(win, allow_scaling)
    possible_hops = [1:length(win)];
    possible_hops = possible_hops(rem(length(win)./possible_hops, 1) == 0);
    
    valid_hops = [];
    
    for i = 1:length(possible_hops)
        win_overlapped = hop_add_win(win, possible_hops(i));
        
        if all(win_overlapped == 1) ...
        || (allow_scaling && all(win_overlapped == win_overlapped(1)))    
            valid_hops = [valid_hops; possible_hops(i)];  
        end
        
        hops = valid_hops;      
    end
end

function winout = hop_add_win (win, hop)
    L = length(win);
    hops = [0:hop:L-1];
    
    hop_IR = zeros(L, 1);
    for i = 1:length(hops)
       hop_IR(hops(i) + 1) = 1;  
    end

    winout = cconv(win, hop_IR, L);   
end