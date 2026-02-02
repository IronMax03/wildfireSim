# wildfireSim

## Project Philosophy

The wildfire in this simulation can be seen as any disruptive event that affects the vegetation. We label such events as "wildfires" for simplicity, but they could represent other phenomena such as floods, pests, or human activities that lead to sudden changes in the environment. This abstraction also comes from the time scale of the simulation, that is in years. At this scale, the intricacies of wildfires are not distinguishable from other disruptive events.

## vegetation growth model
To simulate vegetation growth, we use a cellular automaton approach. To model percolation-like properties.

## lightning strikes

## predators and prey
To simulate wildlife dynamics, we use numerical approximations of the **Lotka–Volterra equations** (also known as the **predator–prey model**). This model describes the coupled evolution of predator and prey populations and allows us to study how their dynamics respond both to mutual interactions and to external environmental factors such as vegetation availability.

### Numerical implementation

We start with the **lotka-volterra equations**:  
- $\frac{dx}{dt}=\alpha x-\beta xy$  
- $\;\frac{dy}{dt}=-\gamma y+\delta xy$  

where:
- $x$ is the prey population (e.g., rabbits)
- $y$ is the predator population (e.g., foxes)
- $t$ is time
- $\alpha, \beta, \gamma, \delta$ are parameters representing interaction rates.

Since the model evolves in discrete time, we approximate the time derivatives using the forward Euler method:  
- $\frac{dx}{dt}\approx \frac{\Delta x}{\Delta t}=\frac{x_{t+1}-x_t}{\Delta t}$   
- $\frac{dy}{dt}\approx \frac{\Delta y}{\Delta t}=\frac{y_{t+1}-y_t}{\Delta t}$  

This gives the update rules:  
- $x_{t+1}=\alpha x_t \Delta t - \beta x_ty_t\Delta t+x_t$  
- $y_{t+1}=-\gamma y_t\Delta t +\delta x_ty_t\Delta t+y_t$  

In the simulation, we absorb the time step $\Delta t$ into the parameters $\alpha$, $\beta$, $\gamma$ and $\delta$ for improved code readability, leading to:  
- $x_{t+1}=\alpha x_t - \beta x_ty_t+x_t$  
- $y_{t+1}=-\gamma y_t +\delta x_ty_t+y_t$  

> [!CAUTION]  
> In my code absorbtion of time apends after the start of the simulation loop. Such that `alpha = alpha * delta_t` and so on.

To account for vegetation availability, the prey growth rate is coupled to the vegetal biomass and prey population, leading to competition for resources. In order to model this, we modify the prey growth rate $\alpha$ as follows:
- $\alpha=\alpha_{max}\cdot\frac{B_v-x_t}{N^2}$
   
 where:
- $\alpha_{max}$ is the maximal prey population growth
- $B_v$ is the vegetal biomass
- $N$ is the size of the simulation(a $N\times N$ square). 

The final update equations are therefore:   
- $\boxed{x_{t+1}=\alpha_{max}\cdot\frac{B_v-x_t}{N^2} x_t - \beta x_ty_t+x_t}$  
- $\boxed{y_{t+1}=-\gamma y_t +\delta x_ty_t+y_t}$
