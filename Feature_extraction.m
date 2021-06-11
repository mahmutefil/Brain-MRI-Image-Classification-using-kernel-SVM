function[feat]=Feature_extraction(tumor)

% In this function we are extracting the features of the tumoruos picture


n=3; %decomposition level
[C S]=wavedec2(tumor,n,'haar');       % 2D DWT with multiple levels
[cHn,cVn,cDn]=detcoef2('all',C,S,n);  % Extracting Horizantal, Vertical, and Diagonal Coefficients
cAn=appcoef2(C,S,'haar',n);            % Extracting Approximation Coefficients at level 3
DWT_Feat = [cAn,cHn,cVn,cDn];

% GLCM
glcm = graycomatrix(DWT_Feat); %Create gray-level co-occurrence matrix from image
stats = graycoprops(glcm,'Contrast Energy Homogeneity'); %Gray Level Co-occurrence Matrix (GLCM) texture extraction
Contrast = stats.Contrast;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
% DWT
Mean = mean2(DWT_Feat);
Standard_Deviation = std2(DWT_Feat);
Entropy = entropy(DWT_Feat);
RMS = mean2(rms(DWT_Feat));
Variance = mean2(var(double(DWT_Feat)));
a = sum(double(DWT_Feat(:)));
Smoothness = 1-(1/(1+a));
% Inverse Difference Movement
[i j] = size(DWT_Feat);
in_difference = 0;
for i = 1:i
    for j = 1:j
        temp = DWT_Feat(i,j)./(1+(i-j).^2);
        in_difference = in_difference+temp;
    end
end
IDM = double(in_difference);
    
feat = [Contrast,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness, IDM ];

end