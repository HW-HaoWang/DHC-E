[![](https://img.shields.io/badge/language-MATLAB-orange.svg)](https://www.mathworks.com/)
[![](https://img.shields.io/badge/language-Julia-yellow.svg)](https://julialang.org/)
[![](https://img.shields.io/badge/language-Python-blue.svg)](https://www.python.org/)

#### [Hyperparameter-free and Explainable Whole Graph Embedding](https://arxiv.org/abs/2108.02113) [Matlab, Julia, and Python code]

Many real-world complex systems can be described as graphs. For a large-scale graph with low sparsity, a node's adjacency vector is a long and sparse representation, limiting the practical utilization of existing machine learning methods on nodal features. In practice, graph embedding (graph representation learning) attempts to learn a lower-dimensional representation vector for each node or the whole graph while maintaining the most basic information of graph. Since various machine learning methods can efficiently process lower-dimensional vectors, graph embedding has recently attracted a lot of attention. However, most node embedding or whole graph embedding methods suffer from the problem of having more sophisticated methodology, hyperparameter optimization, and low explainability. This paper proposes a `hyperparameter-free`, `extensible`, and `explainable` **whole graph embedding** method, combining the `DHC (Degree, H-index and Coreness) theorem` and `Shannon Entropy (E)`, abbreviated as **DHC-E**. The new whole graph embedding scheme can obtain a trade-off between the simplicity and the quality under some supervised classification learning tasks, using molecular, social, and brain networks. In addition, the proposed approach has a good performance in lower-dimensional graph visualization. The new methodology is overall simple, hyperparameter-free, extensible, and explainable for whole graph embedding with promising potential for exploring graph classification, prediction, and lower-dimensional graph visualization.

```
Important notes:
The current algorithm is only applicable to binary and undirected networks.
```

**How to use the MATLAB code** 

The code is tested under `macOS Big Sur 11.5` [MacBook Pro (Retina, 13-inch, Early 2015); Processor 2.7 GHz Dual-Core Intel Core i5] and `MATLAB_R2019a--MATLAB_R2021a`.
Download the `DHC-E` repository from github, then addpath DHC-E to your matlab path.

Run like this (`Elapsed time is 4.077985 seconds in MATLAB`):
```
[path,~,~] = fileparts(which('DHC_E'));
dataPath = fullfile(path,'Binary_BrainSulc_Net');
[T] = DHC_E(dataPath, path, 'BrainEmbedding_Matlab')
```

**How to use the Julia code**

The code is tested under `macOS Big Sur 11.5` [MacBook Pro (Retina, 13-inch, Early 2015); Processor 2.7 GHz Dual-Core Intel Core i5] and `Julia Version 1.6.2`.
Download the `DHC-E` repository from github to your local path. 
Modify your local path according to your situation, if you download DHC-E to /Users/XXX/Downloads/, the file path is /Users/XXX/Downloads/DHC-E-main '(replace the XXX with your specifical name)'


`The time cost info of Julia is below`

```
BenchmarkTools.Trial: 3 samples with 1 evaluation.
 Range (min … max):  2.003 s …   2.097 s  ┊ GC (min … max): 8.38% … 7.97%
 Time  (median):     2.086 s              ┊ GC (median):    8.05%
 Time  (mean ± σ):   2.062 s ± 51.449 ms  ┊ GC (mean ± σ):  8.58% ± 0.72%

  █                                                 █     █  
  █▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁█▁▁▁▁▁█ ▁
  2 s            Histogram: frequency by time         2.1 s <

```

Run like this:

```
yourPath = "/Users/XXX/Downloads/DHC-E-main" 
include(joinpath(yourPath, "DHC_E.jl"))

dataPath = joinpath(yourPath, "Binary_BrainSulc_Net")
DHC_E(dataPath, yourPath, "BrainEmbedding_Julia")
```
