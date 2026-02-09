begin
    using DataStructures
    using GLMakie 
    using Distributions

    include("utils.jl")
    loadData()

    grid = rand(Beta(0.1, 0.6), N, N)

    isruning = Observable(false)
end


begin # window
    # Initializing Graph variables
    treeCountLst = Float64[]
    preyPopulationLst = Float64[]
    predatorPopulationLst = Float64[]
    treeCountLstObs = Observable(treeCountLst)
    preyPopulationLstObs = Observable(preyPopulationLst)
    predatorPopulationLstObs = Observable(predatorPopulationLst)

    gridObs = Observable(grid)

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
    ax2 = Axis(glGraph[1, 1], title = "Normalized tree population per iteration")
    lines!(ax2, treeCountLstObs; color = :green)

    # wildlife graph
    ax3 = Axis(glGraph[2, 1], title = "Normalized predator and prey population per iteration")
    preysLine = lines!(ax3, preyPopulationLstObs; color = :blue)
    predatorsLine = lines!(ax3, predatorPopulationLstObs; color = :red)

    Legend(glGraph[2, 2],
    [preysLine, predatorsLine],
    ["preys", "predators"])

    display(fig)

    # buttons grid
    glButtons = GridLayout(glGraph[3, 1], tellwidth = false)
    plus50 = Button(glButtons[1, 6], label = "+ 50")
    plus25 = Button(glButtons[1, 5], label = "+ 25")
    plus1 = Button(glButtons[1, 4], label = "+ 1")
    startButtons = Button(glButtons[1, 3], label = "start")
    stopButtons = Button(glButtons[1, 2], label = "stop")
    resetButtons = Button(glButtons[1, 1], label = "reset")

    # buttons
    textGl = GridLayout(fig[2, 1], tellwidth = false)
    Label(textGl[1, 1], constantsStr)
end

begin # events
    on(plus50.clicks) do n
        global isruning
        if !isruning[]
            for i in 1:50
                updateSim()
                updateGraphs()
            end

            println("simulating a 50 iteration")
        end
    end

    on(plus25.clicks) do n
        global isruning
        if !isruning[]
            for i in 1:25
                updateSim()
                updateGraphs()
            end

            println("simulating a 25 iteration")
        end
    end

    # run 1 simulation update
    on(plus1.clicks) do n
        global isruning
        if !isruning[]
            updateSim()
            updateGraphs()

            println("simulating a 1 iteration")
        end
    end

    # start simulation loop
    on(startButtons.clicks) do n
        println("start simulation")

        @async begin
            # simulation variable and constant
            global isruning[] = true

            while isruning[]
                updateSim()
                updateGraphs()
                
                sleep(sleep_time)
            end
        end
    end

    # stop simulation loop
    on(stopButtons.clicks) do n
        global isruning[] = false
        println("stop simulation")
    end

    # reset simulation & load simulation data
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

        # reframe graphs
        autolimits!(ax)
        autolimits!(ax2)
        autolimits!(ax3)

        println("reset simulation")
    end
end