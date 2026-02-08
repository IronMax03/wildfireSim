# wildfireSim
<div align="center">
<img width="75%" alt="example of simulation" src="doc/img/simulation_screenshots/Screenshot 2026-02-09 at 00.45.28.png" />
</div>

> [!WARNING]
>The documentation is currently a work in progress; some sections may be empty and some mistakes not corrected.

An interactive ecosystem simulator that models vegetation growth with a stochastic cellular automaton, wildfires triggered by lightning strikes, and predator–prey interactions. 

## Requirements

This project is written in [**Julia**](https://julialang.org/) programing language.

To install all required packages, run:
``` julia
julia src/Packages.jl
```

## Disclamer
ChatGPT was used only for reviewing and improving documentation clarity.
All modeling choices, equations, and code were designed and implemented independently.

## Documentation Guide

- [Full Model Description](doc/model.md)
  - [Numerical Implementation of predators-preys](doc/model.md#Wildlife-(predators-&-preys))
  - [vegetation growth CA](doc/model.md#vegetation-growth-CA)
- [Examples of Runs](doc/img/simulation_screenshots/)