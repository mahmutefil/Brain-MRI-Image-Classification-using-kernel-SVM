function [clustered_img]= k_means_clustering(inp,num_of_clusters)

% In this function, segmentation is applied using k-means clustering which groups similar data points based on 
% their intensity values and maps the similar patterns with number of
% clusters and centroids


image_vectorized = inp(:);
centroid = zeros(num_of_clusters,1);
class = zeros(length(image_vectorized), num_of_clusters);
% initialize centroid
maximum = max(image_vectorized);

for cent = 1:num_of_clusters
    centroid(cent,1)= cent * maximum / num_of_clusters;
end

for iteration = 0:9  %for each iteration it updates the centroid and classiffy the pixels
    class(1:length(image_vectorized),1:num_of_clusters) = 0;
    % classifying pixels
    for i = 1: length(image_vectorized)
        [val, ind] = min(abs(image_vectorized(i) - centroid((1:num_of_clusters),1)));
        class(i,ind) = image_vectorized(i);
    end
    % updating centroid
    for cent = 1:num_of_clusters
        centroid(cent, 1) = sum(class(:,cent))/length(find(class(:,cent)));
    end
end

clustered_img= reshape(class(1:length(image_vectorized),num_of_clusters:num_of_clusters), [256,256] );

end