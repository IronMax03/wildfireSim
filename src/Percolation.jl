begin
    using DataStructures
    using GLMakie 
    using Distributions

    include("utils.jl")
    loadData()

    N = 200

    grid = rand(Beta(0.1, 0.6), N, N)

    isruning = Observable(false)
end


begin # window
    treeCountLst = Float64[]

    treeCountLstObs = Observable(treeCountLst)
    gridObs = Observable(grid) # displayed grid

    fig = Figure(size = (1200, 800))
    ax = Axis(fig[1, 1], aspect = DataAspect())
    heatmap!(ax, gridObs;
        colormap = :algae,
        colorrange = (0, 1.4),
        lowclip = :orange,
        interpolate = false
    )
    hidedecorations!(ax); hidespines!(ax)

    ax2 = Axis(fig[1, 2])
    lines!(ax2, treeCountLstObs; color = :green)

    display(fig)

    # buttons
    gl = GridLayout(fig[2, 1], tellwidth = false)
    plus = Button(gl[1, 3], label = "+")
    startButtons = Button(gl[1, 2], label = "start")
    stopButtons = Button(gl[1, 1], label = "stop")
end

begin # events
    on(plus.clicks) do n
        global grid,  gridObs

        grid = forestCA(grid, N)
        gridObs[] = grid

        push!(treeCountLst, treeCount)
        treeCountLstObs[] = treeCountLst
        autolimits!(ax2)

        grid = spawnThunder(grid, N)
        gridObs[] = grid
    end

    on(startButtons.clicks) do n
        global isruning, grid, gridObs, treeCount, treeCountLst, treeCountLstObs
        isruning[] = true
        println("start simulation")

        @async begin
            while isruning[]
                grid = forestCA(grid, N)
                gridObs[] = grid

                push!(treeCountLst, treeCount)
                treeCountLstObs[] = treeCountLst
                autolimits!(ax2)

                grid = spawnThunder(grid, N)
                gridObs[] = grid
                sleep(sleep_time)
            end
        end
    end

    on(stopButtons.clicks) do n
        global isruning
        isruning[] = false
        println("stop simulation")
    end
end