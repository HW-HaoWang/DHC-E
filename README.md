# Hyperparameter-free and Explainable Whole Graph Embedding
# [https://arxiv.org/abs/2108.02113]

Many real-world complex systems can be described as graphs. For a large-scale graph with low sparsity, a node's adjacency vector is a long and sparse representation, limiting the practical utilization of existing machine learning methods on nodal features. In practice, graph embedding (graph representation learning) attempts to learn a lower-dimensional representation vector for each node or the whole graph while maintaining the most basic information of graph. Since various machine learning methods can efficiently process lower-dimensional vectors, graph embedding has recently attracted a lot of attention. However, most node embedding or whole graph embedding methods suffer from the problem of having more sophisticated methodology, hyperparameter optimization, and low explainability. This paper proposes a `hyperparameter-free`, `extensible`, and `explainable` **whole graph embedding** method, combining the `DHC (Degree, H-index and Coreness) theorem` and `Shannon Entropy (E)`, abbreviated as **DHC-E**. The new whole graph embedding scheme can obtain a trade-off between the simplicity and the quality under some supervised classification learning tasks, using molecular, social, and brain networks. In addition, the proposed approach has a good performance in lower-dimensional graph visualization. The new methodology is overall simple, hyperparameter-free, extensible, and explainable for whole graph embedding with promising potential for exploring graph classification, prediction, and lower-dimensional graph visualization.

# how to use the MATLAB code
Download the `DHC-E` repository from github, then addpath DHC-E to your matlab path.

Run like this:
```
[path,~,~] = fileparts(which('DHC_E'));
dataPath = fullfile(path,'Binary_BrainSulc_Net');
[T] = DHC_E(dataPath, path, 'BrainEmbedding')
```