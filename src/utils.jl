using Distributions
using DataStructures

# apply cellular au
const lst = [[0,1], [1,0], [0,-1], [-1,0], [1,1], [1,-1], [-1,1], [-1,-1]]
treeCount = 0

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