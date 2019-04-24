function [r1, r2, r3] = unpack_results(results)
[T, A, B] = size(results);
r1 = cell(size(results));
r2 = cell(size(results));
r3 = cell(size(results));

for b = 1:B

    for a = 1:A

        for t = 1:T
       
            result = results{t, a, b};
            if ~isempty (result)
            r1 {t,a,b} = result{1};
            r2 {t,a,b} = result{2};
            r3 {t,a,b} = result{3};
            end
        end
    end
end
