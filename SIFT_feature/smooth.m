function J = smooth(I,s)
%% file:        smooth.m
 % author:      Noemie Phulpin
 % description: smoothing image
 %%
 
%filter 
h=fspecial('gaussian',ceil(4*s),s);%%设定相应的滤波器

%convolution
J=imfilter(I,h);%%滤波平滑

return;