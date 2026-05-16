# HyperPrecision

HyperPrecision: a Mathematica package for the numerical evaluation of Horn-type hypergeometric functions to arbitrary precision, including their expansion in a small parameter ε.

The package automatically derives Pfaffian systems of PDEs satisfied by a given hypergeometric function using [FiniteFlow](https://github.com/peraro/finiteflow). These PDE systems are then solved using the Frobenius method at a user-specified target point. The ε-dependence of the result is reconstructed by evaluating at multiple rational values of ε and performing rational interpolation over a finite field lattice, yielding the coefficients of the Laurent expansion in ε to any desired order. More details can be found in [2605.XXXXX](https://arxiv.org/abs/2605.XXXXX).

## Dependencies

`HyperPrecision.wl` requires the following:

- [FiniteFlow](https://github.com/peraro/finiteflow) — for automatic derivation of Pfaffian systems (T. Peraro, [arXiv:1905.08019](https://arxiv.org/abs/1905.08019))
- [DESolver](https://gitlab.com/multiloop-pku/amflow/-/tree/master/diffeq_solver) — a slightly modified version of the differential equation solver shipped with AMFlow (X. Liu, Y.-Q. Ma, [arXiv:2201.11669](https://arxiv.org/abs/2201.11669)), is included in this repository
## Installation

1. Install [FiniteFlow](https://github.com/peraro/finiteflow) following the instructions in its repository.

2. Clone or download this repository: 

```
   git clone https://github.com/souvik5151/HyperPrecision.git
```

3. Place `HyperPrecision.wl` and `DESolver.m` in a directory on your Mathematica `$Path`, or in the same directory as your notebook.

4. Load the package in Mathematica:
```mathematica
   << HyperPrecision`
```

## Files

| File | Description |
|------|-------------|
| `HyperPrecision.wl` | Main package file |
| `DESolver.m` | Slightly modified version of the differential equation solver shipped with [AMFlow](https://gitlab.com/multiloop-pku/amflow) |
| `Examples.nb` | Example evaluations |

## Authors

- Sumit Banik (SLAC National Accelerator Laboratory, Stanford University) — [banik@stanford.edu](mailto:banik@stanford.edu)
- Souvik Bera (Asia Pacific Center for Theoretical Physics) — [souvik.bera@apctp.org](mailto:souvik.bera@apctp.org)
