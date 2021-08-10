using CSV, DataFrames, LinearAlgebra, LightGraphs, Printf

function DHC_E(dataPath, outPath, outName)
    #--------------------------------------------------------------------------
    # This Julia function is used to calculate Whole Graph Embedding
    #
    #
    # Inputs:
    #        dataPath:
    #                 The directory that contains a serial of graphs. Note that
    #                 all graphs must be binary and undirected graphs.
    #
    #                 File formats can be [.txt or .csv]. Either in the
    #                 form of an adjacency matrix or a two-column list,
    #                 including start and end nodes.
    #
    # e.g., adjacency matrix, 4-node graph
    #-------------------------------
    #   : 1 2 3 4
    # 1 : 0 1 1 0
    # 2 : 1 0 0 1
    # 3 : 1 0 0 1
    # 4 : 0 1 1 0
    #
    # two-column list, 4-node graph
    #     1  2
    #     1  3
    #     2  4
    #     3  4   
    #-------------------------------
    #
    #     outPath: The directory where the results are stored.
    #     outName: The name of the results' .csv file is stored.
    #
    # Output:
    #          T:
    #              The whole graph embedding information for each graph.
    #
    # Example:
    #          DHC_E('~/Downloads/Project1', '~/Downloads', 'Project1') 
    #
    #
    # Reference:
    # Wang, H.#, Deng, Y.#, Lü, L., & Chen, G. (2021). 
    # Hyperparameter-free and Explainable Whole Graph Embedding. arXiv preprint arXiv:2108.02113
    # [#] co-first author
    #
    # Hao Wang, UESTC, Chengdu, March 3, 2021, h.wang.psyc(at)gmail.com
    #--------------------------------------------------------------------------

    cd(dataPath)
    fileExt = [".csv", ".txt"]
    allGraph = []
    for iFile = 1:length(fileExt)
        allGraph = [allGraph; filter(x -> endswith(x, fileExt[iFile]), readdir(pwd()))]
    end

    numGraphs = size(allGraph, 1)
    maxDim = zeros(numGraphs, 1)
    EnGraph = Vector{Matrix{Float64}}()

    for ig = 1:numGraphs
        g = CSV.File(allGraph[ig], header = 0) |> Tables.matrix
        if issymmetric(g) == 1
            #inds = findall(x->x>0, g)
            #source = getindex.(inds, 1)
            #destination = getindex.(inds, 2)
            G = Graph(g)
        elseif size(g, 2) == 2
            source = g[:, 1]
            destination = g[:, 2]
            nEdge = size(destination, 1)
            G = Graph(maximum(g)) # graph with n vertices
            for iver = 1:nEdge
                add_edge!(G, source[iver], destination[iver])
            end
        else
            error("The inputed file format is nor supported")
        end


        Hn = node_Hindex_centrality(G)
        maxDim[ig] = size(Hn, 1)
        tmpEn = zeros(1, size(Hn, 1))
        for ih = 1:size(Hn, 1)
            tmpEn[1, ih] = Entropy_Shannon(Hn[ih, :])
        end

        EnGraph = push!(EnGraph, tmpEn)
        @sprintf "Perform the DHC-E for %s is done" allGraph[ig]
    end

    #
    maxDim = Int64(maximum(maxDim))
    Embeddings = zeros(numGraphs, maxDim)
    # Aligning the embedding dimension with the entropy of coreness
    for ig = 1:numGraphs
        tmpMat = EnGraph[ig]
        if length(tmpMat) == maxDim
            Embeddings[ig, :] = tmpMat
        elseif length(tmpMat) < maxDim
            Embeddings[ig, 1:length(tmpMat)] = tmpMat
            Embeddings[ig, length(tmpMat):maxDim] .= tmpMat[end]
        else
            error(
                "The dimensionality of DHC-E exceeds the maximum dimensionality of embedding",
            )
        end
    end


    df1 = DataFrame(name = allGraph)
    df2 = DataFrame(Embeddings, :auto)
    df = [df1 df2]
    return df
    cd(outPath)
    CSV.write(outName * ".csv", df)
end


# subfunctions
function node_Hindex_centrality(G)

    #--------------------------------------------------------------------------
    # This function is used to calculate nodal H-index centrality.
    # Numerical analyses of the susceptible-infected-removed spreading dynamics
    # on disparate real networks suggest that the H-index is a good trade-off that
    # in many cases can better quantify node influence than either degree or
    # coreness.
    #
    # Input:
    #            G:
    #                a binary undirected AbstractGraph supported by LightGraphs.jl
    # Outputs:
    #        
    #           Hn:
    #                Nodal H-index centrality of G.
    #
    # Reference:
    # Lv, Linyuan, et al. "The H-index of a network node and its relation to
    # degree and coreness." Nature communications 7 (2016).
    #
    # Hao WANG, Hangzhou, China, 2016/02/24,
    #--------------------------------------------------------------------------

    # Record the number of nodes
    numNode = size(G, 1)

    # Record the degree centrality for each node
    TotalDeg = degree(G)

    # Record the first-order neighbors for each node
    Nei = G.fadjlist

    # Initialize the first-order h-index
    Hi = zeros(1, numNode)

    for iNode = 1:numNode
        # first-order neighbors for each node
        index = Nei[iNode, :]
        # sort neighbour's degree
        iDegree = TotalDeg[index[1]]
        iDegree = iDegree[:, :]
        tmp = sort(iDegree, dims = 1, rev = true)
        # >=0
        Hi[iNode] = length(findall(x -> x >= 0, tmp - collect(1:length(tmp))))
    end

    # Continue loop
    Hn = zeros(1, numNode)
    Hn[1, :] = Hi

    for inter = 2:numNode

        for iNode = 1:numNode
            Hitmp = Hn[inter-1, :]
            index = Nei[iNode, :]
            iDegree = Hitmp[index[1]]
            iDegree = iDegree[:, :]
            tmp = sort(iDegree, dims = 1, rev = true)
            Hi[iNode] = length(findall(x -> x >= 0, tmp - collect(1:length(tmp))))
        end

        Hn = [Hn; Hi]
        if isequal(Hn[end, :], Hn[end-1, :])
            break
        end

    end

    Hn = Hn[1:end-1, :]
    # add degree back as H0
    Hn = [TotalDeg'; Hn]

end


function Entropy_Shannon(X)
    # For discrete data
    data = unique(X)
    numData = length(data)
    Frequency = zeros(1, numData)

    for index = 1:numData
        Frequency[index] = length(findall(x -> x == data[index], X))
    end

    P = Frequency / sum(Frequency)
    H = -sum(P .* log2.(P))
end