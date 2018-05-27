function [Priors, Mu, Sigma, Data_id] = EM_init_kmeans_upd(Data, nbStates)
%
% This function initializes the parameters of a Gaussian Mixture Model 
% (GMM) by using k-means clustering algorithm.
%
% Author:	Sylvain Calinon, 2009
%			http://programming-by-demonstration.org
%
% Inputs -----------------------------------------------------------------
%   o Data:     D x N array representing N datapoints of D dimensions.
%   o nbStates: Number K of GMM components.
% Outputs ----------------------------------------------------------------
%   o Priors:   1 x K array representing the prior probabilities of the
%               K GMM components.
%   o Mu:       D x K array representing the centers of the K GMM components.
%   o Sigma:    D x D x K array representing the covariance matrices of the 
%               K GMM components.
% Comments ---------------------------------------------------------------
%   o This function uses the 'kmeans' function from the MATLAB Statistics 
%     toolbox. If you are using a version of the 'netlab' toolbox that also
%     uses a function named 'kmeans', please rename the netlab function to
%     'kmeans_netlab.m' to avoid conflicts. 

[nbVar, nbData] = size(Data);

%Use of the 'kmeans' function from the MATLAB Statistics toolbox
%Initialize with k means
[Data_id, Centers] = kmeans(Data', nbStates); 

%Initialize with GMM
%GMModel = fitgmdist(Data,3,'CovarianceType', 'full', 'RegularizationValue', 0.00001, 'MaxIter', 500, 'SharedCovariance', true);
% for i=1:nbStates
%     temp=find(Data_id==i);
%    % temp_cent(i)=mean(temp);
%     Mu(i)=mean(temp);
% end
%Mu=[temp_cent; Centers'];

%This is for k means
Mu = sort(Centers); %sort(Centers);

%This is for GMM
%Mu=GMModel.mu;
%Data_id=cluster(GMModel, Data);

for i=1:nbStates
  idtmp = find(Data_id==i);
  Priors(i) = length(idtmp);
  Sigma(:,i) = cov([Data(idtmp) Data(idtmp)]);
  %Add a tiny variance to avoid numerical instability
  Sigma(:,i) = Sigma(:,i) + 1E-5.*diag(ones(nbVar,1));
end
Priors = Priors ./ sum(Priors);


