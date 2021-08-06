function [T] = DHC_E(dataPath, outPath, outName)
%--------------------------------------------------------------------------
% This function is used to calculate Whole Graph Embedding
%
%
% Syntax: DHC_E(dataPath)
%
% Inputs:
%        dataPath:
%                 The directory that contains a serial of graphs. Note that
%                 all graphs must be binary and undirected graphs.
%
%                 File formats can be .txt, .csv and .xlsx. Either in the
%                 form of an adjacency matrix or a two-column list,
%                 including start and end nodes.
%
% e.g., adjacency matrix, 4-node graph
%-------------------------------
%   : 1 2 3 4
% 1 : 0 1 1 0
% 2 : 1 0 0 1
% 3 : 1 0 0 1
% 4 : 0 1 1 0
%
% two-column list, 4-node graph
%     1  2
%     1  3
%     2  4
%     3  4   
%-------------------------------
%
%     outPath: The directory where the results are stored.
%     outName: The name of the results' .csv file is stored.
%
% Output:
%          T:
%              The whole graph embedding information for each graph.
%
% Example:
%         [T] = DHC_E('~/Downloads/Project1', '~/Downloads', 'Project1') 
%
%
% Reference:
% Wang, H., Deng, Y., Lü, L., and Chen, G., (2021), Hyperparameter-free and
% Explainable Whole Graph Embedding, https://arxiv.org/abs/2108.02113
%
% Hao Wang, UESTC, Chengdu, March 3, 2021, h.wang.psyc(at)gmail.com
%--------------------------------------------------------------------------

cd (dataPath)
fileExt = {'.csv','.txt','xlsx','xls'};
allGraph = [];
for iFile = 1:length(fileExt)
    allGraph = [allGraph; dir(['*' fileExt{1,iFile}])];
end

numGraphs = size(allGraph,1);

for ig = 1:numGraphs
    g = readmatrix(allGraph(ig).name);
    if issymmetric(g)==1
        G = graph(g);
    elseif size(g,2)==2
        G = graph(g(:,1),g(:,2));
    else
        error('The inputed file format is nor supported')
    end
    
    Hn = node_Hindex_centrality(G);
    for ih = 1:size(Hn)
        EnGraph{ig,ih} = Entropy_Shannon(Hn(ih,:));
    end
    fprintf('Perform the DHC-E for %s is done on %s\n', allGraph(ig).name, datetime('now'))
end

% Aligning the embedding dimension with the entropy of coreness
for ig = 1:numGraphs
    emptyIndex = cellfun('isempty',EnGraph(ig,:)); % true for empty cells
    index = find(emptyIndex==1);
    if isempty(index)==1
        continue;
    else
        % the entropy of coreness
        ind = index(1)-1;
        EnGraph(ig,index) = EnGraph(ig,ind);
    end
end

Embeddings = cell2mat(EnGraph);

cd (outPath)
T1 = struct2table(allGraph);
T1(:,2:end) = [];
T2 = array2table(Embeddings);
T = [T1 T2];

writetable(T,[outName '.csv']);

end

%% subFunctions
function H = Entropy_Shannon(X)
% For discrete data
X = X(:);
data = unique(X);
numData = length(data);
Frequency = zeros(1,numData);

for index = 1:numData
    Frequency(index)= sum(X == data(index));
end

P = Frequency / sum(Frequency);
H = -sum(P .* log2(P));
end


function [Hn] = node_Hindex_centrality(G)

%--------------------------------------------------------------------------
% This function is used to calculate nodal H-index centrality.
% Numerical analyses of the susceptible-infected-removed spreading dynamics
% on disparate real networks suggest that the H-index is a good trade-off that
% in many cases can better quantify node influence than either degree or
% coreness.
%
% Input:
%            G:
%                a binary undirected graph object of MATLAB, see
%                https://www.mathworks.com/help/matlab/ref/graph.html
% Outputs:
%        
%           Hn:
%                Nodal H-index centrality of each node of G.
%
% Reference:
% Lv, Linyuan, et al. "The H-index of a network node and its relation to
% degree and coreness." Nature communications 7 (2016).
%
% Hao WANG, Hangzhou, China, 2016/02/24,
% hall.wong@outlook.com.
%--------------------------------------------------------------------------

% Record the number of nodes
numNode = size(G.Nodes,1); 

% Record the degree centrality for each node
TotalDeg = degree(G); 

% Record the first-order neighbors for each node
Nei = cell(numNode,1);
for iNode = 1:numNode
    Nei{iNode,1} = neighbors(G,iNode);
end

% Initialize the first-order h-index
Hi = zeros(1, numNode);

for iNode = 1:numNode
    % first-order neighbors for each node
    index = Nei{iNode,1};
    % sort neighbour's degree
    tmp = sort(TotalDeg(index),'descend');    
    Hi(iNode)= sum(tmp>=(1:length(tmp))');  
end

% Continue loop
Hn(1,:) = Hi;

for inter = 2:numNode
    
    for iNode = 1:numNode 
        Hitmp = Hn(inter-1,:);
        index = Nei{iNode,1};
        tmp = sort(Hitmp(index),'descend');
        Hn(inter,iNode) = sum(tmp>=(1:length(tmp))); 
    end
    
    if isequal(Hn(end,:),Hn(end-1,:)); break; end
    
end

Hn(end,:) = [];
% add degree back as H0
Hn = [TotalDeg';Hn];

end