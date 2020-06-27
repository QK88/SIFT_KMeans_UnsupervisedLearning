function [ img_paths,Feats] = get_sifts( FullFilePaths )
% GET_SIFTS 用于提取图片库中所有图片的SIFT特征
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT
% FullFilePaths ---记录所有图片路径的文件
% OUTPUT
% img_paths     ---记录所有图片路径的结构体
% Feats         ---所有图片的SIFT特征

img_paths = textread(FullFilePaths,'%s');%读取数据返回元胞数组
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

