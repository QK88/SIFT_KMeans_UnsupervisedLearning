function J = smooth(I,s)
%% file:        smooth.m
 % author:      Noemie Phulpin
 % description: smoothing image
 %%
 
%filter 
h=fspecial('gaussian',ceil(4*s),s);%%�趨��Ӧ���˲���

%convolution
J=imfilter(I,h);%%�˲�ƽ��

return;