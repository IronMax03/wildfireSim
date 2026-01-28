Pkg.add("Distributions")
Pkg.add("DataStructures")
using DataStructures
using Pkg
using GLMakie 
using Distributions


include("utils.jl")

N = 50

grid = rand(Beta(0.1, 0.6), N, N)

isruning = Observable(false)

begin #  window
    gridObs = Observable(grid) # displayed grid

    fig = Figure(size = (700, 700))
    ax = Axis(fig[1, 1], aspect = DataAspect())
    heatmap!(ax, gridObs;
        colormap = :algae,
        colorrange = (0, 1.4),
        lowclip = :orange,
        interpolate = false
    )
    hidedecorations!(ax); hidespines!(ax)

    display(fig)

    # events
    gl = GridLayout(fig[2, 1], tellwidth = false)
    plus = Button(gl[1, 3], label = "+")
    startButtons = Button(gl[1, 2], label = "start")
    stopButtons = Button(gl[1, 1], label = "stop")

    on(plus.clicks) do n
        global grid
        global gridObs

        grid = forestCA(grid, N)
        gridObs[] = grid

        grid = spawnThunder(grid, N)
        gridObs[] = grid
    end

    on(startButtons.clicks) do n
        global isruning
        isruning[] = true
        println("start simulation")
    end

    on(stopButtons.clicks) do n
        global isruning
        isruning[] = false
        println("stop simulation")
    end
end

# sim loop
onany(startButtons.clicks, stopButtons.clicks) do _, _
    global isruning
    global grid
    global gridObs

    @async begin
        while isruning[]
            grid = forestCA(grid, N)
            gridObs[] = grid
            sleep(0.05)

            grid = spawnThunder(grid, N)
            gridObs[] = grid
            sleep(0.2)
        end
    end
end    