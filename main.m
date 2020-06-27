%ʵ��һ������������ͼ�����ϵͳ
%Author����HEARN
%PART2 ����KMeans�����㷨
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part1::����ͼƬ��ȡ
testImg_file='./testPictures';
testImg_name='/youlun2.jpg';
image=imread([testImg_file testImg_name]);
figure(1);
imshow(image);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Part2::SIFT��ȡ�ֲ�����
%��ȡ������ͼƬSIFT����
[~,descr,~,~]=do_sift([testImg_file testImg_name],'Verbosity',1,'NumOctaves',4,'Threshold',0.1/3/2);
% ѡ��������
K=500
% ��ȡͼƬ������ͼƬ��SIFT����
% [img_paths,Feats]=get_sifts('./img_paths.txt');
load sift;
% ��ʼ���������K������
% initMeans=Feats(randi(size(Feats,1),1,K),:);
% % % �������ɵ���������SIFT������ʼ����
% [KMeans]=K_Means(Feats,K,initMeans);
load kmeans_2;
% ͳ��ÿ��ͼ�����������
[countVectors]=get_countVectors(KMeans,K,size(img_paths,1));
% ͳ�ƴ�����ͼƬÿ�����������������õ�һKά����
[cosVector]=get_singleVector(KMeans,K,descr');
% �������Ҷ���������ͼƬ�����ͼƬ�����ҽ�
cosValues=zeros(1,size(img_paths,1));
for N =1:size(img_paths,1)
    dotprod = sum(cosVector .* countVectors(N,:));
    dis = sqrt(sum(cosVector.^2))*sqrt(sum(countVectors(N,:).^2));
    cosin = dotprod/dis;
    cosValues(N) = cosin;
end
% �Խ����������
[vals,index]=sort(acos(cosValues));
% ���ƥ�����ߵ�6��ͼ
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
