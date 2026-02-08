# Model
This document provides a detailed explanation of the simulated model inner workings. All the content below is implemented in [utils.jl](../src/utils.jl).

## Model Philosophy

This model is meant to showcase the balance brought by natural destruction. Therefore wildfire in this simulation describe any disruptive event that affects the vegetation. We label such events as "wildfires" for simplicity, but they could represent other phenomena such as floods, pests, or human activities that lead to sudden changes in the environment. This abstraction also comes from the time scale of the simulation, one simulation update corresponds to a configurable time step (e.g. months or years), depending on parameter choice. At this scale, the intricacies of wildfires are not distinguishable from other disruptive events.

The wildlife is modeled globally because animals may move a lot in large time scale and the detail of the animal population distribution would not be relevant. This and the fact that seeds may be displaced over long distance by wildlife are the justification of the probabilistic nature of the vegetation growth cellular automaton (CA).

## Vegetation CA

Let $g_{ij}\in [0,1]$ represent the cell state at position $(i,j)$ and $G_{ij}\in [0,1]$ the updated cell state of the same cell.  

The vegetation layer is represented by a two-dimensional stochastic cellular automaton defined on an $N\times N$ grid. Each cell has a **continuous state** $g_{ij}\in [0,1]$ , interpreted as local vegetation density or biomass fraction. A special state $g_{ij}=-1$ denotes an actively burning cell. From the cellular automaton point of view the cell state is a probability. The reason for this spatial approach is to add percolation properties to the vegetation growth, which are important for the wildfire dynamics. 

### vegetation growth
<div align="center">
  <img src="img/moore_neighborhood/moore_neighborhood.png" width="200"><br>
  <small>Fig 1: Moore neighborhood of \( g_{ij} \).</small>
</div>

Similarly to the **Conway's Game of Life**, the vegetation growth CA uses a the **Moore neighborhood**. Moore neighborhood encompasses all adjacent cells as shown in **fig 1**. From this we define the probability that the cell updates $\mathbb{P}(g_{ij}\rightarrow G_{ij})$ to be the average of all adjacent cells as shown below.

Let the set $M_{ij}$ contain all the cells in the Moore neighborhood of the cell $(i,j)$, then
- $\mathbb{P}(g_{ij}\rightarrow G_{ij})=\frac{1}{8}\displaystyle\sum_{g\in M_{ij}} g$

If the cell update does not occur the vegetation change is $G_{ij}=g_{ij}$, in the other case it is defined by:   
- $G_{ij}= \max(0,\min(1,g_{ij}+p_g-\frac{x_t}{N^2}))$

where:
- $p_g\in\mathbb{R}^+$ is the **plant growth**, it is typically in $[0,1]$ but values greater than 1 can be used to simulate environment with high prey population.
- $x_t\in\mathbb{R}^+$ the **prey population** before being updated.
- $N\in\mathbb{N}$ is the length of the simulation ( which is a $N\times N$ square).  

<details>
<summary><b> Justification (Click to unfold) </b></summary>

In the absence of herbivore, vegetation increases according to: $G_{ij}=g_{ij}+p_g$.  
To avoid making $G_{ij}$ bigger than 1 we add a min function such that $G_{ij}=\min(1,g_{ij}+p_g)$.  

Now lets add the effect of herbivores by removing the normalized population ($\frac{x_t}{N^2}$), this design choice to remove absolute population come from the fact that in this simulation model behaviour is more important than data accuracy (as discussed in the [Model Philosophy](#model-philosophy) section). Once again we need to ensure $G_{ij}$ does not go out of bounds, this time by using a max function. then the final result is $G_{ij}= \max(0,\min(1,g_{ij}+p_g-\frac{x_t}{N^2}))$.

</details>

## Lightning Strikes
When a lightning appears in the grid, both coordinates `x` and `y` are a random variables with a uniform distribution. Each one as a probability of starting a fire noted `LSP` for **lightnings success probability**. This process is repeated multiple times per updates, those repetitions is defined by the variable `LPU` for lightnings per updates.

## Fire Propagation

In this section the term **clusters** refer to the percolation theory definition. "A cluster is a group of nearest neighbouring occupied sites." [[1]](#sources). In this case the "site" is a cell.

If a fire is ignited, The **CA** starts a clustering algorithm, it only outputs one cluster that includes all high vegetation density connected to the fire starting position. Each cell within this cluster becomes `-1` and becomes `0` at the next update.



## Wildlife (predators & prey)

To simulate wildlife dynamics, we use numerical approximations of the **Lotka–Volterra equations** (also known as the **predator–prey model**). This model describes the coupled evolution of predator and prey populations and allows us to study how their dynamics respond both to mutual interactions and to external environmental factors such as vegetation availability.

### Numerical implementation
This first implementation serve as a quick prototype. It is based on the **lotka-volterra equations**, the next implementation will be more developed.

We start with the **lotka-volterra equations**:  
- $\frac{dx}{dt}=\alpha x-\beta xy$  
- $\frac{dy}{dt}=-\gamma y+\delta xy$  

where:
- $x$ is the prey population (e.g., rabbits)
- $y$ is the predator population (e.g., foxes)
- $t$ is time
- $\alpha, \beta, \gamma, \delta$ are parameters representing interaction rates.

Since the model evolves in discrete time, we approximate the time derivatives using the forward Euler method:  
- $\frac{dx}{dt}\approx \frac{\Delta x}{\Delta t}=\frac{x_{t+1}-x_t}{\Delta t}$   
- $\frac{dy}{dt}\approx \frac{\Delta y}{\Delta t}=\frac{y_{t+1}-y_t}{\Delta t}$  

This gives the following update rules:  
- $x_{t+1}=\alpha x_t \Delta t - \beta x_ty_t\Delta t+x_t$  
- $y_{t+1}=-\gamma y_t\Delta t +\delta x_ty_t\Delta t+y_t$  

In the simulation, we absorb the time step $\Delta t$ into the parameters $\alpha$, $\beta$, $\gamma$ and $\delta$ for improved code readability, leading to:  
- $x_{t+1}=\alpha x_t - \beta x_ty_t+x_t$  
- $y_{t+1}=-\gamma y_t +\delta x_ty_t+y_t$  

> [!CAUTION]  
> In the implementation, parameters and $\Delta t$ are defined separately and multiplied during initialization. Such that `alpha = alpha * delta_t` and so on.

To account for vegetation availability, the prey growth rate is coupled to the vegetal biomass and prey population, leading to competition for resources. In order to model this, we modify the prey growth rate $\alpha$ as follows:
- $\alpha=\alpha_{max}\frac{B_v-\epsilon x_t}{N^2}$
   
 where:
- $\alpha_{max}$ is the maximal prey population growth
- $B_v$ is the vegetal biomass
- $N$ is the size of the simulation(a $N\times N$ square). 
- $\epsilon$ is a competition coefficient representing the impact of prey population on vegetation availability.

The final update equations are therefore:   
- $\boxed{x_{t+1}=\alpha_{max}\frac{B_v-\epsilon x_t}{N^2}x_t - \beta x_ty_t+x_t}$  
- $\boxed{y_{t+1}=-\gamma y_t +\delta x_ty_t+y_t}$

## Sources

1) [Christensen, K. Percolation Theory. Blackett Laboratory, Imperial College London, Oct. 9, 2002.](https://www.mit.edu/~levitov/8.334/notes/percol_notes.pdf)
2) [Theoretical Community Ecology](https://stefanoallesina.github.io/Theoretical_Community_Ecology/index.html)