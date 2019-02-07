function alignment = dtw_test (A, B, cost_func)
   C = zeros(size(A,2), size(B,2));
   D = C;
   
   for i_A = 1:size(C,1)
       for i_B = 1:size(C,2)
           C(i_A, i_B) = cost_func(A(:,i_A), B(:,i_B));
       end
   end
   
   stepsizes = [0,1;1,0;1,1];
   D(1,1) = C(1,1);
   
   for i_A = 1:size(C,1)
       for i_B = 1:size(C,2)
          
           best_prev_cost = +inf;
           
           for j = 1:size(stepsizes,1)
               candidate_index = [i_A-stepsizes(j,1), i_B-stepsizes(j,2)];
               if any(candidate_index <= 0); continue; end
               
               prev_cost = D(candidate_index(1),candidate_index(2));
               if prev_cost < best_prev_cost
                   best_prev_cost = prev_cost;
                   D(i_A, i_B) = best_prev_cost + C(i_A, i_B);
               end        
           end  
       end
   end
    
   warping_path = [];
   curr_index = size
   
   
    
end
