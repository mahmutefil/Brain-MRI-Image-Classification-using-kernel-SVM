% We use this script to extract features of all images to a .mat file for
% further processes. It takes all yes and no images and process on them. 
% It takes too much time. 

clc;clear;clear all;

for i=1:1500  
[img{i}]=imread(['C:\Users\mefil\OneDrive\Masaüstü\FinalVersion\main\no\', sprintf('no%d.jpg',i)]);
% img{i}]=imread(['C:\Users\mefil\OneDrive\Masaüstü\FinalVersion\main\no\No' num2str(i) '.jpg']
% Pre-Processing
inp{i}=img{i};
[result{i}]=Pre_Processing(inp{i});

inp{i} = im2double(result{i}) ;

% k-means Clustering
num_of_clusters = 4;    %Number of clusters
[clustered_img{i}]=k_means_clustering(inp{i},num_of_clusters);

%Apply Morphological Operation to get the area
bw_thresh=imbinarize(clustered_img{i},0.5);
label = bwlabel(bw_thresh);
stats = regionprops(logical(label),'Solidity','Area','BoundingBox');
density = [stats.Solidity];
area = [stats.Area];
high_dense_area = density>0.55;
max_area = max(area(high_dense_area));
tumor_label = find(area==max_area);
tumor = ismember(label,tumor_label);

tumor= imfill(tumor, 'holes');
seD = strel('diamond',3);   %creates diamond shape structure
tumor = imerode(tumor,seD);

se =strel('square',5);
tumor=imdilate(tumor,se); 
segmented_img{i}=tumor;

   
% Feature Extraction using DWT
[feat{i}]=Feature_extraction(segmented_img{i});
    
end

for k=1:1500
   [img1{k}]=imread(['C:\Users\mefil\OneDrive\Masaüstü\FinalVersion\main\yes\', sprintf('y%d.jpg',k)]);
    
    % Pre-Processing
    inp1{k}=img1{k};
    [result1{k}]=Pre_Processing(inp1{k});

    inp1{k} = im2double(result1{k}) ;
   
    % k-means Clustering
    num_of_clusters = 4;    %Number of clusters
    [clustered_img1{k}]=k_means_clustering(inp1{k},num_of_clusters);
    
    %Apply Morphological Operation to get the area
    bw_thresh=imbinarize(clustered_img1{k},0.5);
    label = bwlabel(bw_thresh);
    stats = regionprops(logical(label),'Solidity','Area','BoundingBox');
    density = [stats.Solidity];
    area = [stats.Area];
    high_dense_area = density>0.55;
    max_area = max(area(high_dense_area));
    tumor_label = find(area==max_area);
    tumor = ismember(label,tumor_label);

    tumor= imfill(tumor, 'holes');
    seD = strel('diamond',3);   %creates diamond shape structure
    tumor = imerode(tumor,seD);

    se =strel('square',5);
    tumor=imdilate(tumor,se); 

    segmented_img1{k}=tumor;

    % Feature Extraction using DWT
    [feat1{k}]=Feature_extraction(segmented_img1{k});
end



train_feat=zeros(i, 10);
for j=1:i 
       train_feat(j,:)=feat{1,j}; 
end

train_feat1=zeros(k, 10);
for m=1:k 
       train_feat1(m,:)=feat1{1,m}; 
end

data=[train_feat;train_feat1];


a={repmat({'Normal'},j,1)};
b={repmat({'Abnormal'},k,1)};
label=[a{1, 1}; b{1, 1}];

%saving all features to a .mat file
save Trainsetnew0.5.mat data label 


