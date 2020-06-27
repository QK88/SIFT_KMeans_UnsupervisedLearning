function [cosVector] = get_singleVector(KMeans,K,descr)

% 取得单个图片的余弦向量
cosVector = zeros(1,K);
for N= 1:size(descr,1);
    min = do_eucidean_distance(descr(N,:),KMeans(1).value);
    num = 1;
    for M = 2:K;
        distance = do_eucidean_distance(descr(N,:),KMeans(M).value);
        if(distance<min)
            min = distance;
            num = M;
        end;
    end;
    cosVector(num)=cosVector(num)+1;
end
        
    


