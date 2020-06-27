function [ KMeans] = K_Means( Feats,K,initMeans )
%K_Means K聚类， 根据所给的所有特征，聚类个数以及初始类心，对所有特征进行聚类并更新类心，
%返回结果
% Feats:：需要聚类的特征数组
% K    ::  聚类的个数
for n=1:K
    KMeans(n).value=initMeans(n,1:128);
    KMeans(n).data=[];
    KMeans(n).count=0;
end
repeat=true;
times=0;
while repeat
    balanced=0;
    if times>=1
        for n=1:K
        KMeans(n).data=[];
        KMeans(n).count=0;
        end
    end
    for N=1:size(Feats,1)
    %  K聚合的实现
    %  根据所给的所有特征聚类个数以及初始类心，对所有特征开始聚类
        min_id=0;
        min_distance=inf;
        for M=1:K
            local_distance=do_eucidean_distance(KMeans(M).value,Feats(N,1:128));
            if local_distance<min_distance
                min_distance=local_distance;
                min_id=M;
            end
        end
%         if min_distance~=0
%             &&times==0
        KMeans(min_id).count=KMeans(min_id).count+1;
        KMeans(min_id).data=[KMeans(min_id).data;Feats(N,1:129)];
    end
    
    avg_data=zeros(1,128);
    for N=1:K
        for i=1:size(KMeans(N).data)
            avg_data=avg_data+KMeans(N).data(i,1:128); 
        end
        avg_data=avg_data./KMeans(N).count;
        if isequal(avg_data,KMeans(N).value)
            balanced=balanced+1;
        end
        KMeans(N).value=avg_data;
    end
    % 结束条件
    times=times+1;
    if times>50||balanced>500
        repeat=false;
    end
 end
end
