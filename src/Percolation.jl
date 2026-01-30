begin
    using DataStructures
    using GLMakie 
    using Distributions

    include("utils.jl")
    loadData()

    N = 700

    grid = rand(Beta(0.1, 0.6), N, N)

    isruning = Observable(false)
end


begin # window
    treeCountLst = Float64[]
    preyPopulationLst = Float64[]
    predatorPopulationLst = Float64[]

    treeCountLstObs = Observable(treeCountLst)
    preyPopulationLstObs = Observable(preyPopulationLst)
    predatorPopulationLstObs = Observable(predatorPopulationLst)

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

    # graphs grid
    glGraph = GridLayout(fig[1, 2], tellwidth = false)

    # trees graph
    ax2 = Axis(glGraph[1, 1])
    lines!(ax2, treeCountLstObs; color = :green)

    # wildlife graph
    ax3 = Axis(glGraph[2, 1])
    lines!(ax3, preyPopulationLstObs; color = :blue)
    lines!(ax3, predatorPopulationLstObs; color = :red)

    display(fig)

    # buttons grid
    glButtons = GridLayout(fig[2, 1], tellwidth = false)

    # buttons
    plus = Button(glButtons[1, 4], label = "+")
    startButtons = Button(glButtons[1, 3], label = "start")
    stopButtons = Button(glButtons[1, 2], label = "stop")
    resetButtons = Button(glButtons[1, 1], label = "reset")
end

begin # events
    # run 1 simulation update
    on(plus.clicks) do n
        global grid,  gridObs, predatorPopulation, preyPopulation
        global preyPopulationLst, predatorPopulationLst, preyPopulationLstObs, predatorPopulationLstObs

        grid = forestCA(grid, N)
        gridObs[] = grid

        # update tree count graph
        push!(treeCountLst, treeCount)
        treeCountLstObs[] = treeCountLst

        # spawn thunder
        grid = spawnThunder(grid, N)
        gridObs[] = grid

        # update prey population
        preyPopulation = updatePreys(preyPopulation, predatorPopulation, N, treeCount)
        push!(preyPopulationLst, preyPopulation)
        preyPopulationLstObs[] = preyPopulationLst
        println("preyPopulation: ", preyPopulation)

        # update predator population
        predatorPopulation  = updatePredator(predatorPopulation, preyPopulation)
        push!(predatorPopulationLst, predatorPopulation)
        predatorPopulationLstObs[] = predatorPopulationLst

        # resize graphs
        autolimits!(ax2)
        autolimits!(ax3)

    end

    # start simulation loop
    on(startButtons.clicks) do n
        println("start simulation")

        @async begin
            global grid, gridObs, treeCount, treeCountLst, treeCountLstObs, preyPopulation, predatorPopulation, N
            global preyPopulationLst, predatorPopulationLst, sleep_time
            global isruning[] = true

            while isruning[]
                # run tree growth cellular automaton
                grid = forestCA(grid, N)
                gridObs[] = grid

                # update tree count graph
                push!(treeCountLst, treeCount)
                treeCountLstObs[] = treeCountLst

                # spawn thunder
                grid = spawnThunder(grid, N)
                gridObs[] = grid

                # update prey population
                preyPopulation = updatePreys(preyPopulation, predatorPopulation, N, treeCount)
                push!(preyPopulationLst, preyPopulation)
                preyPopulationLstObs[] = preyPopulationLst
                println("preyPopulation: ", preyPopulation)

                # update predator population
                predatorPopulation  = updatePredator(predatorPopulation, preyPopulation)
                push!(predatorPopulationLst, predatorPopulation)
                predatorPopulationLstObs[] = predatorPopulationLst
                println("predatorPopulation: ", predatorPopulation)

                # resize graphs
                autolimits!(ax2)
                autolimits!(ax3)
                
                sleep(sleep_time)
            end
        end
    end

    # stop simulation loop
    on(stopButtons.clicks) do n
        global isruning[] = false
        println("stop simulation")
    end

    # reset simulation
    on(resetButtons.clicks) do n
        loadData()
        global isruning[] = false

        global grid = rand(Beta(0.1, 0.6), N, N)
        global gridObs[] = grid

        global treeCount = 0 
        global treeCountLst = Float64[]
        global preyPopulationLst = Float64[]
        global predatorPopulationLst = Float64[]

        global treeCountLstObs[] = treeCountLst
        global preyPopulationLstObs[] = preyPopulationLst
        global predatorPopulationLstObs[] = predatorPopulationLst

        println("reset simulation")
    end
end