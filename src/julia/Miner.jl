module Miner

using Clustering
using CSV
using DataFrames
using DelimitedFiles
using Distances
using Distributions
using EnglishText
using EzXML
using Formatting
using Graphs
using GraphIO
using LinearAlgebra
using Missings
using MultivariateStats
using NPZ
using PlotlyJS
using SimpleWeightedGraphs
using SortingAlgorithms
using Statistics
using StatsBase
using TextAnalysis
using WordCloud

"""
The path to the directory containing the text files produced by the Java library Cccdm.jar (default path is `/Miner/data/`). This directory has to be a subdirectory of the working directory of Julia (the working directory can be shown by issuing the command `pwd()`).
"""
global path_to_files = "path_to_directory_containing_the_conference_data_collected_with_Java_code"
"""
The list of conferences already downloaded (taken form DBLP on March 2022).
"""
global downloaded_conf = ["cav" "crypto" "csl" "disc" "esa" "esop" "eurocrypt" "focs" "icalp" "lics" "podc" "popl" "soda" "stacs" "stoc" "tacas"]
"""
The conferences associated with each area.
"""
global conf_area = Dict("alg" => ["esa", "soda"], "crypto" => ["crypto", "eurocrypt"], "dc" => ["disc", "podc"], "fm" => ["cav", "csl", "esop", "lics", "popl", "tacas"], "gen" => ["focs", "icalp", "stacs", "stoc"])
"""
The width of the plot images (default is 600).
"""
global plot_width = 600
"""
The height of the plot images (default is 600).
"""
global plot_height = 600
"""
The vector including the name of the buttons not to be shown in the plots (see the [PLotly.jl documentation](https://plotly.com/julia/)).
"""
global plot_buttons_to_remove = ["zoom", "pan", "select2d", "lasso2d", "zoomIn2d", "zoomOut2d", "resetScale2d"]
"""
The Boolean flag indicating whether the Plotly logo has to be shown in the plots (default is `true`).
"""
global plot_logo = true

"""
English pluralization exceptions
"""
EnglishText.Pluralize.IRREGULAR_CLS["access"] = "access"
EnglishText.Pluralize.IRREGULAR_CLS["algebra"] = "algebra"
EnglishText.Pluralize.IRREGULAR_CLS["asynchronous"] = "asynchronous"
EnglishText.Pluralize.IRREGULAR_CLS["calculus"] = "calculus"
EnglishText.Pluralize.IRREGULAR_CLS["process"] = "process"
EnglishText.Pluralize.IRREGULAR_CLS["synchronous"] = "synchronous"

include("minerutils.jl")
include("icalpminer.jl")
include("dataminer.jl")
include("genderminer.jl")
include("graphminer.jl")
include("titleminer.jl")

end
