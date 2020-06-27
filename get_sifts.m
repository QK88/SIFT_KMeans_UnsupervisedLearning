function [ img_paths,Feats] = get_sifts( FullFilePaths )
% GET_SIFTS ������ȡͼƬ��������ͼƬ��SIFT����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT
% FullFilePaths ---��¼����ͼƬ·�����ļ�
% OUTPUT
% img_paths     ---��¼����ͼƬ·���Ľṹ��
% Feats         ---����ͼƬ��SIFT����

img_paths = textread(FullFilePaths,'%s');%��ȡ���ݷ���Ԫ������
Feats = [];
for N = 1:size(img_paths,1)
        img_paths{N}
        [~,descr,~,~ ] = do_sift( img_paths{N}, 'Verbosity',1, 'NumOctaves', 4, 'Threshold',  0.1/3/2 ) ; 
        descr = descr';
        feat_count = size(descr,1);
        descr = [descr,ones(feat_count,1)*N];
        Feats=[Feats;descr];
end;
end

