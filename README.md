# wildfireSim

## mindset

The wildfire in this simulation can be seen as any disruptive event that affects the vegetation. We label such events as "wildfires" for simplicity, but they could represent other phenomena such as floods, pests, or human activities that lead to sudden changes in the environment. This abstraction also comes from the time scale of the simulation, that is in years. At this scale, the intricacies of wildfires are not distinguishable from other disruptive events.

## vegetation growth model
To simulate vegetation growth, we use a cellular automaton approach.

## lightning strikes

## predators and prey
To simulate wildlife dynamics, we use numerical approximations of the **Lotka–Volterra equations** (also known as the **predator–prey model**). This model describes the coupled evolution of predator and prey populations and allows us to study how their dynamics respond both to mutual interactions and to external environmental factors such as vegetation availability.

### Numerical implementation

We start with the **lotka-volterra equations**:  
- $\frac{dx}{dt}=\alpha x-\beta xy$  
- $\;\frac{dy}{dt}=-\gamma y+\delta xy$  

Since the simulation evolves in discrete time, we approximate the time derivatives using the forward Euler method:  
- $\frac{dx}{dt}\approx \frac{\Delta x}{\Delta t}=\frac{x_{t+1}-x_t}{\Delta t}$   
- $\frac{dy}{dt}\approx \frac{\Delta y}{\Delta t}=\frac{y_{t+1}-y_t}{\Delta t}$  

This gives the update rules:  
- $x_{t+1}=\alpha x_t \Delta t - \beta x_ty_t\Delta t+x_t$  
- $y_{t+1}=-\gamma y_t\Delta t +\delta x_ty_t\Delta t+y_t$  

For a single step update ($\Delta t = 1$ year), the equation becomes:  
- $x_{t+1}=\alpha x_t - \beta x_ty_t+x_t$  
- $y_{t+1}=-\gamma y_t +\delta x_ty_t+y_t$  

To account for vegetation availability, the prey growth rate is coupled to the vegetal biomass:  
- $\alpha=\alpha_{max}\cdot\frac{B_v}{N^2}$
   
 where:
- $\alpha_{max}$ is the maximal prey population growth
- $B_v$ is the vegetal biomass
- $N$ is the size of the simulation(a $N\times N$ square). 

The final update equations are therefore:   
- $\boxed{x_{t+1}=\alpha_{max}\frac{B_v}{N^2} x_t - \beta x_ty_t+x_t}$  
- $\boxed{y_{t+1}=-\gamma y_t +\delta x_ty_t+y_t}$
