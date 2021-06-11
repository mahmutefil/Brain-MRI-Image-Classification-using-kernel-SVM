function[test_accuracy,m]=optimization(X,y)

%   We use this function to test whole data using a special algorithm called Bayes Optimization
%   The function provides test accuracy and confusion matrix at the output. 


% load dataset
load Trainsetfinal.mat

% seperating Train and Test set with 80% and 20% of the whole data randomly
classes = grp2idx(label);
X = data;
y = classes;
rng(size(X,1)); %to form same ramdom sequence in each run
rand_num = randperm(size(X,1));  %Random permutation of i rntegers, for size of X it gives random number sequence
X_train = X(rand_num(1:round(0.8*length(rand_num))),:);  % Train data exportation,randomly, %80
y_train = y(rand_num(1:round(0.8*length(rand_num))),:);

X_test = X(rand_num(round(0.8*length(rand_num))+1:end),:); % Test data exportation, randomly, %20
y_test = y(rand_num(round(0.8*length(rand_num))+1:end),:);

% cross validatiton using CV partition. Using trainset, the data is divided
% into 5 pieces for validating a statistical model using cross-validation. 
c = cvpartition(y_train,'KFold',5);  % 5 Fold CV

% Useful feature selection, based on optimization
% Bayes' Optimization is a sequential process to find out the most proper hyperparameters 
% with a minimized error rate on the validation set. 
opts = statset('display','iter');
classf = @(train_data, train_labels, test_data, test_labels)...
       sum(predict(fitcsvm(train_data, train_labels,'KernelFunction','rbf'), test_data) ~= test_labels);

[fs, history] = sequentialfs(classf, X_train, y_train, 'cv', c, 'options', opts,'nfeatures',7); % Sequential feature selection, 
% it selects the best features, 8 out of 10

% Finding best hyperparameter
X_train_selected = X_train(:,fs);

% Bayes' Optimization
Md1 = fitcsvm(X_train_selected,y_train,'KernelFunction','rbf','OptimizeHyperparameters','auto',...
      'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
      'expected-improvement-plus','ShowPlots',false)); 


% Final test with test and train sets
X_test_selected = X_test(:,fs);
test_accuracy = sum((predict(Md1,X_test_selected) == y_test))/length(y_test)*100;
%train_accuracy=sum((predict(Md1,X_train_selected) == y_train))/length(y_train)*100;
%% Confusion Matrix (precision, recall, F1 Score)
SVM_RBF=(predict(Md1,X_test_selected));
m=confusionmat(y_test,SVM_RBF);
% chart = confusionchart(m,{'Normal','Abnormal'});
% chart.Title = 'Brain Tumor Classification Using SVM';
% 
% Precision=m(1)/(m(1)+m(3));
% Recall=m(1)/(m(1)+m(2));
% F1_Score=2*((Precision*Recall)/(Precision+Recall));
end
