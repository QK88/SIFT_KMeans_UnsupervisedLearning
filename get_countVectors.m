function [ picVectors ] = get_countVectors( KMeans, K ,countPic)
% GET_COUNTVECTORS 用于计算图片库中每张图片每个聚类中的特征点个数，每张图片对应一个K维向量

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT 
% KMeans    --已完成的K聚类信息（每个聚类中包含的特征点，每个聚类的类心）
% K         --K聚类中的K值，即有多少个聚类
% countPic  --图片库中图片个数
% OUPUT
% picVector --countPic*K的矩阵，包含每张图片每个聚类中的特征点个数，每张图片对应一个K维向量

picVectors = zeros(countPic,K);

for N = 1:K;
    for M = 1:KMeans(N).count
        picVectors(KMeans(N).data(M,129),N) = picVectors(KMeans(N).data(M,129),N)+1;
    end;
end;

end

