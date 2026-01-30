using Distributions
using DataStructures
import YAML

# apply cellular au
const lst = [[0,1], [1,0], [0,-1], [-1,0], [1,1], [1,-1], [-1,1], [-1,-1]]
treeCount = 0.0

preyPopulation = 50
predatorPopulation = 20

alpha_max = 1
beta = 1
gamma = 1
delta = 1

sleep_time = 1

function loadData()
    data = YAML.load_file("src/config.yaml")

    # flora
    global sleep_time = data["flora"]["sleep_time"]

    # wildLife
    global alpha_max          = data["wildLife"]["alpha_max"]
    global beta               = data["wildLife"]["beta"]
    global gamma              = data["wildLife"]["gamma"]
    global delta              = data["wildLife"]["delta"]
    global preyPopulation     = data["wildLife"]["preyInitialPop"]
    global predatorPopulation = data["wildLife"]["predatorInitialPop"]

    println("flora:")
    println("   sleep_time: ", sleep_time)

    println("wildlife:")
    println("   alpha_max: ", alpha_max, ", beta: ", beta, ", gamma: ", gamma, ", delta: ", delta, ", preyPopulation: ", preyPopulation, ", predatorPopulation: ", predatorPopulation, "\n\n")
end

function forestCA(grid::Matrix{Float64}, N::Int64)

    global treeCount
    treeCount = 0
    newGrid = copy(grid)

    for i in 1:N
        for j in 1:N
            treeCount += grid[i,j]

            if grid[i,j] < 0
                newGrid[i,j] = 0
            elseif  neighbourhood(grid, i, j)^2 > rand() && grid[i,j] < 1
                newGrid[i,j] += 0.1
            end
        end
    end

    return newGrid
end

function neighbourhood(grid::Matrix{Float64}, x::Int64, y::Int64)
    count = 0
    for i in 1:8
        if x + lst[i][1] < 1 || x + lst[i][1] > N ||  y + lst[i][2] < 1 || y + lst[i][2] > N
            continue
        end
        count += grid[x + lst[i][1], y + lst[i][2]]
    end

    return count/8
end

function spawnThunder(grid::Matrix{Float64}, N::Int64)
    x = rand(2:(N-1))
    y = rand(2:(N-1))

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

function updatePreys(x_t::Float64, y_t::Float64, N::Int64, VB::Float64)
    alpha = alpha_max * (VB/(N^2))

    return (alpha - beta * y_t + 1) * x_t
end

function updatePredator(y_t::Float64, x_t::Float64)
    return (delta * x_t - gamma + 1) * y_t
end