using Distributions
using DataStructures
import YAML

# apply cellular au
const lst = [[0,1], [1,0], [0,-1], [-1,0], [1,1], [1,-1], [-1,1], [-1,-1]]
constantsStr = Observable("")

function loadData()
    data = YAML.load_file("src/config.yaml")

    # flora
    global sleep_time   = data["flora"]["sleep_time"]
    global N            = data["flora"]["N"]
    global plant_growth = data["flora"]["plant_growth"]
    global LPU          = data["flora"]["lightnings_per_updates"]
    global LSP          = data["flora"]["lightnings_success_probability"]

    # wildLife
    global dt                 = data["wildLife"]["dt"]
    global alpha_max          = data["wildLife"]["alpha_max"] * data["wildLife"]["dt"]
    global beta               = data["wildLife"]["beta"] * data["wildLife"]["dt"]
    global gamma              = data["wildLife"]["gamma"] * data["wildLife"]["dt"]
    global delta              = data["wildLife"]["delta"] * data["wildLife"]["dt"]
    global epsilon            = data["wildLife"]["epsilon"]
    global preyPopulation     = data["wildLife"]["preyInitialPop"]
    global predatorPopulation = data["wildLife"]["predatorInitialPop"]

    global constantsStr[]       = "wildLife: 𝚫t=$(data["wildLife"]["dt"]), alpha_max=$(data["wildLife"]["alpha_max"]), β=$(data["wildLife"]["beta"]), Ɣ=$(data["wildLife"]["gamma"]), δ=$(data["wildLife"]["delta"]), ε=$epsilon, preyPopulation=$preyPopulation, predatorPopulation=$predatorPopulation\n flora: N=$N, plant_growth=$plant_growth, LPU=$LPU, LSP=$LSP"

    # variable
    global treeCount = 0.0

    println("loadData()")
    println("   settings:")
    println("       sleep_time: ", sleep_time)

    println("   parameters:")
    println("       ", constantsStr, "\n\n")
end

function forestCA(grid::Matrix{Float64}, N::Int64)::Matrix{Float64}

    global treeCount = 0
    newGrid = copy(grid)

    for i in 1:N
        for j in 1:N
            treeCount += max(0, grid[i,j])

            if grid[i,j] < 0
                newGrid[i,j] = 0
            elseif neighbourhood(grid, i, j)^2 > rand() && grid[i,j] < 1
                newGrid[i,j] = min(1, max(0, newGrid[i,j] + plant_growth - preyPopulation/(N^2)))
            end
        end
    end

    return newGrid
end

function neighbourhood(grid::Matrix{Float64}, x::Int64, y::Int64)::Float64
    count = 0
    for i in 1:8
        if x + lst[i][1] < 1 || x + lst[i][1] > N ||  y + lst[i][2] < 1 || y + lst[i][2] > N
            continue
        end
        count += grid[x + lst[i][1], y + lst[i][2]]
    end

    return count/8
end

function spawnThunder(grid::Matrix{Float64}, N::Int64)::Matrix{Float64}
    x = rand(1:N)
    y = rand(1:N)

    if grid[x, y] > 0.5
        grid[x, y] = -1

        #new
        q = Queue{Vector{Int64}}()
        enqueue!(q, [x, y])
        while length(q) != 0
            p = dequeue!(q)

            for i in 1:4
                if p[1] + lst[i][1] < 1 || p[1] + lst[i][1] > N ||  p[2] + lst[i][2] < 1 || p[2] + lst[i][2] > N
                    continue
                end
                if grid[p[1] + lst[i][1], p[2] + lst[i][2]] > 0.5
                    grid[p[1] + lst[i][1], p[2] + lst[i][2]] = -1
                    enqueue!(q, [p[1] + lst[i][1], p[2] + lst[i][2]])
                end
            end
        end
    end
    return grid
end

function updatePreys(x_t::Float64, y_t::Float64, N::Int64, VB::Float64)::Float64
    alpha = alpha_max * (VB - epsilon*x_t)/(N^2)
    #alpha = alpha_max

    return (alpha - beta * y_t + 1) * x_t
end

function updatePredator(y_t::Float64, x_t::Float64)::Float64
    return (delta * x_t - gamma + 1) * y_t
end


function updateSim()
    global treeCount, N, sleep_time, LPU, LSP

    global grid = forestCA(grid, N)
    global gridObs[] = grid

    for i in 1:LPU
        if LSP > rand()
            grid = spawnThunder(grid, N)
            gridObs[] = grid
        end
    end

    global preyPopulation = updatePreys(preyPopulation, predatorPopulation, N, treeCount)
    global predatorPopulation  = updatePredator(predatorPopulation, preyPopulation)
end


function updateGraphs()

    # graphs objects
    global ax2, ax3

    # graphs data
    global preyPopulationLst, predatorPopulationLst, treeCountLst
    global preyPopulation, predatorPopulation

    # Observables
    global preyPopulationLstObs, predatorPopulationLstObs, treeCountLstObs

    push!(preyPopulationLst, preyPopulation/(N^2))
    push!(predatorPopulationLst, predatorPopulation/(N^2))
    push!(treeCountLst, treeCount/(N^2))

    global preyPopulationLstObs[] = preyPopulationLst
    global predatorPopulationLstObs[] = predatorPopulationLst
    global treeCountLstObs[] = treeCountLst

    # resize graphs
    autolimits!(ax2)
    autolimits!(ax3)
end