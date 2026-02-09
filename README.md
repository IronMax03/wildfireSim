# wildfireSim
<div align="center">
<img width="100%" alt="example of simulation" src="doc/img/simulation_screenshots/Screenshot 2026-02-09 at 00.45.28.png" />
</div>

An interactive ecosystem simulator that models vegetation growth with a stochastic cellular automaton, wildfires triggered by lightning strikes, and predator–prey interactions. 

> [!WARNING]
>The documentation is currently a work in progress; some sections may be empty and some mistakes not corrected.

## Requirements

This project is written in the [**Julia**](https://julialang.org/) programming language.

The project uses a local Julia environment to ensure reproducibility.
All required dependencies are specified in Project.toml and Manifest.toml.

To set up the environment:
``` bash
julia --project=.
```
Then, inside the Julia REPL:
``` julia
]
instantiate
```
This will automatically install all required packages with the exact versions used for development.

## Reporting Issues

This project uses a structured issue template to ensure bug reports are clear, actionable, and easy to triage.
Please use the provided Issue Report template when opening a new issue and make sure to fill in all required fields.

Providing complete and precise information helps identify, reproduce, and fix issues more efficiently.

## Documentation Guide

- [Full Model Description](doc/model.md)
  - [Numerical Implementation of predators-preys](doc/model.md#Wildlife-(predators-&-preys))
  - [vegetation growth CA](doc/model.md#vegetation-growth-CA)
- [Examples of Runs](doc/img/simulation_screenshots/)
