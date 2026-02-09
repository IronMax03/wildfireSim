# wildfireSim
<div align="center">
<img width="100%" alt="example of simulation" src="doc/img/simulation_screenshots/Screenshot 2026-02-09 at 00.45.28.png" />
</div>

An interactive ecosystem simulator that models vegetation growth with a stochastic cellular automaton, wildfires triggered by lightning strikes, and predator–prey interactions. 

> [!WARNING]
>The documentation is currently a work in progress; some sections may be empty and some mistakes not corrected.

## Requirements

This project is written in [**Julia**](https://julialang.org/) programing language.

To install all required packages, run:
``` julia
julia src/Packages.jl
```

## Documentation Guide

- [Full Model Description](doc/model.md)
  - [Numerical Implementation of predators-preys](doc/model.md#Wildlife-(predators-&-preys))
  - [vegetation growth CA](doc/model.md#vegetation-growth-CA)
- [Examples of Runs](doc/img/simulation_screenshots/)
