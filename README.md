# wildfireSim


## predators and Preys

### Numerical solution 

- We start with the **lotka-volterra equations**:  
$\frac{dx}{dt}=\alpha x-\beta xy$  
$\;\frac{dy}{dt}=-\gamma y+\delta xy$  
- Since the simulation work with discrete time we can discritize the equation, meaning $\frac{dx}{dt}\approx \frac{\Delta x}{\Delta t},\frac{dy}{dt}\approx \frac{\Delta y}{\Delta t}$. then  
$x_{t+1}=\alpha x_t \Delta t - \beta x_ty_t\Delta t+x_t$  
$y_{t+1}=-\gamma y_t\Delta t +\delta x_ty_t\Delta t+y_t$  
- For a single update ($\Delta t = 1$), the equation becomes  
$x_{t+1}=\alpha x_t - \beta x_ty_t+x_t$  
$y_{t+1}=-\gamma y_t +\delta x_ty_t+y_t$
- for integrating the vegetal biomass factor i use: $\alpha=\alpha_{max}\cdot\frac{B_v}{N^2}$ where $\alpha_{max}$ is the maximal prey population growth, $B_v$ is the vegetal biomass and $N$ is the size of the simulation(a $N\times N$ square). Then:  
$\boxed{x_{t+1}=\alpha_{max}\frac{B_v}{N^2} x_t - \beta x_ty_t+x_t}$  
$\boxed{y_{t+1}=-\gamma y_t +\delta x_ty_t+y_t}$
