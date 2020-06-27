%实验一：：基于内容图像检索系统
%Author：：HEARN
%PART2 ：：KMeans聚类算法
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part1::测试图片读取
testImg_file='./testPictures';
testImg_name='/youlun2.jpg';
image=imread([testImg_file testImg_name]);
figure(1);
imshow(image);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Part2::SIFT提取局部特征
%提取带检索图片SIFT特征
[~,descr,~,~]=do_sift([testImg_file testImg_name],'Verbosity',1,'NumOctaves',4,'Threshold',0.1/3/2);
% 选择聚类个数
K=500
% 提取图片库所有图片的SIFT特征
% [img_paths,Feats]=get_sifts('./img_paths.txt');
load sift;
% 初始化随机生成K个类心
% initMeans=Feats(randi(size(Feats,1),1,K),:);
% % % 根据生成的类心所有SIFT特征开始聚类
% [KMeans]=K_Means(Feats,K,initMeans);
load kmeans_2;
% 统计每个图的特征点个数
[countVectors]=get_countVectors(KMeans,K,size(img_paths,1));
% 统计带检索图片每个聚类中特征点数得到一K维向量
[cosVector]=get_singleVector(KMeans,K,descr');
% 根据余弦定理求所有图片与检索图片的余弦角
cosValues=zeros(1,size(img_paths,1));
for N =1:size(img_paths,1)
    dotprod = sum(cosVector .* countVectors(N,:));
    dis = sqrt(sum(cosVector.^2))*sqrt(sum(countVectors(N,:).^2));
    cosin = dotprod/dis;
    cosValues(N) = cosin;
end
% 对结果进行排序
[vals,index]=sort(acos(cosValues));
% 输出匹配度最高的6张图
figure(2);
c=0;
for id=1:6
    path=img_paths{index(id)};
    image=imread(path);
    if(mod(id-1,12)==0&&id~=1)
        c=c+1;
        figure(c+2)
    end
    subplot(4,3,id-12*c);
    imshow(image);
end
