function [ picVectors ] = get_countVectors( KMeans, K ,countPic)
% GET_COUNTVECTORS ���ڼ���ͼƬ����ÿ��ͼƬÿ�������е������������ÿ��ͼƬ��Ӧһ��Kά����

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT 
% KMeans    --����ɵ�K������Ϣ��ÿ�������а����������㣬ÿ����������ģ�
% K         --K�����е�Kֵ�����ж��ٸ�����
% countPic  --ͼƬ����ͼƬ����
% OUPUT
% picVector --countPic*K�ľ��󣬰���ÿ��ͼƬÿ�������е������������ÿ��ͼƬ��Ӧһ��Kά����

picVectors = zeros(countPic,K);

for N = 1:K;
    for M = 1:KMeans(N).count
        picVectors(KMeans(N).data(M,129),N) = picVectors(KMeans(N).data(M,129),N)+1;
    end;
end;

end

